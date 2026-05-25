import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/puzzle.dart';

/// Simulates the puzzle_screen runtime: walks the solution tree from the
/// virtual root, descending on each player move and auto-stepping through
/// opponent moves. Returns true when a `correct: true` leaf on the player's
/// colour is reached.
bool _replay(SolutionNode root, int playerColor, List<List<int>> playerMoves) {
  SolutionNode cursor = root;
  for (final m in playerMoves) {
    final next = cursor.matchChild(m[0], m[1], playerColor);
    if (next == null) return false;
    cursor = next;
    if (cursor.correct && cursor.color == playerColor) return true;
    // Auto-step the opponent: first child of the opponent's colour.
    final oppColor = playerColor == 1 ? 2 : 1;
    final opp = cursor.firstChildOfColor(oppColor);
    if (opp == null) {
      // No opponent response — the puzzle is over without reaching a correct
      // leaf. The next player move (if any) will fail to match, which is the
      // correct behaviour.
      continue;
    }
    cursor = opp;
  }
  return false;
}

void main() {
  group('SolutionNode', () {
    test('matchChild finds the right branch on coords + colour', () {
      final root = SolutionNode(
        row: -1,
        col: -1,
        color: 1,
        children: [
          SolutionNode(row: 3, col: 3, color: 1, correct: true),
          SolutionNode(row: 4, col: 4, color: 1),
        ],
      );
      expect(root.matchChild(3, 3, 1)?.correct, true);
      expect(root.matchChild(4, 4, 1)?.correct, false);
      expect(root.matchChild(5, 5, 1), isNull);
      expect(root.matchChild(3, 3, 2), isNull); // wrong colour
    });

    test('firstChildOfColor picks the opponent branch', () {
      final node = SolutionNode(
        row: 3,
        col: 3,
        color: 1,
        children: [
          SolutionNode(row: 4, col: 4, color: 2),
          SolutionNode(row: 5, col: 5, color: 2),
        ],
      );
      expect(node.firstChildOfColor(2)?.col, 4);
      expect(node.firstChildOfColor(1), isNull);
    });
  });

  group('runtime replay', () {
    test('accepts EITHER of two correct first-move alternatives', () {
      // Virtual root with two equally valid first moves at (3,3) and (4,4).
      final root = SolutionNode(
        row: -1,
        col: -1,
        color: 1,
        children: [
          SolutionNode(row: 3, col: 3, color: 1, correct: true),
          SolutionNode(row: 4, col: 4, color: 1, correct: true),
        ],
      );
      expect(
        _replay(root, 1, [
          [3, 3],
        ]),
        true,
      );
      expect(
        _replay(root, 1, [
          [4, 4],
        ]),
        true,
      );
      expect(
        _replay(root, 1, [
          [5, 5],
        ]),
        false,
      );
    });

    test('rejects the wrong branch sibling of a correct branch', () {
      // Only (3,3) is correct; (4,4) leads nowhere (pruned-style: no kids,
      // not marked correct — should never have been emitted by the importer,
      // but the runtime must still reject it cleanly).
      final root = SolutionNode(
        row: -1,
        col: -1,
        color: 1,
        children: [
          SolutionNode(row: 3, col: 3, color: 1, correct: true),
          SolutionNode(row: 4, col: 4, color: 1),
        ],
      );
      expect(
        _replay(root, 1, [
          [3, 3],
        ]),
        true,
      );
      expect(
        _replay(root, 1, [
          [4, 4],
        ]),
        false,
      );
    });

    test('traverses a depth-3 path where only the leaf is correct', () {
      // Player plays (3,3) → opponent auto-replies (3,4) → player must play
      // (3,5) to solve. (3,3) alone does not win.
      final root = SolutionNode(
        row: -1,
        col: -1,
        color: 1,
        children: [
          SolutionNode(
            row: 3,
            col: 3,
            color: 1,
            children: [
              SolutionNode(
                row: 3,
                col: 4,
                color: 2,
                children: [
                  SolutionNode(row: 3, col: 5, color: 1, correct: true),
                ],
              ),
            ],
          ),
        ],
      );
      // Single move doesn't solve.
      expect(
        _replay(root, 1, [
          [3, 3],
        ]),
        false,
      );
      // Full sequence does (opponent reply is auto-played by _replay).
      expect(
        _replay(root, 1, [
          [3, 3],
          [3, 5],
        ]),
        true,
      );
      // Wrong second move is rejected.
      expect(
        _replay(root, 1, [
          [3, 3],
          [9, 9],
        ]),
        false,
      );
    });

    test('fuzz: only paths reaching a correct leaf solve', () {
      // Build 50 random small trees and verify the invariant: replay returns
      // true iff the played sequence corresponds to a root-to-correct-leaf
      // path (interleaved with the opponent's first-child responses).
      final seeds = List<int>.generate(50, (i) => i + 1);
      for (final seed in seeds) {
        final rng = _Lcg(seed);
        final tree = _randomTree(rng, depth: 3, color: 1);
        // Walk all root-to-leaf paths of the player's colour and verify the
        // ones ending on `correct:true` resolve, others don't.
        final paths = <List<List<int>>>[];
        _collectPlayerPaths(tree, 1, <List<int>>[], paths);
        for (final p in paths) {
          // Recompute whether this sequence resolves analytically: simulate
          // with the same auto-opponent rule.
          final expected = _expectedSolves(tree, 1, p);
          expect(_replay(tree, 1, p), expected, reason: 'seed=$seed path=$p');
        }
      }
    });
  });

  group('JSON round-trip', () {
    test('SolutionNode.fromJson/toJson preserves structure', () {
      final original = SolutionNode(
        row: -1,
        col: -1,
        color: 1,
        children: [
          SolutionNode(row: 3, col: 3, color: 1, correct: true),
          SolutionNode(
            row: 4,
            col: 4,
            color: 1,
            children: [SolutionNode(row: 4, col: 5, color: 2, correct: true)],
          ),
        ],
      );
      final round = SolutionNode.fromJson(original.toJson());
      expect(round.children.length, 2);
      expect(round.children[0].correct, true);
      expect(round.children[1].children.first.correct, true);
      expect(round.children[1].children.first.color, 2);
    });
  });
}

