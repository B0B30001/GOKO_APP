import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

/// Chess.com-style competitive league derived from the player's puzzle
/// rating (see `ProgressService.puzzleRating`). Each tier has a colour,
/// icon, and localised label. Used by the Garden hub's XP progress bar
/// and the profile screen badge.
class LeagueTier {
  /// Lower-bound rating (inclusive) for this tier.
  final int threshold;
  final Color color;
  final IconData icon;
  final String Function(AppLocalizations) label;

  const LeagueTier({
    required this.threshold,
    required this.color,
    required this.icon,
    required this.label,
  });

  /// All tiers in ascending threshold order. Stable list — index 0 is
  /// Rookie. Used to drive the "X XP to `next tier`" progress bar.
  static final List<LeagueTier> tiers = [
    LeagueTier(
      threshold: 1000,
      color: Colors.grey,
      icon: Icons.person,
      label: (l) => l.leagueRookie,
    ),
    LeagueTier(
      threshold: 1050,
      color: const Color(0xFFCD7F32),
      icon: Icons.military_tech,
      label: (l) => l.leagueBronze,
    ),
    LeagueTier(
      threshold: 1100,
      color: const Color(0xFFC0C0C0),
      icon: Icons.shield,
      label: (l) => l.leagueSilver,
    ),
    LeagueTier(
      threshold: 1150,
      color: const Color(0xFFFFD700),
      icon: Icons.emoji_events,
      label: (l) => l.leagueGold,
    ),
    LeagueTier(
      threshold: 1200,
      color: const Color(0xFF00BCD4),
      icon: Icons.water_drop,
      label: (l) => l.leaguePlatinum,
    ),
    LeagueTier(
      threshold: 1300,
      color: const Color(0xFF7C4DFF),
      icon: Icons.diamond,
      label: (l) => l.leagueDiamond,
    ),
  ];

  /// The tier the player currently sits in given their puzzle [rating].
  static LeagueTier forRating(int rating) {
    LeagueTier current = tiers.first;
    for (final t in tiers) {
      if (rating >= t.threshold) current = t;
    }
    return current;
  }

  /// The next tier above [rating], or null when the player is already at
  /// the top.
  static LeagueTier? nextAbove(int rating) {
    for (final t in tiers) {
      if (t.threshold > rating) return t;
    }
    return null;
  }
}
