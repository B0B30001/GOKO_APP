import 'dart:async';
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';

/// Manages connection to a specific online game
/// Based on Sente Go's GameConnection architecture
class GameConnection {
  final String gameId;
  final WebSocketService _socketService;
  final bool includeChat;

  // Event streams for this specific game
  final StreamController<GameData> _gameDataController =
      StreamController<GameData>.broadcast();
  final StreamController<MoveData> _moveController =
      StreamController<MoveData>.broadcast();
  final StreamController<ClockData> _clockController =
      StreamController<ClockData>.broadcast();
  final StreamController<String> _phaseController =
      StreamController<String>.broadcast();
  final StreamController<ChatMessage> _chatController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  // Stone removal (scoring) event streams
  final StreamController<Set<int>> _removedStonesController =
      StreamController<Set<int>>.broadcast();
  final StreamController<bool> _removedStonesAcceptedController =
      StreamController<bool>.broadcast();
  // Undo request events
  final StreamController<int> _undoRequestController =
      StreamController<int>.broadcast();

  Stream<GameData> get gameData => _gameDataController.stream;
  Stream<MoveData> get moves => _moveController.stream;
  Stream<ClockData> get clock => _clockController.stream;
  Stream<String> get phase => _phaseController.stream;
  Stream<ChatMessage> get chat => _chatController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<Set<int>> get removedStones => _removedStonesController.stream;
  Stream<bool> get removedStonesAccepted =>
      _removedStonesAcceptedController.stream;
  Stream<int> get undoRequests => _undoRequestController.stream;

  int _refCount = 0;
  bool _isConnected = false;

  GameConnection({
    required this.gameId,
    required WebSocketService socketService,
    this.includeChat = true,
  }) : _socketService = socketService {
    _setupListeners();
    // Monitor underlying socket connection so we can reattach after reconnects
    _socketService.connectionState.listen((connected) {
      if (!connected) {
        // Mark as disconnected so a later reconnect will trigger a fresh game/connect
        if (_isConnected) {
          debugPrint('🔌 [Game $gameId] Detected underlying socket disconnect');
          _isConnected = false;
        }
      } else {
        // On reconnect: if caller still holds references (refCount > 0), re-send connect
        if (_refCount > 0 && !_isConnected) {
          debugPrint('🔁 [Game $gameId] Socket reconnected – rejoining game');
          // Re-send game/connect to obtain fresh authoritative state
          _socketService.send('game/connect', {
            'game_id': gameId,
            'chat': includeChat,
          });
          if (includeChat) {
            _socketService.send('chat/connect', {'channel': 'game-$gameId'});
          }
          _isConnected = true;
        }
      }
    });
  }

  void _setupListeners() {
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ GAME CONNECTION SETUP                                      ║',
    );
    debugPrint(
      '╠════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ Game ID: $gameId');
    debugPrint('║ Include Chat: $includeChat');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    // Listen to game-specific events
    _socketService.on<Map<String, dynamic>>('game/$gameId/gamedata').listen((
      data,
    ) {
      debugPrint('🎮 [Game $gameId] Received gamedata: $data');
      _gameDataController.add(GameData.fromJson(data));
    });

    _socketService.on<Map<String, dynamic>>('game/$gameId/move').listen((data) {
      debugPrint('🎮 [Game $gameId] Received move: $data');
      _moveController.add(MoveData.fromJson(data));
    });

    _socketService.on<Map<String, dynamic>>('game/$gameId/clock').listen((
      data,
    ) {
      debugPrint('🎮 [Game $gameId] Received clock: $data');
      _clockController.add(ClockData.fromJson(data));
    });

    _socketService.on<String>('game/$gameId/phase').listen((phase) {
      debugPrint('🎮 [Game $gameId] Phase changed: $phase');
      _phaseController.add(phase);
    });

    if (includeChat) {
      _socketService.on<Map<String, dynamic>>('game/$gameId/chat').listen((
        data,
      ) {
        debugPrint('💬 [Game $gameId] Chat message: $data');
        _chatController.add(ChatMessage.fromJson(data));
      });
    }

