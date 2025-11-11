import 'package:flutter/material.dart';

/// Widget-based Go board inspired by Lichess Chessground architecture
///
/// Performance improvements over Canvas-based approach:
/// 1. Separates static (grid) and dynamic (stones) layers using RepaintBoundary
/// 2. Only rebuilds stones that changed (Flutter's widget diff algorithm)
/// 3. Uses GPU-accelerated Positioned widgets instead of Canvas painting
/// 4. Const constructors for maximum widget reuse
/// 5. Individual stone animations instead of full board repaints
class WidgetBasedBoard extends StatelessWidget {
  final int boardSize;
  final List<List<int>> board;
  final Function(int i, int j) onTap;
  final bool isDarkTheme;
  final int? lastMoveI;
  final int? lastMoveJ;
  final int? hoverI;
  final int? hoverJ;

  const WidgetBasedBoard({
    required this.boardSize,
    required this.board,
    required this.onTap,
    this.isDarkTheme = false,
    this.lastMoveI,
    this.lastMoveJ,
    this.hoverI,
    this.hoverJ,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          final cellSize = size / boardSize;

          return Stack(
            children: [
              // Layer 1: Static board grid (painted once, cached with RepaintBoundary)
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: StaticGridPainter(
                    boardSize: boardSize,
                    isDarkTheme: isDarkTheme,
                  ),
                ),
              ),

              // Layer 2: Dynamic stones (only changed stones rebuild)
              ...buildStones(cellSize),

              // Layer 3: Last move indicator
              if (lastMoveI != null && lastMoveJ != null)
                buildLastMoveMarker(cellSize, lastMoveI!, lastMoveJ!),

              // Layer 4: Hover indicator
              if (hoverI != null &&
                  hoverJ != null &&
                  board[hoverI!][hoverJ!] == 0)
                buildHoverIndicator(cellSize, hoverI!, hoverJ!),

              // Layer 5: Interactive overlay (tap detection)
              buildInteractiveOverlay(cellSize),
            ],
          );
        },
      ),
    );
  }

  /// Build stone widgets - only changed stones will rebuild thanks to keys
  List<Widget> buildStones(double cellSize) {
    final stones = <Widget>[];

    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        final stoneValue = board[i][j];
        if (stoneValue != 0) {
          // Use ValueKey so Flutter can identify and reuse widgets
          stones.add(
            Positioned(
              key: ValueKey('stone-$i-$j'),
              left: j * cellSize,
              top: i * cellSize,
              child: StoneWidget(
                size: cellSize,
                color: stoneValue == 1 ? StoneColor.black : StoneColor.white,
                isDarkTheme: isDarkTheme,
              ),
            ),
          );
        }
      }
    }

    return stones;
  }

  /// Last move marker with subtle animation
  Widget buildLastMoveMarker(double cellSize, int i, int j) {
    return Positioned(
      left: j * cellSize,
      top: i * cellSize,
      child: RepaintBoundary(
        child: LastMoveMarker(size: cellSize, isDarkTheme: isDarkTheme),
      ),
    );
  }

  /// Hover indicator
  Widget buildHoverIndicator(double cellSize, int i, int j) {
    return Positioned(
      left: j * cellSize,
      top: i * cellSize,
      child: HoverIndicator(size: cellSize, isDarkTheme: isDarkTheme),
    );
  }

  /// Interactive overlay for tap detection
  Widget buildInteractiveOverlay(double cellSize) {
    return Positioned.fill(
      child: GestureDetector(
        onTapUp: (details) {
          final i = (details.localPosition.dy / cellSize).floor();
          final j = (details.localPosition.dx / cellSize).floor();
          if (i >= 0 && i < boardSize && j >= 0 && j < boardSize) {
            onTap(i, j);
          }
        },
        behavior: HitTestBehavior.translucent,
      ),
    );
  }
}

/// Static grid painter - only paints grid lines and star points
/// This is cached with RepaintBoundary and never repaints
class StaticGridPainter extends CustomPainter {
  final int boardSize;
  final bool isDarkTheme;

  const StaticGridPainter({required this.boardSize, required this.isDarkTheme});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / boardSize;
    final paint = Paint()
      ..color = isDarkTheme ? Colors.white70 : Colors.black87
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 0; i < boardSize; i++) {
      final offset = i * cellSize + cellSize / 2;

      // Horizontal line
      canvas.drawLine(
        Offset(cellSize / 2, offset),
        Offset(size.width - cellSize / 2, offset),
        paint,
      );

      // Vertical line
      canvas.drawLine(
        Offset(offset, cellSize / 2),
        Offset(offset, size.height - cellSize / 2),
        paint,
      );
    }

    // Draw star points (hoshi)
    final starPaint = Paint()
      ..color = isDarkTheme ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;

    for (final point in _getStarPoints(boardSize)) {
      final center = Offset(
        point.dx * cellSize + cellSize / 2,
        point.dy * cellSize + cellSize / 2,
      );
      canvas.drawCircle(center, cellSize * 0.08, starPaint);
    }
  }

  List<Offset> _getStarPoints(int size) {
    if (size == 9) {
      return const [
        Offset(2, 2),
        Offset(6, 2),
        Offset(4, 4),
        Offset(2, 6),
        Offset(6, 6),
      ];
    } else if (size == 13) {
      return const [
        Offset(3, 3),
        Offset(9, 3),
        Offset(6, 6),
        Offset(3, 9),
        Offset(9, 9),
      ];
    } else {
      return const [
        Offset(3, 3),
        Offset(9, 3),
        Offset(15, 3),
        Offset(3, 9),
        Offset(9, 9),
        Offset(15, 9),
        Offset(3, 15),
        Offset(9, 15),
        Offset(15, 15),
      ];
    }
  }

  @override
  bool shouldRepaint(StaticGridPainter oldDelegate) {
    // Only repaint if theme or board size changed
    return boardSize != oldDelegate.boardSize ||
        isDarkTheme != oldDelegate.isDarkTheme;
  }
}

