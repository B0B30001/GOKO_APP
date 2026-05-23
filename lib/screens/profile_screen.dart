import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/user.dart';
import 'package:zaibal/services/ogs_service.dart';
import 'package:zaibal/services/user_service.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/services/progress_service.dart';
import 'package:zaibal/services/subscription_service.dart';
import 'package:zaibal/screens/paywall_screen.dart';
import 'package:zaibal/screens/analysis_screen.dart';
import 'package:zaibal/utils/ogs_rank.dart';
import 'package:zaibal/widgets/game_record_tile.dart';
import 'package:zaibal/widgets/rating_sparkline.dart';
import 'package:zaibal/widgets/win_loss_donut.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_shell.dart';

/// Chess.com-style profile: header, 2×2 stats grid, win/loss donut, rating
/// sparkline, recent games list. Premium badges + paywall route remain.
class ProfileScreen extends StatelessWidget {
  /// When false the screen is hosted inside [AppShell]; suppress per-screen nav.
  final bool showBottomNav;

  const ProfileScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().currentUser;
    final history = context.watch<MatchHistoryService>();
    final progress = context.watch<ProgressService>();
    final subscription = context.watch<SubscriptionService>();
    final ogs = context.watch<OgsService>();
    final agg = history.aggregate();

    // Prefer OGS identity when signed in — that's the user's "public" profile.
    final displayName = ogs.isAuthenticated && ogs.username != null
        ? ogs.username!
        : (user?.displayName ?? 'Player');
    final rank = ogs.isAuthenticated
        ? OgsRank.bestLabel(rankString: ogs.rankString, rating: ogs.rating)
        : user?.rank;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: user == null
                    ? null
                    : () => _showEditDialog(context, user),
                tooltip: AppLocalizations.of(context).editProfile,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(displayName),
              background: _buildHeader(context, user, subscription, ogs, rank),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(context, progress, agg),
                const SizedBox(height: 16),
                _buildDonutCard(context, agg),
                const SizedBox(height: 16),
                _buildSparklineCard(context, progress),
                const SizedBox(height: 16),
                if (!subscription.isPremium) _buildPremiumCta(context),
                _buildRecentGamesPanel(context, history),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(
              currentIndex: 3,
              onTap: (index) {
                if (index == 3) return;
                appShellTabIndex.value = index;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            )
          : null,
    );
  }

  Widget _buildHeader(
    BuildContext context,
    User? user,
    SubscriptionService subscription,
    OgsService ogs,
    String? rank,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
              backgroundImage: user?.avatarPath != null
                  ? AssetImage(user!.avatarPath!)
                  : null,
              child: user?.avatarPath == null
                  ? Icon(Icons.person, size: 44, color: cs.primary)
                  : null,
            ),
            const SizedBox(height: 8),
            if (rank != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            if (subscription.isPremium) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD45A), Color(0xFFFF9F1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'GOKO ${AppLocalizations.of(context).premium}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 2x2 stats grid ───────────────────────────────────────────────────────

  Widget _buildStatsGrid(
    BuildContext context,
    ProgressService progress,
    MatchAggregate agg,
  ) {
    final winRate = agg.total == 0
        ? '—'
        : '${(agg.winRate * 100).toStringAsFixed(0)}%';
    final l = AppLocalizations.of(context);
    final stats = [
      _StatData(l.games, '${agg.total}', Icons.sports_esports),
      _StatData(l.winRate, winRate, Icons.emoji_events),
      _StatData(l.streak, '${progress.streak}', Icons.local_fire_department),
      _StatData(l.puzzleRating, '${progress.puzzleRating}', Icons.insights),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => _StatTile(data: stats[i]),
    );
  }

  // ── donut card ───────────────────────────────────────────────────────────

  Widget _buildDonutCard(BuildContext context, MatchAggregate agg) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Win / Loss',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                WinLossDonut(
                  wins: agg.wins,
                  losses: agg.losses,
                  draws: agg.draws,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                        color: Colors.green,
                        label: 'Wins',
                        value: agg.wins,
                      ),
                      const SizedBox(height: 6),
                      _LegendRow(
                        color: Colors.red,
                        label: 'Losses',
                        value: agg.losses,
                      ),
                      const SizedBox(height: 6),
                      _LegendRow(
                        color: Colors.grey,
                        label: 'Draws',
                        value: agg.draws,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        agg.total == 0
                            ? 'Play games to see your split here.'
                            : '${(agg.winRate * 100).toStringAsFixed(0)}% win rate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── sparkline card ───────────────────────────────────────────────────────

  Widget _buildSparklineCard(BuildContext context, ProgressService progress) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).puzzleRating,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${progress.puzzleRating}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RatingSparkline(ratings: progress.ratingHistory),
          ],
        ),
      ),
    );
  }

  // ── premium CTA (free users only) ────────────────────────────────────────

  Widget _buildPremiumCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: const Icon(Icons.workspace_premium, color: Colors.amber),
          title: Text(AppLocalizations.of(context).unlockPremium),
          subtitle: Text(
            '${AppLocalizations.of(context).unlimitedPuzzles}, ${AppLocalizations.of(context).postGameAnalysis}, ${AppLocalizations.of(context).profileFlair}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          ),
        ),
      ),
    );
  }

  // ── recent games ─────────────────────────────────────────────────────────

  /// Always-visible panel of the last 10 games — chess.com pattern.
  /// Single Card with header strip + tile list inside, so the "this is your
  /// games" hierarchy is obvious without any expand/tap.
  Widget _buildRecentGamesPanel(
    BuildContext context,
    MatchHistoryService history,
  ) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final records = history.records.take(10).toList();
    final totalCount = history.records.length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.45),
            ),
            child: Row(
              children: [
                Icon(Icons.history, color: cs.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    totalCount > 0
                        ? '${l.gameHistory} · $totalCount'
                        : l.gameHistory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (totalCount > 10)
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    child: Text(l.seeAll),
                  ),
              ],
            ),
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l.noGamesYet,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: records.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (_, i) => GameRecordTile(
                record: records[i],
                compact: true,
                onTap: () => _openRecord(context, records[i]),
              ),
            ),
        ],
      ),
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

  Future<void> _showEditDialog(BuildContext context, User user) async {
    final controller = TextEditingController(text: user.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).editProfile),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && context.mounted) {
      await context.read<UserService>().updateProfile(displayName: newName);
    }
  }
}

// ── small helpers ──────────────────────────────────────────────────────────

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  const _StatData(this.label, this.value, this.icon);
}

class _StatTile extends StatelessWidget {
  final _StatData data;

  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(data.icon, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
