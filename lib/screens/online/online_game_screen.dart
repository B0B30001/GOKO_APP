import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../services/ogs_service.dart';
import '../../services/online/game_connection.dart';
import '../../services/match_history_service.dart';
import '../../widgets/fast_game_board.dart';
import '../../models/app_settings.dart';
import '../../utils/error_messages.dart';
import '../../services/board/board_engine.dart';
import '../../services/sfx_service.dart';
import '../../models/optimized_board.dart';
import '../../utils/turn.dart';

class OnlineGameScreen extends StatefulWidget {
  final String gameId;

  const OnlineGameScreen({required this.gameId, super.key});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  GameConnection? _gameConnection;
  List<List<int>>? _board;

  /// Bumped on every mutation of [_board] so the child board widget rebuilds
  /// even if Flutter sees the same outer List reference. Without this, in-place
  /// mutations from move/capture events do not trigger a re-render and
  /// captured stones stay visible until another full state refresh.
  int _boardVersion = 0;
  String _blackPlayer = 'Black';
  String _whitePlayer = 'White';
  int _moveNumber = 0;
  String _phase = 'play';
  int _blackTime = 0;
  int _whiteTime = 0;
  int? _blackPeriods; // Byoyomi periods remaining for black
  int? _whitePeriods; // Byoyomi periods remaining for white
  int? _periodTime; // Time per byoyomi period
  int? _timeIncrement; // Fischer increment (seconds added per move)
  int _currentPlayer = 1;
  bool _isMyTurn = false;
  int? _myColor; // 1 = black, 2 = white
  int? _myPlayerId;
  bool _pendingMove = false; // Prevent multiple moves at once
  int? _provRow; // Provisional (optimistic) move row
  int? _provCol; // Provisional (optimistic) move col
  // Result / scoring info (available at end of game)
  int? _winnerColor; // 1=black, 2=white
  double? _blackScore;
  double? _whiteScore;
  String? _outcome;
  // Stone removal (scoring) local state
  Set<int> _localRemoved = <int>{}; // keys: r*width + c
  // Territory ownership (0=neutral, 1=black, 2=white)
  List<int>? _ownership;
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  Timer?
  _countdownTimer; // local countdown to animate clock between server ticks
  // Client-side validation board (updated from server gamedata)
  Board? _validationBoard;
  // Increment feedback (show +seconds after move)
  int? _incrementFeedbackAmount;
  Timer? _incrementFeedbackTimer;
  // Low-time alert state
  bool _lowTimeAlertShown10s = false;
  bool _lowTimeAlertShown5s = false;
  int? _lastAlertedTime; // Track last time we alerted to avoid spam
  // Guard: persist this OGS game to local history exactly once when the
  // server reports the phase transition to 'finished'.
  bool _historyRecorded = false;

  @override
  void initState() {
    super.initState();
    _connectToGame();
  }

