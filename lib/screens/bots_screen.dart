import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../models/bot_engine_config.dart';
import '../models/bot_profile.dart';
import '../services/ai/go_ai_service.dart';
import '../services/subscription_service.dart';
import '../widgets/goko_logo.dart';
import 'game_board_screen.dart';
import 'paywall_screen.dart';

/// Skill tier grouping for chess.com-style sections on the bots screen.
enum _Tier { beginner, intermediate, advanced, master }

extension _TierLabel on _Tier {
  String localizedLabel(AppLocalizations l) => switch (this) {
    _Tier.beginner => l.beginner,
    _Tier.intermediate => l.intermediate,
    _Tier.advanced => l.advanced,
    _Tier.master => l.master,
  };

  Color get accent => switch (this) {
    _Tier.beginner => const Color(0xFF66BB6A),
    _Tier.intermediate => const Color(0xFFFFB300),
    _Tier.advanced => const Color(0xFFEF5350),
    _Tier.master => const Color(0xFF7C4DFF),
  };
}

/// Full 22-bot ladder. Elo runs ~800 → 3500+, ranks from 25 kyu to 9 dan+.
/// Each tier mixes free + premium so the upsell sits at every difficulty.
const _bots = <_Tier, List<BotProfile>>{
  _Tier.beginner: [
    BotProfile(
      name: 'Panda',
      displayRank: '25k',
      elo: 800,
      description: 'Sweet and silly. Loves playing random moves.',
      style: PlayStyle.random,
      stars: 1,
      icon: Icons.sentiment_very_satisfied,
      color: Color(0xFF4CAF50),
      avatarAsset: 'assets/avatars/panda.png',
      engineConfig: BotEngineConfig.beginner,
      legacyDifficulty: AIDifficulty.easy,
      taunts: {
        BotEvent.greet: 'Hi friend! Let\'s play!',
        BotEvent.win: 'Yay! I won!',
        BotEvent.lose: 'You\'re really good!',
      },
    ),
    BotProfile(
      name: 'Pup',
      displayRank: '22k',
      elo: 900,
      description: 'Eager puppy chasing every stone. Easy to outsmart.',
      style: PlayStyle.random,
      stars: 1,
      icon: Icons.pets,
      color: Color(0xFF8D6E63),
      avatarAsset: 'assets/avatars/pup.png',
      engineConfig: BotEngineConfig.beginner,
      legacyDifficulty: AIDifficulty.easy,
    ),
    BotProfile(
      name: 'Bunny',
      displayRank: '20k',
      elo: 1000,
      description: 'Hops around the board with curious, unpredictable moves.',
      style: PlayStyle.random,
      stars: 1,
      icon: Icons.cruelty_free,
      color: Color(0xFFEC407A),
      avatarAsset: 'assets/avatars/bunny.png',
      engineConfig: BotEngineConfig.beginner,
      legacyDifficulty: AIDifficulty.easy,
    ),
    BotProfile(
      name: 'Koi',
      displayRank: '18k',
      elo: 1100,
      description: 'Soft and steady. Loves edge play and small enclosures.',
      style: PlayStyle.territorial,
      stars: 1,
      icon: Icons.water_drop,
      color: Color(0xFF26C6DA),
      avatarAsset: 'assets/avatars/koi.png',
      engineConfig: BotEngineConfig.earlyKyu,
      legacyDifficulty: AIDifficulty.easy,
    ),
    BotProfile(
      name: 'Tanuki',
      displayRank: '15k',
      elo: 1200,
      description: 'Tricky little spirit. Knows basic captures and shapes.',
      style: PlayStyle.calm,
      stars: 1,
      icon: Icons.park,
      color: Color(0xFF8BC34A),
      avatarAsset: 'assets/avatars/tanuki.png',
      engineConfig: BotEngineConfig.earlyKyu,
      legacyDifficulty: AIDifficulty.easy,
    ),
    BotProfile(
      name: 'Pebble',
      displayRank: '12k',
      elo: 1300,
      description: 'Quiet and steady. Builds slowly toward solid frameworks.',
      style: PlayStyle.calm,
      stars: 1,
      icon: Icons.lens,
      color: Color(0xFF607D8B),
      avatarAsset: 'assets/avatars/pebble.png',
      engineConfig: BotEngineConfig.earlyKyu,
      legacyDifficulty: AIDifficulty.easy,
    ),
  ],
  _Tier.intermediate: [
    BotProfile(
      name: 'Heron',
      displayRank: '12k',
      elo: 1400,
      description: 'Patient. Picks apart loose shapes near the side.',
      style: PlayStyle.territorial,
      stars: 2,
      icon: Icons.nature,
      color: Color(0xFF558B2F),
      avatarAsset: 'assets/avatars/heron.png',
      engineConfig: BotEngineConfig.intermediate,
      legacyDifficulty: AIDifficulty.medium,
      isPremium: true,
    ),
    BotProfile(
      name: 'Owl',
      displayRank: '10k',
      elo: 1500,
      description: 'Wise and patient. Builds solid frameworks of territory.',
      style: PlayStyle.territorial,
      stars: 2,
      icon: Icons.nightlight_round,
      color: Color(0xFF5C6BC0),
      avatarAsset: 'assets/avatars/owl.png',
      engineConfig: BotEngineConfig.intermediate,
      legacyDifficulty: AIDifficulty.medium,
    ),
    BotProfile(
      name: 'Crane',
      displayRank: '8k',
      elo: 1600,
      description: 'Graceful and balanced. Plays light and flexible shapes.',
      style: PlayStyle.balanced,
      stars: 2,
      icon: Icons.flutter_dash,
      color: Color(0xFF26C6DA),
      avatarAsset: 'assets/avatars/crane.png',
      engineConfig: BotEngineConfig.intermediate,
      legacyDifficulty: AIDifficulty.medium,
    ),
    BotProfile(
      name: 'Mantis',
      displayRank: '6k',
      elo: 1700,
      description: 'Sharp and quick. Calculates tactical sequences.',
      style: PlayStyle.tactical,
      stars: 2,
      icon: Icons.bug_report,
      color: Color(0xFFAEEA00),
      avatarAsset: 'assets/avatars/mantis.png',
      engineConfig: BotEngineConfig.intermediate,
      legacyDifficulty: AIDifficulty.medium,
    ),
    BotProfile(
      name: 'Badger',
      displayRank: '5k',
      elo: 1800,
      description: 'Never lets a stone go without a fight.',
      style: PlayStyle.aggressive,
      stars: 2,
      icon: Icons.terrain,
      color: Color(0xFF6D4C41),
      avatarAsset: 'assets/avatars/badger.png',
      engineConfig: BotEngineConfig.intermediate,
      legacyDifficulty: AIDifficulty.medium,
    ),
    BotProfile(
      name: 'Kitsune',
      displayRank: '3k',
      elo: 1900,
      description: 'Cunning fox. Punishes overplays and rewards good shape.',
      style: PlayStyle.tactical,
      stars: 2,
      icon: Icons.auto_awesome,
      color: Color(0xFFFF9800),
      avatarAsset: 'assets/avatars/kitsune.png',
      engineConfig: BotEngineConfig.advanced,
      legacyDifficulty: AIDifficulty.medium,
    ),
  ],
  _Tier.advanced: [
    BotProfile(
      name: 'Phoenix',
      displayRank: '1k',
      elo: 2000,
      description: 'Rises from pressure with sharp counter-attacks.',
      style: PlayStyle.tactical,
      stars: 3,
      icon: Icons.local_fire_department,
      color: Color(0xFFFF6F00),
      avatarAsset: 'assets/avatars/phoenix.png',
      engineConfig: BotEngineConfig.advanced,
      legacyDifficulty: AIDifficulty.hard,
      isPremium: true,
    ),
    BotProfile(
      name: 'Hawk',
      displayRank: '1d',
      elo: 2100,
      description: 'Pressure player. Always probing your weak groups.',
      style: PlayStyle.aggressive,
      stars: 3,
      icon: Icons.air,
      color: Color(0xFF795548),
      avatarAsset: 'assets/avatars/hawk.png',
      engineConfig: BotEngineConfig.advanced,
      legacyDifficulty: AIDifficulty.hard,
    ),
    BotProfile(
      name: 'Tiger',
      displayRank: '2d',
      elo: 2200,
      description: 'Fierce fighter. Loves to attack weak groups.',
      style: PlayStyle.aggressive,
      stars: 3,
      icon: Icons.local_fire_department,
      color: Color(0xFFFF7043),
      avatarAsset: 'assets/avatars/tiger.png',
      engineConfig: BotEngineConfig.dan,
      legacyDifficulty: AIDifficulty.hard,
    ),
    BotProfile(
      name: 'Otter',
      displayRank: '2d',
      elo: 2300,
      description: 'Flexible and playful. Pivots between attack and defence.',
      style: PlayStyle.balanced,
      stars: 3,
      icon: Icons.waves,
      color: Color(0xFF00ACC1),
      avatarAsset: 'assets/avatars/otter.png',
      engineConfig: BotEngineConfig.dan,
      legacyDifficulty: AIDifficulty.hard,
    ),
    BotProfile(
      name: 'Dragon',
      displayRank: '3d',
      elo: 2400,
      description: 'Powerful reading and clean endgame. Demands precision.',
      style: PlayStyle.tactical,
      stars: 3,
      icon: Icons.cyclone,
      color: Color(0xFF26A69A),
      avatarAsset: 'assets/avatars/dragon.png',
      engineConfig: BotEngineConfig.dan,
      legacyDifficulty: AIDifficulty.hard,
    ),
    BotProfile(
      name: 'Samurai',
      displayRank: '4d',
      elo: 2500,
      description: 'Honor and discipline. Strong fighting plus clean shape.',
      style: PlayStyle.balanced,
      stars: 3,
      icon: Icons.shield,
      color: Color(0xFF8B0000),
      avatarAsset: 'assets/avatars/samurai.png',
      engineConfig: BotEngineConfig.master,
      legacyDifficulty: AIDifficulty.hard,
      isPremium: true,
    ),
  ],
  _Tier.master: [
    BotProfile(
      name: 'Tengu',
      displayRank: '5d',
      elo: 2700,
      description: 'Mountain spirit. Strong fighting and efficient shape.',
      style: PlayStyle.aggressive,
      stars: 3,
      icon: Icons.whatshot,
      color: Color(0xFFE91E63),
      avatarAsset: 'assets/avatars/tengu.png',
      engineConfig: BotEngineConfig.master,
      legacyDifficulty: AIDifficulty.hard,
      isPremium: true,
    ),
    BotProfile(
      name: 'Monk',
      displayRank: '6d',
      elo: 2900,
      description: 'Calm, deep positional understanding. Whole-board sight.',
      style: PlayStyle.calm,
      stars: 3,
      icon: Icons.spa,
      color: Color(0xFFFFB300),
      avatarAsset: 'assets/avatars/monk.png',
      engineConfig: BotEngineConfig.master,
      legacyDifficulty: AIDifficulty.hard,
      isPremium: true,
    ),
    BotProfile(
      name: 'Oracle',
      displayRank: '7d',
      elo: 3100,
      description: 'Sees variations a dozen moves ahead. Hard to fool.',
      style: PlayStyle.tactical,
      stars: 3,
      icon: Icons.visibility,
      color: Color(0xFF00897B),
      avatarAsset: 'assets/avatars/oracle.png',
      engineConfig: BotEngineConfig.master,
      legacyDifficulty: AIDifficulty.hard,
      isPremium: true,
    ),
    BotProfile(
      name: 'Sensei',
      displayRank: '7d',
      elo: 3200,
      description:
          'Wise teacher. Plays the most instructive professional moves.',
      style: PlayStyle.balanced,
      stars: 3,
      icon: Icons.school,
      color: Color(0xFFAB47BC),
      avatarAsset: 'assets/avatars/sensei.png',
      engineConfig: BotEngineConfig.master,
      legacyDifficulty: AIDifficulty.hard,
      isPremium: true,
    ),
    BotProfile(
      name: 'KataGo',
      displayRank: '9d+',
      elo: 3500,
      description: 'Plans dozens of moves ahead with neural-network lookahead. Superhuman strategic vision.',
      style: PlayStyle.balanced,
      stars: 3,
      icon: Icons.smart_toy,
      color: Color(0xFF7C4DFF),
      avatarAsset: 'assets/avatars/katago.png',
      engineConfig: BotEngineConfig.superhuman,
      isPremium: true,
    ),
  ],
};

