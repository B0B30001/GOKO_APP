import 'package:flutter/material.dart';

import '../services/match_history_service.dart';

/// Compact list tile rendering a single [MatchRecord]. Shared by the home
/// feed, profile recent games, and history screen so they all read the same.
///
/// Layout: result-color stripe ▸ opponent + meta ▸ result chip ▸ chevron.
class GameRecordTile extends StatelessWidget {
  final MatchRecord record;
  final VoidCallback? onTap;

  /// Hide the chevron when the tile is non-interactive (e.g. on a recap list).
  final bool showChevron;

  /// When true, the tile renders without its own Card wrapper — for use
  /// inside an existing Card/grouped panel (e.g. profile recent-games list).
  final bool compact;

  const GameRecordTile({
    required this.record,
    this.onTap,
    this.showChevron = true,
    this.compact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = _resultColor(record.result);
    final textTheme = Theme.of(context).textTheme;
    final inner = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? 0 : 12),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 14),
        child: _rowContent(color, textTheme, context),
      ),
    );
    if (compact) return inner;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: inner,
    );
  }

  Widget _rowContent(Color color, TextTheme textTheme, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'vs ${record.opponent}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _SourceBadge(source: record.source),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${record.boardSize}×${record.boardSize}  ·  ${_relative(record.playedAt)}',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _resultLabel(record.result),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ],
    );
  }

  static Color _resultColor(MatchResult r) => switch (r) {
    MatchResult.win => Colors.green,
    MatchResult.loss => Colors.red,
    MatchResult.draw => Colors.grey,
    MatchResult.unfinished => Colors.blueGrey,
  };

  static String _resultLabel(MatchResult r) => switch (r) {
    MatchResult.win => 'WIN',
    MatchResult.loss => 'LOSS',
    MatchResult.draw => 'DRAW',
    MatchResult.unfinished => '—',
  };

  static String _relative(DateTime then) {
    final diff = DateTime.now().difference(then);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

class _SourceBadge extends StatelessWidget {
  final MatchSource source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (source) {
      MatchSource.ogs => ('OGS', Icons.cloud_done),
      MatchSource.ai => ('AI', Icons.smart_toy_outlined),
      MatchSource.local => ('LOCAL', Icons.people_outline),
    };
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: cs.onSurface.withValues(alpha: 0.55)),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