  void _connectToGame() {
    final ogsService = Provider.of<OgsService>(context, listen: false);
    _gameConnection = ogsService.activeGamesRepository.connectToGame(
      widget.gameId,
      includeChat: true,
    );

    // Get my player ID from OGS service
    _myPlayerId = ogsService.userData?['id'] as int?;

    // Listen to game data
    _gameConnection!.gameData.listen((data) {
      debugPrint('📊 [OnlineGameScreen] Received game data:');
      debugPrint('   Board size: ${data.width}x${data.height}');
      debugPrint(
        '   Board: ${data.board.length}x${data.board.isNotEmpty ? data.board[0].length : 0}',
      );
      debugPrint('   Phase: ${data.phase}');
      debugPrint(
        '   Black: ${data.blackPlayerName} (ID: ${data.blackPlayerId})',
      );
      debugPrint(
        '   White: ${data.whitePlayerName} (ID: ${data.whitePlayerId})',
      );
      debugPrint('   My Player ID: $_myPlayerId');

      setState(() {
        // Always update board from gamedata to handle stone captures
        // Gamedata contains the authoritative board state from the server
        // including captured stones that move events don't provide
        debugPrint(
          '📋 Updating board from gamedata (phase: ${data.phase}, move: ${data.moveNumber})',
        );
        _board = [
          for (var row in data.board) [...row],
        ];
        _boardVersion++;

        // Sync validation board for client-side rule checking
        if (_board != null && _board!.isNotEmpty) {
          final boardSize = _board!.length;
          _validationBoard = BoardEngine.create(
            boardSize,
            mode: GameMode.online,
          );
          // Reconstruct board state from server data
          for (var i = 0; i < boardSize; i++) {
            for (var j = 0; j < boardSize; j++) {
              final val = _board![i][j];
              if (val != 0) {
                _validationBoard!.setStone(i, j, val);
              }
            }
          }
          // Record current state for ko detection
          _validationBoard!.recordCurrentState();
        }

        _phase = data.phase;
        _blackPlayer = data.blackPlayerName;
        _whitePlayer = data.whitePlayerName;
        _currentPlayer = data.currentPlayer;
        _moveNumber = data.moveNumber;
        // Result fields (used for banners/UI when finished)
        _winnerColor = data.winnerColor;
        _blackScore = data.blackScore;
        _whiteScore = data.whiteScore;
        _outcome = data.outcome;
        // Stone removal - seed our local set from server if provided
        if (_phase == 'stone removal') {
          _localRemoved = data.removedStones ?? <int>{};
        } else {
          _localRemoved.clear();
        }
        // Ownership shading (present during stone removal or finished)
        _ownership = data.ownership;

        // Reset pending move flag when gamedata arrives
        // This prevents the "wait for previous move" issue
        _pendingMove = false;
        // Clear any provisional marker (authoritative board just arrived)
        _provRow = null;
        _provCol = null;

        // Determine which color I'm playing
        if (_myPlayerId != null) {
          if (data.blackPlayerId == _myPlayerId) {
            _myColor = 1; // I'm playing black
            debugPrint('✅ You are playing BLACK');
          } else if (data.whitePlayerId == _myPlayerId) {
            _myColor = 2; // I'm playing white
            debugPrint('✅ You are playing WHITE');
          }
        }

        // Determine if it's my turn
        _isMyTurn = (_myColor != null && _myColor == _currentPlayer);
        debugPrint(
          '   Is my turn: $_isMyTurn (my color: $_myColor, current: $_currentPlayer)',
        );

        // Update board size info for debugging
        if (_board != null && _board!.isNotEmpty) {
          debugPrint(
            '✅ Board set successfully: ${_board!.length}x${_board![0].length}',
          );
        } else {
          debugPrint('⚠️ Board is empty or null!');
        }
        _startOrStopCountdown();
      });
      // Persist completed OGS games into local history so they survive
      // offline and surface in profile / home feed alongside AI games.
      if (_phase == 'finished' && !_historyRecorded) {
        _historyRecorded = true;
        unawaited(_recordHistory());
      }
    });

    // Listen to moves
    _gameConnection!.moves.listen((move) {
      debugPrint(
        '🎯 [OnlineGameScreen] Move received: (${move.row}, ${move.col}) = ${move.color}',
      );
      debugPrint(
        '   Move color: ${move.color == 1
            ? "BLACK"
            : move.color == 2
            ? "WHITE"
            : "UNKNOWN"}',
      );

      setState(() {
        _moveNumber = move.moveNumber;
        _pendingMove = false; // Move confirmed, allow next move
        // Clear provisional tracking if it matches this confirmed move
        if (_provRow == move.row && _provCol == move.col) {
          _provRow = null;
          _provCol = null;
        }

        // Switch turns after move is received
        _currentPlayer = nextPlayer(move.color);
        _isMyTurn = (_myColor != null && _myColor == _currentPlayer);

        // Reset low-time alert flags on turn change
        _lowTimeAlertShown10s = false;
        _lowTimeAlertShown5s = false;
        _lastAlertedTime = null;

        debugPrint(
          '🔄 Turn switched - Current player: $_currentPlayer (${_currentPlayer == 1 ? "BLACK" : "WHITE"}), Is my turn: $_isMyTurn',
        );

        // Optimistic local placement with immediate capture detection
        if (_board != null && move.row >= 0 && move.col >= 0) {
          if (move.row < _board!.length && move.col < _board![0].length) {
            // Place the stone
            if (_board![move.row][move.col] == 0) {
              // First calculate captures before placing stone
              List<int> capturedIndices = [];
              if (_validationBoard != null) {
                capturedIndices = _validationBoard!.calculateCaptures(
                  move.row,
                  move.col,
                  move.color,
                );
              }

              // Now place the stone
              _board![move.row][move.col] = move.color;
              debugPrint(
                '🧿 Placed stone at (${move.row}, ${move.col}) color=${move.color}',
              );

              // Audio feedback for both local and remote moves.
              SfxService.instance.play(SfxSound.stonePlace);
              if (capturedIndices.isNotEmpty) {
                SfxService.instance.play(SfxSound.capture);
              }

              // Remove captured stones immediately for instant visual feedback
              if (capturedIndices.isNotEmpty) {
                debugPrint(
                  '⚡ Immediate capture: ${capturedIndices.length} stones',
                );
                for (final idx in capturedIndices) {
                  final r = idx ~/ _board![0].length;
                  final c = idx % _board![0].length;
                  if (r >= 0 &&
                      c >= 0 &&
                      r < _board!.length &&
                      c < _board![0].length) {
                    _board![r][c] = 0; // Remove captured stone
                  }
                }
              }

              // Update validation board with the move
              if (_validationBoard != null) {
                _validationBoard!.setStone(move.row, move.col, move.color);
                // Remove captures from validation board too
                for (final idx in capturedIndices) {
                  final r = idx ~/ _board![0].length;
                  final c = idx % _board![0].length;
                  if (r >= 0 &&
                      c >= 0 &&
                      r < _board!.length &&
                      c < _board![0].length) {
                    _validationBoard!.setStone(r, c, 0);
                  }
                }
                // Record state for ko detection
                _validationBoard!.recordCurrentState();
              }

              // Replace _board with a fresh deep copy so the child board
              // widget sees a new reference and re-renders. Without this,
              // in-place mutations above do not trigger FastGameBoard to
              // rebuild and captured stones remain visible.
              _board = [
                for (final row in _board!) [...row],
              ];
              _boardVersion++;
            } else {
              debugPrint(
                '⚠️ Cell already occupied locally at (${move.row}, ${move.col}); skipping provisional overwrite',
              );
            }
          } else {
            debugPrint(
              '🚫 Move coordinates out of bounds for current board (${_board!.length}x${_board![0].length})',
            );
          }
        } else if (move.row == -1 && move.col == -1) {
          debugPrint('↪️ Pass move received; no stone placed');
        } else {
          debugPrint(
            '⚠️ Board not initialized yet; cannot place provisional stone',
          );
        }
      });
    });

