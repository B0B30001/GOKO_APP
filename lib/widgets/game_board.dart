import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;

/// Painter для отрисовки кэшированной части доски
class CachedBoardPainter extends CustomPainter {
  final ui.Image cachedBoard;
  final int boardSize;
  final bool isDarkTheme;
  final num cellSize;

  CachedBoardPainter(
    this.boardSize,
    this.isDarkTheme,
    this.cellSize, {
    required this.cachedBoard,
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    canvas.drawImage(cachedBoard, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CachedBoardPainter oldDelegate) {
    return cachedBoard != oldDelegate.cachedBoard ||
        boardSize != oldDelegate.boardSize ||
        isDarkTheme != oldDelegate.isDarkTheme ||
        cellSize != oldDelegate.cellSize;
  }
}

class GameBoard extends StatefulWidget {
  final List<List<int>> board;
  final Function(int i, int j) onTap;
  final bool isDarkTheme;

  const GameBoard({
    required this.board,
    required this.onTap,
    this.isDarkTheme = false,
    super.key,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Offset? hoverPosition;
  bool isValidMove = false;
  ui.Image? _cachedBoard;
  ui.Size? _lastSize;
  int? _lastBoardSize;
  bool? _lastTheme;
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

  Future<void> _updateCachedBoard(ui.Size size) async {
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
    final staticPainter = _StaticBoardPainter(
      widget.board.length,
      widget.isDarkTheme,
      _getCachedPaint,
      _getCachedHoshiPoints,
      _textPainter,
    );

    staticPainter.paint(canvas, size);

    final picture = recorder.endRecording();
    _cachedBoard?.dispose();
    _cachedBoard = await picture.toImage(size.width.ceil(), size.height.ceil());
  }

  void _updateHoverPosition(
    PointerHoverEvent event,
    BuildContext context,
    num margin,
    num adjustedCellSize,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);
    _updateBoardPosition(localPos.dx, localPos.dy, margin, adjustedCellSize);
  }

  void _handleTap(TapDownDetails details, num margin, num adjustedCellSize) {
    final (i, j) = _getBoardCoordinates(
      details.localPosition.dx,
      details.localPosition.dy,
      margin,
      adjustedCellSize,
    );
    if (i >= 0 &&
        i < widget.board.length &&
        j >= 0 &&
        j < widget.board.length) {
      widget.onTap(i, j);
    }
  }

  void _updateBoardPosition(num x, num y, num margin, num adjustedCellSize) {
    final (i, j) = _getBoardCoordinates(x, y, margin, adjustedCellSize);

    if (i >= 0 &&
        i < widget.board.length &&
        j >= 0 &&
        j < widget.board.length) {
      setState(() {
        hoverPosition = Offset(
          (margin + j * adjustedCellSize).toDouble(),
          (margin + i * adjustedCellSize).toDouble(),
        );
        isValidMove = widget.board[i][j] == 0;
      });
    } else {
      setState(() {
        hoverPosition = null;
        isValidMove = false;
      });
    }
  }

  (int, int) _getBoardCoordinates(
    num x,
    num y,
    num margin,
    num adjustedCellSize,
  ) {
    final boardX = x - margin;
    final boardY = y - margin;

    final j = (boardX / adjustedCellSize).round();
    final i = (boardY / adjustedCellSize).round();

    return (i, j);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = ui.Size(constraints.maxWidth, constraints.maxWidth);
          final cellSize = size.width / (widget.board.length - 1);
          final margin = cellSize;
          final playArea = size.width - margin * 2;
          final adjustedCellSize = playArea / (widget.board.length - 1);

          // Обновляем кэш доски при изменении размера
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateCachedBoard(size);
          });

          return RepaintBoundary(
            child: MouseRegion(
              onHover: (event) {
                _updateHoverPosition(event, context, margin, adjustedCellSize);
              },
              onExit: (_) {
                setState(() {
                  hoverPosition = null;
                  isValidMove = false;
                });
              },
              child: GestureDetector(
                onTapDown: (details) =>
                    _handleTap(details, margin, adjustedCellSize),
                child: Stack(
                  children: [
                    // Статическая часть доски
                    if (_cachedBoard != null)
                      CustomPaint(
                        size: size,
                        painter: CachedBoardPainter(
                          widget.board.length,
                          widget.isDarkTheme,
                          cellSize,
                          cachedBoard: _cachedBoard!,
                        ),
                      ),
                    // Динамическая часть (камни и подсветка)
                    CustomPaint(
                      size: size,
                      painter: _DynamicBoardPainter(
                        widget.board,
                        cellSize,
                        widget.isDarkTheme,
                        margin,
                        adjustedCellSize,
                        hoverPosition: hoverPosition,
                        isValidMove: isValidMove,
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
  final Paint Function(String, Paint Function()) getPaint;
  final List<Offset> Function(int) getHoshiPoints;
  final TextPainter textPainter;

  _StaticBoardPainter(
    this.boardSize,
    this.isDarkTheme,
    this.getPaint,
    this.getHoshiPoints,
    this.textPainter,
  );

  @override
  void paint(Canvas canvas, ui.Size size) {
    final margin = size.width / (boardSize - 1);
    final playArea = size.width - margin * 2;
    final adjustedCellSize = playArea / (boardSize - 1);

    _drawBoard(canvas, size);
    _drawGrid(canvas, size, margin, adjustedCellSize);
    _drawCoordinates(canvas, size, margin, adjustedCellSize);
    _drawHoshiPoints(canvas, margin, adjustedCellSize);
  }

  void _drawBoard(Canvas canvas, ui.Size size) {
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
    ui.Size size,
    num margin,
    num adjustedCellSize,
  ) {
    final linePaint = getPaint('grid', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..strokeWidth = 1.0;
    });

    for (int i = 0; i < boardSize; i++) {
      final pos = margin + i * adjustedCellSize;
      canvas.drawLine(
        Offset(margin.toDouble(), pos.toDouble()),
        Offset(size.width - margin.toDouble(), pos.toDouble()),
        linePaint,
      );
      canvas.drawLine(
        Offset(pos.toDouble(), margin.toDouble()),
        Offset(pos.toDouble(), size.height - margin.toDouble()),
        linePaint,
      );
    }
  }

  void _drawCoordinates(
    Canvas canvas,
    ui.Size size,
    num margin,
    num adjustedCellSize,
  ) {
    final textStyle = TextStyle(
      color: isDarkTheme ? Colors.white70 : Colors.black87,
      fontSize: adjustedCellSize * 0.35,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < boardSize; i++) {
      // Горизонтальные координаты (A-T, пропуская I)
      final letter = String.fromCharCode(i < 8 ? 65 + i : 66 + i);

      // Нижние буквы
      textPainter.text = TextSpan(text: letter, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (margin + i * adjustedCellSize - textPainter.width / 2),
          (size.height - margin / 2 - textPainter.height / 2),
        ),
      );

      // Верхние буквы (инвертированные)
      final invertedLetter = String.fromCharCode(
        i < 8 ? 65 + (boardSize - 1 - i) : 66 + (boardSize - 1 - i),
      );
      textPainter.text = TextSpan(text: invertedLetter, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (margin + i * adjustedCellSize - textPainter.width / 2),
          (margin / 4 - textPainter.height / 2),
        ),
      );

      // Вертикальные координаты (1-19)
      final number = (i + 1).toString();
      textPainter.text = TextSpan(text: number, style: textStyle);
      textPainter.layout();

      // Левые цифры
      textPainter.paint(
        canvas,
        Offset(
          (margin / 4 - textPainter.width / 2),
          (margin + i * adjustedCellSize - textPainter.height / 2),
        ),
      );

      // Правые цифры (инвертированные)
      final invertedNumber = (boardSize - i).toString();
      textPainter.text = TextSpan(text: invertedNumber, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - margin / 4 - textPainter.width / 2),
          (margin + i * adjustedCellSize - textPainter.height / 2),
        ),
      );
    }
  }

  void _drawHoshiPoints(Canvas canvas, num margin, num adjustedCellSize) {
    final hosiPaint = getPaint('hoshi', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..style = PaintingStyle.fill;
    });

    for (final point in getHoshiPoints(boardSize)) {
      canvas.drawCircle(
        Offset(
          (margin + point.dx * adjustedCellSize).toDouble(),
          (margin + point.dy * adjustedCellSize).toDouble(),
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

class _DynamicBoardPainter extends CustomPainter {
  final List<List<int>> board;
  final num cellSize;
  final bool isDarkTheme;
  final num margin;
  final num adjustedCellSize;
  final Offset? hoverPosition;
  final bool isValidMove;
  final Map<String, Paint> paintCache;

  _DynamicBoardPainter(
    this.board,
    this.cellSize,
    this.isDarkTheme,
    this.margin,
    this.adjustedCellSize, {
    this.hoverPosition,
    this.isValidMove = false,
    required this.paintCache,
  });

  Paint _getCachedPaint(String key, Paint Function() creator) {
    return paintCache.putIfAbsent(key, creator);
  }

  @override
  void paint(Canvas canvas, ui.Size size) {
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
        (adjustedCellSize * 0.45).toDouble(),
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
        (adjustedCellSize * 0.45).toDouble(),
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

    final stoneBorderPaint = _getCachedPaint('stone_border', () {
      return Paint()
        ..style = PaintingStyle.stroke
        ..color = isDarkTheme ? Colors.white30 : Colors.black38
        ..strokeWidth = 1.5;
    });

    final shadowPaint = _getCachedPaint('stone_shadow', () {
      return Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    });

    final radius = (adjustedCellSize * 0.45).toDouble();
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
              Rect.fromCircle(center: const Offset(0, 0), radius: radius * 0.8),
            );
    });

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board.length; j++) {
        if (board[i][j] > 0) {
          final center = Offset(
            (margin + j * adjustedCellSize).toDouble(),
            (margin + i * adjustedCellSize).toDouble(),
          );
          final isBlack = board[i][j] == 1;

          // Draw shadow
          canvas.drawCircle(center.translate(2, 2), radius, shadowPaint);

          // Draw stone
          canvas.drawCircle(
            center,
            radius,
            isBlack ? blackStonePaint : whiteStonePaint,
          );

          // Draw stone border
          canvas.drawCircle(center, radius, stoneBorderPaint);

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
  bool shouldRepaint(_DynamicBoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        hoverPosition != oldDelegate.hoverPosition ||
        isValidMove != oldDelegate.isValidMove;
  }
}
