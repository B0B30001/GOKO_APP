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

    // One clean connecting trail between the two tiles — a soft rounded line,
    // not scattered specks. A faint blurred halo underneath adds gentle depth.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: unlocked ? 0.38 : 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter old) =>
      old.rowIndex != rowIndex ||
      old.unlocked != unlocked ||
      old.accent != accent;
}
