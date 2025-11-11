import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import '../widgets/fast_game_board.dart';

/// Screen to compare performance between Canvas-based and Widget-based boards
class BoardComparisonScreen extends StatefulWidget {
  const BoardComparisonScreen({super.key});

  @override
  State<BoardComparisonScreen> createState() => _BoardComparisonScreenState();
}

class _BoardComparisonScreenState extends State<BoardComparisonScreen> {
  int boardSize = 19;
  late List<List<int>> board;
  int currentPlayer = 1;

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    board = List.generate(boardSize, (i) => List.generate(boardSize, (j) => 0));
  }

  void _handleTap(int i, int j) {
    if (board[i][j] == 0) {
      setState(() {
        board[i][j] = currentPlayer;
        currentPlayer = currentPlayer == 1 ? 2 : 1;
      });
    }
  }

  void _addRandomStones(int count) {
    setState(() {
      for (int n = 0; n < count; n++) {
        int i = (board.length * (n * 13) % 97) % board.length;
        int j = (board.length * (n * 17) % 97) % board.length;
        if (board[i][j] == 0) {
          board[i][j] = (n % 2) + 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Performance Comparison'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => setState(_resetBoard),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addRandomStones(10),
                      icon: const Icon(Icons.add),
                      label: const Text('Add 10 Stones'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addRandomStones(50),
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Add 50 Stones'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 9, label: Text('9x9')),
                    ButtonSegment(value: 13, label: Text('13x13')),
                    ButtonSegment(value: 19, label: Text('19x19')),
                  ],
                  selected: {boardSize},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      boardSize = newSelection.first;
                      _resetBoard();
                    });
                  },
                ),
              ],
            ),
          ),

          // Side-by-side comparison
          Expanded(
            child: Row(
              children: [
                // Canvas-based (Current)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.withValues(alpha: 0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.brush, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Canvas-Based (Current)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GameBoard(
                            board: board,
                            onTap: _handleTap,
                            isDarkTheme: isDarkTheme,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '⚠️ Repaints entire board on every change',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(width: 2, color: Colors.grey.withValues(alpha: 0.3)),

                // Widget-based (Optimized)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.green.withValues(alpha: 0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Widget-Based (Optimized)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FastGameBoard(
                            board: board,
                            onTap: _handleTap,
                            isDarkTheme: isDarkTheme,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '✅ Only rebuilds changed stones',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Performance info
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
            child: Column(
              children: [
                const Text(
                  'Performance Benefits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetric(
                      '🎨 Repaints',
                      'Full board',
                      'Only changed',
                      Colors.red,
                      Colors.green,
                    ),
                    _buildMetric(
                      '⚡ GPU Usage',
                      'CPU Canvas',
                      'GPU Accelerated',
                      Colors.orange,
                      Colors.blue,
                    ),
                    _buildMetric(
                      '🎬 Animation',
                      'Manual frames',
                      'CSS-like smooth',
                      Colors.red,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    String title,
    String oldValue,
    String newValue,
    Color oldColor,
    Color newColor,
  ) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: oldColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                oldValue,
                style: TextStyle(fontSize: 10, color: oldColor),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 12),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: newColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                newValue,
                style: TextStyle(fontSize: 10, color: newColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Comparison'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Canvas-Based (Left)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Full board repaint on every change'),
              Text('• CPU-bound canvas operations'),
              Text('• No widget tree diffing'),
              Text('• Slower on larger boards'),
              SizedBox(height: 16),
              Text(
                'Widget-Based (Right)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Only changed stones rebuild'),
              Text('• GPU-accelerated positioning'),
              Text('• Flutter widget diff algorithm'),
              Text('• Smooth animations'),
              Text('• Consistent performance'),
              SizedBox(height: 16),
              Text(
                'Inspired by Lichess Chessground:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Separate static/dynamic layers'),
              Text('• RepaintBoundary caching'),
              Text('• ValueKey for widget reuse'),
              Text('• Transform-based animations'),
            ],
          ),
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
}
