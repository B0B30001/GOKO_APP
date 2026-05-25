import 'package:flutter/material.dart';

import 'garden_theme.dart';

/// A short curved segment painted in the space between two level tiles. The
/// curve flows in the same zigzag direction as the tile alignment, so the
/// path reads as one continuous winding road (Candy Crush / Chess.com style).
///
/// Drawn as a solid cream line when the next tile is unlocked, dashed grey
/// when locked.
class PathConnector extends StatelessWidget {
  final int rowIndex;
  final bool unlocked;
  final GardenTheme theme;
  const PathConnector({
    super.key,
    required this.rowIndex,
    required this.unlocked,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: CustomPaint(
        size: const Size(double.infinity, 22),
        painter: _PathConnectorPainter(
          rowIndex: rowIndex,
          unlocked: unlocked,
          accent: theme.tileBase,
        ),
      ),
    );
  }
}

class _PathConnectorPainter extends CustomPainter {
  final int rowIndex;
  final bool unlocked;
  final Color accent;
  const _PathConnectorPainter({
    required this.rowIndex,
    required this.unlocked,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Figure out where the previous and next tile centres sit horizontally
    // based on the same zigzag rule the level tile uses.
    double xFor(int idx) => switch (idx % 4) {
      0 => w * 0.16, // centerLeft
      1 => w * 0.50, // center
      2 => w * 0.84, // centerRight
      _ => w * 0.50,
    };
    final xPrev = xFor(rowIndex - 1);
    final xNext = xFor(rowIndex);

    final color = unlocked
        ? const Color(0xFFF5E6D3) // dirt/cream
        : Colors.grey.shade500;

    // Cubic Bezier from previous tile centre to next, with a vertical bulge
    // to suggest the path arcs around the level badge.
    final path = Path()
      ..moveTo(xPrev, h)
      ..cubicTo(xPrev, h * 0.4, xNext, h * 0.6, xNext, 0);

    // Soft drop shadow under the line for depth.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    if (unlocked) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.85),
      );
    } else {
      // Dashed segment for locked future levels.
      final dashed = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.55);
      _drawDashedPath(canvas, path, dashed, dashLength: 7, gapLength: 5);
    }
  }

  /// Walks [path] in arc-length steps and emits alternating filled/empty
  /// segments. Used for locked connectors to read as "future levels."
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dashLength : gapLength);
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            paint,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter old) =>
      old.rowIndex != rowIndex ||
      old.unlocked != unlocked ||
      old.accent != accent;
}
