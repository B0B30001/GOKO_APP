import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ogs_service.dart';
import '../../services/online/game_connection.dart';
import '../../widgets/fast_game_board.dart';
import '../../models/app_settings.dart';

class OnlineGameScreen extends StatefulWidget {
  final String gameId;

  const OnlineGameScreen({required this.gameId, super.key});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  GameConnection? _gameConnection;
  List<List<int>>? _board;
  String _blackPlayer = 'Black';
  String _whitePlayer = 'White';
  int _moveNumber = 0;
  String _phase = 'play';
  int _blackTime = 0;
  int _whiteTime = 0;
  int _currentPlayer = 1;
  bool _isMyTurn = false;
  List<ChatMessage> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();

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

    // Listen to game data
    _gameConnection!.gameData.listen((data) {
      debugPrint('📊 [OnlineGameScreen] Received game data:');
      debugPrint('   Board size: ${data.width}x${data.height}');
      debugPrint(
        '   Board: ${data.board.length}x${data.board.isNotEmpty ? data.board[0].length : 0}',
      );
      debugPrint('   Phase: ${data.phase}');

      setState(() {
        // Create a new board instance to ensure Flutter detects changes
        _board = [
          for (var row in data.board) [...row],
        ];
        _phase = data.phase;

        // Update board size info for debugging
        if (_board != null && _board!.isNotEmpty) {
          debugPrint(
            '✅ Board set successfully: ${_board!.length}x${_board![0].length}',
          );
        } else {
          debugPrint('⚠️ Board is empty or null!');
        }
      });
    });

    // Listen to moves
    _gameConnection!.moves.listen((move) {
      debugPrint(
        '🎯 [OnlineGameScreen] Move: (${move.row}, ${move.col}) = ${move.color}',
      );

      setState(() {
        _moveNumber = move.moveNumber;
        if (_board != null &&
            move.row >= 0 &&
            move.col >= 0 &&
            move.row < _board!.length &&
            move.col < _board![move.row].length) {
          // Create a new board instance so Flutter detects the change
          _board = [
            for (int i = 0; i < _board!.length; i++)
              [
                for (int j = 0; j < _board![i].length; j++)
                  if (i == move.row && j == move.col)
                    move.color
                  else
                    _board![i][j],
              ],
          ];
          debugPrint('✅ Move applied to board (new instance created)');
        } else {
          debugPrint('⚠️ Invalid move coordinates or board not initialized');
        }
      });
    });

    // Listen to clock updates
    _gameConnection!.clock.listen((clock) {
      setState(() {
        _currentPlayer = clock.currentPlayer;
        _blackTime = clock.blackTime;
        _whiteTime = clock.whiteTime;
      });
    });

    // Listen to phase changes
    _gameConnection!.phase.listen((phase) {
      setState(() {
        _phase = phase;
      });
    });

    // Listen to chat
    _gameConnection!.chat.listen((message) {
      setState(() {
        _chatMessages.add(message);
      });
    });
  }

  @override
  void dispose() {
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
                return Column(
                  children: [
                    _buildPlayerInfo(false, isDarkTheme), // White
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FastGameBoard(
                              board: _board!,
                              onTap: _onTapBoard,
                              isDarkTheme: isDarkTheme,
                              showCoordinates: AppSettings.showCoordinates,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildPlayerInfo(true, isDarkTheme), // Black
                    _buildControlPanel(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPlayerInfo(bool isBlack, bool isDarkTheme) {
    final name = isBlack ? _blackPlayer : _whitePlayer;
    final time = isBlack ? _blackTime : _whiteTime;
    final isCurrentPlayer =
        (isBlack && _currentPlayer == 1) || (!isBlack && _currentPlayer == 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isCurrentPlayer
          ? (isDarkTheme ? Colors.green[900] : Colors.green[100])
          : null,
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
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (time > 0)
                  Text(_formatTime(time), style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          if (isCurrentPlayer)
            const Icon(Icons.hourglass_bottom, color: Colors.orange),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
    if (!_isMyTurn || _phase != 'play') return;
    if (_board![i][j] != 0) return; // Already occupied

    _gameConnection?.submitMove(i, j);
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

  void _requestUndo() {
    if (_moveNumber > 0) {
      _gameConnection?.requestUndo(_moveNumber);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Undo request sent')));
    }
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
}
