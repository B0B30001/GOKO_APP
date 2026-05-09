import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fast_game_board.dart';
import '../models/drill.dart';
import '../models/tutorial.dart';
import '../services/content_service.dart';
import 'drill_screen.dart';
import 'tutorial_screen.dart';
import 'tutorial_list_screen.dart';

/// Learn hub with two pinned tabs: **Lessons** (tutorials + topic browser) and
/// **Practice** (quick-start drills + weekly progress).
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(active: AppDrawerSection.learn),
        appBar: AppBar(
          title: const Text('Learn Go'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.school), text: 'Lessons'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Practice'),
            ],
          ),
        ),
        body: const TabBarView(children: [_LessonsTab(), _PracticeTab()]),
        bottomNavigationBar: BottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 1) return;
            final route = switch (index) {
              0 => '/home',
              2 => '/puzzles',
              3 => '/profile',
              _ => '/home',
            };
            Navigator.pushReplacementNamed(context, route);
          },
        ),
      ),
    );
  }
}

// =============================================================================
// Lessons tab
// =============================================================================

class _LessonsTab extends StatelessWidget {
  const _LessonsTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tutorial>>(
      future: ContentService.loadTutorials(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final tutorials = snapshot.data ?? const <Tutorial>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(label: 'Learning Path'),
            const SizedBox(height: 12),
            _LearningPathPager(tutorials: tutorials),
            const SizedBox(height: 24),
            const _SectionHeader(label: 'All Tutorials'),
            const SizedBox(height: 12),
            ..._byCategory(tutorials).entries.map(
              (entry) =>
                  _CategorySection(category: entry.key, tutorials: entry.value),
            ),
            const SizedBox(height: 16),
            _BrowseAllTutorialsTile(),
          ],
        );
      },
    );
  }

  Map<String, List<Tutorial>> _byCategory(List<Tutorial> tutorials) {
    final grouped = <String, List<Tutorial>>{};
    for (final t in tutorials) {
      grouped.putIfAbsent(t.category, () => []).add(t);
    }
    return grouped;
  }
}

class _LearningPathPager extends StatelessWidget {
  final List<Tutorial> tutorials;

  const _LearningPathPager({required this.tutorials});

  @override
  Widget build(BuildContext context) {
    if (tutorials.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Loading lessons…')),
      );
    }
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: tutorials.length,
        itemBuilder: (context, i) =>
            _PathCard(tutorial: tutorials[i], stepNumber: i + 1),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final Tutorial tutorial;
  final int stepNumber;

  const _PathCard({required this.tutorial, required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: cs.primary,
                      child: Text(
                        '$stepNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tutorial.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    tutorial.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                LinearProgressIndicator(
                  value: 0,
                  backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _open(context),
                    child: const Text('Start'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TutorialScreen(tutorial: tutorial)),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final String category;
  final List<Tutorial> tutorials;

  const _CategorySection({required this.category, required this.tutorials});

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded ? _buildLessonList() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _iconFor(widget.category),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _label(widget.category),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Text(
              '${widget.tutorials.length} lesson${widget.tutorials.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 6),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList() {
    return Column(
      children: [
        const Divider(height: 1),
        ...widget.tutorials.map((t) => _LessonCard(tutorial: t)),
      ],
    );
  }

  IconData _iconFor(String c) => switch (c) {
    'fundamentals' => Icons.menu_book,
    'rules' => Icons.gavel,
    'life-death' => Icons.psychology,
    _ => Icons.school,
  };

  String _label(String c) => switch (c) {
    'fundamentals' => 'Fundamentals',
    'rules' => 'Rules',
    'life-death' => 'Life & Death',
    _ => c,
  };
}

class _LessonCard extends StatelessWidget {
  final Tutorial tutorial;

  const _LessonCard({required this.tutorial});

  @override
  Widget build(BuildContext context) {
    final firstStepBoard = tutorial.steps.isNotEmpty
        ? tutorial.steps.first.board
        : List.generate(7, (_) => List.filled(7, 0));
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TutorialScreen(tutorial: tutorial)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: FastGameBoard(
                    board: firstStepBoard,
                    onTap: (_, __) {},
                    isDarkTheme:
                        Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tutorial.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '~${(tutorial.steps.length * 1.2).round()} min · ${tutorial.steps.length} steps',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutorial.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _BrowseAllTutorialsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.list),
        title: const Text('Browse all tutorials'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TutorialListScreen()),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Practice tab
// =============================================================================

class _PracticeTab extends StatelessWidget {
  const _PracticeTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(label: 'Quick Drills'),
        const SizedBox(height: 12),
        _DrillButtonGrid(drills: _drills()),
        const SizedBox(height: 24),
        const _SectionHeader(label: 'This Week'),
        const SizedBox(height: 12),
        const _WeeklyProgress(),
      ],
    );
  }

  List<Drill> _drills() {
    return [
      DrillData.getDrillById('capture_rush'),
      DrillData.getDrillById('life_death_sprint'),
      DrillData.getDrillById('ko_master'),
      DrillData.getDrillById('tesuji_blitz'),
    ];
  }
}

class _DrillButtonGrid extends StatelessWidget {
  final List<Drill> drills;

  const _DrillButtonGrid({required this.drills});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: drills.length,
      itemBuilder: (context, i) => _DrillCard(drill: drills[i]),
    );
  }
}

class _DrillCard extends StatelessWidget {
  final Drill drill;

  const _DrillCard({required this.drill});

  @override
  Widget build(BuildContext context) {
    final palette = _stylesFor(drill.type);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DrillScreen(drill: drill)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(palette.icon, color: palette.color),
              ),
              const Spacer(),
              Text(
                drill.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                drill.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({IconData icon, Color color}) _stylesFor(DrillType type) {
    switch (type) {
      case DrillType.capture:
        return (icon: Icons.close, color: Colors.redAccent);
      case DrillType.lifeAndDeath:
        return (icon: Icons.psychology, color: Colors.purpleAccent);
      case DrillType.ko:
        return (icon: Icons.loop, color: Colors.amber);
      case DrillType.tesuji:
        return (icon: Icons.auto_fix_high, color: Colors.tealAccent);
      case DrillType.mixed:
        return (icon: Icons.shuffle, color: Colors.lightBlueAccent);
    }
  }
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress();

  @override
  Widget build(BuildContext context) {
    // Placeholder weekly distribution. Real data should come from a future
    // PracticeStatsService that tracks daily solved counts.
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const values = [0.4, 0.7, 0.2, 0.85, 0.5, 0.0, 0.3];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            7,
            (i) => _DayBar(label: days[i], value: values[i]),
          ),
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final double value;

  const _DayBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: cs.onSurface.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${(value * 10).round()}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

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
      ],
    );
  }
}
