import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;

/// Ultra-fast game board optimized for all board sizes (9x9, 13x13, 19x19)
///
/// Performance optimizations:
/// 1. Cached static layer (grid, coordinates, hoshi points) - painted once
/// 2. Widget-based stones with keys for Flutter's diff algorithm
/// 3. RepaintBoundary separation prevents cascading rebuilds
/// 4. GPU-accelerated Positioned widgets
/// 5. Paint object caching to avoid recreation
/// 6. Minimal rebuilds - only changed stones update
class FastGameBoard extends StatefulWidget {
  final List<List<int>> board;
  final Function(int i, int j) onTap;
  final bool isDarkTheme;
  final bool showCoordinates;

  const FastGameBoard({
    required this.board,
    required this.onTap,
    this.isDarkTheme = false,
    this.showCoordinates = false,
    super.key,
  });

  @override
  State<FastGameBoard> createState() => _FastGameBoardState();
}

class _FastGameBoardState extends State<FastGameBoard> {
  Offset? _hoverPosition;
  bool _isValidMove = false;
  ui.Image? _cachedBoard;
  Size? _lastSize;
  int? _lastBoardSize;
  bool? _lastTheme;

  // Cache for paint objects to avoid recreation
  final Map<String, Paint> _paintCache = {};
  final Map<int, List<Offset>> _hoshiPointsCache = {};
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  @override
  void dispose() {
    _cachedBoard?.dispose();
    _paintCache.clear();
    _hoshiPointsCache.clear();
    _textPainter.dispose();
    super.dispose();
  }

  Paint _getCachedPaint(String key, Paint Function() creator) {
    return _paintCache.putIfAbsent(key, creator);
  }

  List<Offset> _getCachedHoshiPoints(int boardSize) {
    return _hoshiPointsCache.putIfAbsent(boardSize, () {
      if (boardSize == 19) {
        return [
          const Offset(3, 3),
          const Offset(9, 3),
          const Offset(15, 3),
          const Offset(3, 9),
          const Offset(9, 9),
          const Offset(15, 9),
          const Offset(3, 15),
          const Offset(9, 15),
          const Offset(15, 15),
        ];
      } else if (boardSize == 13) {
        return [
          const Offset(3, 3),
          const Offset(9, 3),
          const Offset(6, 6),
          const Offset(3, 9),
          const Offset(9, 9),
        ];
      } else if (boardSize == 9) {
        return [
          const Offset(2, 2),
          const Offset(6, 2),
          const Offset(4, 4),
          const Offset(2, 6),
          const Offset(6, 6),
        ];
      }
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxWidth);
          final boardSize = widget.board.length;
          final cellSize = size.width / (boardSize - 1);
          final margin = cellSize;
          final playArea = size.width - margin * 2;
          final adjustedCellSize = playArea / (boardSize - 1);

          // Update cached board if needed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateCachedBoard(size);
          });