    // Game specific error events (e.g., illegal move, busy, timeout)
    _socketService.on<String>('game/$gameId/error').listen((error) {
      debugPrint('🛑 [Game $gameId] Error event: $error');
      _errorController.add(error);
    });

    // Stone removal updates (some servers send these separate from gamedata)
    _socketService.on<dynamic>('game/$gameId/removed_stones').listen((
      dynamic data,
    ) {
      debugPrint('🪦 [Game $gameId] removed_stones event: $data');
      // Normalize to Set<int> keys r*width + c using best-effort parsing
      final set = <int>{};
      if (data is List) {
        if (data.isNotEmpty && data.first is List) {
          for (final item in data) {
            if (item is List && item.length >= 2) {
              final c = item[0] is int
                  ? item[0] as int
                  : int.tryParse(item[0].toString()) ?? -1;
              final r = item[1] is int
                  ? item[1] as int
                  : int.tryParse(item[1].toString()) ?? -1;
              if (r >= 0 && c >= 0) {
                // width unknown here; send as tuple encoded r*1000 + c sentinel-free not possible
                // We'll emit a negative width marker by packing pair in a map-less int not ideal.
                // Instead, just emit empty and rely on gamedata where width/height are known.
              }
            }
          }
        }
      }
      // Prefer gamedata parsing which includes dimensions; still notify listeners to refresh
      _removedStonesController.add(set);
    });

    _socketService.on<dynamic>('game/$gameId/removed_stones_accepted').listen((
      dynamic data,
    ) {
      debugPrint('✅ [Game $gameId] removed_stones accepted: $data');
      _removedStonesAcceptedController.add(true);
    });

    // Undo request events (subscribe to multiple possible event names)
    void _handleUndoEvent(dynamic data) {
      int moveNumber = 0;
      if (data is Map<String, dynamic>) {
        final mv = data['move_number'];
        if (mv is int) moveNumber = mv;
        if (moveNumber == 0 && data['move'] is int)
          moveNumber = data['move'] as int;
      } else if (data is int) {
        moveNumber = data;
      }
      debugPrint('↩️ [Game $gameId] Undo requested for move #$moveNumber');
      _undoRequestController.add(moveNumber);
    }

