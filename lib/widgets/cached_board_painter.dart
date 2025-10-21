import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Кэшированный художник для статических элементов доски
class CachedBoardPainter extends CustomPainter {
  final int boardSize;
  final bool isDarkTheme;
  final double cellSize;
  final ui.Image? cachedBoard;

  CachedBoardPainter(
    this.boardSize,
    this.isDarkTheme,
    this.cellSize, {
    this.cachedBoard,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cachedBoard != null) {
      canvas.drawImage(cachedBoard!, Offset.zero, Paint());
      return;
    }
  }

  @override
  bool shouldRepaint(CachedBoardPainter oldDelegate) {
    return boardSize != oldDelegate.boardSize ||
           isDarkTheme != oldDelegate.isDarkTheme ||
           cellSize != oldDelegate.cellSize ||
           cachedBoard != oldDelegate.cachedBoard;
  }
}
