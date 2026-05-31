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

    // Cubic Bezier from previous tile centre to next, with a vertical bulge
    // to suggest the path arcs around the level badge.
    final path = Path()
      ..moveTo(xPrev, h)
      ..cubicTo(xPrev, h * 0.4, xNext, h * 0.6, xNext, 0);

    // Render as a faint trail of small stepping stones along the arc — a hint
    // of the route over the painted scenery, not a competing road. Kept
    // deliberately subtle (lower alpha, ~30% smaller) so the art stays the star.
    final fill = unlocked ? const Color(0xFFF3E4CC) : Colors.grey.shade500;
    final alpha = unlocked ? 0.62 : 0.30;

    for (final metric in path.computeMetrics()) {
      // Evenly space stones along the arc; skip the very ends so stones don't
      // collide with the tiles they connect.
      const spacing = 16.0;
      final count = (metric.length / spacing).floor().clamp(1, 4);
      for (int i = 1; i <= count; i++) {
        final t = i / (count + 1);
        final pos = metric.getTangentForOffset(metric.length * t)?.position;
        if (pos == null) continue;
        // Stones shrink slightly toward the (more distant) top.
        final scale = 0.85 + 0.15 * t;
        final rx = 3.0 * scale;
        final ry = 2.1 * scale;

        // Soft contact shadow.
        canvas.drawOval(
          Rect.fromCenter(
            center: pos.translate(0, 1.0),
            width: rx * 2.2,
            height: ry * 2.0,
          ),
          Paint()
            ..color = Colors.black.withValues(alpha: unlocked ? 0.12 : 0.07)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
        );
        // Paver fill + thin rim.
        canvas.drawOval(
          Rect.fromCenter(center: pos, width: rx * 2, height: ry * 2),
          Paint()..color = fill.withValues(alpha: alpha),
        );
        canvas.drawOval(
          Rect.fromCenter(center: pos, width: rx * 2, height: ry * 2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7
            ..color = Colors.black.withValues(alpha: 0.10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter old) =>
      old.rowIndex != rowIndex ||
      old.unlocked != unlocked ||
      old.accent != accent;
}