    _socketService
        .on<dynamic>('game/$gameId/undo/request')
        .listen(_handleUndoEvent);
    _socketService
        .on<dynamic>('game/$gameId/undo/requested')
        .listen(_handleUndoEvent);
    _socketService
        .on<dynamic>('game/$gameId/undo_requested')
        .listen(_handleUndoEvent);
  }

  /// Connect to the game (OGS protocol)
  void connect() {
    if (_refCount == 0 && !_isConnected) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ CONNECTING TO GAME (OGS Protocol)                          ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Game ID: $gameId');
      debugPrint('║ Chat: $includeChat');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );

      // OGS protocol: socket.send("game/connect", {game_id: gameId})
      _socketService.send('game/connect', {
        'game_id': gameId,
        'chat': includeChat,
      });

      if (includeChat) {
        _socketService.send('chat/connect', {'channel': 'game-$gameId'});
      }

      _isConnected = true;
    }
    _refCount++;
    debugPrint('📊 [Game $gameId] Ref count: $_refCount');
  }

  /// Disconnect from the game
  void disconnect() {
    _refCount--;
    if (_refCount <= 0 && _isConnected) {
      debugPrint('[GameConnection] Disconnecting from game: $gameId');

      _socketService.send('game/disconnect', {'game_id': gameId});

      if (includeChat) {
        _socketService.send('chat/disconnect', {'channel': 'game-$gameId'});
      }

      _isConnected = false;
      _refCount = 0;
    }
  }

  /// Submit a move (OGS protocol)
  void submitMove(int row, int col) {
    final move = _encodeMove(row, col);
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ SUBMITTING MOVE (OGS Protocol)                             ║',
    );
    debugPrint(
      '╠════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ Game ID: $gameId');
    debugPrint('║ Position: ($row, $col)');
    debugPrint('║ Encoded: $move');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    _socketService.send('game/move', {'game_id': gameId, 'move': move});
  }

  /// Resign the game (OGS protocol)
  void resign() {
    debugPrint('[GameConnection] Resigning game: $gameId');
    _socketService.send('game/resign', {'game_id': gameId});
  }

  /// Pass turn (OGS protocol)
  void pass() {
    debugPrint('[GameConnection] Passing turn');
    _socketService.send('game/move', {
      'game_id': gameId,
      'move': '..', // Pass move in SGF format
    });
  }

  /// Suggest removed stones during stone removal phase (OGS protocol)
  /// coords: list of [col, row] pairs
  void setRemovedStones(List<List<int>> coords) {
    debugPrint('[GameConnection] Set removed stones: $coords');
    _socketService.send('game/removed_stones/set', {
      'game_id': gameId,
      'removed_stones': coords,
    });
  }

  /// Accept the current removed stones proposal (OGS protocol)
  void acceptRemovedStones() {
    debugPrint('[GameConnection] Accept removed stones');
    _socketService.send('game/removed_stones/accept', {'game_id': gameId});
  }

  /// Reject the current removed stones proposal (OGS protocol)
  void rejectRemovedStones() {
    debugPrint('[GameConnection] Reject removed stones');
    _socketService.send('game/removed_stones/reject', {'game_id': gameId});
  }

  /// Send chat message (OGS protocol)
  void sendChatMessage(String message, {int? moveNumber}) {
    if (!includeChat) return;

    _socketService.send('game/chat', {
      'game_id': gameId,
      'body': message,
      'move_number': moveNumber,
      'type': 'main',
    });
  }

  /// Request undo (OGS protocol)
  void requestUndo(int moveNumber) {
    _socketService.send('game/undo/request', {
      'game_id': gameId,
      'move_number': moveNumber,
    });
  }

  /// Accept undo (OGS protocol)
  void acceptUndo(int moveNumber) {
    _socketService.send('game/undo/accept', {
      'game_id': gameId,
      'move_number': moveNumber,
    });
  }

  /// Decline/Reject undo (OGS protocol)
  void declineUndo(int moveNumber) {
    // Some servers use 'decline' or 'reject'; send both for compatibility
    _socketService.send('game/undo/decline', {
      'game_id': gameId,
      'move_number': moveNumber,
    });
    _socketService.send('game/undo/reject', {
      'game_id': gameId,
      'move_number': moveNumber,
    });
  }

  String _encodeMove(int row, int col) {
    // Convert to SGF style coordinates (column + row)
    // OGS uses straight alphabet sequence without skipping 'i'.
    // For boards up to 19x19 we therefore use 'abcdefghijklmnopqrs'.
    const letters = 'abcdefghijklmnopqrs';

    if (row < 0 || col < 0) return '..'; // safeguard / pass fallback
    if (col >= letters.length || row >= letters.length) {
      debugPrint('🚫 [Encoding] Coordinate out of range row=$row col=$col');
      return '..';
    }

    debugPrint(
      '🔢 [Encoding] row=$row, col=$col -> ${letters[col]}${letters[row]}',
    );

    return letters[col] + letters[row];
  }

  void dispose() {
    disconnect();
    _gameDataController.close();
    _moveController.close();
    _clockController.close();
    _phaseController.close();
    _chatController.close();
    _errorController.close();
    _removedStonesController.close();
    _removedStonesAcceptedController.close();
    _undoRequestController.close();
  }
}

// Data models
class GameData {
  final String gameId;
  final int width;
  final int height;
  final List<List<int>> board;
  final String phase;
  final int currentPlayer; // 1 = black, 2 = white
  final String blackPlayerName;
  final String whitePlayerName;
  final int? blackPlayerId;
  final int? whitePlayerId;
  final int moveNumber;
  // Optional result/score fields (present when finished or in stone removal)
  final int? winnerColor; // 1=black, 2=white
  final double? blackScore;
  final double? whiteScore;
  final String? outcome;
  // Optional stone removal and territory data during scoring phases
  final Set<int>? removedStones; // keys: r*width + c
  final List<int>?
  ownership; // length width*height, 0=neutral, 1=black, 2=white