          return MouseRegion(
            onHover: (event) =>
                _updateHoverPosition(event, context, margin, adjustedCellSize),
            onExit: (_) {
              setState(() {
                _hoverPosition = null;
                _isValidMove = false;
              });
            },
            child: GestureDetector(
              onTapDown: (details) =>
                  _handleTap(details, context, margin, adjustedCellSize),
              child: Stack(
                children: [
                  // Layer 1: Static board (cached)
                  if (_cachedBoard != null)
                    RepaintBoundary(
                      child: CustomPaint(
                        size: size,
                        painter: _CachedBoardPainter(_cachedBoard!),
                      ),
                    ),

                  // Layer 2: Hover indicator (separate layer to avoid stone rebuilds)
                  if (_hoverPosition != null)
                    RepaintBoundary(
                      child: CustomPaint(
                        size: size,
                        painter: _HoverPainter(
                          _hoverPosition!,
                          adjustedCellSize,
                          _isValidMove,
                          _paintCache,
                        ),
                      ),
                    ),

                  // Layer 3: Stones as widgets (GPU accelerated, smart diffing)
                  // Wrapped in IgnorePointer so hover events pass through
                  IgnorePointer(
                    child: Stack(
                      children: buildStoneWidgets(margin, adjustedCellSize),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build stones as individual widgets for optimal performance
  /// Only rebuilds stones that changed since last render
  List<Widget> buildStoneWidgets(double margin, double adjustedCellSize) {
    final stones = <Widget>[];
    final boardSize = widget.board.length;

    // Safety check
    if (boardSize == 0) return stones;

    for (int i = 0; i < boardSize; i++) {
      // Safety check for row length
      if (i >= widget.board.length || widget.board[i].isEmpty) continue;

      final rowSize = widget.board[i].length;
      for (int j = 0; j < rowSize; j++) {
        final stoneValue = widget.board[i][j];
        if (stoneValue != 0) {
          final isBlack = stoneValue == 1;
          final center = Offset(
            margin + j * adjustedCellSize,
            margin + i * adjustedCellSize,
          );

          // Use unique key so Flutter can identify and reuse the widget
          stones.add(
            Positioned(
              key: ValueKey('s$i$j'),
              left: center.dx - adjustedCellSize * 0.45,
              top: center.dy - adjustedCellSize * 0.45,
              width: adjustedCellSize * 0.9,
              height: adjustedCellSize * 0.9,
              child: _StoneWidget(
                isBlack: isBlack,
                size: adjustedCellSize * 0.45,
              ),
            ),
          );
        }
      }
    }

    return stones;
  }

  Future<void> _updateCachedBoard(Size size) async {
    if (_lastSize == size &&
        _lastBoardSize == widget.board.length &&
        _lastTheme == widget.isDarkTheme) {
      return;
    }

    _lastSize = size;
    _lastBoardSize = widget.board.length;
    _lastTheme = widget.isDarkTheme;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    _drawStaticBoard(canvas, size, widget.board.length, widget.isDarkTheme);

    final picture = recorder.endRecording();
    if (_cachedBoard != null) {
      _cachedBoard!.dispose();
    }
    _cachedBoard = await picture.toImage(size.width.ceil(), size.height.ceil());

    if (mounted) {
      setState(() {});
    }
  }

  void _drawStaticBoard(
    Canvas canvas,
    Size size,
    int boardSize,
    bool isDarkTheme,
  ) {
    final margin = size.width / (boardSize - 1);
    final playArea = size.width - margin * 2;
    final adjustedCellSize = playArea / (boardSize - 1);

    // Draw board background
    _drawBoardBackground(canvas, size, isDarkTheme);

    // Draw grid lines
    _drawGrid(canvas, size, margin, adjustedCellSize, boardSize, isDarkTheme);

    // Draw coordinates if enabled
    if (widget.showCoordinates) {
      _drawCoordinates(
        canvas,
        size,
        margin,
        adjustedCellSize,
        boardSize,
        isDarkTheme,
      );
    }

    // Draw hoshi points
    _drawHoshiPoints(canvas, margin, adjustedCellSize, boardSize, isDarkTheme);
  }

  void _drawBoardBackground(Canvas canvas, Size size, bool isDarkTheme) {
    final boardPaint = _getCachedPaint('board', () {
      return Paint()
        ..color = isDarkTheme
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFDEB887)
        ..style = PaintingStyle.fill;
    });

    canvas.drawRect(Offset.zero & size, boardPaint);

    // Gradient overlay
    final colors = isDarkTheme
        ? [
            const Color(0xFF2C2C2C).withValues(alpha: 0.7),
            const Color(0xFF1A1A1A).withValues(alpha: 0.3),
          ]
        : [
            const Color(0xFFDEB887).withValues(alpha: 0.7),
            const Color(0xFFD2691E).withValues(alpha: 0.3),
          ];

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, Paint()..shader = gradient);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double margin,
    double adjustedCellSize,
    int boardSize,
    bool isDarkTheme,
  ) {
    final linePaint = _getCachedPaint('grid', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..strokeWidth = 1.0;
    });

    for (int i = 0; i < boardSize; i++) {
      final pos = margin + i * adjustedCellSize;
      // Horizontal lines
      canvas.drawLine(
        Offset(margin, pos),
        Offset(size.width - margin, pos),
        linePaint,
      );
      // Vertical lines
      canvas.drawLine(
        Offset(pos, margin),
        Offset(pos, size.height - margin),
        linePaint,
      );
    }
  }

  void _drawCoordinates(
    Canvas canvas,
    Size size,
    double margin,
    double adjustedCellSize,
    int boardSize,
    bool isDarkTheme,
  ) {
    const letters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
    ];

    final textStyle = TextStyle(
      color: isDarkTheme ? Colors.white70 : Colors.black87,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < boardSize; i++) {
      // Column letters
      _textPainter.text = TextSpan(text: letters[i], style: textStyle);
      _textPainter.layout();
      final x = margin + i * adjustedCellSize - _textPainter.width / 2;
      _textPainter.paint(
        canvas,
        Offset(x, margin / 2 - _textPainter.height / 2),
      );
      _textPainter.paint(
        canvas,
        Offset(x, size.height - margin / 2 - _textPainter.height / 2),
      );

      // Row numbers
      _textPainter.text = TextSpan(text: '${boardSize - i}', style: textStyle);
      _textPainter.layout();
      final y = margin + i * adjustedCellSize - _textPainter.height / 2;
      _textPainter.paint(
        canvas,
        Offset(margin / 2 - _textPainter.width / 2, y),
      );
      _textPainter.paint(
        canvas,
        Offset(size.width - margin / 2 - _textPainter.width / 2, y),
      );
    }
  }

  void _drawHoshiPoints(
    Canvas canvas,
    double margin,
    double adjustedCellSize,
    int boardSize,
    bool isDarkTheme,
  ) {
    final hoshiPaint = _getCachedPaint('hoshi', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..style = PaintingStyle.fill;
    });

    final hoshiPoints = _getCachedHoshiPoints(boardSize);
    for (final point in hoshiPoints) {
      final center = Offset(
        margin + point.dx * adjustedCellSize,
        margin + point.dy * adjustedCellSize,
      );
      canvas.drawCircle(center, 3, hoshiPaint);
    }
  }

  void _updateHoverPosition(
    PointerHoverEvent event,
    BuildContext context,
    double margin,
    double adjustedCellSize,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);

    final i = ((localPos.dy - margin) / adjustedCellSize).round();
    final j = ((localPos.dx - margin) / adjustedCellSize).round();

    final boardSize = widget.board.length;
    if (i >= 0 && i < boardSize && j >= 0 && j < boardSize) {
      final newHoverPos = Offset(
        margin + j * adjustedCellSize,
        margin + i * adjustedCellSize,
      );

      final isValid = widget.board[i][j] == 0;

      if (_hoverPosition != newHoverPos || _isValidMove != isValid) {
        setState(() {
          _hoverPosition = newHoverPos;
          _isValidMove = isValid;
        });
      }
    } else {
      if (_hoverPosition != null) {
        setState(() {
          _hoverPosition = null;
          _isValidMove = false;
        });
      }
    }
  }

