import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
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

    final children = <Widget>[];
    int rowIndex = 0;
    bool firstTileEmitted = false;
    for (final category in _categoryOrder) {
      final lessons = byCategory[category];
      if (lessons == null || lessons.isEmpty) continue;
      // Category banner.
      children.add(
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
        // Path connector lives BETWEEN tiles, not before the first one of a
        // category (the WorldGate provides visual separation there).
        if (firstTileEmitted) {
          children.add(
            PathConnector(rowIndex: rowIndex, unlocked: true, theme: theme),
          );
        }
        firstTileEmitted = true;
        children.add(
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
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 160),
            children: children,
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
        // Floating CTA: jump to the next not-yet-completed lesson.
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: next == null ? null : () => _openTutorial(next),
              icon: const Icon(Icons.school, size: 20),
              label: Text(
                ctaLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sticky Learn header (Panda coach + progress) ────────────────────────────

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
    final frac = totalCount == 0
        ? 0.0
        : (completedCount / totalCount).clamp(0.0, 1.0);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 18,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$completedCount / $totalCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE4E2DC),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1565C0)),
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool get _isCurrent => !widget.completed && !widget.locked; // visible next-up

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = switch (widget.rowIndex % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };
    final width = 100.0;
    final height = 72.0;

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
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final glow = _isCurrent
                  ? Curves.easeInOut.transform(_pulse.value)
                  : 0.0;
              return SizedBox(
                width: width,
                // Reserve a bit of headroom above the pedestal for the player
                // stone (which sits ON the back-top of the pedestal). 36px
                // matches PuzzleGardenScreen's _LevelTile.
                height: height + (_isCurrent ? 36 : 0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
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
                    Positioned(
                      bottom: 0,
                      child: CustomPaint(
                        size: Size(width, height),
                        painter: LessonPedestalPainter(
                          baseColor: tileColor,
                          unlocked: !widget.locked,
                        ),
                      ),
                    ),
                    // Title fragment + status icon, centred on the pedestal top face.
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
                    // Player stone perched on the next-up pedestal.
                    if (_isCurrent)
                      Positioned(
                        bottom: height * 0.55,
                        child: const PlayerStone3D(color: 1),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
