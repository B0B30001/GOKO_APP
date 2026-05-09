import 'package:flutter/material.dart';

/// Visual horizontal strip of captured stones — matches the Chess.com
/// "captured pieces" bar above each player. Renders one stone-disc per
/// capture up to [maxRendered]; beyond that, falls back to "+N".
class CapturedStonesStrip extends StatelessWidget {
  /// Player who made the captures (1=black, 2=white). The captured stones
  /// are the OPPOSITE color, so this widget renders that color.
  final int capturedByColor;

  /// Number of stones captured.
  final int count;

  /// Stone diameter in logical pixels.
  final double size;

  /// Maximum number of individual stones to render before collapsing to "+N".
  final int maxRendered;

  const CapturedStonesStrip({
    super.key,
    required this.capturedByColor,
    required this.count,
    this.size = 12,
    this.maxRendered = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final stoneColor = capturedByColor == 1 ? Colors.white : Colors.black;
    final renderedCount = count.clamp(0, maxRendered);
    final overflow = count - renderedCount;

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < renderedCount; i++)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: stoneColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade600, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 1,
                  offset: const Offset(0, 0.5),
                ),
              ],
            ),
          ),
        if (overflow > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}
