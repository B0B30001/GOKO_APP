import 'package:flutter/material.dart';

import '../services/ai/go_ai_service.dart' show AIDifficulty;
import 'bot_engine_config.dart';

/// High-level play-style label shown on bot cards and in the post-game
/// overlay. Drives the style-chip colour too.
enum PlayStyle { random, territorial, tactical, aggressive, calm, balanced }

extension PlayStyleX on PlayStyle {
  String get label => switch (this) {
    PlayStyle.random => 'Random',
    PlayStyle.territorial => 'Territorial',
    PlayStyle.tactical => 'Tactical',
    PlayStyle.aggressive => 'Aggressive',
    PlayStyle.calm => 'Calm',
    PlayStyle.balanced => 'Balanced',
  };

  Color get color => switch (this) {
    PlayStyle.random => const Color(0xFF9E9E9E),
    PlayStyle.territorial => const Color(0xFF26A69A),
    PlayStyle.tactical => const Color(0xFFFF7043),
    PlayStyle.aggressive => const Color(0xFFE53935),
    PlayStyle.calm => const Color(0xFF42A5F5),
    PlayStyle.balanced => const Color(0xFFAB47BC),
  };
}

/// Trigger that picks which line of a bot's `taunts` to surface.
enum BotEvent { greet, win, lose, resign }

/// Public-facing bot definition: identity (name/rank/Elo/avatar), play-style
/// flavour (`style`, `taunts`), engine tuning (`engineConfig`), and the
/// existing premium gate. Forwarded into [GameBoardScreen] so the opponent
/// panel, hint logic and Game-Over overlay all share one source of truth.
class BotProfile {
  final String name;
  final String displayRank; // "12k" / "3d"
  final int elo; // 800–3500+
  final String description;
  final PlayStyle style;
  final int stars; // 1-3
  final IconData icon;
  final Color color;
  final String avatarAsset;
  final bool isPremium;

  /// Engine tuning for cloud KataGo. MCTS fallback only reads `maxVisits`
  /// and `blunderRate` (via [legacyDifficulty]).
  final BotEngineConfig engineConfig;

  /// Legacy mapping for the MCTS fallback path / non-bot entry points that
  /// still take `AIDifficulty`. Roughly mirrors `engineConfig.maxVisits`:
  /// <50 → easy, <300 → medium, else hard. `null` reserved for the KataGo
  /// bot (handled separately — it always wants the strongest engine).
  final AIDifficulty? legacyDifficulty;

  /// Up to 4 short lines keyed by event. The Game-Over overlay picks one
  /// based on the result.
  final Map<BotEvent, String> taunts;

  const BotProfile({
    required this.name,
    required this.displayRank,
    required this.elo,
    required this.description,
    required this.style,
    required this.stars,
    required this.icon,
    required this.color,
    required this.avatarAsset,
    required this.engineConfig,
    this.legacyDifficulty,
    this.isPremium = false,
    this.taunts = const {},
  });

  String taunt(BotEvent e) => taunts[e] ?? _defaultTaunt(e);
}

/// Generic fall-back line so we don't need to spell taunts on every bot.
String _defaultTaunt(BotEvent e) => switch (e) {
  BotEvent.greet => 'Let\'s play!',
  BotEvent.win => 'Good game! You earned that one.',
  BotEvent.lose => 'Nicely played — better luck next time!',
  BotEvent.resign => 'Thanks for the game!',
};