/// Screen listing AI bots organized by skill tier, in a chess.com-style grid.
class BotsScreen extends StatelessWidget {
  const BotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // KataGo bot requires cloud analysis (coming soon); always locked for now.
    const kataGoReady = false;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GokoLogo(size: 22),
            const SizedBox(width: 8),
            Text(l.playVsBotTitle),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 1100
              ? 5
              : width >= 800
              ? 4
              : width >= 560
              ? 3
              : 2;
          return CustomScrollView(
            slivers: [
              for (final tier in _Tier.values) ...[
                SliverToBoxAdapter(child: _TierHeader(tier: tier)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final bot = _bots[tier]![i];
                      // KataGo's "legacyDifficulty" is null because it always
                      // wants the strongest backend. Card is available when
                      // either (a) the cloud is configured, or (b) the bot
                      // has a legacy MCTS difficulty to fall back on.
                      final available =
                          bot.legacyDifficulty != null ||
                          (bot.name == 'KataGo' && kataGoReady);
                      return _BotCard(bot: bot, available: available);
                    }, childCount: _bots[tier]!.length),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  final _Tier tier;
  const _TierHeader({required this.tier});

  @override
  Widget build(BuildContext context) {
    final tierBots = _bots[tier]!;
    final pro = tierBots.where((b) => b.isPremium).length;
    final free = tierBots.length - pro;
    final fadedOnSurface = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: tier.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            tier.localizedLabel(AppLocalizations.of(context)),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tierBots.length} bots',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: fadedOnSurface),
          ),
          const SizedBox(width: 6),
          Text(
            '·',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: fadedOnSurface),
          ),
          const SizedBox(width: 6),
          Text(
            '$free free',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tier.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (pro > 0) ...[
            const SizedBox(width: 6),
            Text(
              '· $pro pro',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotCard extends StatelessWidget {
  final BotProfile bot;
  final bool available;

  const _BotCard({required this.bot, required this.available});

  @override
  Widget build(BuildContext context) {
    final color = available ? bot.color : Colors.grey;
    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: available ? () => _handleTap(context) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar header with colored background
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.22),
                          color.withValues(alpha: 0.06),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _Avatar(bot: bot, available: available),
                  ),
                  if (bot.isPremium)
                    const Positioned(top: 8, right: 8, child: _PremiumPill()),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _StarsBadge(stars: bot.stars, color: color),
                  ),
                ],
              ),
            ),
            // Info footer
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bot.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: available ? null : Colors.grey,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _RankChip(text: bot.displayRank, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _EloChip(elo: bot.elo),
                      const SizedBox(width: 4),
                      Flexible(child: _StyleChip(style: bot.style)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (bot.isPremium && !context.read<SubscriptionService>().isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PaywallScreen(reason: PaywallReason.advancedBots),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _BotDetailSheet(bot: bot),
    );
  }
}

