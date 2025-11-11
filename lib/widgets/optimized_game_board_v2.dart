import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import '../utils/performance_config.dart';

@immutable
class _BoardMetrics {
  final Size size;
  final double cellSize;
  final double margin;
  final double adjustedCellSize;

  const _BoardMetrics({
    required this.size,
    required this.cellSize,
    required this.margin,
    required this.adjustedCellSize,
  });

  factory _BoardMetrics.fromConstraints(
    BoxConstraints constraints,
    int boardSize,
  ) {
    final size = Size(constraints.maxWidth, constraints.maxWidth);
    final cellSize = size.width / (boardSize - 1);
    final margin = cellSize;
    final playArea = size.width - margin * 2;
    final adjustedCellSize = playArea / (boardSize - 1);
    return _BoardMetrics(
      size: size,
      cellSize: cellSize,
      margin: margin,
      adjustedCellSize: adjustedCellSize,
    );
  }
}

class OptimizedGameBoard extends StatefulWidget {
  final List<List<int>> board;
  final Function(int i, int j) onTap;
  final bool isDarkTheme;
  final bool showCoordinates;

  const OptimizedGameBoard({
    required this.board,
    required this.onTap,
    this.isDarkTheme = false,
    this.showCoordinates = false,
    super.key,
  });

  @override
  State<OptimizedGameBoard> createState() => _OptimizedGameBoardState();
}

