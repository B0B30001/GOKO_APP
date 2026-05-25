import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../models/league_tier.dart';
import '../models/puzzle.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../widgets/coach_speech.dart';
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

// ── World themes ─────────────────────────────────────────────────────────────

class _GardenTheme {
  final Color skyTop;
  final Color skyBottom;
  final Color hillTop;
  final Color hillBottom;
  final Color tileBase;
  final IconData icon;
  const _GardenTheme({
    required this.skyTop,
    required this.skyBottom,
    required this.hillTop,
    required this.hillBottom,
    required this.tileBase,
    required this.icon,
  });
}

const _themes = <_GardenTheme>[
  _GardenTheme(
    // Levels 1-5 — Stone Forest
    skyTop: Color(0xFFB8DCF0),
    skyBottom: Color(0xFFF5E6C8),
    hillTop: Color(0xFFA5C99B),
    hillBottom: Color(0xFF5C8E4F),
    tileBase: Color(0xFF388E3C),
    icon: Icons.park,
  ),
  _GardenTheme(
    // Levels 6-10 — Crystal Cave
    skyTop: Color(0xFF1A1A2E),
    skyBottom: Color(0xFF16213E),
    hillTop: Color(0xFF2D3561),
    hillBottom: Color(0xFF0F3460),
    tileBase: Color(0xFF7C4DFF),
    icon: Icons.diamond,
  ),
  _GardenTheme(
    // Levels 11-15 — Copper Peaks
    skyTop: Color(0xFFFF8C42),
    skyBottom: Color(0xFFFFD700),
    hillTop: Color(0xFFCD7F32),
    hillBottom: Color(0xFF8B4513),
    tileBase: Color(0xFFE65100),
    icon: Icons.terrain,
  ),
  _GardenTheme(
    // Levels 16-20 — Diamond Tundra
    skyTop: Color(0xFFB3E5FC),
    skyBottom: Color(0xFFE3F2FD),
    hillTop: Color(0xFF80D8FF),
    hillBottom: Color(0xFF29B6F6),
    tileBase: Color(0xFF0288D1),
    icon: Icons.ac_unit,
  ),
  _GardenTheme(
    // Levels 21+ — Jade Highlands
    skyTop: Color(0xFF2E7D32),
    skyBottom: Color(0xFF4CAF50),
    hillTop: Color(0xFF1B5E20),
    hillBottom: Color(0xFF33691E),
    tileBase: Color(0xFF00BFA5),
    icon: Icons.landscape,
  ),
];

String _themeName(int themeIdx, AppLocalizations l) => switch (themeIdx) {
  0 => l.worldStoneForest,
  1 => l.worldCrystalCave,
  2 => l.worldCopperPeaks,
  3 => l.worldDiamondTundra,
  _ => l.worldJadeHighlands,
};

int _levelFor(int xp) {
  for (int i = _levelThresholds.length - 1; i >= 0; i--) {
    if (xp >= _levelThresholds[i]) return i + 1;
  }
  return 1;
}

int _themeIdxForLevel(int level) =>
    ((level - 1) ~/ 5).clamp(0, _themes.length - 1);

// ── Screen ───────────────────────────────────────────────────────────────────

class PuzzleGardenScreen extends StatefulWidget {
  const PuzzleGardenScreen({super.key});

  @override
  State<PuzzleGardenScreen> createState() => _PuzzleGardenScreenState();
}

