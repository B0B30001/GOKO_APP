import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../models/puzzle.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/menu_fab.dart';
import '../widgets/app_shell.dart';
import '../widgets/fast_game_board.dart';
import '../services/daily_puzzle_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import 'puzzle_screen.dart';
import 'puzzle_category_screen.dart';
import 'paywall_screen.dart';

/// Chess.com-style puzzles hub: rating + streak header, daily-set strip
/// (5 puzzles/day with swap), and a 2-column category grid.
class PuzzlesHubScreen extends StatefulWidget {
  /// When false the screen is hosted inside [AppShell]; suppress per-screen nav.
  final bool showBottomNav;

  const PuzzlesHubScreen({super.key, this.showBottomNav = true});

  @override
  State<PuzzlesHubScreen> createState() => _PuzzlesHubScreenState();
}

class _PuzzlesHubScreenState extends State<PuzzlesHubScreen> {
  late final DailyPuzzleService _daily;

  @override
  void initState() {
    super.initState();
    _daily = DailyPuzzleService();
    // Refresh-on-pop so solving a daily puzzle updates the strip.
    _daily.addListener(_onDailyChanged);
  }

  @override
  void dispose() {
    _daily.removeListener(_onDailyChanged);
    super.dispose();
  }

  void _onDailyChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.puzzles),
      appBar: AppBar(title: Text(l.puzzles), centerTitle: true),
      floatingActionButton: widget.showBottomNav ? const MenuFab() : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Consumer<ProgressService>(
            builder: (context, progress, _) => _HeaderCard(
              puzzleRating: progress.puzzleRating,
              streak: progress.streak,
              solvedToday: progress.solvedCount,
            ),
          ),
          const SizedBox(height: 16),
          ChangeNotifierProvider.value(
            value: _daily,
            child: const _DailySetCard(),
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: l.categories, onTap: null),
          const SizedBox(height: 12),
          _CategoryGrid(categories: _categories()),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavBar(
              currentIndex: 2,
              onTap: (index) {
                if (index == 2) return;
                appShellTabIndex.value = index;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            )
          : null,
    );
  }

  static List<_CategorySpec> _categories() => const [
    _CategorySpec('Captures', Icons.close, Colors.redAccent),
    _CategorySpec('Liberties', Icons.blur_circular, Colors.lightBlueAccent),
    _CategorySpec('Life & Death', Icons.psychology, Colors.purpleAccent),
    _CategorySpec('Ko Basics', Icons.loop, Colors.amber),
    _CategorySpec('Tesuji', Icons.auto_fix_high, Colors.tealAccent),
    _CategorySpec('Ladder', Icons.linear_scale, Colors.cyanAccent),
    _CategorySpec('Snapback', Icons.sync, Colors.deepOrangeAccent),
    _CategorySpec('Connect', Icons.hub, Colors.greenAccent),
  ];
}

class _HeaderCard extends StatelessWidget {
  final int puzzleRating;
  final int streak;
  final int solvedToday;

  const _HeaderCard({
    required this.puzzleRating,
    required this.streak,
    required this.solvedToday,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _Stat(
              icon: Icons.trending_up,
              value: '$puzzleRating',
              label: AppLocalizations.of(context).rating,
              color: cs.primary,
            ),
            _Divider(color: cs.onSurface.withValues(alpha: 0.12)),
            _Stat(
              icon: Icons.local_fire_department,
              value: '$streak',
              label: AppLocalizations.of(context).dayStreakLabel,
              color: Colors.orange,
            ),
            _Divider(color: cs.onSurface.withValues(alpha: 0.12)),
            _Stat(
              icon: Icons.check_circle,
              value: '$solvedToday',
              label: AppLocalizations.of(context).today,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: color);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Chess.com-style five-puzzles-per-day strip. Consumes [DailyPuzzleService]
/// via Provider so solve / swap calls trigger a rebuild without prop drilling.
class _DailySetCard extends StatelessWidget {
  const _DailySetCard();

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DailyPuzzleService>();
    return FutureBuilder<_DailySetSnapshot>(
      future: _snapshot(svc),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _DailySetBody(snapshot: snapshot.data!, service: svc);
      },
    );
  }

  Future<_DailySetSnapshot> _snapshot(DailyPuzzleService svc) async {
    final puzzles = await svc.todaysPuzzles();
    final solved = await svc.solvedIds();
    final swapsLeft = await svc.remainingSwaps();
    return _DailySetSnapshot(
      puzzles: puzzles,
      solvedIds: solved,
      swapsLeft: swapsLeft,
    );
  }
}

class _DailySetSnapshot {
  final List<Puzzle> puzzles;
  final Set<String> solvedIds;
  final int swapsLeft;