  void _handleTap(
    TapDownDetails details,
    BuildContext context,
    double margin,
    double adjustedCellSize,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);

    final i = ((localPos.dy - margin) / adjustedCellSize).round();
    final j = ((localPos.dx - margin) / adjustedCellSize).round();

    final boardSize = widget.board.length;
    if (i >= 0 && i < boardSize && j >= 0 && j < boardSize) {
      widget.onTap(i, j);
    }
  }
}

/// Cached board painter - draws the cached image
class _CachedBoardPainter extends CustomPainter {
  final ui.Image cachedBoard;

  const _CachedBoardPainter(this.cachedBoard);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(cachedBoard, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(_CachedBoardPainter oldDelegate) {
    return cachedBoard != oldDelegate.cachedBoard;
  }
}

/// Hover indicator painter
class _HoverPainter extends CustomPainter {
  final Offset hoverPosition;
  final double cellSize;
  final bool isValidMove;
  final Map<String, Paint> paintCache;

  const _HoverPainter(
    this.hoverPosition,
    this.cellSize,
    this.isValidMove,
    this.paintCache,
  );

  Paint _getCachedPaint(String key, Paint Function() creator) {
    return paintCache.putIfAbsent(key, creator);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final hoverPaint = _getCachedPaint('hover_$isValidMove', () {
      return Paint()
        ..color = isValidMove
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
    });

    final radius = cellSize * 0.45;
    canvas.drawCircle(hoverPosition, radius, hoverPaint);

    final hoverBorderPaint = _getCachedPaint('hover_border_$isValidMove', () {
      return Paint()
        ..color = isValidMove
            ? Colors.green.withValues(alpha: 0.8)
            : Colors.red.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
    });

    canvas.drawCircle(hoverPosition, radius, hoverBorderPaint);
  }

  @override
  bool shouldRepaint(_HoverPainter oldDelegate) {
    return hoverPosition != oldDelegate.hoverPosition ||
        cellSize != oldDelegate.cellSize ||
        isValidMove != oldDelegate.isValidMove;
  }
}

/// Individual stone widget - uses GPU acceleration
class _StoneWidget extends StatelessWidget {
  final bool isBlack;
  final double size;

  const _StoneWidget({required this.isBlack, required this.size});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size * 2, size * 2),
        painter: _StonePainter(isBlack: isBlack, radius: size),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

/// Stone painter - draws individual stones with cached paints
class _StonePainter extends CustomPainter {
  final bool isBlack;
  final double radius;

  // Static paint cache shared across all stone painters
  static final Map<String, Paint> _paintCache = {};

  const _StonePainter({required this.isBlack, required this.radius});

  Paint _getCachedPaint(String key, Paint Function() creator) {
    return _paintCache.putIfAbsent(key, creator);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow (cached)
    final shadowPaint = _getCachedPaint('shadow', () {
      return Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    });
    canvas.drawCircle(center.translate(2, 2), radius, shadowPaint);

    // Stone (cached)
    final stonePaint = _getCachedPaint('stone_$isBlack', () {
      return Paint()
        ..style = PaintingStyle.fill
        ..color = isBlack ? Colors.black : Colors.white;
    });
    canvas.drawCircle(center, radius, stonePaint);

    // Highlight for white stones (cached)
    if (!isBlack) {
      final highlightPaint = _getCachedPaint('highlight_${radius.toInt()}', () {
        return Paint()
          ..style = PaintingStyle.fill
          ..shader =
              RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(center: Offset.zero, radius: radius * 0.8),
              );
      });

      canvas.save();
      canvas.translate(center.dx - radius * 0.3, center.dy - radius * 0.3);
      canvas.drawCircle(Offset.zero, radius, highlightPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StonePainter oldDelegate) {
    return isBlack != oldDelegate.isBlack || radius != oldDelegate.radius;
  }
}