class _RankChip extends StatelessWidget {
  final String text;
  final Color color;
  const _RankChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EloChip extends StatelessWidget {
  final int elo;
  const _EloChip({required this.elo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$elo Elo',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  final PlayStyle style;
  const _StyleChip({required this.style});

  @override
  Widget build(BuildContext context) {
    final c = style.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        style.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }
}

class _StarsBadge extends StatelessWidget {
  final int stars;
  final Color color;
  const _StarsBadge({required this.stars, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Icon(
            i < stars ? Icons.star : Icons.star_border,
            size: 11,
            color: i < stars ? Colors.amber : Colors.white54,
          );
        }),
      ),
    );
  }
}

class _PremiumPill extends StatelessWidget {
  const _PremiumPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final BotProfile bot;
  final bool available;

  const _Avatar({required this.bot, required this.available});

  /// Duolingo-style gradient fallback when the avatar asset is missing.
  Widget _gradientFallback() {
    final baseColor = available ? bot.color : Colors.grey;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: 0.85),
            baseColor.withValues(alpha: 0.40),
          ],
        ),
      ),
      child: Center(
        child: Text(
          bot.name.isNotEmpty ? bot.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: available ? 1.0 : 0.55),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        bot.avatarAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _gradientFallback(),
      ),
    );
  }
}