class _PuzzleGardenScreenState extends State<PuzzleGardenScreen> {
  /// Pool of OGS puzzles the "Solve Puzzles" CTA picks from at random.
  /// Tutorials live separately in `TutorialListScreen` — this screen is
  /// puzzles-only. Hand-curated `puzzles.json` and `PuzzleData` entries are
  /// excluded (they lack a `solutionTree` and are reached via the categories
  /// screen for explicit per-puzzle study).
  List<Puzzle> _solvePool = const [];
  LeagueTier? _lastLeague;
  String? _celebrateMessage;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await ContentService.loadAllPuzzles();
    if (!mounted) return;
    setState(() {
      // OGS puzzles have a branching solutionTree; hand-curated ones don't.
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
    // ~100 px per level tile, ~96 px per world gate (every 5 levels).
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
    final theme = _themes[themeIdx];
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
        final bandThemeIdx = (i ~/ 5).clamp(0, _themes.length - 1);
        children.add(
          _WorldGate(
            themeIdx: bandThemeIdx,
            theme: _themes[bandThemeIdx],
            unlocked: xp >= _levelThresholds[i],
            xpThreshold: _levelThresholds[i],
          ),
        );
      } else {
        // Connector lives BETWEEN tiles (skip before the first tile of a band).
        children.add(
          _PathConnector(
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
              child: _ThemedBackground(themeIdx: themeIdx),
            ),
          ),
        ),
        // Floating ambient decorations (clouds + drifting petals/snow per theme).
        Positioned.fill(
          child: IgnorePointer(child: _AmbientDecorations(themeIdx: themeIdx)),
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

// ── World gate banner ─────────────────────────────────────────────────────────

class _WorldGate extends StatelessWidget {
  final int themeIdx;
  final _GardenTheme theme;
  final bool unlocked;
  final int xpThreshold;

  const _WorldGate({
    required this.themeIdx,
    required this.theme,
    required this.unlocked,
    required this.xpThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = _themeName(themeIdx, l);
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: unlocked
                ? [theme.tileBase.withValues(alpha: 0.85), theme.tileBase]
                : [Colors.grey.shade600, Colors.grey.shade800],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (unlocked ? theme.tileBase : Colors.black).withValues(
                alpha: 0.38,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              unlocked ? theme.icon : Icons.lock,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  if (!unlocked && xpThreshold > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      l.gateLockedUnlockAt(xpThreshold),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Level tile (display-only milestone) ──────────────────────────────────────

class _LevelTile extends StatefulWidget {
  final int level;
  final int rowIndex;
  final bool unlocked;
  final bool isCurrent;
  final int xpNeeded;
  final _GardenTheme theme;

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
    // Zigzag alignment for the winding-path feel.
    final alignment = switch (widget.rowIndex % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };

    // Pedestal dimensions — compressed Y for the 3/4-perspective feel that
    // makes the platform read as a thick coin viewed from slightly above,
    // not a flat circle from straight overhead.
    final width = widget.isCurrent ? 108.0 : 92.0;
    final height = widget.isCurrent ? 78.0 : 66.0; // ~70% of width

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
            // Reserve vertical room for the stone perched on the back edge of
            // the pedestal. The pedestal itself sits at the bottom of this
            // box so the stone can overlap it without clipping.
            return SizedBox(
              width: width,
              // Pedestal + stone room above it.
              height: height + (widget.isCurrent ? 36 : 0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Pulse glow ring — only when this is the player's tile.
                  if (widget.isCurrent)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: width,
                        height: height * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
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
                  // Pedestal — painted with 3D depth (top face + side band).
                  Positioned(
                    bottom: 0,
                    child: CustomPaint(
                      size: Size(width, height),
                      painter: _PedestalPainter(
                        baseColor: tileColor,
                        unlocked: widget.unlocked,
                      ),
                    ),
                  ),
                  // Level number / lock — embossed on the pedestal top face.
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
                  // Player stone sits ON the back edge of the pedestal,
                  // viewed from the same 3/4 angle. Cast shadow lands on the
                  // pedestal top.
                  if (widget.isCurrent)
                    Positioned(
                      bottom: height * 0.55,
                      child: const _PlayerStone3D(color: 1),
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

/// Paints the 3/4-perspective pedestal: bottom shadow ground, dark side band
/// suggesting thickness, lighter top face with a soft inner ring (the
/// "step" / power-up tile look), and a rim highlight along the top edge.
class _PedestalPainter extends CustomPainter {
  final Color baseColor;
  final bool unlocked;
  const _PedestalPainter({required this.baseColor, required this.unlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cast shadow on the ground (under the pedestal). Wider than the
    // pedestal so it reads as ambient occlusion.
    final shadowRect = Rect.fromLTWH(w * 0.08, h * 0.88, w * 0.84, h * 0.18);
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = Colors.black.withValues(alpha: unlocked ? 0.30 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Side band — darker shade, visible as the "thickness" of the coin.
    final sideRect = Rect.fromLTWH(0, h * 0.30, w, h * 0.70);
    final sideColor = Color.lerp(baseColor, Colors.black, 0.42)!;
    canvas.drawOval(sideRect, Paint()..color = sideColor);

    // Top face — slightly smaller oval, sits on the upper portion of the
    // pedestal. Radial gradient lit from upper-left.
    final topRect = Rect.fromLTWH(0, 0, w, h * 0.62);
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.95,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.20)!,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.18)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(topRect);
    canvas.drawOval(topRect, topPaint);

    // Rim highlight along the top edge — thin arc of light.
    final rimRect = Rect.fromLTWH(w * 0.06, h * 0.02, w * 0.88, h * 0.38);
    canvas.drawArc(
      rimRect,
      3.14, // π — start from left
      3.14, // sweep 180° (top half only)
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // Inner ring on the top face — gives the "stepped pedestal" / power-up
    // platform look reminiscent of Mario / Candy Crush map tiles.
    final innerRect = Rect.fromLTWH(w * 0.20, h * 0.10, w * 0.60, h * 0.42);
    canvas.drawOval(
      innerRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _PedestalPainter old) =>
      old.baseColor != baseColor || old.unlocked != unlocked;
}

// ── Connector path between consecutive level tiles ─────────────────────────

/// A short curved segment painted in the space between two level tiles. The
/// curve flows in the same zigzag direction as the tile alignment, so the
/// path reads as one continuous winding road (Candy Crush / Chess.com style).
///
/// Drawn as a dashed line when the next tile is locked, solid cream when
/// unlocked. Sits BEHIND the tiles in stacking order because the parent
/// ListView paints children in order — but visually the connector reads as
/// part of the same layer.
class _PathConnector extends StatelessWidget {
  final int rowIndex;
  final bool unlocked;
  final _GardenTheme theme;
  const _PathConnector({
    required this.rowIndex,
    required this.unlocked,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: CustomPaint(
        size: const Size(double.infinity, 22),
        painter: _PathConnectorPainter(
          rowIndex: rowIndex,
          unlocked: unlocked,
          accent: theme.tileBase,
        ),
      ),
    );
  }
}

class _PathConnectorPainter extends CustomPainter {
  final int rowIndex;
  final bool unlocked;
  final Color accent;
  const _PathConnectorPainter({
    required this.rowIndex,
    required this.unlocked,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Figure out where the previous and next tile centres sit horizontally
    // based on the same zigzag rule used by _LevelTile.
    double xFor(int idx) => switch (idx % 4) {
      0 => w * 0.16, // centerLeft
      1 => w * 0.50, // center
      2 => w * 0.84, // centerRight
      _ => w * 0.50,
    };
    final xPrev = xFor(rowIndex - 1);
    final xNext = xFor(rowIndex);

    final color = unlocked
        ? const Color(0xFFF5E6D3) // dirt/cream
        : Colors.grey.shade500;

    // Cubic Bezier from previous tile centre to next, with a vertical bulge
    // to suggest the path arcs around the level badge.
    final path = Path()
      ..moveTo(xPrev, h)
      ..cubicTo(xPrev, h * 0.4, xNext, h * 0.6, xNext, 0);

    // Soft drop shadow under the line for depth.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    if (unlocked) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.85),
      );
    } else {
      // Dashed segment for locked future levels.
      final dashed = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.55);
      _drawDashedPath(canvas, path, dashed, dashLength: 7, gapLength: 5);
    }
  }

  /// Walks [path] in arc-length steps and emits alternating filled/empty
  /// segments. Used for locked connectors to read as "future levels."
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dashLength : gapLength);
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            paint,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter old) =>
      old.rowIndex != rowIndex ||
      old.unlocked != unlocked ||
      old.accent != accent;
}

// ── Player stone — 3rd-person side view, sits ON the pedestal ──────────────

/// The player's Go-stone avatar rendered from a slight 3/4 perspective so it
/// looks like a real stone sitting on top of a pedestal, not a flat disc
/// floating above the board.
///
/// Composition (bottom-to-top in the Stack):
///   1. Cast shadow ellipse on the pedestal top (compressed, dark, blurred)
///   2. Stone body — width > height (perspective compression), 3-stop radial
///      gradient with the bright spot near the upper-left
///   3. Specular highlight — small white flare at the top-left to imply
///      polished glass
///
/// Subtle 4px bob on a 1600ms loop so the avatar feels alive without
/// distracting from the level number underneath.
class _PlayerStone3D extends StatefulWidget {
  /// 1 = black stone, 2 = white stone.
  final int color;
  const _PlayerStone3D({required this.color});

  @override
  State<_PlayerStone3D> createState() => _PlayerStone3DState();
}

class _PlayerStone3DState extends State<_PlayerStone3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stone is rendered as an oval (perspective-compressed) to read as a
    // real Go stone viewed from 3/4 above. Width:height ≈ 1.45:1.
    const stoneW = 42.0;
    const stoneH = 30.0;
    const shadowW = 36.0;
    const shadowH = 9.0;
    final isBlack = widget.color == 1;
    final baseColors = isBlack
        ? const [Color(0xFFA0A0A0), Color(0xFF2A2A2A), Color(0xFF050505)]
        : const [Color(0xFFFFFFFF), Color(0xFFE6E6E6), Color(0xFFA8A8A8)];

    return AnimatedBuilder(
      animation: _bob,
      builder: (ctx, child) {
        // Subtle bob — the stone "breathes" on the pedestal but stays planted.
        final t = Curves.easeInOut.transform(_bob.value);
        final dy = -2.0 - 3.0 * (1 - t);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: SizedBox(
        width: stoneW,
        height: stoneH + shadowH + 4,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Cast shadow on the pedestal top — drawn first so the stone
            // sits over it. Slight Y-offset down so it reads as on the
            // surface, not under it.
            Positioned(
              bottom: 0,
              child: Container(
                width: shadowW,
                height: shadowH,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(shadowW, shadowH),
                  ),
                  color: Colors.black.withValues(alpha: 0.42),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            // Stone body — oval with 3-stop radial gradient.
            Positioned(
              top: 0,
              child: Container(
                width: stoneW,
                height: stoneH,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(stoneW, stoneH),
                  ),
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.45),
                    radius: 0.95,
                    colors: baseColors,
                    stops: const [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
            // Specular highlight — small bright flare near the upper-left.
            Positioned(
              top: stoneH * 0.12,
              left: stoneW * 0.18,
              child: Container(
                width: stoneW * 0.32,
                height: stoneH * 0.30,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.elliptical(14, 5)),
                  gradient: RadialGradient(
                    colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ambient floating decorations (clouds, petals, butterflies) ─────────────

/// Layered ambient overlay that softens the painted environment so it reads
/// as a living scene rather than flat geometry. Each theme band has its own
/// drifting motifs — petals in the forest, sparkles in the cave, embers in
/// the peaks, snowflakes on the tundra, leaves in the highlands.
class _AmbientDecorations extends StatefulWidget {
  final int themeIdx;
  const _AmbientDecorations({required this.themeIdx});

  @override
  State<_AmbientDecorations> createState() => _AmbientDecorationsState();
}

class _AmbientDecorationsState extends State<_AmbientDecorations>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _AmbientPainter(themeIdx: widget.themeIdx, t: _ctrl.value),
        );
      },
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final int themeIdx;
  final double t;
  const _AmbientPainter({required this.themeIdx, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Clouds drift gently across all themes — varying opacity per theme.
    final cloudOpacity = switch (themeIdx) {
      1 => 0.10, // crystal cave — dim
      _ => 0.45,
    };
    _paintClouds(canvas, w, h, cloudOpacity);

    // Theme-specific drifting motifs.
    switch (themeIdx) {
      case 0:
        _paintMotifs(canvas, w, h, motif: _Motif.petal, count: 12);
        break;
      case 1:
        _paintMotifs(canvas, w, h, motif: _Motif.sparkle, count: 18);
        break;
      case 2:
        _paintMotifs(canvas, w, h, motif: _Motif.ember, count: 14);
        break;
      case 3:
        _paintMotifs(canvas, w, h, motif: _Motif.snow, count: 16);
        break;
      default:
        _paintMotifs(canvas, w, h, motif: _Motif.leaf, count: 10);
    }
  }

  void _paintClouds(Canvas canvas, double w, double h, double opacity) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    // Three clouds drifting at different speeds and altitudes.
    final positions = [(0.6, 0.10, 1.0), (0.3, 0.18, 0.6), (0.85, 0.28, 0.45)];
    for (int i = 0; i < positions.length; i++) {
      final (yFrac, sizeFrac, speed) = (
        positions[i].$2,
        positions[i].$3,
        0.4 + i * 0.15,
      );
      final cx = ((positions[i].$1 + t * speed) % 1.2 - 0.1) * w;
      final cy = yFrac * h;
      final radius = 32.0 * sizeFrac;
      // Three overlapping ellipses make a puffy cloud silhouette.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: radius * 3,
          height: radius * 1.4,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - radius, cy + 4),
          width: radius * 1.8,
          height: radius,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + radius, cy + 6),
          width: radius * 1.5,
          height: radius * 0.9,
        ),
        paint,
      );
    }
  }

  void _paintMotifs(
    Canvas canvas,
    double w,
    double h, {
    required _Motif motif,
    required int count,
  }) {
    final rng = math.Random(motif.index * 1000 + 7);
    for (int i = 0; i < count; i++) {
      // Each motif drifts down (or floats up for embers) at its own speed.
      final baseX = rng.nextDouble();
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble();
      final yProg = ((t * speed + phase) % 1.0);
      final cx = (baseX * w) + math.sin((t + phase) * math.pi * 2) * 12;
      final cy = motif == _Motif.ember
          ? h *
                (1.0 - yProg) // embers float up
          : h * yProg; // others drift down
      final scale = 0.5 + rng.nextDouble() * 0.6;
      _paintMotif(canvas, motif, Offset(cx, cy), scale);
    }
  }

  void _paintMotif(Canvas canvas, _Motif motif, Offset c, double scale) {
    switch (motif) {
      case _Motif.petal:
        final p = Paint()
          ..color = const Color(0xFFFFC1CC).withValues(alpha: 0.7);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 8 * scale, height: 5 * scale),
          p,
        );
        break;
      case _Motif.sparkle:
        final p = Paint()
          ..color = const Color(0xFFE1BEE7).withValues(alpha: 0.85);
        canvas.drawCircle(c, 1.5 * scale, p);
        canvas.drawCircle(
          c,
          0.8 * scale,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
        break;
      case _Motif.ember:
        final p = Paint()
          ..color = const Color(0xFFFFAB40).withValues(alpha: 0.75);
        canvas.drawCircle(c, 2 * scale, p);
        canvas.drawCircle(
          c,
          1 * scale,
          Paint()..color = const Color(0xFFFFE0B2).withValues(alpha: 0.7),
        );
        break;
      case _Motif.snow:
        final p = Paint()..color = Colors.white.withValues(alpha: 0.8);
        canvas.drawCircle(c, 2.2 * scale, p);
        break;
      case _Motif.leaf:
        final p = Paint()
          ..color = const Color(0xFFAED581).withValues(alpha: 0.7);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 7 * scale, height: 4 * scale),
          p,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) =>
      old.t != t || old.themeIdx != themeIdx;
}

enum _Motif { petal, sparkle, ember, snow, leaf }

// ── Themed background: PNG asset first, painter fallback ────────────────────

const _themeAssetNames = <String>[
  'stone_forest',
  'crystal_cave',
  'copper_peaks',
  'diamond_tundra',
  'jade_highlands',
];

/// Tries to load the Canva-designed background PNG for the given theme. If
/// the asset isn't bundled, falls back to the procedural
/// [_GardenBackgroundPainter] so the screen always has something to render.
///
/// To swap a background in: drop `assets/backgrounds/<theme>.png` into the
/// repo (see `assets/backgrounds/README.md`). No code change needed.
class _ThemedBackground extends StatelessWidget {
  final int themeIdx;
  const _ThemedBackground({required this.themeIdx});

  String get _assetPath {
    final name =
        _themeAssetNames[themeIdx.clamp(0, _themeAssetNames.length - 1)];
    return 'assets/backgrounds/$name.png';
  }

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      painter: _GardenBackgroundPainter(themeIdx: themeIdx),
      size: Size.infinite,
    );
    // `Image.asset` throws asynchronously on missing files; route the error
    // to the painter so we never see a broken image icon.
    return Image.asset(
      _assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // No frameBuilder: we want the painter immediately, not after fade-in.
      errorBuilder: (_, __, ___) => painter,
    );
  }
}

// ── Painted environment (fallback when no PNG asset is bundled) ─────────────

class _GardenBackgroundPainter extends CustomPainter {
  final int themeIdx;
  const _GardenBackgroundPainter({required this.themeIdx});

  @override
  void paint(Canvas canvas, Size size) {
    final theme = _themes[themeIdx.clamp(0, _themes.length - 1)];
    final w = size.width;
    final h = size.height;

    // Sky gradient — soft three-stop blend for natural light depth.
    final skyMid = Color.lerp(theme.skyTop, theme.skyBottom, 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.skyTop, skyMid, theme.skyBottom],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Soft sun/moon halo near the upper-left — adds focal light without
    // looking like a hard disc.
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.16),
      80,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(w * 0.78, h * 0.16), radius: 80),
            )
        ..blendMode = BlendMode.plus,
    );

    // Layered curved ridges using cubic Bezier paths for an organic skyline
    // (no zigzag spikes). Each layer is a smooth flowing silhouette.
    for (int layer = 0; layer < 3; layer++) {
      final yBase = h * (0.30 + layer * 0.08);
      final amplitude = 28.0 + layer * 16.0;
      final opacity = 0.30 + layer * 0.18;
      final ridgePaint = Paint()
        ..color = theme.hillTop.withValues(alpha: opacity);
      final path = Path()
        ..moveTo(0, h)
        ..lineTo(0, yBase);

      // Cubic peaks: 4 control points across the width make graceful arcs.
      final peaks = 4 + layer;
      final dx = w / peaks;
      double prevX = 0, prevY = yBase;
      for (int p = 0; p < peaks; p++) {
        final x1 = prevX + dx * 0.35;
        final x2 = prevX + dx * 0.65;
        final endX = prevX + dx;
        final dipAmount = ((p + layer) % 2 == 0) ? amplitude : amplitude * 0.55;
        final y1 = yBase - dipAmount;
        final y2 = yBase - dipAmount * 0.85;
        path.cubicTo(x1, y1, x2, y2, endX, prevY);
        prevX = endX;
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(path, ridgePaint);
    }

    // Mid-ground rolling hills — softer curves rather than sine spikes.
    final hills = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.62);
    final hillPeaks = 5;
    final hdx = w / hillPeaks;
    double prevX = 0;
    for (int p = 0; p < hillPeaks; p++) {
      final endX = prevX + hdx;
      final midX = prevX + hdx / 2;
      final dip = h * 0.62 - (p.isEven ? 28.0 : 18.0);
      hills.quadraticBezierTo(midX, dip, endX, h * 0.62);
      prevX = endX;
    }
    hills
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hills, Paint()..color = theme.hillTop);

    // Foreground ground band — gradient from mid hill tone into the deeper
    // shade beneath, giving a sense of nearness.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.74, w, h * 0.26),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.hillTop, theme.hillBottom],
        ).createShader(Rect.fromLTWH(0, h * 0.74, w, h * 0.26)),
    );

    // Subtle ground-line speckles — tiny dots suggest grass or stones.
    final speckle = Paint()..color = theme.hillBottom.withValues(alpha: 0.4);
    final speckleRng = math.Random(themeIdx * 13 + 5);
    for (int i = 0; i < 40; i++) {
      final sx = speckleRng.nextDouble() * w;
      final sy = h * 0.76 + speckleRng.nextDouble() * (h * 0.22);
      canvas.drawCircle(
        Offset(sx, sy),
        0.8 + speckleRng.nextDouble() * 1.4,
        speckle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GardenBackgroundPainter old) =>
      old.themeIdx != themeIdx;
}
