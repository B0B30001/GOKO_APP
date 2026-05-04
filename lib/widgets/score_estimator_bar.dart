import 'package:flutter/material.dart';

/// A compact horizontal advantage bar (Chess.com-style eval bar, but applied
/// to Go territory + captures). Black fills from the left, white from the
/// right, in proportion to total scores.
class ScoreEstimatorBar extends StatelessWidget {
  final num blackTotal;
  final num whiteTotal;

  /// Optional komi just shown as a label.
  final double? komi;

  const ScoreEstimatorBar({
    super.key,
    required this.blackTotal,
    required this.whiteTotal,
    this.komi,
  });

  @override
  Widget build(BuildContext context) {
    final total = (blackTotal + whiteTotal).toDouble();
    final blackFraction = total <= 0
        ? 0.5
        : (blackTotal / total).clamp(0.0, 1.0);
    final lead = (blackTotal - whiteTotal).toDouble();
    final leader = lead.abs() < 0.5
        ? 'Even'
        : lead > 0
        ? 'B +${lead.toStringAsFixed(0)}'
        : 'W +${(-lead).toStringAsFixed(0)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(color: Colors.white),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    widthFactor: blackFraction.toDouble(),
                    heightFactor: 1,
                    child: Container(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              leader,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (komi != null)
              Text(
                'komi ${komi!.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
