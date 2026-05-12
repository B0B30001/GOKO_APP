import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/user.dart';
import 'package:zaibal/services/user_service.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/services/subscription_service.dart';
import 'package:zaibal/screens/paywall_screen.dart';
import 'package:zaibal/screens/analysis_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  /// When false the screen is hosted inside [AppShell]; suppress per-screen nav.
  final bool showBottomNav;

  const ProfileScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().currentUser;
    final history = context.watch<MatchHistoryService>();
    final subscription = context.watch<SubscriptionService>();
    final agg = history.aggregate();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: user == null
                    ? null
                    : () => _showEditDialog(context, user),
                tooltip: 'Edit profile',
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreMenu(context),
                tooltip: 'More',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user?.displayName ?? 'Player'),
              background: _buildHeader(context, user, subscription),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsCard(context, agg, user),
                _buildPremiumSection(context, subscription),
                _buildRecentGames(context, history),
              ],
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
            if (user?.rank != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user!.rank!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            if (subscription.isPremium) ...[
              const SizedBox(height: 4),
              const Chip(
                label: Text('Premium'),
                avatar: Icon(Icons.workspace_premium, size: 16),
                backgroundColor: Colors.amberAccent,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, MatchAggregate agg, User? user) {
    final winRatePct = agg.total == 0
        ? '—'
        : '${(agg.winRate * 100).toStringAsFixed(0)}%';
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).statistics,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Puzzle rating',
                  user?.puzzleRating.toString() ?? '—',
                ),
                _buildStatItem(context, 'Games', agg.total.toString()),
                _buildStatItem(context, 'Win rate', winRatePct),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Wins', agg.wins.toString()),
                _buildStatItem(context, 'Losses', agg.losses.toString()),
                _buildStatItem(context, 'Draws', agg.draws.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildPremiumSection(
    BuildContext context,
    SubscriptionService subscription,
  ) {
    if (subscription.entitlements.profileFlair) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListTile(
          leading: const Icon(Icons.workspace_premium, color: Colors.amber),
          title: const Text('Profile flair unlocked'),
          subtitle: const Text('Customize badges and avatar borders'),
          onTap: () {
            // TODO: open flair customizer (premium-only)
          },
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.lock_outline),
        title: const Text('Unlock Premium'),
        subtitle: const Text(
          'Unlimited puzzles, post-game analysis, profile flair',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        ),
      ),
    );
  }

  Widget _buildRecentGames(BuildContext context, MatchHistoryService history) {
    final records = history.records;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Match history',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('No games yet — finish one to see it here.'),
            )
          else
            for (final r in records.take(10))
              ListTile(
                leading: _resultAvatar(r.result),
                title: Text('vs ${r.opponent}'),
                subtitle: Text(
                  '${r.boardSize}×${r.boardSize} • ${_relative(r.playedAt)}',
                ),
                trailing: Text(
                  _resultLabel(r.result),
                  style: TextStyle(
                    color: _resultColor(r.result),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  final entitlements = context
                      .read<SubscriptionService>()
                      .entitlements;
                  if (!entitlements.postGameAnalysis) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalysisScreen(matchId: r.id),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  CircleAvatar _resultAvatar(MatchResult r) {
    switch (r) {
      case MatchResult.win:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.arrow_upward, color: Colors.white),
        );
      case MatchResult.loss:
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.arrow_downward, color: Colors.white),
        );
      case MatchResult.draw:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.drag_handle, color: Colors.white),
        );
      case MatchResult.unfinished:
        return const CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.pause, color: Colors.white),
        );
    }
  }

  Color _resultColor(MatchResult r) => switch (r) {
    MatchResult.win => Colors.green,
    MatchResult.loss => Colors.red,
    MatchResult.draw => Colors.grey,
    MatchResult.unfinished => Colors.blueGrey,
  };

  String _resultLabel(MatchResult r) => switch (r) {
    MatchResult.win => 'Win',
    MatchResult.loss => 'Loss',
    MatchResult.draw => 'Draw',
    MatchResult.unfinished => '—',
  };

  String _relative(DateTime then) {
    final diff = DateTime.now().difference(then);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  Future<void> _showEditDialog(BuildContext context, User user) async {
    final controller = TextEditingController(text: user.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && context.mounted) {
      await context.read<UserService>().updateProfile(displayName: newName);
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