    // Listen to clock updates
    _gameConnection!.clock.listen((clock) {
      setState(() {
        // Store previous times to detect increment
        final prevBlackTime = _blackTime;
        final prevWhiteTime = _whiteTime;

        // DO NOT update _currentPlayer from clock events!
        // Clock events can be delayed/stale. Only trust move events for turn changes.
        // Update times and periods
        _blackTime = clock.blackTime;
        _whiteTime = clock.whiteTime;
        _blackPeriods = clock.blackPeriods;
        _whitePeriods = clock.whitePeriods;
        _periodTime = clock.periodTime;
        _timeIncrement = clock.timeIncrement;

        // Detect if time increased (increment applied)
        // Show feedback if our color got increment and time went up
        if (_timeIncrement != null && _timeIncrement! > 0) {
          if (_myColor == 1 && _blackTime > prevBlackTime) {
            // Black got increment
            _showIncrementFeedback(_timeIncrement!);
          } else if (_myColor == 2 && _whiteTime > prevWhiteTime) {
            // White got increment
            _showIncrementFeedback(_timeIncrement!);
          }
        }

        debugPrint(
          '⏰ Clock update - Black: $_blackTime (${_blackPeriods ?? 0}p), White: $_whiteTime (${_whitePeriods ?? 0}p), Increment: $_timeIncrement',
        );
        _startOrStopCountdown();
      });
    });

    // Listen to phase changes
    _gameConnection!.phase.listen((phase) {
      final oldPhase = _phase;
      setState(() {
        _phase = phase;
      });
      debugPrint(
        '🎯 [Game ${widget.gameId}] Phase changed: $oldPhase -> $phase',
      );

      // Show user-friendly notifications for phase changes
      if (mounted && oldPhase != phase) {
        if (phase == 'stone removal') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game ended - Mark dead stones for scoring'),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (phase == 'finished') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Game finished'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
      _startOrStopCountdown();
    });

    // Listen to chat
    _gameConnection!.chat.listen((message) {
      setState(() {
        _chatMessages.add(message);
      });
    });

    // Listen to stone removal updates (if server emits separate events)
    _gameConnection!.removedStones.listen((set) {
      if (_phase == 'stone removal') {
        setState(() {
          // When empty, we keep local selection until gamedata arrives
          if (set.isNotEmpty && _board != null) {
            _localRemoved = set;
          }
        });
      }
    });

    // Listen to acceptance confirmations
    _gameConnection!.removedStonesAccepted.listen((accepted) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stone removal accepted')));
    });

