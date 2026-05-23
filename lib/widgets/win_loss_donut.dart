import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Donut chart showing the user's win / loss / draw split. Mirrors the
/// chess.com profile chart. Renders an empty grey ring when [total] is 0.
class WinLossDonut extends StatelessWidget {
  final int wins;
  final int losses;
  final int draws;
  final double size;

  const WinLossDonut({
    required this.wins,
    required this.losses,
    required this.draws,
    this.size = 160,
    super.key,
  });

  int get total => wins + losses + draws;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          wins: wins,
          losses: losses,
          draws: draws,
          winColor: Colors.green,
          lossColor: Colors.red,
          drawColor: Colors.grey,
          emptyColor: cs.onSurface.withValues(alpha: 0.12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                total == 1 ? 'game' : 'games',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int wins;
  final int losses;
  final int draws;
  final Color winColor;
  final Color lossColor;
  final Color drawColor;
  final Color emptyColor;

  _DonutPainter({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winColor,
    required this.lossColor,
    required this.drawColor,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.18;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );
    final total = wins + losses + draws;

    final empty = Paint()
      ..color = emptyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(rect.center, rect.width / 2, empty);

    if (total == 0) return;

    const sweepGap = 0.02; // small visual gap between segments (radians)
    final segments = <(int, Color)>[
      (wins, winColor),
      (losses, lossColor),
      (draws, drawColor),
    ].where((s) => s.$1 > 0).toList();

    var start = -math.pi / 2; // 12 o'clock
    final usableSweep =
        2 * math.pi - sweepGap * (segments.length > 1 ? segments.length : 0);
    for (final (count, color) in segments) {
      final sweep = usableSweep * (count / total);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + sweepGap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.wins != wins || old.losses != losses || old.draws != draws;
}
