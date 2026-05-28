import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../models/league_tier.dart';
import '../models/puzzle.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../widgets/coach_speech.dart';
import '../widgets/garden/garden.dart';
import 'puzzle_screen.dart';

// ── XP milestone thresholds ─────────────────────────────────────────────────

/// XP required to REACH each level (1-indexed). Level 1 = 0 XP (always active).
///
/// Designed in the spirit of Chess.com puzzles — each level is a meaningful
/// milestone, not a per-puzzle bump. Players gain 10 XP per puzzle solved,
/// so Level 2 (≈3k XP) requires ~30 puzzles of sustained play, and the
/// later worlds gate behind real long-term commitment.
const _levelThresholds = <int>[
  0, // Level 1   — start (always open)
  300, // Level 2   — ~30 puzzles (first real milestone)
  750, // Level 3   — ~75
  1300, // Level 4   — ~130
  2000, // Level 5   — ~200
  3000, // Level 6   — 300 puzzles      ← Crystal Cave unlocks
  4200, // Level 7
  5600, // Level 8
  7200, // Level 9
  9000, // Level 10  — ~900 puzzles
  11000, // Level 11                     ← Copper Peaks unlocks
  13200,
  15600,
  18200,
  21000,
  24000, // Level 16                     ← Diamond Tundra unlocks
  27200,
  30600,
  34200,
  38000, // Level 20                     ← Jade Highlands unlocks
];

int _levelFor(int xp) {
  for (int i = _levelThresholds.length - 1; i >= 0; i--) {
    if (xp >= _levelThresholds[i]) return i + 1;
  }
  return 1;
}

int _themeIdxForLevel(int level) =>
    ((level - 1) ~/ 5).clamp(0, gardenThemes.length - 1);

// ── Screen ───────────────────────────────────────────────────────────────────

class PuzzleGardenScreen extends StatefulWidget {
  const PuzzleGardenScreen({super.key});

  @override
  State<PuzzleGardenScreen> createState() => _PuzzleGardenScreenState();
}

