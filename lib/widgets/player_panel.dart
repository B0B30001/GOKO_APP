import 'package:flutter/material.dart';

/// Chess.com-style compact player card. Shows avatar, name, rank chip,
/// optional clock, and capture count badge.
///
/// Rendered in a right-side column on desktop/tablet and stacked top/bottom
/// on mobile. Layout-agnostic: parent decides positioning.
class PlayerPanel extends StatelessWidget {
  /// 0=none, 1=black, 2=white. Drives the stone-marker color.
  final int color;
  final String name;
  final String? rank;
  final String? avatarPath;
  final Duration? clock;
  final int captures;
  final bool isActive;
  final bool isDarkBackground;

  const PlayerPanel({
    super.key,
    required this.color,
    required this.name,
    this.rank,
    this.avatarPath,
    this.clock,
    this.captures = 0,
    this.isActive = false,
    this.isDarkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeRing = isActive
        ? Border.all(color: cs.primary, width: 2)
        : Border.all(color: Colors.transparent, width: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkBackground
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: activeRing,
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (rank != null) ...[
                      const SizedBox(width: 6),
                      _RankChip(rank: rank!),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _CaptureBadge(color: color, count: captures),
                    const Spacer(),
                    if (clock != null)
                      _ClockChip(duration: clock!, isActive: isActive),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color == 1
              ? Colors.black87
              : color == 2
              ? Colors.white
              : Colors.grey.shade400,
          backgroundImage: avatarPath != null ? AssetImage(avatarPath!) : null,
          child: avatarPath == null
              ? Icon(
                  Icons.person,
                  color: color == 2 ? Colors.black54 : Colors.white,
                  size: 22,
                )
              : null,
        ),
        if (color != 0)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color == 1 ? Colors.black : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}

class _RankChip extends StatelessWidget {
  final String rank;
  const _RankChip({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rank,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _CaptureBadge extends StatelessWidget {
  /// Color of the player whose captures these are (1=black, 2=white).
  /// The captured stones are the opposite color, so we render the opposite
  /// color stone marker.
  final int color;
  final int count;
  const _CaptureBadge({required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    final capturedStoneColor = color == 1 ? Colors.white : Colors.black;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: capturedStoneColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade600, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '×$count',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ClockChip extends StatelessWidget {
  final Duration duration;
  final bool isActive;
  const _ClockChip({required this.duration, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final mins = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final low = duration.inSeconds <= 10 && duration.inSeconds > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? (low ? Colors.red.shade700 : Colors.green.shade700)
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$mins:$secs',
        style: const TextStyle(
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
