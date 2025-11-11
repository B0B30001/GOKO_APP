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

  Stream<GameData> get gameData => _gameDataController.stream;
  Stream<MoveData> get moves => _moveController.stream;
  Stream<ClockData> get clock => _clockController.stream;
  Stream<String> get phase => _phaseController.stream;
  Stream<ChatMessage> get chat => _chatController.stream;

  int _refCount = 0;
  bool _isConnected = false;

  GameConnection({
    required this.gameId,
    required WebSocketService socketService,
    this.includeChat = true,
  }) : _socketService = socketService {
    _setupListeners();
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

  String _encodeMove(int row, int col) {
    // Convert to SGF coordinates (a-s, skipping i)
    const letters = 'abcdefghjklmnopqrs';
    return letters[col] + letters[row];
  }

  void dispose() {
    disconnect();
    _gameDataController.close();
    _moveController.close();
    _clockController.close();
    _phaseController.close();
    _chatController.close();
  }
}

// Data models
class GameData {
  final String gameId;
  final int width;
  final int height;
  final List<List<int>> board;
  final String phase;

  GameData({
    required this.gameId,
    required this.width,
    required this.height,
    required this.board,
    required this.phase,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      gameId: json['game_id'].toString(),
      width: json['width'] ?? 19,
      height: json['height'] ?? 19,
      board: json['board'] ?? [],
      phase: json['phase'] ?? 'play',
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
    return MoveData(
      gameId: json['game_id'].toString(),
      moveNumber: json['move_number'] ?? 0,
      row: move.length > 0 ? move[0] : 0,
      col: move.length > 1 ? move[1] : 0,
      color: move.length > 2 ? move[2] : 0,
    );
  }
}

class ClockData {
  final String gameId;
  final int currentPlayer;
  final int blackTime;
  final int whiteTime;

  ClockData({
    required this.gameId,
    required this.currentPlayer,
    required this.blackTime,
    required this.whiteTime,
  });

  factory ClockData.fromJson(Map<String, dynamic> json) {
    return ClockData(
      gameId: json['game_id'].toString(),
      currentPlayer: json['current_player'] ?? 0,
      blackTime: json['black_time'] ?? 0,
      whiteTime: json['white_time'] ?? 0,
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