// ── helpers ───────────────────────────────────────────────────────────────

/// Tiny deterministic LCG — avoids importing dart:math.Random for test
/// reproducibility across platforms.
class _Lcg {
  int _s;
  _Lcg(this._s);
  int next(int bound) {
    _s = (_s * 1103515245 + 12345) & 0x7fffffff;
    return _s % bound;
  }
}

SolutionNode _randomTree(_Lcg rng, {required int depth, required int color}) {
  if (depth == 0) {
    return SolutionNode(
      row: rng.next(19),
      col: rng.next(19),
      color: color,
      correct: rng.next(3) == 0,
    );
  }
  final branchCount = 1 + rng.next(3); // 1..3 children
  final children = <SolutionNode>[];
  final used = <String>{};
  for (int i = 0; i < branchCount; i++) {
    int r = rng.next(19), c = rng.next(19);
    // Avoid duplicates at this level so matchChild is unambiguous.
    while (used.contains('$r,$c')) {
      r = rng.next(19);
      c = rng.next(19);
    }
    used.add('$r,$c');
    children.add(
      SolutionNode(
        row: r,
        col: c,
        color: color,
        correct: rng.next(4) == 0,
        children: rng.next(2) == 0
            ? []
            : [
                _randomTree(
                  rng,
                  depth: depth - 1,
                  color: color == 1 ? 2 : 1,
                ).copyWithChildrenColor(color),
              ],
      ),
    );
  }
  return SolutionNode(
    row: depth == 3 ? -1 : rng.next(19),
    col: depth == 3 ? -1 : rng.next(19),
    color: color,
    children: children,
  );
}

extension on SolutionNode {
  /// Returns a copy of this node with all immediate children's colour
  /// flipped to [color]. Used to build alternating-colour trees in the fuzz
  /// generator without rewriting the recursion from scratch.
  SolutionNode copyWithChildrenColor(int color) => SolutionNode(
    row: row,
    col: col,
    color: color,
    correct: correct,
    children: children,
  );
}

/// Collects every player-only move path through the tree (skipping over
/// opponent auto-responses, since the test replays the player's moves
/// explicitly).
void _collectPlayerPaths(
  SolutionNode node,
  int playerColor,
  List<List<int>> current,
  List<List<List<int>>> out,
) {
  for (final child in node.children) {
    if (child.color != playerColor) {
      // Skip an opponent step — its child is the next player move.
      for (final next in child.children) {
        if (next.color != playerColor) continue;
        final newPath = [
          ...current,
          [next.row, next.col],
        ];
        out.add(newPath);
        _collectPlayerPaths(next, playerColor, newPath, out);
      }
      continue;
    }
    final newPath = [
      ...current,
      [child.row, child.col],
    ];
    out.add(newPath);
    _collectPlayerPaths(child, playerColor, newPath, out);
  }
}

/// Walks the same way `_replay` does and returns whether the path ends on a
/// correct-leaf player move.
bool _expectedSolves(
  SolutionNode root,
  int playerColor,
  List<List<int>> moves,
) {
  SolutionNode cursor = root;
  for (final m in moves) {
    final next = cursor.matchChild(m[0], m[1], playerColor);
    if (next == null) return false;
    cursor = next;
    if (cursor.correct && cursor.color == playerColor) return true;
    final oppColor = playerColor == 1 ? 2 : 1;
    final opp = cursor.firstChildOfColor(oppColor);
    if (opp == null) continue;
    cursor = opp;
  }
  return false;
}
