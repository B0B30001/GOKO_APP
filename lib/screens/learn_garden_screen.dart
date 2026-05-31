import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/learning_rank.dart';
import 'package:zaibal/models/tutorial.dart';
import 'package:zaibal/services/content_service.dart';
import 'package:zaibal/services/progress_service.dart';
import 'package:zaibal/widgets/coach_speech.dart';
import 'package:zaibal/widgets/garden/garden.dart';
import 'tutorial_screen.dart';

/// Gamified Learn page modelled on the Puzzle Garden — a winding vertical
/// path of 3D-pedestal tiles, each representing one Tutorial. Lessons are
/// grouped into "worlds" by their `category` field (Fundamentals → Rules →
/// Life & Death → Strategy), and the screen picks ONE [GardenTheme] derived
/// from the user's chosen `AppSettings.backgroundThemeId` so the look matches
/// their global palette preference.
///
/// State per tile:
///   - Completed (green check) when `ProgressService.isLessonCompleted`
///   - In-progress (progress ring) when a bookmark exists
///   - Locked (padlock) when difficulty >= 2 and user is on free tier
///   - Default (lesson number) otherwise
///
/// Tapping a tile pushes the existing [TutorialScreen] — that screen is
/// untouched. A floating "Continue Lesson" CTA at the bottom jumps to the
/// next not-yet-completed tutorial.
class LearnGardenScreen extends StatefulWidget {
  const LearnGardenScreen({super.key});

  @override
  State<LearnGardenScreen> createState() => _LearnGardenScreenState();
}

/// Display order for the category bands (renders top-to-bottom; reverse:false
/// ListView so the first lesson is at the TOP — opposite of puzzle garden
/// which climbs upward through XP).
const _categoryOrder = <String>[
  'fundamentals',
  'rules',
  'life-death',
  'strategy',
];

