// lib/screens/game_board_screen.dart

import 'package:flutter/material.dart';
import 'package:zaibal/models/optimized_game.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/widgets/fast_game_board.dart';

class GameBoardScreen extends StatefulWidget {
  final int boardSize;

  const GameBoardScreen({required this.boardSize, super.key});

  @override
  _GameBoardScreenState createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late Game _game;

  @override
  void initState() {
    super.initState();
    _game = Game(widget.boardSize);
  }

  void _onTapBoard(int i, int j) {
    if (_game.isGameOver) return;

    // Play turn without setState to check if valid first
    final success = _game.playTurn(i, j);

    if (success) {
      // Only rebuild if move was successful
      setState(() {});

      // Check for no valid moves after a frame delay to avoid jank
      if (!_game.hasValidMoves()) {
        Future.microtask(() {
          if (mounted) {
            _showSnack('No legal moves available. Press Pass to continue.');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final forceLight = AppSettings.forceLightThemeInGame;
    final scaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: forceLight ? Colors.white : null,
        title: Text(
          'GO Game ${widget.boardSize}x${widget.boardSize}',
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
              Icons.refresh,
              color: forceLight ? Colors.black87 : null,
            ),
            onPressed: () {
              _game = Game(widget.boardSize);
              setState(() {});
            },
          ),
        ],
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildDesktopLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _game.canUndo
                    ? () {
                        _game.undo();
                        setState(() {});
                      }
                    : null,
                tooltip: 'Undo move',
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  _game.pass();
                  setState(() {});
                  if (!_game.hasValidMoves()) {
                    Future.microtask(() {
                      if (mounted) _showGameOverDialog();
                    });
                  }
                },
                tooltip: 'Pass turn',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: _game.canRedo
                    ? () {
                        _game.redo();
                        setState(() {});
                      }
                    : null,
                tooltip: 'Redo move',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _game = Game(widget.boardSize);
                  });
                },
                tooltip: 'New game',
              ),
            ],
          ),
        ),
      ),
    );

    return forceLight
        ? Theme(data: ThemeData.light(), child: scaffold)
        : scaffold;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    final double boardSize = constraints.maxHeight * 0.8;
    final forceLight = AppSettings.forceLightThemeInGame;
    final isDarkTheme = forceLight
        ? false
        : Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: FastGameBoard(
                board: _game.board.board,
                onTap: _onTapBoard,
                isDarkTheme: isDarkTheme,
                showCoordinates: AppSettings.showCoordinates,
              ),
            ),
          ),
        ),
        Expanded(flex: 1, child: _buildGameInfo()),
      ],
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    final double boardSize = constraints.maxWidth * 0.95;
    final forceLight = AppSettings.forceLightThemeInGame;
    final isDarkTheme = forceLight
        ? false
        : Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: boardSize,
              height: boardSize,
              child: FastGameBoard(
                board: _game.board.board,
                onTap: _onTapBoard,
                isDarkTheme: isDarkTheme,
                showCoordinates: AppSettings.showCoordinates,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGameInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    final score = _game.getScore();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current Turn:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _game.isBlackTurn ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Score', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildScoreRow('Black', score['black']),
                  const Divider(),
                  _buildScoreRow('White', score['white']),
                  if (_game.isGameOver) ...[
                    const Divider(),
                    Text(
                      'Game Over!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      _getWinnerText(score),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _game = Game(widget.boardSize);
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('New Game'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _game.pass();
                    if (_game.isGameOver) {
                      _showGameOverDialog();
                    }
                  });
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('Pass'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String player, Map<String, dynamic> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(player),
        Row(
          children: [
            Tooltip(message: 'Stones', child: Text('⚫ ${stats['stones']}')),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Territory',
              child: Text('◻ ${stats['territory']}'),
            ),
            const SizedBox(width: 8),
            Tooltip(message: 'Captured', child: Text('✕ ${stats['captured']}')),
            const SizedBox(width: 16),
            Text(
              '= ${stats['total']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _getWinnerText(Map<String, dynamic> score) {
    final blackTotal = score['black']['total'];
    final whiteTotal = score['white']['total'];
    if (blackTotal > whiteTotal) {
      return 'Black wins by ${blackTotal - whiteTotal} points!';
    } else if (whiteTotal > blackTotal) {
      return 'White wins by ${whiteTotal - blackTotal} points!';
    } else {
      return 'Game is tied!';
    }
  }

  void _showGameOverDialog() {
    final score = _game.getScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getWinnerText(score)),
            const SizedBox(height: 16),
            _buildScoreRow('Black', score['black']),
            const Divider(),
            _buildScoreRow('White', score['white']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _game = Game(widget.boardSize);
              });
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