  GameData({
    required this.gameId,
    required this.width,
    required this.height,
    required this.board,
    required this.phase,
    required this.currentPlayer,
    required this.blackPlayerName,
    required this.whitePlayerName,
    this.blackPlayerId,
    this.whitePlayerId,
    required this.moveNumber,
    this.winnerColor,
    this.blackScore,
    this.whiteScore,
    this.outcome,
    this.removedStones,
    this.ownership,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [GameData] Parsing JSON: ${json.keys.toList()}');

    final width = json['width'] as int? ?? 19;
    final height = json['height'] as int? ?? 19;

    debugPrint('📦 [GameData] Board dimensions: ${width}x${height}');

    // Parse the board data
    List<List<int>> board;
    bool initializedFromBoardField = false;
    if (json['board'] != null && json['board'] is List) {
      // Board comes as a flat array or 2D array from OGS
      final boardData = json['board'];
      debugPrint('📦 [GameData] Board data type: ${boardData.runtimeType}');
      debugPrint('📦 [GameData] Board data length: ${boardData.length}');

      if (boardData is List && boardData.isNotEmpty) {
        debugPrint(
          '📦 [GameData] First element type: ${boardData[0].runtimeType}',
        );

        // Check if it's already a 2D array
        if (boardData[0] is List) {
          debugPrint('📦 [GameData] Board is 2D array');
          board = boardData
              .map(
                (row) => (row as List).map((cell) {
                  // OGS uses: 0=empty, 1=black, 2=white
                  return cell as int;
                }).toList(),
              )
              .toList();
          initializedFromBoardField = true;
        } else {
          // Convert flat array to 2D array
          debugPrint('📦 [GameData] Board is flat array, converting to 2D');

          // Check first few values to understand encoding
          if (boardData.length > 0) {
            debugPrint(
              '📦 [GameData] Sample values: ${boardData.take(10).toList()}',
            );
          }

          board = List.generate(
            height,
            (i) => List.generate(width, (j) {
              final index = i * width + j;
              if (index < boardData.length) {
                final value = boardData[index];
                // OGS uses: 0=empty, 1=black, 2=white
                return value as int;
              }
              return 0;
            }),
          );
          initializedFromBoardField = true;
        }

        // Log board stats
        int blackCount = 0, whiteCount = 0, emptyCount = 0;
        for (var row in board) {
          for (var cell in row) {
            if (cell == 1)
              blackCount++;
            else if (cell == 2)
              whiteCount++;
            else
              emptyCount++;
          }
        }
        debugPrint(
          '📦 [GameData] Board stats - Black: $blackCount, White: $whiteCount, Empty: $emptyCount',
        );
      } else {
        // Empty board
        debugPrint('📦 [GameData] Board data is empty, creating empty board');
        board = List.generate(height, (i) => List.generate(width, (j) => 0));
      }
    } else {
      // Initialize empty board if no board data
      debugPrint('📦 [GameData] No board field in JSON, creating empty board');
      board = List.generate(height, (i) => List.generate(width, (j) => 0));
    }

    debugPrint(
      '✅ [GameData] Board created: ${board.length}x${board.isNotEmpty ? board[0].length : 0}',
    );

    // Apply moves from the moves array if present and board wasn't provided
    if (!initializedFromBoardField &&
        json['moves'] != null &&
        json['moves'] is List) {
      final moves = json['moves'] as List;
      debugPrint(
        '📦 [GameData] Reconstructing board from ${moves.length} moves',
      );

      // Helper functions for capture-aware reconstruction
      bool inBounds(int r, int c) =>
          r >= 0 && r < height && c >= 0 && c < width;
      int opp(int c) => c == 1 ? 2 : 1;

      // DFS to collect a group and its liberties
      Set<int> getGroup(int sr, int sc) {
        final color = board[sr][sc];
        final stack = <List<int>>[
          [sr, sc],
        ];
        final seen = <int>{};
        while (stack.isNotEmpty) {
          final cur = stack.removeLast();
          final r = cur[0], c = cur[1];
          final key = r * width + c;
          if (seen.contains(key)) continue;
          seen.add(key);
          const dr = [1, -1, 0, 0];
          const dc = [0, 0, 1, -1];
          for (int k = 0; k < 4; k++) {
            final nr = r + dr[k], nc = c + dc[k];
            if (!inBounds(nr, nc)) continue;
            if (board[nr][nc] == color) {
              stack.add([nr, nc]);
            }
          }
        }
        return seen;
      }

      bool hasLiberty(Set<int> group) {
        for (final key in group) {
          final r = key ~/ width;
          final c = key % width;
          const dr = [1, -1, 0, 0];
          const dc = [0, 0, 1, -1];
          for (int k = 0; k < 4; k++) {
            final nr = r + dr[k], nc = c + dc[k];
            if (!inBounds(nr, nc)) continue;
            if (board[nr][nc] == 0) return true;
          }
        }
        return false;
      }

      void removeGroup(Set<int> group) {
        for (final key in group) {
          final r = key ~/ width;
          final c = key % width;
          board[r][c] = 0;
        }
      }

      for (int i = 0; i < moves.length; i++) {
        final move = moves[i];
        int row = -1, col = -1;

        if (move is String) {
          // SGF format (OGS: sequential letters incl. 'i')
          if (move == '..' || move.length < 2) {
            row = col = -1; // pass
          } else {
            const letters = 'abcdefghijklmnopqrs';
            col = letters.indexOf(move[0]);
            row = letters.indexOf(move[1]);
          }
        } else if (move is List && move.length >= 2) {
          // Integer array format [col, row, timing]
          col = move[0] as int;
          row = move[1] as int;
          if (row == -1 || col == -1) {
            // pass
            row = col = -1;
          }
        }

        // Determine color from move number (odd=black:1, even=white:2)
        final color = ((i + 1) % 2 == 1) ? 1 : 2;

        // Apply move to board with captures
        if (row >= 0 && row < height && col >= 0 && col < width) {
          // Place stone
          board[row][col] = color;

          // Check neighboring opponent groups for capture
          const dr = [1, -1, 0, 0];
          const dc = [0, 0, 1, -1];
          final capturedGroups = <Set<int>>[];
          for (int k = 0; k < 4; k++) {
            final nr = row + dr[k], nc = col + dc[k];
            if (!inBounds(nr, nc)) continue;
            if (board[nr][nc] == opp(color)) {
              final grp = getGroup(nr, nc);
              if (!hasLiberty(grp)) {
                capturedGroups.add(grp);
              }
            }
          }
          for (final grp in capturedGroups) {
            removeGroup(grp);
          }

          // Check for suicide (if no opponents captured and no liberties)
          final ownGroup = getGroup(row, col);
          if (!hasLiberty(ownGroup)) {
            // Suicide (rare on OGS default rules), remove own stones
            removeGroup(ownGroup);
          }

          debugPrint('   Move ${i + 1}: ($row, $col) = $color');
        } else {
          debugPrint('   Move ${i + 1}: pass');
        }
      }
    }

    // Parse player information
    final players = json['players'] as Map<String, dynamic>?;
    final black = players?['black'] as Map<String, dynamic>?;
    final white = players?['white'] as Map<String, dynamic>?;

    final blackPlayerName = black?['username'] as String? ?? 'Black';
    final whitePlayerName = white?['username'] as String? ?? 'White';
    final blackPlayerId = black?['id'] as int?;
    final whitePlayerId = white?['id'] as int?;

    // Result/score parsing (best-effort)
    int? winnerColor;
    final winner = json['winner'];
    if (winner is String) {
      if (winner.toLowerCase().startsWith('b')) winnerColor = 1;
      if (winner.toLowerCase().startsWith('w')) winnerColor = 2;
    } else if (winner is int) {
      // winner as player id
      if (blackPlayerId != null && winner == blackPlayerId) winnerColor = 1;
      if (whitePlayerId != null && winner == whitePlayerId) winnerColor = 2;
    }

    double? blackScore;
    double? whiteScore;
    final score = json['score'];
    if (score is Map) {
      final sBlack = score['black'];
      final sWhite = score['white'];
      if (sBlack is Map && sBlack['total'] is num) {
        blackScore = (sBlack['total'] as num).toDouble();
      }
      if (sWhite is Map && sWhite['total'] is num) {
        whiteScore = (sWhite['total'] as num).toDouble();
      }
    }

    final outcome = json['outcome'] as String?;

    // Parse removed stones and ownership (best-effort; formats may vary)
    Set<int>? removedSet;
    if (json.containsKey('removed_stones')) {
      final rs = json['removed_stones'];
      if (rs is List) {
        // Case 1: list of pairs [[col,row], ...]
        if (rs.isNotEmpty &&
            rs.first is List &&
            (rs.first as List).length >= 2) {
          removedSet = <int>{};
          for (final item in rs) {
            if (item is List && item.length >= 2) {
              final c = item[0] is int
                  ? item[0] as int
                  : int.tryParse(item[0].toString()) ?? -1;
              final r = item[1] is int
                  ? item[1] as int
                  : int.tryParse(item[1].toString()) ?? -1;
              if (r >= 0 && r < height && c >= 0 && c < width) {
                removedSet.add(r * width + c);
              }
            }
          }
        } else {
          // Case 2: flat or 2D mask of 0/1
          if (rs.isNotEmpty && rs.first is List) {
            // 2D mask height x width
            final mask2d = rs;
            removedSet = <int>{};
            for (int r = 0; r < mask2d.length && r < height; r++) {
              final rowList = mask2d[r];
              if (rowList is List) {
                for (int c = 0; c < rowList.length && c < width; c++) {
                  final v = rowList[c];
                  final isRemoved = v is num
                      ? v != 0
                      : (v?.toString() == 'true');
                  if (isRemoved) removedSet.add(r * width + c);
                }
              }
            }
          } else {
            // Flat mask length width*height
            final flat = rs.cast<dynamic>();
            removedSet = <int>{};
            for (
              int idx = 0;
              idx < flat.length && idx < width * height;
              idx++
            ) {
              final v = flat[idx];
              final isRemoved = v is num ? v != 0 : (v?.toString() == 'true');
              if (isRemoved) removedSet.add(idx);
            }
          }
        }
      }
    }

    List<int>? ownership;
    if (json.containsKey('ownership')) {
      final own = json['ownership'];
      if (own is List) {
        // Could be flat or 2D. Normalize to flat length width*height.
        if (own.isNotEmpty && own.first is List) {
          final mask2d = own;
          final temp = List<int>.filled(width * height, 0);
          for (int r = 0; r < mask2d.length && r < height; r++) {
            final rowList = mask2d[r];
            if (rowList is List) {
              for (int c = 0; c < rowList.length && c < width; c++) {
                final v = rowList[c];
                int val;
                if (v is num) {
                  val = v.toInt();
                } else if (v is String) {
                  // common encodings: 'B'/'W' or '1'/'2'
                  if (v.toUpperCase().startsWith('B')) {
                    val = 1;
                  } else if (v.toUpperCase().startsWith('W')) {
                    val = 2;
                  } else {
                    val = int.tryParse(v) ?? 0;
                  }
                } else {
                  val = 0;
                }
                temp[r * width + c] = val;
              }
            }
          }
          ownership = temp;
        } else {
          // Flat list
          final flat = List<int>.filled(width * height, 0);
          for (int idx = 0; idx < own.length && idx < width * height; idx++) {
            final v = own[idx];
            flat[idx] = v is num
                ? v.toInt()
                : (int.tryParse(v.toString()) ?? 0);
          }
          ownership = flat;
        }
      }
    }

    final currentPlayer = json['current_player'] as int? ?? 1;
    final moveNumber = json['move_number'] as int? ?? 0;

    debugPrint(
      '📦 [GameData] Players: $blackPlayerName (ID: $blackPlayerId) vs $whitePlayerName (ID: $whitePlayerId)',
    );
    if (winnerColor != null ||
        blackScore != null ||
        whiteScore != null ||
        outcome != null) {
      debugPrint(
        '📦 [GameData] Result: winnerColor=$winnerColor, blackScore=$blackScore, whiteScore=$whiteScore, outcome=$outcome',
      );
    }
    debugPrint('📦 [GameData] Current Player: $currentPlayer');
    debugPrint('📦 [GameData] Move Number: $moveNumber');

    return GameData(
      gameId: json['game_id'].toString(),
      width: width,
      height: height,
      board: board,
      phase: json['phase'] as String? ?? 'play',
      currentPlayer: currentPlayer,
      blackPlayerName: blackPlayerName,
      whitePlayerName: whitePlayerName,
      blackPlayerId: blackPlayerId,
      whitePlayerId: whitePlayerId,
      moveNumber: moveNumber,
      winnerColor: winnerColor,
      blackScore: blackScore,
      whiteScore: whiteScore,
      outcome: outcome,
      removedStones: removedSet,
      ownership: ownership,
    );
  }
}

class MoveData {
  final String gameId;
  final int moveNumber;
  final int row;
  final int col;
  final int color;

