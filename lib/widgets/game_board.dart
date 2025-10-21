import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  final List<List<int>> board;
  final Function(int i, int j) onTap;

  const GameBoard({
    required this.board,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Доска всегда квадратная
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cellSize = constraints.maxWidth / (board.length - 1);

          return GestureDetector(
            onTapDown: (details) {
              // Преобразование координат тапа в координаты сетки
              final double localX = details.localPosition.dx;
              final double localY = details.localPosition.dy;

              int j = (localX / cellSize).round();
              int i = (localY / cellSize).round();

              // Убедимся, что координаты в пределах доски
              if (i >= 0 && i < board.length && j >= 0 && j < board.length) {
                onTap(i, j);
              }
            },
            child: CustomPaint(
              painter: GoBoardPainter(board, cellSize),
            ),
          );
        },
      ),
    );
  }
}

class GoBoardPainter extends CustomPainter {
  final List<List<int>> board;
  final double cellSize;

  GoBoardPainter(this.board, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    // Рисование доски
    final paint = Paint()
      ..color = Colors.brown[300]!
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Рисование сетки
    for (int i = 0; i < board.length; i++) {
      // Горизонтальные линии
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        linePaint,
      );
      // Вертикальные линии
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        linePaint,
      );
    }

    // Рисование камней
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board.length; j++) {
        final double centerX = j * cellSize;
        final double centerY = i * cellSize;

        if (board[i][j] == 1) {
          // Чёрный камень
          canvas.drawCircle(
            Offset(centerX, centerY),
            cellSize * 0.45,
            Paint()..color = Colors.black,
          );
        } else if (board[i][j] == 2) {
          // Белый камень
          canvas.drawCircle(
            Offset(centerX, centerY),
            cellSize * 0.45,
            Paint()..color = Colors.white,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Перерисовывать, если состояние доски изменилось
    return true;
  }
}