class _OptimizedGameBoardState extends State<OptimizedGameBoard> {
  Offset? _hoverPosition;
  bool _isValidMove = false;
  ui.Image? _cachedBoard;
  Size? _lastSize;
  int? _lastBoardSize;
  bool? _lastTheme;
  bool? _lastShowCoordinates;
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
      if (boardSize == 9) {
        return const [
          Offset(2, 2),
          Offset(6, 2),
          Offset(4, 4),
          Offset(2, 6),
          Offset(6, 6),
        ];
      } else if (boardSize == 13) {
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
    });
  }

  Future<void> _updateCachedBoard(_BoardMetrics metrics) async {
    if (_lastSize == metrics.size &&
        _lastBoardSize == widget.board.length &&
        _lastTheme == widget.isDarkTheme &&
        _lastShowCoordinates == widget.showCoordinates) {
      return;
    }

    _lastSize = metrics.size;
    _lastBoardSize = widget.board.length;
    _lastTheme = widget.isDarkTheme;
    _lastShowCoordinates = widget.showCoordinates;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final staticPainter = _StaticBoardPainter(
      widget.board.length,
      widget.isDarkTheme,
      widget.showCoordinates,
      _getCachedPaint,
      _getCachedHoshiPoints,
      _textPainter,
    );

    staticPainter.paint(canvas, metrics.size);

    final picture = recorder.endRecording();
    _cachedBoard?.dispose();
    _cachedBoard = await picture.toImage(
      metrics.size.width.ceil(),
      metrics.size.height.ceil(),
    );
  }

  void _updateHoverPosition(
    PointerHoverEvent event,
    BuildContext context,
    _BoardMetrics metrics,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);
    _handleBoardInteraction(localPos, metrics);
  }

  void _handleTap(TapDownDetails details, _BoardMetrics metrics) {
    final (i, j) = _getBoardCoordinates(details.localPosition, metrics);

    if (i >= 0 &&
        i < widget.board.length &&
        j >= 0 &&
        j < widget.board.length) {
      widget.onTap(i, j);
    }
  }

  (int, int) _getBoardCoordinates(Offset position, _BoardMetrics metrics) {
    final boardX = position.dx - metrics.margin;
    final boardY = position.dy - metrics.margin;

    final j = (boardX / metrics.adjustedCellSize).round();
    final i = (boardY / metrics.adjustedCellSize).round();

    return (i, j);
  }

  void _handleBoardInteraction(Offset position, _BoardMetrics metrics) {
    final (i, j) = _getBoardCoordinates(position, metrics);

    if (i >= 0 &&
        i < widget.board.length &&
        j >= 0 &&
        j < widget.board.length) {
      setState(() {
        _hoverPosition = Offset(
          metrics.margin + j * metrics.adjustedCellSize,
          metrics.margin + i * metrics.adjustedCellSize,
        );
        _isValidMove = widget.board[i][j] == 0;
      });
    } else {
      setState(() {
        _hoverPosition = null;
        _isValidMove = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = _BoardMetrics.fromConstraints(
            constraints,
            widget.board.length,
          );

          // Schedule board caching after frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateCachedBoard(metrics);
          });

          return RepaintBoundary(
            child: MouseRegion(
              onHover: (event) => _updateHoverPosition(event, context, metrics),
              onExit: (_) {
                setState(() {
                  _hoverPosition = null;
                  _isValidMove = false;
                });
              },
              child: GestureDetector(
                onTapDown: (details) => _handleTap(details, metrics),
                child: Stack(
                  children: [
                    // Static board layer
                    if (_cachedBoard != null)
                      CustomPaint(
                        size: metrics.size,
                        painter: _CachedBoardPainter(_cachedBoard!),
                      ),
                    // Dynamic layer (stones and hover highlight)
                    CustomPaint(
                      size: metrics.size,
                      painter: _DynamicBoardPainter(
                        widget.board,
                        metrics,
                        widget.isDarkTheme,
                        hoverPosition: _hoverPosition,
                        isValidMove: _isValidMove,
                        paintCache: _paintCache,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StaticBoardPainter extends CustomPainter {
  final int boardSize;
  final bool isDarkTheme;
  final bool showCoordinates;
  final Paint Function(String, Paint Function()) getPaint;
  final List<Offset> Function(int) getHoshiPoints;
  final TextPainter textPainter;

  _StaticBoardPainter(
    this.boardSize,
    this.isDarkTheme,
    this.showCoordinates,
    this.getPaint,
    this.getHoshiPoints,
    this.textPainter,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final margin = size.width / (boardSize - 1);
    final playArea = size.width - margin * 2;
    final adjustedCellSize = playArea / (boardSize - 1);

    _drawBoard(canvas, size);
    _drawGrid(canvas, size, margin, adjustedCellSize);
    if (showCoordinates) {
      _drawCoordinates(canvas, size, margin, adjustedCellSize);
    }
    _drawHoshiPoints(canvas, margin, adjustedCellSize);
  }

  void _drawBoard(Canvas canvas, Size size) {
    final boardPaint = getPaint('board', () {
      return Paint()
        ..color = isDarkTheme
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFDEB887)
        ..style = PaintingStyle.fill;
    });

    final colors = isDarkTheme
        ? [
            const Color(0xFF2C2C2C).withOpacity(0.7),
            const Color(0xFF1A1A1A).withOpacity(0.3),
          ]
        : [
            const Color(0xFFDEB887).withOpacity(0.7),
            const Color(0xFFD2691E).withOpacity(0.3),
          ];

    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    ).createShader(rect);

    canvas.drawRect(rect, boardPaint);
    canvas.drawRect(rect, Paint()..shader = gradient);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double margin,
    double adjustedCellSize,
  ) {
    final linePaint = getPaint('grid', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..strokeWidth = 1.0;
    });

    for (int i = 0; i < boardSize; i++) {
      final pos = margin + i * adjustedCellSize;
      canvas.drawLine(
        Offset(margin, pos),
        Offset(size.width - margin, pos),
        linePaint,
      );
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
  ) {
    final textStyle = TextStyle(
      color: isDarkTheme ? Colors.white70 : Colors.black87,
      fontSize: 14,
    );

    for (int i = 0; i < boardSize; i++) {
      // Horizontal coordinates
      final letter = String.fromCharCode(i < 8 ? 65 + i : 66 + i);
      textPainter.text = TextSpan(text: letter, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          margin + i * adjustedCellSize - textPainter.width / 2,
          size.height - margin / 2 - textPainter.height / 2,
        ),
      );

      // Vertical coordinates
      final number = (boardSize - i).toString();
      textPainter.text = TextSpan(text: number, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          margin / 2 - textPainter.width / 2,
          margin + i * adjustedCellSize - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawHoshiPoints(Canvas canvas, double margin, double adjustedCellSize) {
    final hosiPaint = getPaint('hoshi', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..style = PaintingStyle.fill;
    });

    for (final point in getHoshiPoints(boardSize)) {
      canvas.drawCircle(
        Offset(
          margin + point.dx * adjustedCellSize,
          margin + point.dy * adjustedCellSize,
        ),
        3.0,
        hosiPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_StaticBoardPainter oldDelegate) {
    return boardSize != oldDelegate.boardSize ||
        isDarkTheme != oldDelegate.isDarkTheme;
  }
}

class _CachedBoardPainter extends CustomPainter {
  final ui.Image cachedBoard;

  _CachedBoardPainter(this.cachedBoard);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(cachedBoard, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(_CachedBoardPainter oldDelegate) {
    return cachedBoard != oldDelegate.cachedBoard;
  }
}

class _DynamicBoardPainter extends CustomPainter {
  final List<List<int>> board;
  final _BoardMetrics metrics;
  final bool isDarkTheme;
  final Offset? hoverPosition;
  final bool isValidMove;
  final Map<String, Paint> paintCache;

  _DynamicBoardPainter(
    this.board,
    this.metrics,
    this.isDarkTheme, {
    this.hoverPosition,
    this.isValidMove = false,
    required this.paintCache,
  });

  Paint _getCachedPaint(String key, Paint Function() creator) {
    return paintCache.putIfAbsent(key, creator);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawHoverHighlight(canvas);
    _drawStones(canvas);
  }

  void _drawHoverHighlight(Canvas canvas) {
    if (hoverPosition != null) {
      final hoverPaint = _getCachedPaint('hover_$isValidMove', () {
        return Paint()
          ..color = isValidMove
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3)
          ..style = PaintingStyle.fill;
      });

      canvas.drawCircle(
        hoverPosition!,
        metrics.adjustedCellSize * 0.45,
        hoverPaint,
      );

      final hoverBorderPaint = _getCachedPaint('hover_border_$isValidMove', () {
        return Paint()
          ..color = isValidMove
              ? Colors.green.withOpacity(0.8)
              : Colors.red.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
      });

      canvas.drawCircle(
        hoverPosition!,
        metrics.adjustedCellSize * 0.45,
        hoverBorderPaint,
      );
    }
  }

  void _drawStones(Canvas canvas) {
    final blackStonePaint = _getCachedPaint('stone_black', () {
      return Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black;
    });

    final whiteStonePaint = _getCachedPaint('stone_white', () {
      return Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white;
    });

    final shadowPaint = _getCachedPaint('stone_shadow', () {
      return Paint()
        ..color = Colors.black26
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          PerformanceConfig.stoneShadowBlur,
        );
    });

    final highlightPaint = _getCachedPaint('stone_highlight', () {
      return Paint()
        ..style = PaintingStyle.fill
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: const Offset(0, 0),
                radius: metrics.adjustedCellSize * 0.45 * 0.8,
              ),
            );
    });

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board.length; j++) {
        if (board[i][j] > 0) {
          final center = Offset(
            metrics.margin + j * metrics.adjustedCellSize,
            metrics.margin + i * metrics.adjustedCellSize,
          );
          final radius = metrics.adjustedCellSize * 0.45;
          final isBlack = board[i][j] == 1;

          // Draw shadow
          canvas.drawCircle(center.translate(2, 2), radius, shadowPaint);

          // Draw stone
          canvas.drawCircle(
            center,
            radius,
            isBlack ? blackStonePaint : whiteStonePaint,
          );

          // Draw highlight for white stones
          if (!isBlack) {
            canvas.save();
            canvas.translate(
              center.dx - radius * 0.3,
              center.dy - radius * 0.3,
            );
            canvas.drawCircle(Offset.zero, radius, highlightPaint);
            canvas.restore();
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicBoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        hoverPosition != oldDelegate.hoverPosition ||
        isValidMove != oldDelegate.isValidMove;
  }
}
