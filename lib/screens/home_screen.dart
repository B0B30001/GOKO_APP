// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/login_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/menu_fab.dart';
import '../widgets/app_shell.dart';
import '../widgets/game_record_tile.dart';
import '../widgets/goko_logo.dart';
import '../services/ogs_service.dart';
import '../services/match_history_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import './game_board_screen.dart';
import './online/online_lobby_screen.dart';
import './analysis_screen.dart';
import './paywall_screen.dart';
import '../services/ai/go_ai_service.dart';

/// Chess.com-inspired home: big Play CTA, quick-start strip, stats row, and a
/// recent-games feed pulling from local history (AI + local 2P + OGS-synced).
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
    final history = context.watch<MatchHistoryService>();
    final progress = context.watch<ProgressService>();
    final agg = history.aggregate();
    final recent = history.records.take(5).toList();

    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.home),
      floatingActionButton: showBottomNav ? const MenuFab() : null,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context) : null,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, ogs),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPlayCta(context),
                const SizedBox(height: 16),
                _buildQuickStart(context),
                const SizedBox(height: 24),
                _buildStatsRow(context, progress, agg),
                const SizedBox(height: 24),
                _buildRecentGamesHeader(context),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const _RecentGamesEmptyState()
                else
                  ...recent.map((r) => _RecentGameRow(record: r)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, OgsService ogs) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 110,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const GokoLogo(
        size: 28,
        showWordmark: true,
        wordmarkColor: Colors.white,
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          tooltip: 'Menu',
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          tooltip: 'Profile',
          onPressed: () {
            appShellTabIndex.value = 3;
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
        ),
      ],
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
              padding: const EdgeInsets.fromLTRB(56, 8, 56, 8),
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

  // ── play CTA ─────────────────────────────────────────────────────────────

  Widget _buildPlayCta(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: cs.primary.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showGameModes(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).play,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Friend, Computer, or Online',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── quick start ──────────────────────────────────────────────────────────

  Widget _buildQuickStart(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStartCard(
            label: 'Daily Puzzle',
            icon: Icons.stars,
            tint: Colors.amber,
            onTap: () => Navigator.pushNamed(context, '/puzzles'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStartCard(
            label: 'Play Bot',
            icon: Icons.smart_toy_rounded,
            tint: Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/bots'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStartCard(
            label: 'Lessons',
            icon: Icons.school_rounded,
            tint: Colors.blue,
            onTap: () {
              appShellTabIndex.value = 1;
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  // ── stats row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(
    BuildContext context,
    ProgressService progress,
    MatchAggregate agg,
  ) {
    final winRate = agg.total == 0
        ? '—'
        : '${(agg.winRate * 100).toStringAsFixed(0)}%';
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Puzzle Rating',
            value: '${progress.puzzleRating}',
            icon: Icons.insights,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Games',
            value: '${agg.total}',
            icon: Icons.sports_esports,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Win Rate',
            value: winRate,
            icon: Icons.emoji_events,
          ),
        ),
      ],
    );
  }

  // ── recent games ─────────────────────────────────────────────────────────

  Widget _buildRecentGamesHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context).recentGames,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/history'),
          child: Text(AppLocalizations.of(context).seeAll),
        ),
      ],
    );
  }

  // ── bottom nav ───────────────────────────────────────────────────────────

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

  // ── game-mode bottom sheet ───────────────────────────────────────────────

  void _showGameModes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Game Mode',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _ModeButton(
                title: 'vs Computer',
                subtitle: 'Pick a bot — offline AI',
                icon: Icons.smart_toy_rounded,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.pushNamed(context, '/bots');
                },
              ),
              const SizedBox(height: 10),
              _ModeButton(
                title: 'vs Friend',
                subtitle: 'Same device, pass-and-play',
                icon: Icons.people_alt_rounded,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showBoardSize(context, isComputer: false);
                },
              ),
              const SizedBox(height: 10),
              _ModeButton(
                title: 'vs Online',
                subtitle: 'Live games via OGS',
                icon: Icons.wifi_rounded,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final ogsService = Provider.of<OgsService>(
                    context,
                    listen: false,
                  );
                  if (!ogsService.isAuthenticated) {
                    await showLoginDialog(context);
                  } else if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnlineLobbyScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBoardSize(BuildContext context, {required bool isComputer}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
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
            const SizedBox(height: 20),
            for (final size in [9, 13, 19]) ...[
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(sheetCtx);
                  if (isComputer) {
                    final difficulty = await showDialog<AIDifficulty>(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: Text(
                          AppLocalizations.of(context).selectDifficulty,
                        ),
                        children: AIDifficulty.values
                            .map(
                              (d) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(ctx, d),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Text(d.label),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                    if (difficulty == null || !context.mounted) return;
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameBoardScreen(boardSize: size),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('$size×$size'),
              ),
              if (size != 19) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ── quick-start card ────────────────────────────────────────────────────────

class _QuickStartCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  const _QuickStartCard({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: tint.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: tint),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── stat tile ───────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          appShellTabIndex.value = 3;
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 22, color: cs.primary),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── mode button ─────────────────────────────────────────────────────────────

class _ModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ── recent games ────────────────────────────────────────────────────────────

class _RecentGameRow extends StatelessWidget {
  final MatchRecord record;

  const _RecentGameRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return GameRecordTile(
      record: record,
      onTap: () => _openRecord(context, record),
    );
  }

  void _openRecord(BuildContext context, MatchRecord r) {
    final entitlements = context.read<SubscriptionService>().entitlements;
    if (!entitlements.postGameAnalysis) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalysisScreen(matchId: r.id)),
    );
  }
}

class _RecentGamesEmptyState extends StatelessWidget {
  const _RecentGamesEmptyState();

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