/// Stone color enum
enum StoneColor { black, white }

/// Individual stone widget with smooth appearance animation
/// Uses const constructor for widget reuse
class StoneWidget extends StatefulWidget {
  final double size;
  final StoneColor color;
  final bool isDarkTheme;

  const StoneWidget({
    required this.size,
    required this.color,
    this.isDarkTheme = false,
    super.key,
  });

  @override
  State<StoneWidget> createState() => _StoneWidgetState();
}

class _StoneWidgetState extends State<StoneWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            child: Container(
              width: widget.size * 0.85,
              height: widget.size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.color == StoneColor.black
                    ? RadialGradient(
                        colors: [Colors.grey[800]!, Colors.black],
                        stops: const [0.3, 1.0],
                      )
                    : RadialGradient(
                        colors: [Colors.white, Colors.grey[200]!],
                        stops: const [0.3, 1.0],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.3 * _scaleAnimation.value,
                    ),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Last move marker with pulsing animation
class LastMoveMarker extends StatefulWidget {
  final double size;
  final bool isDarkTheme;

  const LastMoveMarker({
    required this.size,
    this.isDarkTheme = false,
    super.key,
  });

  @override
  State<LastMoveMarker> createState() => _LastMoveMarkerState();
}

class _LastMoveMarkerState extends State<LastMoveMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          child: Container(
            width: widget.size * 0.3,
            height: widget.size * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.isDarkTheme ? Colors.red[300] : Colors.red[600])!
                  .withValues(alpha: _pulseAnimation.value),
            ),
          ),
        );
      },
    );
  }
}

/// Hover indicator
class HoverIndicator extends StatelessWidget {
  final double size;
  final bool isDarkTheme;

  const HoverIndicator({
    required this.size,
    this.isDarkTheme = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Container(
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: (isDarkTheme ? Colors.white : Colors.black).withValues(
              alpha: 0.3,
            ),
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Example usage with state management
class WidgetBasedBoardExample extends StatefulWidget {
  final int boardSize;

  const WidgetBasedBoardExample({this.boardSize = 19, super.key});

  @override
  State<WidgetBasedBoardExample> createState() =>
      _WidgetBasedBoardExampleState();
}

class _WidgetBasedBoardExampleState extends State<WidgetBasedBoardExample> {
  late List<List<int>> board;
  int? lastMoveI;
  int? lastMoveJ;
  int? hoverI;
  int? hoverJ;
  int currentPlayer = 1; // 1 = black, 2 = white

  @override
  void initState() {
    super.initState();
    board = List.generate(
      widget.boardSize,
      (i) => List.generate(widget.boardSize, (j) => 0),
    );
  }

  void _handleTap(int i, int j) {
    if (board[i][j] == 0) {
      setState(() {
        board[i][j] = currentPlayer;
        lastMoveI = i;
        lastMoveJ = j;
        currentPlayer = currentPlayer == 1 ? 2 : 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Widget-Based Board (Optimized)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MouseRegion(
            onHover: (event) {
              // Calculate hover position
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final size = box.size.width - 32; // padding
                final cellSize = size / widget.boardSize;
                final i = (event.localPosition.dy / cellSize).floor();
                final j = (event.localPosition.dx / cellSize).floor();

                if (i >= 0 &&
                    i < widget.boardSize &&
                    j >= 0 &&
                    j < widget.boardSize) {
                  setState(() {
                    hoverI = i;
                    hoverJ = j;
                  });
                }
              }
            },
            onExit: (_) {
              setState(() {
                hoverI = null;
                hoverJ = null;
              });
            },
            child: WidgetBasedBoard(
              boardSize: widget.boardSize,
              board: board,
              onTap: _handleTap,
              isDarkTheme: isDarkTheme,
              lastMoveI: lastMoveI,
              lastMoveJ: lastMoveJ,
              hoverI: hoverI,
              hoverJ: hoverJ,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            board = List.generate(
              widget.boardSize,
              (i) => List.generate(widget.boardSize, (j) => 0),
            );
            lastMoveI = null;
            lastMoveJ = null;
            currentPlayer = 1;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
