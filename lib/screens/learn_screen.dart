import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/menu_fab.dart';
import '../widgets/app_shell.dart';
import '../widgets/fast_game_board.dart';
import '../widgets/goko_logo.dart';
import '../models/drill.dart';
import '../models/tutorial.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import 'drill_screen.dart';
import 'tutorial_screen.dart';
import 'level_track_screen.dart';
import 'paywall_screen.dart';

/// Unified Learning Path screen. Replaces the prior tabbed Lessons / Practice
/// layout with a single scrollable list:
///
/// 1. Progress header (rating / streak / lessons-complete pill)
/// 2. Resume card (if a lesson was started but not completed)
/// 3. Three level sections (Beginner, Intermediate, Advanced) with collapsible
///    lesson rows. Tap a lesson → animated step-through, then puzzle practice.
/// 4. Quick Drills at the bottom (timed rushing — preserved).
class LearnScreen extends StatefulWidget {
  /// When false the screen is hosted inside [AppShell]; suppress per-screen nav.
  final bool showBottomNav;

  const LearnScreen({super.key, this.showBottomNav = true});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // Stored so FutureBuilder never re-fires when subscription state changes.
  late Future<List<Tutorial>> _tutorialsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tutorialsFuture = ContentService.loadTutorials(
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.learn),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GokoLogo(size: 22),
            const SizedBox(width: 8),
            Text(l.learnGo),
          ],
        ),
      ),
      body: FutureBuilder<List<Tutorial>>(
        future: _tutorialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LearnScreenSkeleton();
          }
          final tutorials = snapshot.data ?? const <Tutorial>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              const _ProgressHeader(),
              const SizedBox(height: 16),
              _ResumeCard(tutorials: tutorials),
              const SizedBox(height: 20),
              _SectionHeader(label: l.learningPath),
              const SizedBox(height: 10),
              _LevelSection(
                tier: LevelTier.beginner,
                title: l.beginner,
                icon: Icons.eco,
                tutorials: _filterByTier(tutorials, LevelTier.beginner),
              ),
              _LevelSection(
                tier: LevelTier.intermediate,
                title: l.intermediate,
                icon: Icons.trending_up,
                tutorials: _filterByTier(tutorials, LevelTier.intermediate),
              ),
              _LevelSection(
                tier: LevelTier.advanced,
                title: l.advanced,
                icon: Icons.emoji_events,
                tutorials: _filterByTier(tutorials, LevelTier.advanced),
              ),
              const _UnlockLessonsCard(),
              const SizedBox(height: 20),
              _SectionHeader(label: l.quickDrills),
              const SizedBox(height: 10),
              _DrillGrid(drills: _featuredDrills()),
            ],
          );
        },
      ),
      floatingActionButton: widget.showBottomNav ? const MenuFab() : null,
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 1) return;
                appShellTabIndex.value = index;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            )
          : null,
    );
  }

  static List<Tutorial> _filterByTier(List<Tutorial> all, LevelTier tier) {
    bool ok(int d) => switch (tier) {
      LevelTier.beginner => d <= 1,
      LevelTier.intermediate => d == 2,
      LevelTier.advanced => d >= 3,
    };
    return all.where((t) => ok(t.difficulty)).toList();
  }

  static List<Drill> _featuredDrills() => [
    DrillData.getDrillById('capture_rush'),
    DrillData.getDrillById('life_death_sprint'),
    DrillData.getDrillById('ko_master'),
    DrillData.getDrillById('tesuji_blitz'),
  ];
}

// ── Skeleton loading state ─────────────────────────────────────────────────

/// Pulsing placeholder shown while tutorials are loading from disk.
class _LearnScreenSkeleton extends StatefulWidget {
  const _LearnScreenSkeleton();

  @override
  State<_LearnScreenSkeleton> createState() => _LearnScreenSkeletonState();
}

