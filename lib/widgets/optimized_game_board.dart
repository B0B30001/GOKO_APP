import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;

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
  Size? _lastSize;
  int? _lastBoardSize;
  bool? _lastTheme;
  final Map<String, Paint> _paintCache = {};
  final Map<int, List<Offset>> _hoshiPointsCache = {};
  final TextPainter _textPainter = TextPainter(textDirection: TextDirection.ltr);
  
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

    _drawStaticBoard(
      canvas,
      size,
      widget.board.length,
      widget.isDarkTheme,
    );

    final picture = recorder.endRecording();
    _cachedBoard?.dispose();
    _cachedBoard = await picture.toImage(
      size.width.ceil(),
      size.height.ceil(),
    );
  }

  void _drawStaticBoard(Canvas canvas, Size size, int boardSize, bool isDarkTheme) {
    final margin = size.width / (boardSize - 1);
    final playArea = size.width - margin * 2;
    final adjustedCellSize = playArea / (boardSize - 1);

    // Draw board background
    final boardPaint = _getCachedPaint('board', () {
      return Paint()
        ..color = isDarkTheme ? const Color(0xFF2C2C2C) : const Color(0xFFDEB887)
        ..style = PaintingStyle.fill;
    });

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkTheme
          ? [
              const Color(0xFF2C2C2C).withOpacity(0.7),
              const Color(0xFF1A1A1A).withOpacity(0.3),
            ]
          : [
              const Color(0xFFDEB887).withOpacity(0.7),
              const Color(0xFFD2691E).withOpacity(0.3),
            ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, boardPaint);
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );

    // Draw grid
    final linePaint = _getCachedPaint('grid', () {
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

    // Draw coordinates
    final textStyle = TextStyle(
      color: isDarkTheme ? Colors.white70 : Colors.black87,
      fontSize: 14,
    );

    for (int i = 0; i < boardSize; i++) {
      // Horizontal coordinates
      final letter = String.fromCharCode(i < 8 ? 65 + i : 66 + i);
      _textPainter.text = TextSpan(text: letter, style: textStyle);
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(
          margin + i * adjustedCellSize - _textPainter.width / 2,
          size.height - margin / 2 - _textPainter.height / 2,
        ),
      );

      // Vertical coordinates
      final number = (boardSize - i).toString();
      _textPainter.text = TextSpan(text: number, style: textStyle);
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(
          margin / 2 - _textPainter.width / 2,
          margin + i * adjustedCellSize - _textPainter.height / 2,
        ),
      );
    }

    // Draw hoshi points
    final hosiPaint = _getCachedPaint('hoshi', () {
      return Paint()
        ..color = isDarkTheme ? Colors.white70 : Colors.black87
        ..style = PaintingStyle.fill;
    });

    for (final point in _getCachedHoshiPoints(boardSize)) {
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

  void _updateHoverPosition(
    PointerHoverEvent event,
    BuildContext context,
    double margin,
    double adjustedCellSize,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);
    final (i, j) = _getBoardCoordinates(
      localPos.dx,
      localPos.dy,
      margin,
      adjustedCellSize,
    );

    if (i >= 0 && i < widget.board.length && j >= 0 && j < widget.board.length) {
      if (mounted) {
        setState(() {
          hoverPosition = Offset(
            margin + j * adjustedCellSize,
            margin + i * adjustedCellSize,
          );
          isValidMove = widget.board[i][j] == 0;
        });
      }
    } else if (mounted) {
      setState(() {
        hoverPosition = null;
        isValidMove = false;
      });
    }
  }

  void _handleTap(TapDownDetails details, double margin, double adjustedCellSize) {
    final (i, j) = _getBoardCoordinates(
      details.localPosition.dx,
      details.localPosition.dy,
      margin,
      adjustedCellSize,
    );
    
    if (i >= 0 && i < widget.board.length && j >= 0 && j < widget.board.length) {
      widget.onTap(i, j);
    }
  }

  (int, int) _getBoardCoordinates(
    double x,
    double y,
    double margin,
    double adjustedCellSize,
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
          final size = Size(constraints.maxWidth, constraints.maxWidth);
          final cellSize = size.width / (widget.board.length - 1);
          final margin = cellSize * 1.0;
          final playArea = size.width - margin * 2;
          final adjustedCellSize = playArea / (widget.board.length - 1);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateCachedBoard(size);
          });

          return RepaintBoundary(
            child: MouseRegion(
              onHover: (event) {
                _updateHoverPosition(event, context, margin, adjustedCellSize);
              },
              onExit: (_) {
                if (mounted) {
                  setState(() {
                    hoverPosition = null;
                    isValidMove = false;
                  });
                }
              },
              child: GestureDetector(
                onTapDown: (details) =>
                    _handleTap(details, margin, adjustedCellSize),
                child: Stack(
                  children: [
                    if (_cachedBoard != null)
                      RawImage(
                        image: _cachedBoard!,
                        width: size.width,
                        height: size.height,
                      ),
                    CustomPaint(
                      size: size,
                      painter: _DynamicElementsPainter(
                        board: widget.board,
                        margin: margin,
                        adjustedCellSize: adjustedCellSize,
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

class _DynamicElementsPainter extends CustomPainter {
  final List<List<int>> board;
  final double margin;
  final double adjustedCellSize;
  final Offset? hoverPosition;
  final bool isValidMove;
  final Map<String, Paint> paintCache;

  const _DynamicElementsPainter({
    required this.board,
    required this.margin,
    required this.adjustedCellSize,
    required this.paintCache,
    this.hoverPosition,
    this.isValidMove = false,
  });

  Paint _getCachedPaint(String key, Paint Function() creator) {
    return paintCache.putIfAbsent(key, creator);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawStones(canvas);
    _drawHoverHighlight(canvas);
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

      canvas.drawCircle(hoverPosition!, adjustedCellSize * 0.45, hoverPaint);

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
        adjustedCellSize * 0.45,
        hoverBorderPaint,
      );
    }
  }

  void _drawStones(Canvas canvas) {
    final radius = adjustedCellSize * 0.45;
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
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    });

    final highlightPaint = _getCachedPaint('stone_highlight', () {
      return Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: const Offset(0, 0),
            radius: radius * 0.8,
          ),
        );
    });

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board.length; j++) {
        if (board[i][j] > 0) {
          final center = Offset(
            margin + j * adjustedCellSize,
            margin + i * adjustedCellSize,
          );
          final isBlack = board[i][j] == 1;

          canvas.drawCircle(
            center.translate(2, 2),
            radius,
            shadowPaint,
          );

          canvas.drawCircle(
            center,
            radius,
            isBlack ? blackStonePaint : whiteStonePaint,
          );

          if (!isBlack) {
            canvas.save();
            canvas.translate(
              center.dx - radius * 0.3,
              center.dy - radius * 0.3,
            );
            canvas.drawCircle(
              Offset.zero,
              radius,
              highlightPaint,
            );
            canvas.restore();
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DynamicElementsPainter oldDelegate) {
    return board != oldDelegate.board ||
           hoverPosition != oldDelegate.hoverPosition ||
           isValidMove != oldDelegate.isValidMove;
  }
}
