import 'package:flutter/material.dart';

/// Compact line chart of puzzle-rating snapshots over time. Renders an empty
/// state if fewer than two data points are available.
class RatingSparkline extends StatelessWidget {
  final List<int> ratings;
  final double height;

  const RatingSparkline({required this.ratings, this.height = 64, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (ratings.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Solve a few puzzles to see your rating trend',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          ratings: ratings,
          lineColor: cs.primary,
          fillColor: cs.primary.withValues(alpha: 0.12),
          gridColor: cs.onSurface.withValues(alpha: 0.08),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> ratings;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _SparklinePainter({
    required this.ratings,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (ratings.length < 2) return;

    final minR = ratings.reduce((a, b) => a < b ? a : b);
    final maxR = ratings.reduce((a, b) => a > b ? a : b);
    final range = (maxR - minR) == 0 ? 1 : (maxR - minR);
    final dx = size.width / (ratings.length - 1);

    // Baseline.
    final baseline = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      baseline,
    );

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < ratings.length; i++) {
      final x = i * dx;
      final norm = (ratings[i] - minR) / range;
      final y = size.height - norm * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Dot on the latest point.
    final lastX = (ratings.length - 1) * dx;
    final lastNorm = (ratings.last - minR) / range;
    final lastY = size.height - lastNorm * (size.height - 4) - 2;
    canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      !_listEquals(old.ratings, ratings) ||
      old.lineColor != lineColor ||
      old.fillColor != fillColor;

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