class _LearnScreenSkeletonState extends State<_LearnScreenSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final opacity = 0.35 + 0.35 * _anim.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _shimmerBox(height: 80, radius: 16, opacity: opacity),
            const SizedBox(height: 16),
            for (var i = 0; i < 3; i++) ...[
              _shimmerBox(height: 24, width: 120, radius: 6, opacity: opacity),
              const SizedBox(height: 8),
              for (var j = 0; j < 3; j++) ...[
                _shimmerBox(height: 64, radius: 12, opacity: opacity),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    required double radius,
    required double opacity,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: opacity * 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Progress header ────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = context.watch<ProgressService>();
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            _HeaderStat(
              icon: Icons.insights,
              value: '${progress.puzzleRating}',
              label: l.rating,
              color: cs.primary,
            ),
            _HeaderDivider(color: cs.onSurface.withValues(alpha: 0.12)),
            _HeaderStat(
              icon: Icons.workspace_premium,
              value: '${progress.xp}',
              label: l.xp,
              color: Colors.amber.shade700,
            ),
            _HeaderDivider(color: cs.onSurface.withValues(alpha: 0.12)),
            _HeaderStat(
              icon: Icons.local_fire_department,
              value: '${progress.streak}',
              label: l.streak,
              color: Colors.orange,
            ),
            _HeaderDivider(color: cs.onSurface.withValues(alpha: 0.12)),
            _HeaderStat(
              icon: Icons.school_rounded,
              value: '${progress.lessonsCompleted}',
              label: l.lessons,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeaderStat({
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
          Icon(icon, size: 20, color: color),
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

class _HeaderDivider extends StatelessWidget {
  final Color color;

  const _HeaderDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: color);
  }
}

// ── Resume card ────────────────────────────────────────────────────────────

class _ResumeCard extends StatelessWidget {
  final List<Tutorial> tutorials;

  const _ResumeCard({required this.tutorials});

  @override
  Widget build(BuildContext context) {
    if (tutorials.isEmpty) return const SizedBox.shrink();
    final progress = context.watch<ProgressService>();
    final next = tutorials.firstWhere(
      (t) => !progress.isLessonCompleted(t.id),
      orElse: () => tutorials.first,
    );
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TutorialScreen(tutorial: next)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.play_arrow_rounded, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.isLessonCompleted(next.id)
                          ? AppLocalizations.of(context).replay
                          : AppLocalizations.of(context).continueLearning,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Level section ──────────────────────────────────────────────────────────

class _LevelSection extends StatelessWidget {
  final LevelTier tier;
  final String title;
  final IconData icon;
  final List<Tutorial> tutorials;

  const _LevelSection({
    required this.tier,
    required this.title,
    required this.icon,
    required this.tutorials,
  });

  /// Intermediate and Advanced tiers require Premium.
  bool get _isPremiumTier =>
      tier == LevelTier.intermediate || tier == LevelTier.advanced;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = context.watch<ProgressService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;
    final premiumGated = _isPremiumTier && !isPremium;
    final completed = tutorials
        .where((t) => progress.isLessonCompleted(t.id))
        .length;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  premiumGated ? Icons.lock : icon,
                  color: premiumGated
                      ? cs.onSurface.withValues(alpha: 0.45)
                      : cs.primary,
                ),
              ),
            ],
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: premiumGated
                  ? cs.onSurface.withValues(alpha: 0.55)
                  : null,
            ),
          ),
          subtitle: premiumGated
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).premium,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                )
              : tutorials.isEmpty
              ? Text(AppLocalizations.of(context).noLessonsYet)
              : Text('$completed / ${tutorials.length} completed'),
          trailing: TextButton(
            onPressed: () {
              if (premiumGated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(
                      reason: PaywallReason.premiumLessons,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelTrackScreen(tier: tier),
                  ),
                );
              }
            },
            child: const Text('Open'),
          ),
          children: [
            for (var i = 0; i < tutorials.take(5).length; i++)
              _LessonRow(
                tutorial: tutorials[i],
                completed: progress.isLessonCompleted(tutorials[i].id),
                locked: premiumGated ||
                    (i > 0 &&
                        !progress.isLessonCompleted(tutorials[i - 1].id)),
                premiumGated: premiumGated,
                bookmarkStep: progress.getLessonBookmark(tutorials[i].id),
              ),
            if (tutorials.length > 5)
              ListTile(
                title: Text(
                  AppLocalizations.of(context).seeAllLessons(tutorials.length),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.primary),
                ),
                onTap: () {
                  if (premiumGated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaywallScreen(
                          reason: PaywallReason.premiumLessons,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelTrackScreen(tier: tier),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final Tutorial tutorial;
  final bool completed;

  /// True when a prior lesson in the same tier hasn't been finished yet.
  /// Locked rows render dimmed and ignore taps (with an inline tooltip).
  final bool locked;

  /// True when the whole tier requires Premium. Shows the paywall on tap.
  final bool premiumGated;

  /// Saved step index for partial progress, used to fill the progress ring.
  /// Null when the user has never opened the lesson.
  final int? bookmarkStep;

  const _LessonRow({
    required this.tutorial,
    required this.completed,
    this.locked = false,
    this.premiumGated = false,
    this.bookmarkStep,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalSteps = tutorial.steps.length.clamp(1, 999);
    final progressFraction = completed
        ? 1.0
        : (bookmarkStep != null
              ? (bookmarkStep! / totalSteps).clamp(0.0, 1.0)
              : 0.0);
    final disabledTint = locked ? 0.45 : 1.0;
    return Opacity(
      opacity: disabledTint,
      child: InkWell(
        onTap: premiumGated
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaywallScreen(
                    reason: PaywallReason.premiumLessons,
                  ),
                ),
              )
            : locked
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).finishPreviousLesson,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              )
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TutorialScreen(tutorial: tutorial),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  children: [
                    // Progress ring sits behind the mini-board preview.
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: progressFraction == 0.0
                            ? null
                            : progressFraction,
                        strokeWidth: 3,
                        backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completed ? Colors.green : cs.primary,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: IgnorePointer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: FastGameBoard(
                              board: tutorial.steps.isNotEmpty
                                  ? tutorial.steps.first.board
                                  : List.generate(7, (_) => List.filled(7, 0)),
                              onTap: (_, __) {},
                              isDarkTheme:
                                  Theme.of(context).brightness ==
                                  Brightness.dark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tutorial.steps.length} steps'
                      '${tutorial.practicePuzzleIds.isNotEmpty ? '  ·  ${tutorial.practicePuzzleIds.length} puzzles' : ''}'
                      '${bookmarkStep != null && !completed ? '  ·  resume @ ${bookmarkStep! + 1}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (locked)
                Icon(
                  Icons.lock,
                  color: cs.onSurface.withValues(alpha: 0.45),
                  size: 20,
                )
              else if (completed)
                const Icon(Icons.check_circle, color: Colors.green, size: 22)
              else
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

// ── Unlock lessons banner (free users only) ────────────────────────────────

class _UnlockLessonsCard extends StatelessWidget {
  const _UnlockLessonsCard();

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionService>().isPremium;
    if (isPremium) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PaywallScreen(reason: PaywallReason.premiumLessons),
          ),
        ),
        icon: const Icon(Icons.workspace_premium, color: Colors.amber),
        label: Text(l.unlockPremium),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ── Drill grid ─────────────────────────────────────────────────────────────

class _DrillGrid extends StatelessWidget {
  final List<Drill> drills;

  const _DrillGrid({required this.drills});

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

// ── Section header ─────────────────────────────────────────────────────────

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