class _LearnGardenScreenState extends State<LearnGardenScreen> {
  List<Tutorial> _all = const [];
  bool _loading = true;
  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
    // Listen to scroll changes to update parallax background
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Update scroll offset for parallax effect
    final newOffset = _scroll.offset;
    if (_scrollOffset != newOffset) {
      setState(() {
        _scrollOffset = newOffset;
      });
    }
  }

  Future<void> _load() async {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final tutorials = await ContentService.loadTutorials(languageCode: code);
    if (!mounted) return;
    setState(() {
      _all = _sorted(tutorials);
      _loading = false;
    });
  }

  /// Sort by category (per `_categoryOrder`) then by difficulty within each
  /// category so beginner lessons surface first inside their band.
  List<Tutorial> _sorted(List<Tutorial> input) {
    final out = [...input];
    out.sort((a, b) {
      final ai = _categoryOrder.indexOf(a.category);
      final bi = _categoryOrder.indexOf(b.category);
      final aIdx = ai >= 0 ? ai : _categoryOrder.length;
      final bIdx = bi >= 0 ? bi : _categoryOrder.length;
      if (aIdx != bIdx) return aIdx.compareTo(bIdx);
      return a.difficulty.compareTo(b.difficulty);
    });
    return out;
  }

  String _categoryTitle(String category, AppLocalizations l) =>
      switch (category) {
        'fundamentals' => l.categoryFundamentals,
        'rules' => l.categoryRules,
        'life-death' => l.categoryLifeDeath,
        'strategy' => l.categoryStrategy,
        _ => category,
      };

  Tutorial? _nextUnfinished(ProgressService progress) {
    for (final t in _all) {
      if (!progress.isLessonCompleted(t.id)) return t;
    }
    return null;
  }

  Future<void> _openTutorial(Tutorial t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TutorialScreen(tutorial: t)),
    );
    if (mounted) setState(() {});
  }

  /// All lessons are free in the current build — just open the tutorial.
  Future<void> _onTileTap(Tutorial t) => _openTutorial(t);

  List<String> _coachLines(AppLocalizations l) => [
    l.coachLearnIntro1,
    l.coachLearnIntro2,
    l.coachLearnIntro3,
    l.coachLearnIntro4,
    l.coachLearnIntro5,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = context.watch<ProgressService>();
    // Single theme derived from user palette — Learn doesn't rotate themes
    // like Puzzle Garden does (which earns the theme change via XP).
    final theme = themeForCurrentSettings();
    // Look up which theme index that maps to so ambient decorations and the
    // themed background painter pick the matching motifs/colors.
    final themeIdx = gardenThemes.indexWhere(
      (t) => t.tileBase == theme.tileBase && t.skyTop == theme.skyTop,
    );
    final safeThemeIdx = themeIdx >= 0 ? themeIdx : 0;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group lessons by category, in `_categoryOrder` sequence.
    final byCategory = <String, List<Tutorial>>{};
    for (final t in _all) {
      byCategory.putIfAbsent(t.category, () => []).add(t);
    }

    // Each lesson category becomes one GardenWorldPanel whose scenery scrolls
    // with the path (Learn uses a single palette, so every panel shares
    // safeThemeIdx). reverse:false ⇒ panels and their columns stay in natural
    // top-to-bottom order.
    final panels = <Widget>[];
    var bandChildren = <Widget>[];
    int rowIndex = 0;
    bool firstTileEmitted = false;

    void flushBand() {
      if (bandChildren.isEmpty) return;
      panels.add(
        GardenWorldPanel(
          themeIdx: safeThemeIdx,
          child: Column(mainAxisSize: MainAxisSize.min, children: bandChildren),
        ),
      );
      bandChildren = <Widget>[];
    }

    for (final category in _categoryOrder) {
      final lessons = byCategory[category];
      if (lessons == null || lessons.isEmpty) continue;
      flushBand();
      // Category banner.
      bandChildren.add(
        WorldGate(
          theme: theme,
          title: _categoryTitle(category, l),
          unlocked: true,
          subtitle: l.lessonsInCategoryCount(lessons.length),
        ),
      );
      for (final tutorial in lessons) {
        final completed = progress.isLessonCompleted(tutorial.id);
        final bookmark = progress.getLessonBookmark(tutorial.id);
        // Path connector lives BETWEEN tiles, not before the very first one.
        if (firstTileEmitted) {
          bandChildren.add(
            PathConnector(rowIndex: rowIndex, unlocked: true, theme: theme),
          );
        }
        firstTileEmitted = true;
        bandChildren.add(
          _LessonTile(
            tutorial: tutorial,
            rowIndex: rowIndex,
            theme: theme,
            completed: completed,
            bookmarkStep: bookmark,
            locked: false,
            onTap: () => _onTileTap(tutorial),
          ),
        );
        rowIndex++;
      }
    }
    flushBand();

    final next = _nextUnfinished(progress);
    final ctaLabel = next == null
        ? l.startLessonCta
        : (progress.getLessonBookmark(next.id) != null
              ? l.continueLessonCta
              : l.startLessonCta);

    return Stack(
      children: [
        Positioned.fill(
          child: ThemedBackground(
            themeIdx: safeThemeIdx,
            scrollOffset: _scrollOffset,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AmbientDecorations(themeIdx: safeThemeIdx),
          ),
        ),
        Positioned.fill(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.only(top: 120, bottom: 160),
            children: panels,
          ),
        ),
        // Sticky Panda coach at the top.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _StickyLearnHeader(
            messages: _coachLines(l),
            completedCount: progress.lessonsCompleted,
            totalCount: _all.length,
          ),
        ),
        // Floating CTA: card-style with next-lesson title preview.
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: next == null ? null : () => _openTutorial(next),
              child: AnimatedOpacity(
                opacity: next == null ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x551565C0),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.nextUp.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              next?.title ?? ctaLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sticky Learn header (coach + chess.com-style rank + progress) ───────────

class _StickyLearnHeader extends StatelessWidget {
  final List<String> messages;
  final int completedCount;
  final int totalCount;

