import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../models/league_tier.dart';
import '../models/puzzle.dart';
import '../models/puzzle_path.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../widgets/coach_speech.dart';
import 'puzzle_screen.dart';

/// Duolingo-meets-Chess.com Puzzles hub.
///
/// Replaces the v1 Map/List toggle with a single polished screen:
///   - Sticky panda coach + XP/league progress bar at the top
///   - Painted "garden" environment (sky → mountains → hills → grass)
///   - Winding path tiles, with the player's pseudo-3D Go-stone avatar
///     perched on the next unsolved node
///   - World banners with locked/unlocked gates tied to XP thresholds
///
/// World gating mirrors the v1 candy-crush map:
///   Beginner — always open
///   Intermediate — 50 XP (~5 puzzles solved)
///   Advanced — 150 XP (~15 puzzles solved)
class PuzzleGardenScreen extends StatefulWidget {
  const PuzzleGardenScreen({super.key});

  @override
  State<PuzzleGardenScreen> createState() => _PuzzleGardenScreenState();
}

class _PuzzleGardenScreenState extends State<PuzzleGardenScreen> {
  PuzzlePath? _path;
  Map<String, Puzzle> _byId = const {};
  final ScrollController _scroll = ScrollController();

  /// Snapshot of the league at the previous build — used to trigger a
  /// short league-up celebration if the player crosses a threshold while
  /// the screen is mounted.
  LeagueTier? _lastLeague;
  String? _celebrateMessage;

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
    final puzzles = await ContentService.loadAllPuzzles();
    if (!mounted) return;
    setState(() {
      _path = PuzzlePath.fromPuzzles(puzzles);
      _byId = {for (final p in puzzles) p.id: p};
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToFrontier();
    });
  }

  void _scrollToFrontier() {
    final path = _path;
    if (path == null) return;
    final progress = context.read<ProgressService>();
    final idx = path.nodes.indexWhere(
      (n) => !progress.isPuzzleSolved(n.puzzleId),
    );
    if (idx <= 0) return;
    // With reverse:true the offset still grows toward "later" content
    // (visually upward), so this formula still scrolls to where the player
    // is — they'll see their avatar centred on screen.
    final target = (idx * 116.0 - 220).clamp(
      0.0,
      _scroll.position.hasContentDimensions
          ? _scroll.position.maxScrollExtent
          : double.infinity,
    );
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isWorldLocked(PuzzleWorld world, ProgressService progress) {
    switch (world) {
      case PuzzleWorld.beginner:
        return false;
      case PuzzleWorld.intermediate:
        return progress.xp < 50;
      case PuzzleWorld.advanced:
        return progress.xp < 150;
    }
  }

  int _xpForWorld(PuzzleWorld w) => w == PuzzleWorld.intermediate ? 50 : 150;

  Future<void> _onTileTap(PuzzleNode node, bool locked) async {
    if (locked) {
      final l = AppLocalizations.of(context);
      final progress = context.read<ProgressService>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.gateLockedUnlockAt(_xpForWorld(node.world))),
          duration: const Duration(seconds: 2),
        ),
      );
      // Cheap progress hint:
      // ignore: unused_local_variable
      final _ = progress.xp;
      return;
    }
    final puzzle = _byId[node.puzzleId];
    if (puzzle == null) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: puzzle)),
    );
    if (!mounted) return;
    if (result != null && result['solved'] == true) {
      final progress = context.read<ProgressService>();
      await progress.markPuzzleSolved(node.puzzleId);
      await progress.recordPuzzleStars(node.puzzleId, 3);
      setState(() {});
    }
  }

  void _maybeCelebrateLeague(LeagueTier current, AppLocalizations l) {
    final prev = _lastLeague;
    _lastLeague = current;
    if (prev == null || prev.threshold >= current.threshold) return;
    // Threshold crossed during this session — congratulate.
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
    final path = _path;
    if (path == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final progress = context.watch<ProgressService>();
    final l = AppLocalizations.of(context);
    final firstUnsolvedIdx = path.nodes.indexWhere(
      (n) => !progress.isPuzzleSolved(n.puzzleId),
    );
    final currentTier = LeagueTier.forRating(progress.puzzleRating);
    _maybeCelebrateLeague(currentTier, l);

    final children = <Widget>[];
    PuzzleWorld? lastWorld;
    for (int i = 0; i < path.nodes.length; i++) {
      final node = path.nodes[i];
      if (node.world != lastWorld) {
        children.add(
          _WorldGate(
            world: node.world,
            locked: _isWorldLocked(node.world, progress),
            xpThreshold: _xpForWorld(node.world),
            currentXp: progress.xp,
          ),
        );
        lastWorld = node.world;
      }
      final locked = _isWorldLocked(node.world, progress);
      children.add(
        _PuzzleTile(
          node: node,
          rowIndex: i,
          isNext: i == firstUnsolvedIdx && !locked,
          isSolved: progress.isPuzzleSolved(node.puzzleId),
          stars: progress.starsFor(node.puzzleId),
          locked: locked,
          playerColor: 1, // black avatar — neutral for both colours in puzzles
          onTap: () => _onTileTap(node, locked),
        ),
      );
    }

    return Stack(
      children: [
        // Painted Duolingo-style environment fills the whole screen.
        Positioned.fill(
          child: CustomPaint(painter: _GardenBackgroundPainter()),
        ),
        // Scrolling path. reverse:true so node 1 sits at the bottom and the
        // player physically climbs upward through the worlds.
        Positioned.fill(
          child: ListView(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
            children: children,
          ),
        ),
        // Sticky header — coach + XP/league progress bar.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _StickyCoachHeader(
            currentTier: currentTier,
            rating: progress.puzzleRating,
            xp: progress.xp,
            streakCount: _solvedStreakHint(progress, path, firstUnsolvedIdx),
            celebrateMessage: _celebrateMessage,
          ),
        ),
      ],
    );
  }

  /// Returns the current consecutive-solve count from the tip of the path
  /// (i.e. how many puzzles in a row leading up to the frontier the user
  /// has solved). Used to pick a streak-flavoured coach line.
  int _solvedStreakHint(
    ProgressService progress,
    PuzzlePath path,
    int frontier,
  ) {
    if (frontier <= 0) return 0;
    int count = 0;
    for (int i = frontier - 1; i >= 0; i--) {
      if (progress.isPuzzleSolved(path.nodes[i].puzzleId)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}

// ── Sticky coach + XP bar header ────────────────────────────────────────────

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

  List<String> _coachLines(AppLocalizations l) {
    final lines = <String>[
      l.coachStreakIntro1,
      l.coachStreakIntro2,
      l.coachStreakIntro3,
      l.coachStreakIntro4,
      l.coachStreakIntro5,
      l.coachKeepGoing,
    ];
    if (streakCount >= 3) {
      lines.insert(0, l.coachSolve3);
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nextTier = LeagueTier.nextAbove(rating);
    final progressFrac = nextTier == null
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
                      ? [celebrateMessage!, ..._coachLines(l)]
                      : _coachLines(l),
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
                    value: progressFrac,
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

// ── World gates ─────────────────────────────────────────────────────────────

class _WorldGate extends StatelessWidget {
  final PuzzleWorld world;
  final bool locked;
  final int xpThreshold;
  final int currentXp;

  const _WorldGate({
    required this.world,
    required this.locked,
    required this.xpThreshold,
    required this.currentXp,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final spec = _worldSpec(world);
    final title = switch (world) {
      PuzzleWorld.beginner => l.world1Beginner,
      PuzzleWorld.intermediate => l.world2Intermediate,
      PuzzleWorld.advanced => l.world3Advanced,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: locked
                ? [Colors.grey.shade600, Colors.grey.shade800]
                : [spec.color.withValues(alpha: 0.9), spec.color],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (locked ? Colors.black : spec.color).withValues(
                alpha: 0.4,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock : spec.icon,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      fontSize: 15,
                    ),
                  ),
                  if (locked) ...[
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

({Color color, IconData icon}) _worldSpec(PuzzleWorld w) {
  switch (w) {
    case PuzzleWorld.beginner:
      return (color: const Color(0xFF388E3C), icon: Icons.eco);
    case PuzzleWorld.intermediate:
      return (color: const Color(0xFF1976D2), icon: Icons.water);
    case PuzzleWorld.advanced:
      return (
        color: const Color(0xFF7B1FA2),
        icon: Icons.local_fire_department,
      );
  }
}

// ── Puzzle tile + player avatar ─────────────────────────────────────────────

class _PuzzleTile extends StatelessWidget {
  final PuzzleNode node;
  final int rowIndex;
  final bool isNext;
  final bool isSolved;
  final int stars;
  final bool locked;
  final int playerColor;
  final VoidCallback onTap;

  const _PuzzleTile({
    required this.node,
    required this.rowIndex,
    required this.isNext,
    required this.isSolved,
    required this.stars,
    required this.locked,
    required this.playerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Zigzag alignment for the winding-path feel.
    final alignment = switch (rowIndex % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };
    final boss = node.type == PuzzleNodeType.boss;
    final size = boss ? 92.0 : 72.0;

    final baseColor = locked
        ? Colors.grey.shade700
        : isSolved
        ? const Color(0xFF43A047)
        : isNext
        ? const Color(0xFF1E88E5)
        : Colors.blueGrey.shade600;

    final borderColor = boss
        ? const Color(0xFFFFC107)
        : Colors.white.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar floats above the next-up tile.
            SizedBox(
              height: 44,
              child: isNext && !locked
                  ? _PlayerStoneAvatar(color: playerColor)
                  : const SizedBox.shrink(),
            ),
            // 48×48 minimum hit area — wraps the visual tile.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: SizedBox(
                width: math.max(size + 16, 56),
                height: math.max(size + 16, 56),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.3),
                        radius: 0.95,
                        colors: [
                          baseColor.withValues(alpha: 1.0),
                          baseColor.withValues(alpha: 0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(boss ? 22 : 18),
                      border: Border.all(
                        color: borderColor,
                        width: boss ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.55),
                          blurRadius: locked ? 4 : 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Center(
                      child: locked
                          ? const Icon(
                              Icons.lock,
                              color: Colors.amber,
                              size: 26,
                            )
                          : isSolved
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 32,
                            )
                          : Text(
                              '${node.order}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: boss ? 26 : 22,
                                fontWeight: FontWeight.w900,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            if (isSolved) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pseudo-3D Go stone used as the player avatar. Radial gradient gives the
/// illusion of a top-left light source — same trick as the in-game board
/// stones, so the visual language stays consistent.
class _PlayerStoneAvatar extends StatefulWidget {
  /// 1 = black, 2 = white. Defaults to black; white available for future use.
  final int color;
  const _PlayerStoneAvatar({required this.color});

  @override
  State<_PlayerStoneAvatar> createState() => _PlayerStoneAvatarState();
}

class _PlayerStoneAvatarState extends State<_PlayerStoneAvatar>
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
    final isBlack = widget.color == 1;
    final colors = isBlack
        ? const [Color(0xFF666666), Color(0xFF111111), Color(0xFF000000)]
        : const [Color(0xFFFAFAFA), Color(0xFFE0E0E0), Color(0xFFBDBDBD)];
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final dy = -2 - 4 * (1 - Curves.easeInOut.transform(_bob.value));
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.45, -0.45),
            radius: 0.95,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painted environment ─────────────────────────────────────────────────────

/// Painter that lays down a Duolingo-esque scene: sky gradient at the top,
/// soft mountain silhouettes, a band of rolling hills, and a foreground
/// grass tint. No assets needed.
class _GardenBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Sky gradient — sunrise blue → soft cream.
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB8DCF0), Color(0xFFE0EAD9), Color(0xFFF5E6C8)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    // Distant mountains — three layered ridges.
    final mountainPaints = [
      Paint()..color = const Color(0xFFB8B5C8).withValues(alpha: 0.55),
      Paint()..color = const Color(0xFFA29DB8).withValues(alpha: 0.7),
      Paint()..color = const Color(0xFF8D88A6).withValues(alpha: 0.85),
    ];
    for (int layer = 0; layer < 3; layer++) {
      final amplitude = 30.0 + layer * 18.0;
      final yBase = h * (0.35 + layer * 0.05);
      final path = Path()..moveTo(0, h);
      path.lineTo(0, yBase);
      for (double x = 0; x <= w; x += 24) {
        final t = (x / w) * math.pi * (2 + layer);
        final y = yBase - amplitude * (0.5 + 0.5 * math.sin(t));
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(path, mountainPaints[layer]);
    }

    // Rolling hills — green band that grounds the tiles.
    final hillsPaint = Paint()..color = const Color(0xFFA5C99B);
    final hills = Path()..moveTo(0, h);
    final hillBase = h * 0.62;
    hills.lineTo(0, hillBase);
    for (double x = 0; x <= w; x += 18) {
      final t = (x / w) * math.pi * 5;
      final y = hillBase - 18 * (0.5 + 0.5 * math.sin(t));
      hills.lineTo(x, y);
    }
    hills
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hills, hillsPaint);

    // Foreground grass tint — deeper green sitting under the path.
    final grass = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7BAE6F), Color(0xFF5C8E4F)],
      ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.3));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.7, w, h * 0.3), grass);
  }

  @override
  bool shouldRepaint(covariant _GardenBackgroundPainter oldDelegate) => false;
}