  MoveData({
    required this.gameId,
    required this.moveNumber,
    required this.row,
    required this.col,
    required this.color,
  });

  factory MoveData.fromJson(Map<String, dynamic> json) {
    final move = json['move'] as List;

    debugPrint('🔍 [MoveData] Parsing move JSON:');
    debugPrint('   Full JSON: $json');
    debugPrint('   Raw move array: $move');
    debugPrint('   Move length: ${move.length}');
    debugPrint('   Move types: ${move.map((e) => e.runtimeType).toList()}');

    int row, col, color;

    // OGS can send moves in different formats:
    // 1. [row, col, color] as integers (0-based indices)
    // 2. ["ab", color] as SGF string (needs decoding)
    // 3. ["ab"] with color determined by move_number (odd=black, even=white)

    if (move.isEmpty) {
      row = col = color = 0;
    } else if (move[0] is String) {
      // SGF format like "dd" - need to decode
      final sgf = move[0] as String;
      debugPrint('   SGF string format: $sgf');

      if (sgf == '..' || sgf.isEmpty) {
        // Pass move
        row = col = -1;
        color = move.length > 1 ? move[1] as int : 0;
      } else if (sgf.length >= 2) {
        // Decode SGF: first char = col, second char = row
        const letters = 'abcdefghijklmnopqrs';
        col = letters.indexOf(sgf[0]);
        row = letters.indexOf(sgf[1]);
        
        // Get color from move array if provided, otherwise determine from move number
        if (move.length > 1 && move[1] is int) {
          color = move[1] as int;
          debugPrint('   Color from move array: $color');
        } else {
          // If color not provided, determine from move_number
          // Move 1 = black, Move 2 = white, Move 3 = black, etc.
          final moveNumber = json['move_number'] ?? 0;
          color = (moveNumber % 2 == 1) ? 1 : 2; // Odd moves = black (1), Even = white (2)
          debugPrint('   Color from move_number $moveNumber: $color');
        }
        
        debugPrint('   Decoded SGF: "$sgf" -> row=$row, col=$col, color=$color');
      } else {
        row = col = color = 0;
      }
    } else {
      // Integer array format [col, row, milliseconds] - SAME as SGF order!
      // NOTE: Third element is NOT color - it's timing info!
      // OGS sends moves in SGF coordinate order: column first, then row
      col = move.length > 0 ? move[0] as int : 0;
      row = move.length > 1 ? move[1] as int : 0;
      
      // Determine color from move_number (odd = black, even = white)
      final moveNumber = json['move_number'] ?? 0;
      color = (moveNumber % 2 == 1) ? 1 : 2;
      
      debugPrint(
        '   Integer array format: col=$col, row=$row, timing=${move.length > 2 ? move[2] : 0}',
      );
      debugPrint('   Color from move_number $moveNumber: $color');
    }

    debugPrint(
      '   Final color: $color (${color == 1
          ? "BLACK"
          : color == 2
          ? "WHITE"
          : "UNKNOWN"})',
    );