  const _DailySetSnapshot({
    required this.puzzles,
    required this.solvedIds,
    required this.swapsLeft,
  });
}

class _DailySetBody extends StatelessWidget {
  final _DailySetSnapshot snapshot;
  final DailyPuzzleService service;

  const _DailySetBody({required this.snapshot, required this.service});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final solved = snapshot.puzzles
        .where((p) => snapshot.solvedIds.contains(p.id))
        .length;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppLocalizations.of(context).dailyPuzzles.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppLocalizations.of(context).solvedCount(solved, snapshot.puzzles.length)} · '
                  '${AppLocalizations.of(context).swapsLeft(snapshot.swapsLeft)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.puzzles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => _DailyTile(
                  puzzle: snapshot.puzzles[i],
                  index: i,
                  solved: snapshot.solvedIds.contains(snapshot.puzzles[i].id),
                  canSwap: snapshot.swapsLeft > 0,
                  service: service,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTile extends StatelessWidget {
  final Puzzle puzzle;
  final int index;
  final bool solved;
  final bool canSwap;
  final DailyPuzzleService service;

  const _DailyTile({
    required this.puzzle,
    required this.index,
    required this.solved,
    required this.canSwap,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPremium = context.watch<SubscriptionService>().isPremium;
    final locked = index >= 3 && !isPremium;
    return SizedBox(
      width: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _open(context, isPremium),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: SizedBox(
                    key: ValueKey(puzzle.id),
                    width: 64,
                    height: 64,
                    child: Stack(
                      children: [
                        IgnorePointer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Opacity(
                              opacity: locked ? 0.35 : 1.0,
                              child: FastGameBoard(
                                board: puzzle.initialBoard,
                                onTap: (_, __) {},
                                isDarkTheme:
                                    Theme.of(context).brightness ==
                                    Brightness.dark,
                              ),
                            ),
                          ),
                        ),
                        if (locked)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.lock,
                                size: 20,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < puzzle.difficulty ? Icons.star : Icons.star_border,
                      size: 10,
                      color: locked ? Colors.grey : Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (solved && !locked)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            )
          else if (canSwap && !locked)
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: cs.surface,
                shape: const CircleBorder(),
                elevation: 2,
                child: IconButton(
                  iconSize: 14,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(context).swapPuzzle,
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => service.swap(index),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, bool isPremium) async {
    if (index >= 3 && !isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PaywallScreen(reason: PaywallReason.puzzleDailyQuota),
        ),
      );
      return;
    }
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: puzzle)),
    );
    if (result != null && result['solved'] == true) {
      await service.markSolved(puzzle.id);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SectionHeader({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 3, height: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(AppLocalizations.of(context).seeAll),
          ),
      ],
    );
  }
}

class _CategorySpec {
  /// Internal topic key matching [PuzzleData.getPuzzlesForTopic]. Not displayed.
  final String name;
  final IconData icon;
  final Color tint;

  const _CategorySpec(this.name, this.icon, this.tint);

  /// Localized display label.
  String label(AppLocalizations l) => switch (name) {
    'Captures' => l.captures,
    'Liberties' => l.liberties,
    'Life & Death' => l.lifeDeath,
    'Ko Basics' => l.koBasics,
    'Tesuji' => l.tesuji,
    'Ladder' => l.ladder,
    'Snapback' => l.snapback,
    'Connect' => l.connect,
    _ => name,
  };
}

class _CategoryGrid extends StatelessWidget {
  final List<_CategorySpec> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) => _CategoryCard(spec: categories[i]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategorySpec spec;

  const _CategoryCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final puzzles = PuzzleData.getPuzzlesForTopic(spec.name);
    final count = puzzles.where((p) => p.solution.isNotEmpty).length;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PuzzleCategoryScreen(category: spec.name),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: spec.tint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(spec.icon, color: spec.tint),
                    ),
                    const Spacer(),
                    Text(
                      spec.label(l),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 4, color: spec.tint),
          ],
        ),
      ),
    );
  }
}
