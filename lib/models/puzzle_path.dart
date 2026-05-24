/// Candy-crush-style puzzle map data model.
///
/// A [PuzzlePath] is an ordered sequence of [PuzzleNode]s built from the
/// merged puzzle pool (curated JSON + OGS imports + legacy code puzzles).
/// Nodes are grouped into three "worlds" by ascending difficulty:
///
///  - **Beginner** (difficulty 1-2)        — first ~60 puzzles
///  - **Intermediate** (difficulty 3)      — next ~80 puzzles
///  - **Advanced** (difficulty 4-5)         — remaining puzzles
///
/// Every 10th node is a "boss" tile (larger, gold-bordered) to give the
/// player a sense of milestone progression.
library;

import 'puzzle.dart';

/// Visual variant of a node on the map.
enum PuzzleNodeType {
  /// Standard 80×80 tile.
  regular,

  /// Larger gold-bordered milestone tile, placed every 10th node.
  boss,
}

/// World groupings shown as banner separators on the map.
enum PuzzleWorld { beginner, intermediate, advanced }

/// Single node on the candy-crush puzzle map.
class PuzzleNode {
  final String puzzleId;
  final int order; // 1-based — displayed as the node number
  final PuzzleNodeType type;
  final PuzzleWorld world;

  const PuzzleNode({
    required this.puzzleId,
    required this.order,
    required this.type,
    required this.world,
  });
}

/// The full ordered map.
class PuzzlePath {
  final List<PuzzleNode> nodes;

  const PuzzlePath(this.nodes);

  /// First node in [world], or null if none exist.
  PuzzleNode? firstNodeOfWorld(PuzzleWorld world) {
    for (final n in nodes) {
      if (n.world == world) return n;
    }
    return null;
  }

  /// Builds a path from the merged puzzle pool. Sorts by difficulty so the
  /// player walks from easy to hard; ties broken by id for determinism.
  factory PuzzlePath.fromPuzzles(List<Puzzle> puzzles) {
    final sorted = List<Puzzle>.from(puzzles)
      ..removeWhere((p) => p.solution.isEmpty)
      ..sort((a, b) {
        final byDiff = a.difficulty.compareTo(b.difficulty);
        if (byDiff != 0) return byDiff;
        return a.id.compareTo(b.id);
      });

    final nodes = <PuzzleNode>[];
    for (int i = 0; i < sorted.length; i++) {
      final p = sorted[i];
      final order = i + 1;
      final world = _worldFor(p.difficulty, order);
      final isBoss = order % 10 == 0;
      nodes.add(
        PuzzleNode(
          puzzleId: p.id,
          order: order,
          type: isBoss ? PuzzleNodeType.boss : PuzzleNodeType.regular,
          world: world,
        ),
      );
    }
    return PuzzlePath(nodes);
  }

  static PuzzleWorld _worldFor(int difficulty, int order) {
    // Difficulty is the primary signal, but cap by order so the first ~60
    // nodes are always beginner-world regardless of an outlier-hard puzzle
    // that happened to fall early.
    if (difficulty <= 2 && order <= 60) return PuzzleWorld.beginner;
    if (difficulty <= 3 && order <= 140) return PuzzleWorld.intermediate;
    return PuzzleWorld.advanced;
  }
}