    // Listen to undo requests from opponent/server
    _gameConnection!.undoRequests.listen((moveNumber) {
      if (!mounted) return;
      _showUndoRequestDialog(moveNumber);
    });

    // Listen to game-specific errors (illegal moves, etc.)
    _gameConnection!.errors.listen((error) {
      debugPrint('🛑 [OnlineGameScreen] Game error received: $error');
      // Reset pending state so user can try again
      setState(() {
        _pendingMove = false;
        // Revert provisional stone if present
        if (_provRow != null &&
            _provCol != null &&
            _board != null &&
            _provRow! >= 0 &&
            _provCol! >= 0 &&
            _provRow! < _board!.length &&
            _provCol! < _board![0].length) {
          // Only revert if the board still shows our color (optimistic placement)
          _board![_provRow!][_provCol!] = 0;
          _board = [
            for (final row in _board!) [...row],
          ];
          _boardVersion++;
        }
        _provRow = null;
        _provCol = null;
      });
      if (mounted) {
        final display = mapGameError(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(display),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  /// Build a [MatchRecord] from the current end-of-game state and upsert it
  /// into [MatchHistoryService]. Idempotent at the service layer thanks to
  /// the `'ogs:<gameId>'` id, but [_historyRecorded] still guards the call
  /// to avoid redundant writes on repeated gamedata pushes.
  Future<void> _recordHistory() async {
    if (!mounted) return;
    final history = Provider.of<MatchHistoryService>(context, listen: false);
    final size = _board?.length ?? 19;
    // Determine outcome from this user's perspective.
    final MatchResult result;
    if (_winnerColor == null) {
      result = MatchResult.unfinished;
    } else if (_myColor == null) {
      result = MatchResult.unfinished;
    } else if (_winnerColor == _myColor) {
      result = MatchResult.win;
    } else {
      result = MatchResult.loss;
    }
    final opponentName = _myColor == 1 ? _whitePlayer : _blackPlayer;
    await history.add(
      MatchRecord(
        id: 'ogs:${widget.gameId}',
        playedAt: DateTime.now(),
        opponent: opponentName,
        boardSize: size,
        result: result,
        moves: const [],
        source: MatchSource.ogs,
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _incrementFeedbackTimer?.cancel();
    _gameConnection?.disconnect();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forceLight = AppSettings.forceLightThemeInGame;
    final isDarkTheme = forceLight
        ? false
        : Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: forceLight ? Colors.white : null,
        title: Text(
          '$_blackPlayer vs $_whitePlayer',
          style: forceLight ? const TextStyle(color: Colors.black87) : null,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: forceLight ? Colors.black87 : null,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: forceLight ? Colors.black87 : null,
            ),
            onPressed: _showGameInfo,
          ),
        ],
      ),
      body: _board == null || _board!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading game ${widget.gameId}...',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Determine who goes on top vs bottom
                // Bottom = You (my color), Top = Opponent
                final bool showMeAsBlack = _myColor == 1;
                final bool showMeAsWhite = _myColor == 2;

                return Column(
                  children: [
                    // Game status banner (for non-play phases)
                    if (_phase != 'play') _buildGameStatusBanner(isDarkTheme),

                    // Top: Opponent
                    if (showMeAsBlack)
                      _buildPlayerInfo(false, isDarkTheme) // Opponent is White
                    else if (showMeAsWhite)
                      _buildPlayerInfo(true, isDarkTheme) // Opponent is Black
                    else
                      _buildPlayerInfo(
                        false,
                        isDarkTheme,
                      ), // Default: White on top

                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                // Base board
                                FastGameBoard(
                                  key: ValueKey<int>(_boardVersion),
                                  board: _board!,
                                  onTap: _onTapBoard,
                                  isDarkTheme: isDarkTheme,
                                  showCoordinates: AppSettings.showCoordinates,
                                ),
                                // Territory ownership overlay (stone removal or finished)
                                if ((_phase == 'stone removal' ||
                                        _phase == 'finished') &&
                                    _ownership != null &&
                                    _ownership!.isNotEmpty)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: CustomPaint(
                                        painter: _OwnershipOverlayPainter(
                                          board: _board!,
                                          ownership: _ownership!,
                                          isDark: isDarkTheme,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Stone removal overlay (only in that phase)
                                if (_phase == 'stone removal')
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      ignoring: false,
                                      child: CustomPaint(
                                        painter: _RemovedOverlayPainter(
                                          board: _board!,
                                          removed: _localRemoved,
                                          isDark: isDarkTheme,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom: You
                    if (showMeAsBlack)
                      _buildPlayerInfo(true, isDarkTheme) // You are Black
                    else if (showMeAsWhite)
                      _buildPlayerInfo(false, isDarkTheme) // You are White
                    else
                      _buildPlayerInfo(
                        true,
                        isDarkTheme,
                      ), // Default: Black on bottom

                    _buildControlPanel(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildGameStatusBanner(bool isDarkTheme) {
    Color backgroundColor;
    IconData icon;
    String message;

    if (_phase == 'finished') {
      backgroundColor = isDarkTheme ? Colors.blue[900]! : Colors.blue[100]!;
      icon = Icons.flag;
      // Prefer explicit score margin when available; fall back to outcome or generic
      if (_winnerColor != null) {
        final winnerName = _winnerColor == 1 ? 'Black' : 'White';
        String detail = '';
        if (_blackScore != null && _whiteScore != null) {
          final margin = (_blackScore! - _whiteScore!).abs();
          if (margin > 0) {
            detail =
                ' by ${margin.toStringAsFixed(margin.truncateToDouble() == margin ? 0 : 1)}';
          }
        } else if (_outcome != null && _outcome!.isNotEmpty) {
          detail = ' ($_outcome)';
        }
        message = '$winnerName won$detail';
      } else if (_outcome != null && _outcome!.isNotEmpty) {
        message = 'Game finished ($_outcome)';
      } else {
        message = 'Game Finished';
      }
    } else if (_phase == 'stone removal') {
      backgroundColor = isDarkTheme ? Colors.orange[900]! : Colors.orange[100]!;
      icon = Icons.delete_outline;
      message = 'Mark Dead Stones';
    } else {
      backgroundColor = isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!;
      icon = Icons.info_outline;
      message = 'Game in $_phase phase';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (_phase == 'finished') ...[
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: const Size(0, 0),
              ),
              child: const Text('Leave Game'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(bool isBlack, bool isDarkTheme) {
    final name = isBlack ? _blackPlayer : _whitePlayer;
    final time = isBlack ? _blackTime : _whiteTime;
    final periods = isBlack ? _blackPeriods : _whitePeriods;
    final isCurrentPlayer =
        (isBlack && _currentPlayer == 1) || (!isBlack && _currentPlayer == 2);
    final isMe =
        (_myColor != null &&
        ((isBlack && _myColor == 1) || (!isBlack && _myColor == 2)));
    // Determine if in overtime (byoyomi)
    final inOvertime =
        periods != null && periods > 0 && time <= (_periodTime ?? 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? (isDarkTheme ? Colors.green[900] : Colors.green[100])
            : null,
        border: isMe ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isBlack ? Colors.black : Colors.white,
            foregroundColor: isBlack ? Colors.white : Colors.black,
            child: Text(name[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (time >= 0)
                  Row(
                    children: [
                      Text(
                        _formatTime(time),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrentPlayer ? FontWeight.w600 : null,
                          color: (isCurrentPlayer && (time <= 10 || inOvertime))
                              ? Colors.red
                              : null,
                        ),
                      ),
                      // Show increment feedback when time is added
                      if (_incrementFeedbackAmount != null &&
                          isMe &&
                          !isCurrentPlayer) ...[
                        const SizedBox(width: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: 1.0 - (value * 0.3),
                              child: Transform.scale(
                                scale: 1.0 + (value * 0.2),
                                child: Text(
                                  '+$_incrementFeedbackAmount',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      if (periods != null && periods > 0) ...[
                        const SizedBox(width: 8),
                        _buildPeriodsIndicator(
                          periods,
                          inOvertime && isCurrentPlayer,
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          if (isCurrentPlayer) ...[
            const Icon(Icons.hourglass_bottom, color: Colors.orange),
            const SizedBox(width: 4),
            if (isMe)
              const Text(
                'Your turn!',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _phase == 'stone removal'
            ? [
                _buildControlButton(
                  icon: Icons.checklist_rtl,
                  label: 'Suggest',
                  onPressed: (_board != null && _board!.isNotEmpty)
                      ? _submitRemovedStones
                      : null,
                ),
                _buildControlButton(
                  icon: Icons.done_all,
                  label: 'Accept',
                  onPressed: _acceptRemoval,
                ),
                _buildControlButton(
                  icon: Icons.close,
                  label: 'Reject',
                  onPressed: _rejectRemoval,
                ),
              ]
            : [
                _buildControlButton(
                  icon: Icons.chat,
                  label: 'Chat',
                  onPressed: _showChat,
                ),
                _buildControlButton(
                  icon: Icons.undo,
                  label: 'Undo',
                  onPressed: _phase == 'play' ? _requestUndo : null,
                ),
                _buildControlButton(
                  icon: Icons.skip_next,
                  label: 'Pass',
                  onPressed: _phase == 'play' && _isMyTurn ? _pass : null,
                ),
                _buildControlButton(
                  icon: Icons.flag,
                  label: 'Resign',
                  onPressed: _phase == 'play' ? _resign : null,
                ),
              ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: onPressed != null ? null : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPressed != null ? null : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _onTapBoard(int i, int j) {
    debugPrint(
      '🎯 Tap at ($i, $j) - Phase: $_phase, My turn: $_isMyTurn, My color: $_myColor, Pending: $_pendingMove',
    );

    // In stone removal phase, taps toggle dead/alive marking instead of playing moves
    if (_phase == 'stone removal') {
      if (_board == null ||
          i < 0 ||
          j < 0 ||
          i >= _board!.length ||
          j >= _board![0].length) {
        return;
      }
      if (_board![i][j] == 0) {
        // Ignore empty intersections during removal marking
        return;
      }
      final key = i * _board![0].length + j;
      setState(() {
        if (_localRemoved.contains(key)) {
          _localRemoved.remove(key);
        } else {
          _localRemoved.add(key);
        }
      });
      // Note: Sending updated removed_stones to server will be implemented in the next task
      return;
    }

    if (_pendingMove) {
      debugPrint('❌ Cannot place stone - move already pending');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for previous move')),
      );
      return;
    }

    if (_phase != 'play') {
      debugPrint('❌ Cannot place stone - game phase is $_phase');

      String message;
      if (_phase == 'finished') {
        message = 'Game has ended';
      } else if (_phase == 'stone removal') {
        message = 'Game ended - Mark dead stones for scoring';
      } else {
        message = 'Game is in $_phase phase';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: _phase == 'finished'
              ? SnackBarAction(
                  label: 'Leave',
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
      );
      return;
    }

    if (!_isMyTurn) {
      debugPrint('❌ Cannot place stone - not your turn');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('It\'s not your turn!')));
      return;
    }

    if (_board![i][j] != 0) {
      debugPrint(
        '❌ Cannot place stone - position occupied (value: ${_board![i][j]})',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position already occupied')),
      );
      return; // Already occupied
    }

    // Client-side validation using optimized board engine
    if (_validationBoard != null && _myColor != null) {
      if (!_validationBoard!.isValidMove(i, j, _myColor!)) {
        debugPrint('❌ Cannot place stone - invalid move (ko/suicide)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid move (suicide or ko rule violation)'),
          ),
        );
        return;
      }
    }

    debugPrint('✅ Submitting move at ($i, $j) with color $_myColor');

    setState(() {
      _pendingMove = true;
      // Calculate captures before placing stone
      List<int> capturedIndices = [];
      if (_validationBoard != null && _myColor != null) {
        capturedIndices = _validationBoard!.calculateCaptures(i, j, _myColor!);
      }

      // Optimistic local placement for immediate feedback on tap
      if (_myColor != null) {
        _board![i][j] = _myColor!;
        _provRow = i;
        _provCol = j;

        // Immediately show captures for instant visual feedback
        if (capturedIndices.isNotEmpty) {
          debugPrint('⚡ Optimistic capture: ${capturedIndices.length} stones');
          for (final idx in capturedIndices) {
            final r = idx ~/ _board![0].length;
            final c = idx % _board![0].length;
            if (r >= 0 &&
                c >= 0 &&
                r < _board!.length &&
                c < _board![0].length) {
              _board![r][c] = 0; // Remove captured stone
            }
          }
        }

        // Replace _board reference and bump version so the child board widget
        // re-renders with the optimistic placement and any captures.
        _board = [
          for (final row in _board!) [...row],
        ];
        _boardVersion++;
      }
    });

    // Send move to server
    _gameConnection?.submitMove(i, j);

    // Safety timeout - if server doesn't respond in 10 seconds, reset pending state
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _pendingMove) {
        debugPrint('⚠️ Move timeout - resetting pending state');
        setState(() {
          _pendingMove = false;
          // Revert provisional on timeout
          if (_provRow != null &&
              _provCol != null &&
              _board != null &&
              _provRow! >= 0 &&
              _provCol! >= 0 &&
              _provRow! < _board!.length &&
              _provCol! < _board![0].length) {
            _board![_provRow!][_provCol!] = 0;
            _board = [
              for (final row in _board!) [...row],
            ];
            _boardVersion++;
          }
          _provRow = null;
          _provCol = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Move timed out - please try again')),
          );
        }
      }
    });
  }

  void _pass() {
    _gameConnection?.pass();
  }

  void _resign() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resign Game?'),
        content: const Text('Are you sure you want to resign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gameConnection?.resign();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  void _submitRemovedStones() {
    if (_board == null) return;
    final width = _board![0].length;
    final coords = <List<int>>[];
    for (final key in _localRemoved) {
      final r = key ~/ width;
      final c = key % width;
      coords.add([c, r]);
    }
    _gameConnection?.setRemovedStones(coords);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suggested ${coords.length} removed stones')),
    );
  }

  void _acceptRemoval() {
    _gameConnection?.acceptRemovedStones();
  }

  void _rejectRemoval() {
    _gameConnection?.rejectRemovedStones();
  }

  void _requestUndo() {
    if (_moveNumber > 0) {
      _gameConnection?.requestUndo(_moveNumber);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Undo request sent')));
    }
  }

  void _showUndoRequestDialog(int moveNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Undo Request'),
        content: Text('Your opponent requested an undo to move #$moveNumber.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _gameConnection?.declineUndo(moveNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Undo request declined')),
              );
            },
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gameConnection?.acceptUndo(moveNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Undo request accepted')),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game ID: ${widget.gameId}'),
            Text('Move: $_moveNumber'),
            Text('Phase: $_phase'),
            Text('Board: ${_board?.length ?? 0}×${_board?.first.length ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChat() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Game Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  return ListTile(
                    title: Text(msg.username),
                    subtitle: Text(msg.message),
                    trailing: Text(
                      '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_chatController.text.isNotEmpty) {
                      _gameConnection?.sendChatMessage(
                        _chatController.text,
                        moveNumber: _moveNumber,
                      );
                      _chatController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildPeriodsIndicator(int periods, bool highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: highlight ? Colors.red : Colors.orange,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: Colors.red[900]!, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$periods',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'p',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showIncrementFeedback(int seconds) {
    setState(() {
      _incrementFeedbackAmount = seconds;
    });
    _incrementFeedbackTimer?.cancel();
    _incrementFeedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _incrementFeedbackAmount = null;
        });
      }
    });
  }

  void _checkLowTimeAlerts() {
    // Only alert for my turn during play phase
    if (_phase != 'play' || !_isMyTurn || _myColor == null) {
      return;
    }

    final myTime = _myColor == 1 ? _blackTime : _whiteTime;
    final myPeriods = _myColor == 1
        ? (_blackPeriods ?? 0)
        : (_whitePeriods ?? 0);

    // Skip if time already alerted at this value
    if (_lastAlertedTime == myTime) return;

    // Alert at 10 seconds (once)
    if (myTime == 10 && myPeriods == 0 && !_lowTimeAlertShown10s) {
      _lowTimeAlertShown10s = true;
      _lastAlertedTime = myTime;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('10 seconds remaining!'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange.shade900,
        ),
      );
    }
    // Alert at 5 seconds (once)
    else if (myTime == 5 && myPeriods == 0 && !_lowTimeAlertShown5s) {
      _lowTimeAlertShown5s = true;
      _lastAlertedTime = myTime;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('5 seconds remaining!'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
    // Alert when entering new period
    else if (myTime == (_periodTime ?? 0) &&
        myPeriods > 0 &&
        _lastAlertedTime != myTime) {
      _lastAlertedTime = myTime;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.timer, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Period $myPeriods - ${_periodTime}s'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }
  }

  void _startOrStopCountdown() {
    // Only tick during play phase and when board/time is initialized
    final shouldRun = _phase == 'play' && _board != null && _board!.isNotEmpty;
    if (!shouldRun) {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      return;
    }
    if (_countdownTimer != null) return; // already running
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      // Decrement active player's clock locally for smooth UI
      setState(() {
        if (_currentPlayer == 1) {
          if (_blackTime > 0) {
            _blackTime -= 1;
          } else if (_blackPeriods != null && _blackPeriods! > 0) {
            // Entering/continuing byoyomi overtime
            // When main time hits 0, switch to period time
            if (_periodTime != null && _blackTime <= 0) {
              _blackTime = _periodTime!;
              _blackPeriods = _blackPeriods! - 1;
            }
          }
        } else if (_currentPlayer == 2) {
          if (_whiteTime > 0) {
            _whiteTime -= 1;
          } else if (_whitePeriods != null && _whitePeriods! > 0) {
            // Entering/continuing byoyomi overtime
            if (_periodTime != null && _whiteTime <= 0) {
              _whiteTime = _periodTime!;
              _whitePeriods = _whitePeriods! - 1;
            }
          }
        }
        // Check for low-time alerts after updating time
        _checkLowTimeAlerts();
      });
    });
  }
}

/// Painter for stone removal overlay (draws X marks on removed stones)
class _RemovedOverlayPainter extends CustomPainter {
  final List<List<int>> board;
  final Set<int> removed; // keys r*width + c
  final bool isDark;

  _RemovedOverlayPainter({
    required this.board,
    required this.removed,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (board.isEmpty) return;
    final boardSize = board.length;
    final width = board[0].length;
    if (boardSize == 0 || width == 0) return;

    final margin = size.width / (boardSize - 1);
    final playArea = size.width - margin * 2;
    final cell = playArea / (boardSize - 1);

    final xPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.15
      ..strokeCap = StrokeCap.round;

    for (final key in removed) {
      final r = key ~/ width;
      final c = key % width;
      if (r < 0 || c < 0 || r >= boardSize || c >= width) continue;

      final center = Offset(margin + c * cell, margin + r * cell);
      final delta = cell * 0.35;
      final p1 = center + Offset(-delta, -delta);
      final p2 = center + Offset(delta, delta);
      final p3 = center + Offset(-delta, delta);
      final p4 = center + Offset(delta, -delta);
      canvas.drawLine(p1, p2, xPaint);
      canvas.drawLine(p3, p4, xPaint);

      // Optional halo to improve visibility on dark/light themes
      final halo = Paint()
        ..color = (isDark ? Colors.white30 : Colors.black26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = xPaint.strokeWidth * 0.5;
      canvas.drawLine(p1, p2, halo);
      canvas.drawLine(p3, p4, halo);
    }
  }

  @override
  bool shouldRepaint(covariant _RemovedOverlayPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.removed.length != removed.length ||
        !oldDelegate.removed.containsAll(removed) ||
        !removed.containsAll(oldDelegate.removed) ||
        oldDelegate.isDark != isDark;
  }
}

/// Painter for territory ownership overlay
class _OwnershipOverlayPainter extends CustomPainter {
  final List<List<int>> board;
  final List<int> ownership; // length width*height
  final bool isDark;

  _OwnershipOverlayPainter({
    required this.board,
    required this.ownership,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (board.isEmpty) return;
    final h = board.length;
    final w = board[0].length;
    if (ownership.length < w * h) return;

    final margin = size.width / (h - 1);
    final playArea = size.width - margin * 2;
    final cell = playArea / (h - 1);

    // Colors: use subtle but visible shades per theme
    final blackFill = isDark
        ? const Color(0xFF000000).withValues(alpha: 0.18)
        : const Color(0xFF1565C0).withValues(alpha: 0.12);
    final whiteFill = isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: 0.18)
        : const Color(0xFFFFA000).withValues(alpha: 0.12);

    final blackPaint = Paint()
      ..color = blackFill
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = whiteFill
      ..style = PaintingStyle.fill;

    final rRadius = cell * 0.38;

    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        final idx = r * w + c;
        final owner = ownership[idx]; // 0,1,2
        if (owner == 0) continue;
        final center = Offset(margin + c * cell, margin + r * cell);
        final paint = owner == 1 ? blackPaint : whitePaint;
        // draw soft disk overlay centered at intersection
        canvas.drawCircle(center, rRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OwnershipOverlayPainter oldDelegate) {
    if (oldDelegate.isDark != isDark) return true;
    if (oldDelegate.board.length != board.length) return true;
    if (oldDelegate.board.isNotEmpty &&
        oldDelegate.board[0].length != board[0].length) {
      return true;
    }
    if (oldDelegate.ownership.length != ownership.length) return true;
    for (int i = 0; i < ownership.length; i++) {
      if (ownership[i] != oldDelegate.ownership[i]) return true;
    }
    return false;
  }
}