  const _StickyLearnHeader({
    required this.messages,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rank = LearningRank.forLessonsCompleted(completedCount);
    final nextRank = LearningRank.nextAbove(completedCount);

    // Progress within current rank band.
    final frac = nextRank == null
        ? 1.0
        : ((completedCount - rank.threshold) /
                  (nextRank.threshold - rank.threshold))
              .clamp(0.0, 1.0);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoachSpeech.sticky(messages: messages),
                const SizedBox(height: 10),
                // ── Rank row (chess.com "Learning Rank" style) ──────────
                Row(
                  children: [
                    // Rank icon in a coloured circle.
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: rank.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: rank.color, width: 1.5),
                      ),
                      child: Icon(rank.icon, color: rank.color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rank.label(l).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: rank.color,
                            ),
                          ),
                          Text(
                            '$completedCount / $totalCount ${l.lessons}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lessons-to-next-rank chip.
                    if (nextRank != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: nextRank.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l.lessonsToNextRank(
                            nextRank.threshold - completedCount,
                            nextRank.label(l),
                          ),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: nextRank.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Progress bar coloured to the current rank ───────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE4E2DC),
                    valueColor: AlwaysStoppedAnimation(rank.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Lesson tile (3D pedestal + per-state badge) ─────────────────────────────

class _LessonTile extends StatefulWidget {
  final Tutorial tutorial;
  final int rowIndex;
  final GardenTheme theme;
  final bool completed;
  final int? bookmarkStep;
  final bool locked;
  final VoidCallback onTap;

  const _LessonTile({
    required this.tutorial,
    required this.rowIndex,
    required this.theme,
    required this.completed,
    required this.bookmarkStep,
    required this.locked,
    required this.onTap,
  });

  @override
  State<_LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<_LessonTile>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _tap;
  late final Animation<double> _tapScale;

  bool get _isCurrent =>
      !widget.completed && !widget.locked && widget.bookmarkStep == null;
  bool get _isNew =>
      !widget.completed && !widget.locked && widget.bookmarkStep == null;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _tapScale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _tap, curve: Curves.easeIn));
    if (_isCurrent) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_LessonTile old) {
    super.didUpdateWidget(old);
    if (_isCurrent && _pulse.status == AnimationStatus.dismissed) {
      _pulse.repeat(reverse: true);
    } else if (!_isCurrent && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _tap.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _tap.forward();
  void _handleTapUp(TapUpDetails _) {
    _tap.reverse();
    widget.onTap();
  }

  void _handleTapCancel() => _tap.reverse();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final alignment = switch (widget.rowIndex % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };
    const width = 100.0;
    const height = 72.0;

    final tileColor = widget.locked
        ? Colors.blueGrey.shade700
        : widget.completed
        ? const Color(0xFF43A047)
        : widget.theme.tileBase;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _tap]),
            builder: (context, _) {
              final glow = _isCurrent
                  ? Curves.easeInOut.transform(_pulse.value)
                  : 0.0;
              return ScaleTransition(
                scale: _tapScale,
                child: SizedBox(
                  width: width,
                  height: height + (_isCurrent ? 36 : 0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Pulsing glow halo under the current tile.
                      if (_isCurrent)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: width,
                            height: height * 0.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(width, height),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tileColor.withValues(
                                    alpha: 0.30 + glow * 0.30,
                                  ),
                                  blurRadius: 18 + glow * 14,
                                  spreadRadius: 2 + glow * 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      // 3D book-stack pedestal.
                      Positioned(
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(width, height),
                          painter: LessonPedestalPainter(
                            baseColor: tileColor,
                            unlocked: !widget.locked,
                          ),
                        ),
                      ),
                      // Status icon + lesson title on the top face.
                      Positioned(
                        bottom: height * 0.28,
                        child: SizedBox(
                          width: width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.locked)
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                  size: 22,
                                )
                              else if (widget.completed)
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 26,
                                )
                              else if (widget.bookmarkStep != null)
                                const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                )
                              else
                                const Icon(
                                  Icons.menu_book,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              const SizedBox(height: 2),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  widget.tutorial.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ⭐ Completion star badge (top-right corner).
                      if (widget.completed)
                        Positioned(
                          top: _isCurrent ? 36 - height : 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD700),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      // 🆕 NEW badge on the very first untouched tile.
                      if (_isNew && widget.rowIndex == 0)
                        Positioned(
                          top: _isCurrent ? 36 - height : 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              l.newBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      // Mascot perched on the current pedestal.
                      if (_isCurrent)
                        Positioned(
                          bottom: height * 0.55,
                          child: const GardenMascot(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
