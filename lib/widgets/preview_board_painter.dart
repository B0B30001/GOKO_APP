import 'package:flutter/material.dart';

class PreviewBoardPainter extends CustomPainter {
  final bool isDark;

  PreviewBoardPainter({
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boardPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDEB887)
      ..style = PaintingStyle.fill;

    // Фон доски
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, boardPaint);

    // Добавляем градиент для текстуры дерева
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDEB887)).withOpacity(0.7),
        (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFD2691E)).withOpacity(0.3),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Параметры сетки
    final margin = size.width * 0.1;
    final playArea = size.width - margin * 2;
    final cellSize = playArea / 18; // 19x19 сетка

    final linePaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..strokeWidth = 1.0;

    // Рисуем сетку
    for (int i = 0; i < 19; i++) {
      final pos = margin + i * cellSize;
      
      // Горизонтальные линии
      canvas.drawLine(
        Offset(margin, pos),
        Offset(size.width - margin, pos),
        linePaint,
      );
      
      // Вертикальные линии
      canvas.drawLine(
        Offset(pos, margin),
        Offset(pos, size.height - margin),
        linePaint,
      );
    }

    // Рисуем точки хоси
    final hosiPoints = [
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

    final hosiPaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..style = PaintingStyle.fill;

    for (final point in hosiPoints) {
      canvas.drawCircle(
        Offset(
          margin + point.dx * cellSize,
          margin + point.dy * cellSize,
        ),
        3.0,
        hosiPaint,
      );
    }

    // Рисуем несколько камней для превью
    _drawPreviewStones(canvas, margin, cellSize);
  }

  void _drawPreviewStones(Canvas canvas, double margin, double cellSize) {
    final positions = [
      (pos: Offset(3, 4), isBlack: true),
      (pos: Offset(4, 3), isBlack: false),
      (pos: Offset(15, 15), isBlack: true),
      (pos: Offset(14, 15), isBlack: false),
      (pos: Offset(9, 9), isBlack: true),
    ];

    for (final stone in positions) {
      final center = Offset(
        margin + stone.pos.dx * cellSize,
        margin + stone.pos.dy * cellSize,
      );
      _drawStone(canvas, center, cellSize * 0.45, stone.isBlack);
    }
  }

  void _drawStone(Canvas canvas, Offset center, double radius, bool isBlack) {
    // Тень
    canvas.drawCircle(
      center.translate(2, 2),
      radius,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Камень
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.fill
        ..color = isBlack ? Colors.black : Colors.white,
    );

    // Блик для белых камней
    if (!isBlack) {
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: center.translate(-radius * 0.3, -radius * 0.3),
            radius: radius * 0.8,
          ),
        );
      canvas.drawCircle(center, radius, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
