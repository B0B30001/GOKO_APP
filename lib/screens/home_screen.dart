// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/login_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/menu_fab.dart';
import '../widgets/app_shell.dart';
import '../services/ogs_service.dart';
import '../services/match_history_service.dart';
import './game_board_screen.dart';
import './online/online_lobby_screen.dart';
import './online/online_game_screen.dart';
import '../services/ai/go_ai_service.dart';

class HomeScreen extends StatelessWidget {
  final Function onThemeToggle;

  /// When [showBottomNav] is false the screen is rendered inside [AppShell];
  /// the shell provides the NavigationBar, so we suppress the per-screen one.
  final bool showBottomNav;

  const HomeScreen({
    required this.onThemeToggle,
    this.showBottomNav = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ogs = context.watch<OgsService>();
    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.home),
      floatingActionButton: showBottomNav ? const MenuFab() : null,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context) : null,
      body: CustomScrollView(
        slivers: [
          // ── Slimmer app bar with greeting ──────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 110,
            automaticallyImplyLeading: false,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Menu',
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(ogs),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ogs.username != null)
                          Text(
                            ogs.rankString ?? 'Unranked',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Play strip: big button + inline board size chips
                  _buildPlayStrip(context),
                  const SizedBox(height: 24),
                  // Daily puzzle card
                  _buildDailyPuzzleCard(context),
                  const SizedBox(height: 24),
                  // 2-col feature grid
                  _buildFeatureGrid(context),
                  const SizedBox(height: 24),
                  // Recent games
                  _buildRecentHistory(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(OgsService ogs) {
    final hour = DateTime.now().hour;
    final name = ogs.username;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return name != null ? '$greeting, $name!' : '$greeting!';
  }

  Widget _buildPlayStrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.play_arrow_rounded, size: 26),
          label: Text(
            AppLocalizations.of(context).play,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _showGameModes(context),
        ),
        const SizedBox(height: 10),
        // Quick-start board-size chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final size in [9, 13, 19]) ...[
              _QuickSizeChip(
                size: size,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameBoardScreen(boardSize: size),
                    ),
                  );
                },
              ),
              if (size != 19) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDailyPuzzleCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/puzzles'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mini board thumbnail
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCB468), // classic board tan
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomPaint(painter: _MiniBoardThumbPainter()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          'Daily Puzzle',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: cs.onPrimaryContainer.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solve today\'s challenge',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to solve →',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final items = [
      _GridItem(
        label: l.lessons,
        icon: Icons.school_rounded,
        color: Colors.blue,
        onTap: () {
          appShellTabIndex.value = 1;
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
      _GridItem(
        label: l.puzzles,
        icon: Icons.grid_view_rounded,
        color: Colors.green,
        onTap: () => Navigator.pushNamed(context, '/puzzles'),
      ),
      _GridItem(
        label: l.playVsBot,
        icon: Icons.smart_toy_rounded,
        color: Colors.orange,
        onTap: () => Navigator.pushNamed(context, '/bots'),
      ),
      _GridItem(
        label: l.vsOnline,
        icon: Icons.wifi_rounded,
        color: Colors.purple,
        onTap: () async {
          final ogsService = Provider.of<OgsService>(context, listen: false);
          if (ogsService.isAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OnlineLobbyScreen()),
            );
          } else {
            await showLoginDialog(context);
          }
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick access',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: items
              .map((item) => _FeatureGridCell(item: item, cs: cs))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    final history = context.watch<MatchHistoryService>();
    final records = history.records.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).recentGames,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          _RecentGamesEmptyState()
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _HistoryCard(item: _historyItemFor(record)),
            ),
          ),
      ],
    );
  }

  /// Converts a [MatchRecord] to the [_HistoryItem] shape consumed by
  /// [_HistoryCard]. Centralizes the formatting (score delta, time-ago).
  _HistoryItem _historyItemFor(MatchRecord record) {
    final win = record.result == MatchResult.win;
    final delta = switch (record.result) {
      MatchResult.win => '+',
      MatchResult.loss => '-',
      MatchResult.draw => '=',
      MatchResult.unfinished => '…',
    };
    return _HistoryItem(
      'vs ${record.opponent}',
      '${record.boardSize}×${record.boardSize}',
      delta,
      win,
      _timeAgo(record.playedAt),
    );
  }

  String _timeAgo(DateTime then) {
    final diff = DateTime.now().difference(then);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) return;
        appShellTabIndex.value = index;
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
    );
  }

  void _showGameModes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Game Mode',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildModeButton(
              context,
              'vs Computer',
              Icons.computer,
              () => _showBoardSize(context, isComputer: true),
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              'vs Friend (Same Device)',
              Icons.people,
              () => _showBoardSize(context, isComputer: false),
            ),
            const SizedBox(height: 16),
            _buildModeButton(context, 'vs Online', Icons.wifi, () async {
              Navigator.pop(context); // Close the play mode dialog first

              final ogsService = Provider.of<OgsService>(
                context,
                listen: false,
              );

              if (!ogsService.isAuthenticated) {
                // Show login dialog
                await showLoginDialog(context);
              } else {
                // Already logged in, go to lobby
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnlineLobbyScreen(),
                  ),
                );
              }
            }),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              'vs AI (Online – KataGo)',
              Icons.smart_toy_outlined,
              () => _showBotPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBotPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _BotPickerSheet(
        onPick: (level, boardSize) async {
          Navigator.pop(sheetCtx);
          final ogsService = Provider.of<OgsService>(context, listen: false);
          if (!ogsService.isAuthenticated) {
            await showLoginDialog(context);
            if (!ogsService.isAuthenticated) return;
          }
          if (!context.mounted) return;
          _launchBotChallenge(context, ogsService, level, boardSize);
        },
      ),
    );
  }

  void _launchBotChallenge(
    BuildContext context,
    OgsService ogsService,
    String level,
    int boardSize,
  ) async {
    final username = OgsService.botUsernameForLevel(level);
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Finding bot…'),
          ],
        ),
      ),
    );
    final botId = await ogsService.findBotId(username);
    if (!context.mounted) return;
    Navigator.pop(context); // dismiss loading dialog

    if (botId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bot "$username" is currently offline. Try again later.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating game…'),
          ],
        ),
      ),
    );
    final gameId = await ogsService.challengeBot(botId, boardSize);
    if (!context.mounted) return;
    Navigator.pop(context); // dismiss loading dialog

    if (gameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create bot game. Please try again.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineGameScreen(gameId: gameId.toString()),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDisabled = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showBoardSize(BuildContext context, {required bool isComputer}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Board Size',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildSizeButton(context, '9×9', 9, isComputer: isComputer),
            const SizedBox(height: 16),
            _buildSizeButton(context, '13×13', 13, isComputer: isComputer),
            const SizedBox(height: 16),
            _buildSizeButton(context, '19×19', 19, isComputer: isComputer),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeButton(
    BuildContext context,
    String label,
    int size, {
    required bool isComputer,
  }) {
    return ElevatedButton(
      onPressed: () async {
        if (isComputer) {
          final difficulty = await showDialog<AIDifficulty>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: Text(AppLocalizations.of(context).selectDifficulty),
              children: AIDifficulty.values
                  .map(
                    (d) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, d),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(d.label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
          if (difficulty == null) return;
          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameBoardScreen(
                boardSize: size,
                isComputerMode: true,
                aiDifficulty: difficulty,
              ),
            ),
          );
        } else {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GameBoardScreen(boardSize: size)),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

/// Friendly placeholder shown on the home screen when [MatchHistoryService]
/// has no records yet. Replaces the prior 3-fake-game hardcoded list.
class _RecentGamesEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.sports_esports,
              size: 28,
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Play your first game — it will show up here.',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String title;
  final String board;
  final String delta;
  final bool win;
  final String timeAgo;

  _HistoryItem(this.title, this.board, this.delta, this.win, this.timeAgo);
}

// Separate widget for history cards to avoid rebuilds
class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.win ? Colors.green : Colors.red,
          child: Icon(
            item.win ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(item.title),
        subtitle: Text('${item.board} • ${item.timeAgo}'),
        trailing: Text(
          item.delta,
          style: TextStyle(
            color: item.win ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/history');
        },
      ),
    );
  }
}

// ── Helper data class ──────────────────────────────────────────────────────

class _GridItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GridItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ── Feature grid cell ──────────────────────────────────────────────────────

class _FeatureGridCell extends StatelessWidget {
  final _GridItem item;
  final ColorScheme cs;

  const _FeatureGridCell({required this.item, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: item.color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 28, color: item.color),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: item.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick size chip ────────────────────────────────────────────────────────

class _QuickSizeChip extends StatelessWidget {
  final int size;
  final VoidCallback onTap;

  const _QuickSizeChip({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('$size×$size'),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── Mini board thumbnail painter ──────────────────────────────────────────

class _MiniBoardThumbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const lines = 5;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..strokeWidth = 0.8;

    final step = size.width / (lines + 1);
    for (var i = 1; i <= lines; i++) {
      final pos = step * i;
      canvas.drawLine(
        Offset(pos, step),
        Offset(pos, size.height - step),
        paint,
      );
      canvas.drawLine(Offset(step, pos), Offset(size.width - step, pos), paint);
    }

    // Draw a few example stones
    final black = Paint()..color = Colors.black87;
    final white = Paint()..color = Colors.white;
    final border = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    void stone(double x, double y, Paint fill) {
      final r = step * 0.38;
      canvas.drawCircle(Offset(x, y), r, fill);
      if (fill.color == Colors.white) {
        canvas.drawCircle(Offset(x, y), r, border);
      }
    }

    stone(step * 2, step * 2, black);
    stone(step * 3, step * 2, white);
    stone(step * 2, step * 3, white);
    stone(step * 3, step * 3, black);
    stone(step * 4, step * 2, black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom sheet that lets the user pick bot level + board size before
/// launching a challenge against an OGS bot.
class _BotPickerSheet extends StatefulWidget {
  final void Function(String level, int boardSize) onPick;

  const _BotPickerSheet({required this.onPick});

  @override
  State<_BotPickerSheet> createState() => _BotPickerSheetState();
}

class _BotPickerSheetState extends State<_BotPickerSheet> {
  String _level = 'medium';
  int _size = 9;

  static const _levels = [
    ('easy', 'Easy', 'GnuGo — great for beginners'),
    ('medium', 'Medium', 'Leela Zero — intermediate'),
    ('hard', 'Hard', 'KataGo — strong AI'),
  ];
  static const _sizes = [9, 13, 19];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Play vs AI Online',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Powered by OGS bots (requires login)',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text('Difficulty', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...(_levels.map((rec) {
              final (key, label, desc) = rec;
              return RadioListTile<String>(
                value: key,
                groupValue: _level,
                title: Text(label),
                subtitle: Text(desc),
                onChanged: (v) => setState(() => _level = v!),
                dense: true,
              );
            })),
            const SizedBox(height: 12),
            Text('Board size', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: _sizes
                  .map(
                    (s) => ButtonSegment<int>(value: s, label: Text('$s×$s')),
                  )
                  .toList(),
              selected: {_size},
              onSelectionChanged: (s) => setState(() => _size = s.first),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => widget.onPick(_level, _size),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Game', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