/// Chess.com-style detail sheet: shows bot info, strength, taunt, a Practice
/// Mode toggle, then the board-size picker.
class _BotDetailSheet extends StatefulWidget {
  final BotProfile bot;

  const _BotDetailSheet({required this.bot});

  @override
  State<_BotDetailSheet> createState() => _BotDetailSheetState();
}

class _BotDetailSheetState extends State<_BotDetailSheet> {
  bool _practiceMode = false;

  void _startGame(BuildContext context, int size) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameBoardScreen(
          boardSize: size,
          isComputerMode: true,
          aiDifficulty: widget.bot.legacyDifficulty ?? AIDifficulty.hard,
          opponentName: widget.bot.name,
          opponentRank: widget.bot.displayRank,
          opponentAvatarPath: widget.bot.avatarAsset,
          botProfile: widget.bot,
          practiceMode: _practiceMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _Avatar(bot: widget.bot, available: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bot.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _RankChip(
                          text: widget.bot.displayRank,
                          color: widget.bot.color,
                        ),
                        const SizedBox(width: 6),
                        _EloChip(elo: widget.bot.elo),
                        const SizedBox(width: 6),
                        _StarsBadge(
                          stars: widget.bot.stars,
                          color: widget.bot.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _StyleChip(style: widget.bot.style),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.bot.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '"${widget.bot.taunt(BotEvent.greet)}"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 14),
          // ── Practice Mode toggle ──────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _practiceMode
                  ? Colors.green.withValues(alpha: 0.09)
                  : cs.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _practiceMode
                    ? Colors.green.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              title: Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 15,
                    color:
                        _practiceMode ? Colors.green.shade700 : cs.onSurface,
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Practice Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              subtitle: const Text(
                'Best move shown after each turn · result is 1 ★',
                style: TextStyle(fontSize: 11),
              ),
              value: _practiceMode,
              onChanged: (v) => setState(() => _practiceMode = v),
              activeThumbColor: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose board size',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final size in [9, 13, 19])
                _SizeButton(
                  size: size,
                  color: widget.bot.color,
                  onTap: () => _startGame(context, size),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final int size;
  final Color color;
  final VoidCallback onTap;
  const _SizeButton({
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(86, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        '$size×$size',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}
