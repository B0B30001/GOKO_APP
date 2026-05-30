import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

/// Chess.com-style learning rank derived from lesson-completion count.
/// Sibling to [LeagueTier] but tied to Learn progress (deterministic,
/// not Elo-based). Drives the rank chip + progress bar in the Learn
/// Garden's sticky header.
class LearningRank {
  /// Lower-bound completed-lesson count (inclusive) for this rank.
  final int threshold;
  final Color color;
  final IconData icon;
  final String Function(AppLocalizations) label;

  const LearningRank({
    required this.threshold,
    required this.color,
    required this.icon,
    required this.label,
  });

  /// All ranks in ascending threshold order. Index 0 is the starting rank.
  static final List<LearningRank> ranks = [
    LearningRank(
      threshold: 0,
      color: const Color(0xFF8BC34A), // sprout green
      icon: Icons.spa,
      label: (l) => l.learningRankNovice,
    ),
    LearningRank(
      threshold: 3,
      color: const Color(0xFF1565C0), // deep blue
      icon: Icons.menu_book,
      label: (l) => l.learningRankApprentice,
    ),
    LearningRank(
      threshold: 7,
      color: const Color(0xFF7C4DFF), // purple
      icon: Icons.psychology,
      label: (l) => l.learningRankScholar,
    ),
    LearningRank(
      threshold: 12,
      color: const Color(0xFFFFB300), // amber
      icon: Icons.auto_awesome,
      label: (l) => l.learningRankMaster,
    ),
    LearningRank(
      threshold: 18,
      color: const Color(0xFFE91E63), // pink
      icon: Icons.workspace_premium,
      label: (l) => l.learningRankGrandmaster,
    ),
  ];

  /// The rank the player currently sits in given their [lessonsCompleted].
  static LearningRank forLessonsCompleted(int lessonsCompleted) {
    LearningRank current = ranks.first;
    for (final r in ranks) {
      if (lessonsCompleted >= r.threshold) current = r;
    }
    return current;
  }

  /// The next rank above [lessonsCompleted], or null when at top rank.
  static LearningRank? nextAbove(int lessonsCompleted) {
    for (final r in ranks) {
      if (r.threshold > lessonsCompleted) return r;
    }
    return null;
  }
}
