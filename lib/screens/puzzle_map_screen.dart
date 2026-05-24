import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../models/puzzle.dart';
import '../models/puzzle_path.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import 'puzzle_screen.dart';

/// Candy-crush-style puzzle progression map.
///
/// Renders the merged puzzle pool as a vertical winding path of tiles
/// grouped into Beginner / Intermediate / Advanced worlds. Solved tiles
/// flip green with stars; the next-unsolved tile pulses to draw the eye;
/// later tiles are locked until the previous is solved.
///
/// Designed to live inside the Puzzles hub via a Map/List toggle, so it
/// renders without its own Scaffold — the host hub provides nav + AppBar.
class PuzzleMapScreen extends StatefulWidget {
  const PuzzleMapScreen({super.key});

  @override
  State<PuzzleMapScreen> createState() => _PuzzleMapScreenState();
}

class _PuzzleMapScreenState extends State<PuzzleMapScreen> {
  PuzzlePath? _path;
  Map<String, Puzzle> _byId = const {};
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
    final puzzles = await ContentService.loadAllPuzzles();
    if (!mounted) return;
    setState(() {
      _path = PuzzlePath.fromPuzzles(puzzles);
      _byId = {for (final p in puzzles) p.id: p};
    });
    // Scroll to the next unsolved node after layout so the user opens the
    // map at their current frontier — not at puzzle 1 they finished weeks ago.
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
    // Each "row" is ~120px tall; estimate target offset and clamp to extent.
    final target = (idx * 120.0 - 200).clamp(
      0.0,
      _scroll.position.hasContentDimensions
          ? _scroll.position.maxScrollExtent
          : double.infinity,
    );
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    if (path == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final progress = context.watch<ProgressService>();
    final firstUnsolvedIdx = path.nodes.indexWhere(
      (n) => !progress.isPuzzleSolved(n.puzzleId),
    );

    // Emit per-world sections so banners separate them visually.
    final children = <Widget>[];
    PuzzleWorld? lastWorld;
    for (int i = 0; i < path.nodes.length; i++) {
      final node = path.nodes[i];
      if (node.world != lastWorld) {
        children.add(_WorldBanner(world: node.world, index: i));
        lastWorld = node.world;
      }
      final locked = _isLocked(node, progress);
      children.add(
        _MapTile(
          node: node,
          rowIndex: i,
          isNext: i == firstUnsolvedIdx && !locked,
          isSolved: progress.isPuzzleSolved(node.puzzleId),
          stars: progress.starsFor(node.puzzleId),
          locked: locked,
          onTap: () => _onTileTap(node, locked),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B2438), Color(0xFF14172A)],
        ),
      ),
      // reverse=true renders item 0 (easiest) at bottom — player climbs up.
      child: ListView(
        controller: _scroll,
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: children,
      ),
    );
  }

  /// Returns true when [node]'s world is not yet unlocked by the player's XP.
  /// Beginner is always open. Intermediate unlocks at 50 XP (~5 puzzles).
  /// Advanced unlocks at 150 XP (~15 puzzles).
  bool _isLocked(PuzzleNode node, ProgressService progress) {
    switch (node.world) {
      case PuzzleWorld.beginner:
        return false;
      case PuzzleWorld.intermediate:
        return progress.xp < 50;
      case PuzzleWorld.advanced:
        return progress.xp < 150;
    }
  }

  Future<void> _onTileTap(PuzzleNode node, bool locked) async {
    if (locked) {
      final needed = node.world == PuzzleWorld.intermediate ? 50 : 150;
      final progress = context.read<ProgressService>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solve more puzzles to unlock — ${progress.xp}/$needed XP',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
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
      // Star scoring: 3 = solved (placeholder until hint-aware scoring lands).
      final progress = context.read<ProgressService>();
      await progress.markPuzzleSolved(node.puzzleId);
      await progress.recordPuzzleStars(node.puzzleId, 3);
      setState(() {});
    }
  }
}

// ── World banners ────────────────────────────────────────────────────────────

class _WorldBanner extends StatelessWidget {
  final PuzzleWorld world;
  final int index;
  const _WorldBanner({required this.world, required this.index});

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
      padding: EdgeInsets.only(top: index == 0 ? 8 : 28, bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [spec.color.withValues(alpha: 0.85), spec.color],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: spec.color.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(spec.icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 14,
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
      return (color: const Color(0xFF2E7D32), icon: Icons.eco);
    case PuzzleWorld.intermediate:
      return (color: const Color(0xFF1565C0), icon: Icons.water);
    case PuzzleWorld.advanced:
      return (
        color: const Color(0xFF6A1B9A),
        icon: Icons.local_fire_department,
      );
  }
}

// ── Map tile ─────────────────────────────────────────────────────────────────

class _MapTile extends StatelessWidget {
  final PuzzleNode node;
  final int rowIndex;
  final bool isNext;
  final bool isSolved;
  final int stars;
  final bool locked;
  final VoidCallback onTap;

  const _MapTile({
    required this.node,
    required this.rowIndex,
    required this.isNext,
    required this.isSolved,
    required this.stars,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Zigzag horizontal alignment to give the path a winding candy-crush
    // feel. Cycles through left -> center -> right -> center.
    final alignment = switch (rowIndex % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };

    final boss = node.type == PuzzleNodeType.boss;
    final size = boss ? 96.0 : 72.0;

    final baseColor = locked
        ? Colors.grey.shade800
        : isSolved
        ? const Color(0xFF43A047)
        : isNext
        ? const Color(0xFF1E88E5)
        : Colors.blueGrey.shade700;

    final borderColor = boss
        ? const Color(0xFFFFD54F)
        : baseColor.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseRing(
              enabled: isNext && !locked,
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(boss ? 22 : 16),
                    border: Border.all(color: borderColor, width: boss ? 3 : 2),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.45),
                        blurRadius: locked ? 0 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: locked
                        ? const Icon(Icons.lock, color: Colors.amber, size: 26)
                        : isSolved
                        ? const Icon(Icons.check, color: Colors.white, size: 30)
                        : Text(
                            '${node.order}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: boss ? 28 : 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Star row below the tile for solved nodes.
            if (isSolved)
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
        ),
      ),
    );
  }
}

/// Pulsing ring drawn behind the "next-up" tile to draw the player's eye.
class _PulseRing extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const _PulseRing({required this.child, required this.enabled});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Two staggered expanding rings for that "this is the next step"
            // chess.com-style pulse.
            Container(
              width: 72 + 30 * t,
              height: 72 + 30 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(
                    0xFF42A5F5,
                  ).withValues(alpha: (1 - t) * 0.55),
                  width: 3,
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