    final moveData = MoveData(
      gameId: json['game_id'].toString(),
      moveNumber: json['move_number'] ?? 0,
      row: row,
      col: col,
      color: color,
    );

    debugPrint(
      '✅ [MoveData] Final parsed: row=${moveData.row}, col=${moveData.col}, color=${moveData.color}',
    );

    return moveData;
  }
}

class ClockData {
  final String gameId;
  final int currentPlayer;
  final int blackTime;
  final int whiteTime;
  // Byoyomi periods remaining (null if not byoyomi)
  final int? blackPeriods;
  final int? whitePeriods;
  // Time per period (for display)
  final int? periodTime;
  // Fischer/Canadian increment (seconds added per move)
  final int? timeIncrement;

  ClockData({
    required this.gameId,
    required this.currentPlayer,
    required this.blackTime,
    required this.whiteTime,
    this.blackPeriods,
    this.whitePeriods,
    this.periodTime,
    this.timeIncrement,
  });

  factory ClockData.fromJson(Map<String, dynamic> json) {
    // Parse current_player - can be either int (player number) or int (player ID)
    int currentPlayer = 0;
    final currentPlayerValue = json['current_player'];
    if (currentPlayerValue is int) {
      currentPlayer = currentPlayerValue;
    }
    
    // Parse time values - can be int (seconds) or Map (detailed time info)
    int blackTime = 0;
    int whiteTime = 0;
    int? blackPeriods;
    int? whitePeriods;
    int? periodTime;
    int? timeIncrement;
    
    final blackTimeValue = json['black_time'];
    if (blackTimeValue is int) {
      blackTime = blackTimeValue;
    } else if (blackTimeValue is num) {
      blackTime = blackTimeValue.round();
    } else if (blackTimeValue is Map) {
      // Extract thinking_time from map - can be int or double
      final thinkingTime = blackTimeValue['thinking_time'];
      blackTime = (thinkingTime is num) ? thinkingTime.round() : 0;
      // Extract byoyomi periods if present
      final periods = blackTimeValue['periods'];
      if (periods is int) {
        blackPeriods = periods;
      }
      // Extract period time for display
      final perTime = blackTimeValue['period_time'];
      if (perTime is num) {
        periodTime = perTime.round();
      }
      // Extract Fischer increment if present
      final increment = blackTimeValue['time_increment'];
      if (increment is num) {
        timeIncrement = increment.round();
      }
    }
    
    final whiteTimeValue = json['white_time'];
    if (whiteTimeValue is int) {
      whiteTime = whiteTimeValue;
    } else if (whiteTimeValue is num) {
      whiteTime = whiteTimeValue.round();
    } else if (whiteTimeValue is Map) {
      // Extract thinking_time from map - can be int or double
      final thinkingTime = whiteTimeValue['thinking_time'];
      whiteTime = (thinkingTime is num) ? thinkingTime.round() : 0;
      // Extract byoyomi periods if present
      final periods = whiteTimeValue['periods'];
      if (periods is int) {
        whitePeriods = periods;
      }
      // Extract period time for display
      final perTime = whiteTimeValue['period_time'];
      if (perTime is num) {
        periodTime ??= perTime.round(); // Use first occurrence
      }
      // Extract Fischer increment if present
      final increment = whiteTimeValue['time_increment'];
      if (increment is num) {
        timeIncrement ??= increment.round(); // Use first occurrence
      }
    }
    
    return ClockData(
      gameId: json['game_id'].toString(),
      currentPlayer: currentPlayer,
      blackTime: blackTime,
      whiteTime: whiteTime,
      blackPeriods: blackPeriods,
      whitePeriods: whitePeriods,
      periodTime: periodTime,
      timeIncrement: timeIncrement,
    );
  }
}

class ChatMessage {
  final String username;
  final String message;
  final int moveNumber;
  final DateTime timestamp;

  ChatMessage({
    required this.username,
    required this.message,
    required this.moveNumber,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      username: json['username'] ?? 'Unknown',
      message: json['body'] ?? '',
      moveNumber: json['move_number'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['date'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