class _PuzzleGardenScreenState extends State<PuzzleGardenScreen> {
  /// Pool of OGS puzzles the "Solve Puzzles" CTA picks from at random.
  /// Tutorials live separately in `LearnGardenScreen` — this screen is
  /// puzzles-only. Hand-curated `puzzles.json` and `PuzzleData` entries are
  /// excluded (they lack a `solutionTree` and are reached via the categories
  /// screen for explicit per-puzzle study).
  List<Puzzle> _solvePool = const [];
  LeagueTier? _lastLeague;
  String? _celebrateMessage;
  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final newOffset = _scroll.offset;
    if (_scrollOffset != newOffset) {
      setState(() => _scrollOffset = newOffset);
    }
  }

  Future<void> _load() async {
    final all = await ContentService.loadAllPuzzles();
    if (!mounted) return;
    setState(() {
      _solvePool = all.where((p) => p.solutionTree != null).toList();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    if (!_scroll.hasClients) return;
    final progress = context.read<ProgressService>();
    final level = _levelFor(progress.xp);
    final offset = (level * 100.0 + (level ~/ 5) * 96.0 - 260).clamp(
      0.0,
      _scroll.position.hasContentDimensions
          ? _scroll.position.maxScrollExtent
          : double.infinity,
    );
    _scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _launchRandomPuzzle() async {
    if (_solvePool.isEmpty) return;
    final puzzle = _solvePool[math.Random().nextInt(_solvePool.length)];
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: puzzle)),
    );
    if (mounted) setState(() {});
  }

  void _maybeCelebrateLeague(LeagueTier current, AppLocalizations l) {
    final prev = _lastLeague;
    _lastLeague = current;
    if (prev == null || prev.threshold >= current.threshold) return;
    final msg = switch (current.threshold) {
      1050 => l.coachLeagueBronzeUnlocked,
      1100 => l.coachLeagueSilverUnlocked,
      1150 => l.coachLeagueGoldUnlocked,
      1200 => l.coachLeaguePlatinumUnlocked,
      1300 => l.coachLeagueDiamondUnlocked,
      _ => l.coachLeagueRookieUnlocked,
    };
    setState(() => _celebrateMessage = msg);
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _celebrateMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final l = AppLocalizations.of(context);
    final xp = progress.xp;
    final currentLevel = _levelFor(xp);
    final themeIdx = _themeIdxForLevel(currentLevel);
    final theme = gardenThemes[themeIdx];
    final currentTier = LeagueTier.forRating(progress.puzzleRating);
    _maybeCelebrateLeague(currentTier, l);

    // Build the level milestone list. A world gate banner is inserted at the
    // start of every 5-level band (indices 0, 5, 10, 15…). Connector path
    // segments are drawn between consecutive level tiles to give the map a
    // Candy Crush / Chess.com winding-path feel.
    final children = <Widget>[];
    for (int i = 0; i < _levelThresholds.length; i++) {
      final level = i + 1;
      if (i % 5 == 0) {
        final bandThemeIdx = (i ~/ 5).clamp(0, gardenThemes.length - 1);
        final bandTheme = gardenThemes[bandThemeIdx];
        final unlocked = xp >= _levelThresholds[i];
        children.add(
          WorldGate(
            theme: bandTheme,
            title: gardenThemeName(bandThemeIdx, l),
            unlocked: unlocked,
            subtitle: unlocked
                ? null
                : l.gateLockedUnlockAt(_levelThresholds[i]),
          ),
        );
      } else {
        // Connector lives BETWEEN tiles (skip before the first tile of a band).
        children.add(
          PathConnector(
            rowIndex: i,
            unlocked: xp >= _levelThresholds[i],
            theme: theme,
          ),
        );
      }
      children.add(
        _LevelTile(
          level: level,
          rowIndex: i,
          theme: theme,
          unlocked: xp >= _levelThresholds[i],
          isCurrent: currentLevel == level,
          xpNeeded: math.max(0, _levelThresholds[i] - xp),
        ),
      );
    }

    return Stack(
      children: [
        // Themed environment — Canva PNG if present, painter fallback otherwise.
        // Soft cross-fade when the theme band changes.
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: KeyedSubtree(
              key: ValueKey(themeIdx),
              child: ThemedBackground(
                themeIdx: themeIdx,
                scrollOffset: _scrollOffset,
              ),
            ),
          ),
        ),
        // Floating ambient decorations (clouds + drifting petals/snow per theme).
        Positioned.fill(
          child: IgnorePointer(child: AmbientDecorations(themeIdx: themeIdx)),
        ),
        // Scrollable level map. reverse:true puts Level 1 at the bottom so the
        // player climbs upward through the world bands.
        Positioned.fill(
          child: ListView(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 160),
            children: children,
          ),
        ),
        // Sticky panda coach + XP progress bar.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _StickyCoachHeader(
            currentTier: currentTier,
            rating: progress.puzzleRating,
            xp: xp,
            streakCount: math.min(currentLevel - 1, xp ~/ 10),
            celebrateMessage: _celebrateMessage,
          ),
        ),
        // Floating "Solve Puzzles" CTA — the only entry-point into puzzle play.
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: _solvePool.isEmpty ? null : _launchRandomPuzzle,
              icon: const Icon(Icons.extension, size: 20),
              label: Text(
                l.solvePuzzles,
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

// ── Sticky coach + XP bar header ─────────────────────────────────────────────

class _StickyCoachHeader extends StatelessWidget {
  final LeagueTier currentTier;
  final int rating;
  final int xp;
  final int streakCount;
  final String? celebrateMessage;

  const _StickyCoachHeader({
    required this.currentTier,
    required this.rating,
    required this.xp,
    required this.streakCount,
    required this.celebrateMessage,
  });

  List<String> _lines(AppLocalizations l) {
    final base = [
      l.coachStreakIntro1,
      l.coachStreakIntro2,
      l.coachStreakIntro3,
      l.coachStreakIntro4,
      l.coachStreakIntro5,
      l.coachKeepGoing,
    ];
    if (streakCount >= 3) base.insert(0, l.coachSolve3);
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nextTier = LeagueTier.nextAbove(rating);
    final frac = nextTier == null
        ? 1.0
        : ((rating - currentTier.threshold) /
                  (nextTier.threshold - currentTier.threshold))
              .clamp(0.0, 1.0);
    final xpToNext = nextTier == null
        ? 0
        : math.max(0, (nextTier.threshold - rating) * 3);

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
                CoachSpeech.sticky(
                  messages: celebrateMessage != null
                      ? [celebrateMessage!, ..._lines(l)]
                      : _lines(l),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(currentTier.icon, color: currentTier.color, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      currentTier.label(l).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: currentTier.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$xp XP',
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
                    valueColor: AlwaysStoppedAnimation(currentTier.color),
                  ),
                ),
                if (nextTier != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l.xpToNextLeague(xpToNext, nextTier.label(l)),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Puzzle level tile (uses PuzzlePedestalPainter + PlayerStone3D) ──────────

class _LevelTile extends StatefulWidget {
  final int level;
  final int rowIndex;
  final bool unlocked;
  final bool isCurrent;
  final int xpNeeded;
  final GardenTheme theme;

  const _LevelTile({
    required this.level,
    required this.rowIndex,
    required this.unlocked,
    required this.isCurrent,
    required this.xpNeeded,
    required this.theme,
  });

  @override
  State<_LevelTile> createState() => _LevelTileState();
}

class _LevelTileState extends State<_LevelTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isCurrent) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_LevelTile old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !old.isCurrent) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isCurrent && old.isCurrent) {
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
    final l = AppLocalizations.of(context);
    final alignment = switch (widget.rowIndex % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };

    final width = widget.isCurrent ? 108.0 : 92.0;
    final height = widget.isCurrent ? 78.0 : 66.0;

    final tileColor = !widget.unlocked
        ? Colors.blueGrey.shade700
        : widget.theme.tileBase;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: alignment,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final glow = widget.isCurrent
                ? Curves.easeInOut.transform(_pulse.value)
                : 0.0;
            return SizedBox(
              width: width,
              height: height + (widget.isCurrent ? 36 : 0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  if (widget.isCurrent)
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
                      painter: PuzzlePedestalPainter(
                        baseColor: tileColor,
                        unlocked: widget.unlocked,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.30,
                    child: SizedBox(
                      width: width,
                      child: Center(
                        child: widget.unlocked
                            ? Text(
                                '${widget.level}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.isCurrent ? 30 : 22,
                                  fontWeight: FontWeight.w900,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  if (widget.xpNeeded > 0)
                                    Text(
                                      l.xpToUnlock(widget.xpNeeded),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  if (widget.isCurrent)
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
    );
  }
}
