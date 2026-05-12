import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../services/ai/go_ai_service.dart';
import '../services/ai/katago_process_service.dart';
import 'game_board_screen.dart';

/// A single bot profile shown on the Bots screen.
class _BotProfile {
  final String name;
  final String rank;
  final String description;
  final AIDifficulty? difficulty; // null = not yet available
  final IconData icon;
  final Color color;

  /// Asset path to the bot avatar image, e.g. 'assets/avatars/panda.png'.
  final String avatarAsset;

  const _BotProfile({
    required this.name,
    required this.rank,
    required this.description,
    required this.icon,
    required this.color,
    required this.avatarAsset,
    this.difficulty,
  });
}

const _bots = <_BotProfile>[
  _BotProfile(
    name: 'Panda',
    rank: '30k – 20k',
    description:
        'Perfect for absolute beginners. Plays random moves with occasional captures.',
    difficulty: AIDifficulty.easy,
    icon: Icons.sentiment_very_satisfied,
    color: Color(0xFF4CAF50),
    avatarAsset: 'assets/avatars/panda.png',
  ),
  _BotProfile(
    name: 'Tanuki',
    rank: '15k – 10k',
    description:
        'Understands basic captures and territory. A good stepping stone.',
    difficulty: AIDifficulty.easy,
    icon: Icons.park,
    color: Color(0xFF8BC34A),
    avatarAsset: 'assets/avatars/tanuki.png',
  ),
  _BotProfile(
    name: 'Kitsune',
    rank: '5k – 1k',
    description:
        'Plays solid territory moves and will punish overplays. Challenging for club players.',
    difficulty: AIDifficulty.medium,
    icon: Icons.auto_awesome,
    color: Color(0xFFFF9800),
    avatarAsset: 'assets/avatars/kitsune.png',
  ),
  _BotProfile(
    name: 'Tengu',
    rank: '1d – 3d',
    description:
        'Strong reading, efficient shapes, aggressive fighting. Serious opposition.',
    difficulty: AIDifficulty.hard,
    icon: Icons.whatshot,
    color: Color(0xFFE91E63),
    avatarAsset: 'assets/avatars/tengu.png',
  ),
  _BotProfile(
    name: 'KataGo',
    rank: '9d+',
    description:
        'Neural-network engine at professional strength. Integration coming soon — stay tuned.',
    difficulty: null, // not yet available
    icon: Icons.smart_toy,
    color: Color(0xFF7C4DFF),
    avatarAsset: 'assets/avatars/katago.png',
  ),
];

/// Screen listing AI bots at progressively higher strength levels.
/// Tapping a bot opens a board-size picker, then starts a game.
class BotsScreen extends StatelessWidget {
  const BotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kataGoReady = context.watch<KataGoProcessService>().isAvailable;
    return Scaffold(
      appBar: AppBar(title: Text(l.playVsBotTitle), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: _bots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final bot = _bots[i];
          final isKataGo = bot.name == 'KataGo';
          return _BotCard(bot: bot, forceAvailable: isKataGo && kataGoReady);
        },
      ),
    );
  }
}

class _BotCard extends StatelessWidget {
  final _BotProfile bot;
  /// When true, overrides `bot.difficulty == null` so the card is enabled.
  final bool forceAvailable;

  const _BotCard({required this.bot, this.forceAvailable = false});

  @override
  Widget build(BuildContext context) {
    final available = bot.difficulty != null || forceAvailable;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: available ? () => _pickBoardSize(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(bot: bot, available: available),
              const SizedBox(width: 16),
              Expanded(child: _Info(bot: bot)),
              if (available)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                )
              else
                _ComingSoonChip(),
            ],
          ),
        ),
      ),
    );
  }

  void _pickBoardSize(BuildContext context) {
    // KataGo may have null difficulty but be enabled via forceAvailable.
    final effectiveDifficulty = bot.difficulty ?? AIDifficulty.hard;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          _BoardSizePicker(bot: bot, effectiveDifficulty: effectiveDifficulty),
    );
  }
}

class _Avatar extends StatelessWidget {
  final _BotProfile bot;
  final bool available;

  const _Avatar({required this.bot, required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: available
            ? bot.color.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        bot.avatarAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          bot.icon,
          size: 30,
          color: available ? bot.color : Colors.grey,
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final _BotProfile bot;
  const _Info({required this.bot});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              bot.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bot.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                bot.rank,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: bot.difficulty != null ? bot.color : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          bot.description,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ComingSoonChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l.comingSoon,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

class _BoardSizePicker extends StatelessWidget {
  final _BotProfile bot;
  final AIDifficulty effectiveDifficulty;

  const _BoardSizePicker({
    required this.bot,
    required this.effectiveDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Play vs ${bot.name}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose a board size to start',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final size in [9, 13, 19])
                _SizeButton(
                  size: size,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameBoardScreen(
                          boardSize: size,
                          isComputerMode: true,
                          aiDifficulty: effectiveDifficulty,
                        ),
                      ),
                    );
                  },
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
  final VoidCallback onTap;
  const _SizeButton({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(80, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        '$size×$size',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
