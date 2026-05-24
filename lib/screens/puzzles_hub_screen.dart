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
import '../widgets/coach_speech.dart';
import 'puzzle_map_screen.dart';
import 'puzzle_screen.dart';
import 'puzzle_streak_screen.dart';
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

enum _HubView { map, list }

class _PuzzlesHubScreenState extends State<PuzzlesHubScreen> {
  late final DailyPuzzleService _daily;

  /// Map = chess.com-style candy-crush progression (default for engagement);
  /// List = classic header + daily-set + streak layout.
  _HubView _view = _HubView.map;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: SegmentedButton<_HubView>(
              segments: [
                ButtonSegment(
                  value: _HubView.map,
                  label: Text(l.puzzleMap),
                  icon: const Icon(Icons.map),
                ),
                ButtonSegment(
                  value: _HubView.list,
                  label: Text(l.puzzleList),
                  icon: const Icon(Icons.view_list),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          Expanded(
            child: _view == _HubView.map
                ? const PuzzleMapScreen()
                : _buildListView(l),
          ),
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

  Widget _buildListView(AppLocalizations l) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Consumer<ProgressService>(
          builder: (context, progress, _) => _HeaderCard(
            puzzleRating: progress.puzzleRating,
            streak: progress.streak,
            solvedToday: progress.solvedCount,
          ),
        ),
        const SizedBox(height: 12),
        const _QuotaPill(),
        const SizedBox(height: 16),
        _SectionHeader(label: l.puzzleModes, onTap: null),
        const SizedBox(height: 10),
        const _ModesSection(),
        const SizedBox(height: 20),
        ChangeNotifierProvider.value(
          value: _daily,
          child: const _DailySetCard(),
        ),
      ],
    );
  }
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
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final league = _PuzzleLeague.forRating(puzzleRating);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _Stat(
                  icon: Icons.trending_up,
                  value: '$puzzleRating',
                  label: l.rating,
                  color: cs.primary,
                ),
                _Divider(color: cs.onSurface.withValues(alpha: 0.12)),
                _Stat(
                  icon: Icons.local_fire_department,
                  value: '$streak',
                  label: l.dayStreakLabel,
                  color: Colors.orange,
                ),
                _Divider(color: cs.onSurface.withValues(alpha: 0.12)),
                _Stat(
                  icon: Icons.check_circle,
                  value: '$solvedToday',
                  label: l.today,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: league.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: league.color.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(league.icon, color: league.color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${l.leagueLabel}: ${league.label(l)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: league.color,
                    ),
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
    final tint = _categoryTint(puzzle.category);
    return SizedBox(
      width: 88,
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
                    width: 76,
                    height: 76,
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
                // Category color strip — visually distinguishes tile contents
                // even when the mini-board pixels look similar.
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 56,
                  height: 3,
                  decoration: BoxDecoration(
                    color: locked ? Colors.grey.shade600 : tint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
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

/// Chess.com-style daily-puzzle quota pill. Shows "X / N free puzzles today"
/// for free users, "Unlimited" for premium. Turns amber + clickable when
/// the free quota is exhausted; tap opens the paywall.
class _QuotaPill extends StatelessWidget {
  const _QuotaPill();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sub = context.watch<SubscriptionService>();
    final cs = Theme.of(context).colorScheme;

    if (sub.isPremium) {
      return _PillContainer(
        bg: Colors.amber.withValues(alpha: 0.18),
        fg: Colors.amber.shade800,
        icon: Icons.workspace_premium,
        text: '${l.today}: ∞ ${l.unlimitedPuzzles}',
      );
    }

    final solved = sub.dailyPuzzlesSolved;
    final cap = SubscriptionService.freeDailyPuzzleQuota;
    final exhausted = solved >= cap;

    final container = _PillContainer(
      bg: exhausted
          ? Colors.amber.withValues(alpha: 0.20)
          : cs.primary.withValues(alpha: 0.10),
      fg: exhausted ? Colors.amber.shade800 : cs.primary,
      icon: exhausted ? Icons.lock_outline : Icons.bolt,
      text: '${l.today}: $solved / $cap',
    );

    if (!exhausted) return container;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PaywallScreen(reason: PaywallReason.puzzleDailyQuota),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: container,
    );
  }
}

class _PillContainer extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String text;

  const _PillContainer({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps a puzzle category string to a tint color used for the daily-tile
/// bottom strip. Falls back to grey for unrecognized categories.
Color _categoryTint(String category) {
  final key = category.toLowerCase().replaceAll('-', '_');
  return switch (key) {
    'capture' || 'captures' => Colors.redAccent,
    'liberties' || 'liberty' => Colors.lightBlueAccent,
    'life_death' || 'lifedeath' || 'life and death' => Colors.purpleAccent,
    'ko' || 'ko_basics' => Colors.amber,
    'tesuji' => Colors.tealAccent,
    'ladder' => Colors.cyanAccent,
    'snapback' => Colors.deepOrangeAccent,
    'connect' => Colors.greenAccent,
    _ => Colors.blueGrey.shade300,
  };
}

// ── Puzzle League ────────────────────────────────────────────────────────────

class _PuzzleLeague {
  final Color color;
  final IconData icon;
  final String Function(AppLocalizations) label;

  const _PuzzleLeague({
    required this.color,
    required this.icon,
    required this.label,
  });

  static _PuzzleLeague forRating(int rating) {
    if (rating >= 1300) {
      return _PuzzleLeague(
        color: const Color(0xFF7C4DFF),
        icon: Icons.diamond,
        label: (l) => l.leagueDiamond,
      );
    }
    if (rating >= 1200) {
      return _PuzzleLeague(
        color: const Color(0xFF00BCD4),
        icon: Icons.water_drop,
        label: (l) => l.leaguePlatinum,
      );
    }
    if (rating >= 1150) {
      return _PuzzleLeague(
        color: const Color(0xFFFFD700),
        icon: Icons.emoji_events,
        label: (l) => l.leagueGold,
      );
    }
    if (rating >= 1100) {
      return _PuzzleLeague(
        color: const Color(0xFFC0C0C0),
        icon: Icons.shield,
        label: (l) => l.leagueSilver,
      );
    }
    if (rating >= 1050) {
      return _PuzzleLeague(
        color: const Color(0xFFCD7F32),
        icon: Icons.military_tech,
        label: (l) => l.leagueBronze,
      );
    }
    return _PuzzleLeague(
      color: Colors.grey,
      icon: Icons.person,
      label: (l) => l.leagueRookie,
    );
  }
}

// ── Puzzle Modes section ─────────────────────────────────────────────────────

class _ModesSection extends StatefulWidget {
  const _ModesSection();

  @override
  State<_ModesSection> createState() => _ModesSectionState();
}

class _ModesSectionState extends State<_ModesSection> {
  bool _coachDismissed = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tips = <String>[
      l.coachStreakIntro1,
      l.coachStreakIntro2,
      l.coachStreakIntro3,
      l.coachStreakIntro4,
      l.coachStreakIntro5,
    ];
    final coachTip = tips[DateTime.now().day % tips.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_coachDismissed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CoachSpeech(
              message: coachTip,
              onDismiss: () => setState(() => _coachDismissed = true),
            ),
          ),
        _ModeCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: l.puzzleStreak,
          subtitle: l.puzzleStreakSubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PuzzleStreakScreen()),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
