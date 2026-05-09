import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fast_game_board.dart';
import 'puzzle_screen.dart';
import 'puzzle_category_screen.dart';

/// Chess.com-style puzzles hub: rating + streak header, daily puzzle card,
/// and a 2-column category grid. Reached from the Puzzles bottom-nav tab and
/// from the hamburger drawer.
class PuzzlesHubScreen extends StatelessWidget {
  const PuzzlesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.puzzles),
      appBar: AppBar(title: const Text('Puzzles'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _HeaderCard(puzzleRating: 1420, streak: 7, solvedToday: 3),
          const SizedBox(height: 16),
          _DailyPuzzleCard(puzzle: _dailyPuzzle()),
          const SizedBox(height: 24),
          _SectionHeader(label: 'Categories', onTap: null),
          const SizedBox(height: 12),
          _CategoryGrid(categories: _categories()),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          final route = switch (index) {
            0 => '/home',
            1 => '/learn',
            3 => '/profile',
            _ => '/home',
          };
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }

  /// Pick a deterministic puzzle for "today" so it changes daily but is
  /// stable within a single day. Uses local-day index modulo total count.
  static Puzzle _dailyPuzzle() {
    final all = PuzzleData.allPuzzles;
    final dayOfYear = _dayOfYear(DateTime.now());
    return all[dayOfYear % all.length];
  }

  static int _dayOfYear(DateTime d) {
    final start = DateTime(d.year);
    return d.difference(start).inDays;
  }

  static List<_CategorySpec> _categories() => const [
    _CategorySpec('Captures', Icons.close, Colors.redAccent),
    _CategorySpec('Liberties', Icons.blur_circular, Colors.lightBlueAccent),
    _CategorySpec('Life & Death', Icons.psychology, Colors.purpleAccent),
    _CategorySpec('Ko Basics', Icons.loop, Colors.amber),
    _CategorySpec('Tesuji', Icons.auto_fix_high, Colors.tealAccent),
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
              label: 'Rating',
              color: cs.primary,
            ),
            _Divider(color: cs.onSurface.withValues(alpha: 0.12)),
            _Stat(
              icon: Icons.local_fire_department,
              value: '$streak',
              label: 'Day Streak',
              color: Colors.orange,
            ),
            _Divider(color: cs.onSurface.withValues(alpha: 0.12)),
            _Stat(
              icon: Icons.check_circle,
              value: '$solvedToday',
              label: 'Today',
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

class _DailyPuzzleCard extends StatelessWidget {
  final Puzzle puzzle;

  const _DailyPuzzleCard({required this.puzzle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FastGameBoard(
                      board: puzzle.initialBoard,
                      onTap: (_, __) {},
                      isDarkTheme:
                          Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                        'DAILY PUZZLE',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      puzzle.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < puzzle.difficulty
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _open(context),
                        child: const Text('Solve →'),
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

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: puzzle)),
    );
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
          TextButton(onPressed: onTap, child: const Text('See all')),
      ],
    );
  }
}

class _CategorySpec {
  final String name;
  final IconData icon;
  final Color tint;

  const _CategorySpec(this.name, this.icon, this.tint);
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
    final puzzles = PuzzleData.getPuzzlesForTopic(spec.name);
    final count = puzzles.length;
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
                      spec.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count puzzle${count == 1 ? '' : 's'}',
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
