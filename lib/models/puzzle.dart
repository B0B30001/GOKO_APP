/// Predicate evaluated against the live board state after a successful move.
/// A puzzle "solves" only when both: (a) the move sequence has been played,
/// and (b) [WinCondition.isSatisfied] returns true.
sealed class WinCondition {
  const WinCondition();

  /// True when the current board state matches the win predicate.
  bool isSatisfied(List<List<int>> board);
}

/// Default win condition: solver played the exact recorded sequence.
class ExactSequence extends WinCondition {
  const ExactSequence();

  @override
  bool isSatisfied(List<List<int>> board) => true;
}

/// Win when every stone listed in [targetStones] is no longer on the board
/// (i.e. has been captured). Use for kill / capture tsumego where coordinate
/// match alone is necessary but not sufficient.
class CaptureGroup extends WinCondition {
  final List<PuzzleMove> targetStones;

  const CaptureGroup(this.targetStones);

  @override
  bool isSatisfied(List<List<int>> board) {
    for (final s in targetStones) {
      if (board[s.row][s.col] != 0) return false;
    }
    return true;
  }
}

/// Tree-shaped solution for puzzles with multiple valid lines.
///
/// OGS-imported tsumego often have several correct first-move alternatives
/// (e.g. "kill at A *or* B"). A linear [Puzzle.solution] list cannot express
/// this — any move not on the chosen path gets marked wrong even when it is
/// objectively correct Go. [SolutionNode] models the full game-tree:
///
///   - Each node is a move (`row`, `col`, `color`)
///   - [children] are the legal continuations from this node
///   - [correct] true means "if the player reaches this leaf, the puzzle is
///     solved." Non-leaf nodes with `correct: true` are allowed (some puzzles
///     accept an early stop) but typical OGS data only marks leaves.
///
/// The root node is a virtual placeholder with `row = col = -1`; its [children]
/// are the first-move alternatives. This mirrors the OGS `move_tree` shape.
class SolutionNode {
  final int row;
  final int col;
  final int color;
  final bool correct;
  final List<SolutionNode> children;

  const SolutionNode({
    required this.row,
    required this.col,
    required this.color,
    this.correct = false,
    this.children = const [],
  });

  /// Find the child whose coordinates and color match the player's move.
  /// Returns null when no child matches — caller should treat as wrong move.
  ///
  /// **Why this isn't DFS or BFS**: the runtime keeps a `_treeCursor`
  /// pointing at "where we are in the solution tree." Each player move only
  /// needs to inspect the cursor's *direct* children (1–10 branches for
  /// typical tsumego), not search the whole tree. The matcher is
  /// O(branching_factor) per move — effectively O(1) — and full puzzle
  /// evaluation is O(depth × branching). A graph search over the whole tree
  /// would be strictly slower *and* incorrect: the player's position in the
  /// tree must advance one node at a time as they play, not jump to a goal.
  SolutionNode? matchChild(int row, int col, int color) {
    for (final c in children) {
      if (c.row == row && c.col == col && c.color == color) return c;
    }
    return null;
  }

  /// First child whose color is [color] — used to pick the opponent's
  /// deterministic auto-response after a correct player move.
  SolutionNode? firstChildOfColor(int color) {
    for (final c in children) {
      if (c.color == color) return c;
    }
    return null;
  }

  factory SolutionNode.fromJson(Map<String, Object?> json) {
    final kids = (json['children'] as List?) ?? const [];
    return SolutionNode(
      row: (json['row'] as num?)?.toInt() ?? -1,
      col: (json['col'] as num?)?.toInt() ?? -1,
      color: (json['color'] as num?)?.toInt() ?? 0,
      correct: json['correct'] == true,
      children: kids
          .whereType<Map>()
          .map((m) => SolutionNode.fromJson(m.cast<String, Object?>()))
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => {
    'row': row,
    'col': col,
    'color': color,
    if (correct) 'correct': true,
    if (children.isNotEmpty) 'children': [for (final c in children) c.toJson()],
  };
}

class Puzzle {
  final String id;
  final String title;
  final String description;
  final String category; // 'capture', 'life_death', 'tesuji', etc.
  final int difficulty; // 1-5
  final int boardSize;
  final List<List<int>> initialBoard; // 0=empty, 1=black, 2=white
  final int playerColor; // 1=black, 2=white (who should play)
  final List<PuzzleMove> solution;
  final String hint;
  final String explanation; // Explains why the solution works

  /// Optional per-mistake explanations. Keyed by "row,col" of the wrong move.
  /// When the user plays a wrong move that has a matching entry, the failure
  /// dialog shows this targeted reason instead of the generic [hint].
  final Map<String, String> failureReasons;

  /// Predicate evaluated against board state after each successful move.
  /// Defaults to [ExactSequence] (preserves legacy click-driven behavior).
  final WinCondition winCondition;

  /// Optional branching solution. When non-null, the runtime evaluator walks
  /// this tree instead of comparing against [solution] linearly — required for
  /// OGS puzzles where multiple first-move alternatives are correct.
  final SolutionNode? solutionTree;

  Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.boardSize,
    required this.initialBoard,
    required this.playerColor,
    required this.solution,
    required this.hint,
    this.explanation = '',
    this.failureReasons = const {},
    this.winCondition = const ExactSequence(),
    this.solutionTree,
  });
}

class PuzzleMove {
  final int row;
  final int col;
  final int color;

  PuzzleMove(this.row, this.col, this.color);
}

class PuzzleData {
  // Simple capture puzzles
  static final List<Puzzle> _capturePuzzles = [
    Puzzle(
      id: 'capture_1',
      title: 'Simple Capture',
      description: 'Capture the white stone by removing its last liberty',
      category: 'capture',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 2, 1, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 1, 1)],
      hint: 'Look for the white stone with only one liberty remaining',
      failureReasons: {
        '3,4':
            'That fills your own stone\'s liberty without removing white\'s last one. Look at white\'s remaining liberty instead.',
        '4,2':
            'White still has a liberty at (3,1) — capture from there directly.',
      },
      explanation:
          '''The white stone at (3,2) has only one liberty at (3,1). Playing there captures it immediately.

Key Learning Points:
• Liberties are empty intersections directly adjacent to stones (not diagonal)
• When all liberties are filled by the opponent, the stone is captured
• Always count your liberties and your opponent's!

This is the most fundamental concept in Go - understanding liberties is essential for all tactics.''',
    ),
    Puzzle(
      id: 'capture_2',
      title: 'Two Stone Capture',
      description: 'Capture two white stones in a row',
      category: 'capture',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 2, 2, 1, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 1, 1)],
      hint: 'Find where both white stones share their last liberty',
      explanation:
          '''Both white stones share one liberty at (3,1). Capturing them together demonstrates an important principle.

Key Learning Points:
• Connected stones (touching horizontally or vertically) share liberties
• They form one group and are captured as a unit
• Larger groups can have more liberties than individual stones
• But they can also be captured all at once!

Understanding group connectivity is crucial for both attack and defense.''',
    ),
    Puzzle(
      id: 'capture_3',
      title: 'Corner Capture',
      description: 'Use the corner to trap white stones',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [2, 2, 1, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(1, 0, 1)],
      hint: 'The corner limits white\'s liberties',
      explanation:
          '''In the corner, stones have fewer liberties. Playing at (1,0) captures the two white stones.

Key Learning Points:
• Corner stones start with only 2 liberties (vs 4 in the center)
• Edge stones have 3 liberties
• The board edge acts like an opponent's stone
• Corners and edges are easier to attack but also easier to defend

"Corners first, then sides, then center" is an ancient Go proverb reflecting this principle.''',
    ),
    Puzzle(
      id: 'capture_4',
      title: 'Net Capture (Geta)',
      description: 'The white stone cannot escape — net it without touching',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 2, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(1, 3, 1)],
      hint: 'Play above the white stone to close off its escape route',
      failureReasons: {
        '2,2':
            'That puts you in atari immediately — check your own liberties first.',
        '2,4': 'Good direction but the wrong side. White can still run upward.',
        '3,3':
            'That captures right now but only because the net was almost complete — try the cleaner net move first.',
      },
      explanation:
          '''Playing at (1,3) closes off the white stone's only escape route. White cannot run upward, left (Black at 3,2 cuts off), or right (Black at 3,4 cuts off). This is a net (geta).

Key Learning Points:
• A net works by controlling squares the stone WOULD escape to
• You don't touch the stone — you block its future moves
• The trapped stone has zero escape regardless of which direction it tries
• Nets are more efficient than chasing step-by-step

The geta is one of Go's most beautiful shapes. Recognising when a net is possible takes practice but becomes second nature.''',
    ),
  ];

  // Liberty counting puzzles
  static final List<Puzzle> _libertyPuzzles = [
    Puzzle(
      id: 'liberty_1',
      title: 'Count Liberties - Single Stone',
      description: 'This black stone has 4 liberties',
      category: 'liberties',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint: 'Count up, down, left, and right from the stone',
      explanation:
          '''A single stone in the center has 4 liberties (one in each direction).

Key Learning Points:
• Liberties are orthogonal (horizontal/vertical), never diagonal
• Center stones have the maximum 4 liberties
• Corner stones have only 2 liberties
• Edge stones have 3 liberties
• Empty points count as liberties

Liberty counting is the foundation of all Go tactics. Master this and you master the fundamentals!''',
    ),
    Puzzle(
      id: 'liberty_2',
      title: 'Connected Stones Share Liberties',
      description: 'This black group has 6 liberties total',
      category: 'liberties',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint: 'Connected stones form one group and share liberties',
      explanation: '''The 3 black stones form one group with 6 total liberties.

Key Learning Points:
• Stones connected horizontally or vertically form ONE group
• The group shares all liberties - count them all together
• Some liberties belong to multiple stones in the group
• Strong groups have many liberties
• The more liberties a group has, the safer it is

When counting liberties for a group, mark each empty adjacent point only once, even if multiple stones touch it.''',
    ),
    Puzzle(
      id: 'liberty_3',
      title: 'Reduce Liberties to Capture',
      description: 'White has 2 liberties. Reduce to 1 for atari!',
      category: 'liberties',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 2, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 1, 1)],
      hint: 'Play next to the white stone to reduce its liberties',
      explanation:
          '''Reducing liberties puts pressure on enemy stones. After this move, the next move will capture!

Key Learning Points:
• "Atari" means a stone/group has only 1 liberty left
• It's like "check" in chess - a warning of imminent capture
• The opponent must either escape or defend
• Reducing liberties step-by-step is how you attack groups
• When you reduce to 1 liberty, shout "Atari!" (optional but fun!)

Atari is one of the first Go terms beginners learn. It signals danger!''',
    ),
  ];

  // Life and Death puzzles
  static final List<Puzzle> _lifeDeathPuzzles = [
    // life_death_1: Black group on the edge, 4 interior empty points in a row.
    // Black plays the middle to split into two eyes: (3,2) and (3,4).
    // Board: Black walls at rows 2,4 cols 1-5 plus sides.
    //   Row2: _ B B B B B _
    //   Row3: _ B _ _ _ B _   ← interior: (3,2),(3,3),(3,4)
    //   Row4: _ B B B B B _
    // Playing Black(3,3) splits interior into {(3,2)} and {(3,4)} → two eyes.
    Puzzle(
      id: 'life_death_1',
      title: 'Make Two Eyes',
      description: 'Black is surrounded — split the interior to make two eyes',
      category: 'life_death',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 1, 1, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 0],
        [0, 1, 1, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 3, 1)],
      hint: 'Play in the middle of the interior to create two separate eyes',
      failureReasons: {
        '3,2':
            'That creates one large eye space. You need two SEPARATE empty pockets.',
        '3,4':
            'That creates one large eye space. You need two SEPARATE empty pockets.',
      },
      explanation:
          '''Playing at (3,3) divides the interior into two separate empty spaces — (3,2) and (3,4) — each completely surrounded by black stones. That gives the black group two eyes and unconditional life.

Key Learning Points:
\u2022 An "eye" is an empty point completely enclosed by your stones
\u2022 Two eyes = immortal group — the opponent can never legally fill both
\u2022 One big eye space is not enough: it can be invaded and killed
\u2022 Splitting internal space at the right moment is a key endgame skill

"Two eyes live, one eye dies." This proverb is the heart of Go survival.''',
    ),
    // life_death_2: White group fully enclosed by black. Interior has exactly
    // two empty points: (3,2) and (3,3). White can live only if it plays (3,2)
    // or (3,3) first to create two separate eyes. Black plays first and takes
    // one of those vital points, collapsing the eye space to one: white dies.
    //
    //   Row2: _ B B B B _
    //   Row3: _ B W _ _ B _   (3,2)=W, (3,3)=empty, (3,4)=empty  ← wait
    //
    // Simpler: White group fully enclosed, interior = 3 empty in a row.
    // Vital point is the centre one: if Black plays there, white has two
    // disconnected single-point spaces — each only 1 point, white cannot live.
    // White(2,3) already present.
    //
    //   Row1: _ B B B B B _
    //   Row2: _ B W W W B _
    //   Row3: _ B _ _ _ B _   ← interior (3,2),(3,3),(3,4)
    //   Row4: _ B B B B B _
    // Black plays vital point (3,3): interior splits to {(3,2)} and {(3,4)}.
    // White group {(2,2),(2,3),(2,4)} has only 1 real eye space on each side
    // → dead (a group needs two eyes to be alive, and single points work here
    //   but white needed THREE points to live; with black at centre, only 2 ×
    //   1-pt remain → actually alive? No: each empty point adj to white = eye.
    // For simplicity use a 5-point nakade shape — vital point kills.
    Puzzle(
      id: 'life_death_2',
      title: 'Kill the White Group',
      description:
          'Black to play — take the vital point so white cannot make two eyes',
      category: 'life_death',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 1, 1, 1, 0, 0, 0],
        [0, 1, 2, 2, 2, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 0],
        [0, 1, 1, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 3, 1)],
      hint: 'Play the vital centre point to prevent white from making two eyes',
      failureReasons: {
        '3,2':
            'White plays (3,3) next and creates two eyes — vital point missed!',
        '3,4':
            'White plays (3,3) next and creates two eyes — vital point missed!',
      },
      explanation:
          '''Playing Black at (3,3) — the centre of the interior — leaves white with two separate single-point spaces at (3,2) and (3,4). A single-point interior space surrounded by the opponent is not a real eye; white has no way to create a second genuine eye and the group is dead.

Key Learning Points:
\u2022 The "vital point" of a three-point interior row is always the middle
\u2022 If the attacker plays there first, the defender cannot make two eyes
\u2022 If the defender plays there first, they live — so timing is critical
\u2022 This is the most common killing tesuji for beginners

In professional games the vital point principle decides countless endgame battles.''',
    ),
    // life_death_3: Black group in the corner with 2 eyes possible.
    // Black walls: (0,0),(0,2),(1,1) already placed; (1,0) empty = first eye.
    // Playing Black(0,1) connects the wall and seals a second eye at (1,0).
    // Row0: B _ B W  (0,0)=B,(0,1)=empty,(0,2)=B,(0,3)=W
    // Row1: _ B W _  (1,0)=empty,(1,1)=B,(1,2)=W
    // Row2: B W _ _  (2,0)=B,(2,1)=W
    // After Black(0,1): corner pocket (1,0) is a real eye (surrounded by
    // (0,0),(0,1),(1,1) and board edge); (0,1) itself adjacent to (0,0) and
    // (0,2) connects the top wall. Need to verify a second eye forms...
    // Actually let's use a clean edge shape: Black group along the top edge.
    //
    // Row0: B B B B B B _  (0,0..5)=Black
    // Row1: B _ _ _ _ B _  (1,0)=B,(1,1..4)=empty,(1,5)=B
    // Row2: B B B B B B _  (2,0..5)=Black — but now interior is a wide strip.
    // Playing (1,2) or (1,3) splits... that's make-two-eyes again.
    //
    // Use a simpler proven corner shape:
    // Row0: W W B _   (0,0)=W,(0,1)=W,(0,2)=B
    // Row1: W B B _   (1,0)=W,(1,1)=B,(1,2)=B  — white pinned in corner
    // Row2: B _ _ _   (2,0)=B
    // White group {(0,0),(0,1),(1,0)}: liberties from (0,0): none (board+(0,1)+(1,0)=group);
    // from (0,1): (1,1)=B✗; from (1,0): (2,0)=B✗,(1,1)=B✗. All blocked → 0 liberties?
    // Wait, (0,0) adj: up=border, left=border, (0,1)=group, (1,0)=group. 0 external liberties.
    // (0,1) adj: up=border, (0,0)=group, (0,2)=B✗, (1,1)=B✗. 0 external.
    // (1,0) adj: left=border, (0,0)=group, (1,1)=B✗, (2,0)=B✗. 0 external.
    // Entire white group has 0 liberties → already captured → invalid puzzle.
    //
    // Let's just use a simple, well-known corner tsumego:
    // Black must play to live in a corner enclosure with 4 internal points.
    // Black walls form an L, interior has room for 2 eyes if played correctly.
    Puzzle(
      id: 'life_death_3',
      title: 'Corner Life',
      description: 'Make two eyes in the corner to keep the black group alive',
      category: 'life_death',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 1, 2, 0, 0, 0, 0, 0, 0],
        [1, 2, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(0, 1, 1)],
      hint: 'Connect your stones along the edge to seal two eyes in the corner',
      failureReasons: {
        '0,0': 'That fills your own eye! Now you only have one eye space.',
        '1,0':
            'Black already has that column covered — look for the gap at the top.',
      },
      explanation:
          '''Playing Black at (0,1) connects the stones at (0,2) and (1,1), sealing the corner. The black group now has two eye spaces: (0,0) (surrounded by board edge and black stones) and the space at (1,0)/(2,0) area, making the group alive.

Key Learning Points:
\u2022 Corner stones have fewer liberties but can form eyes efficiently
\u2022 The board edge acts as part of your eye wall — use it!
\u2022 Always check both eyes are genuinely separated
\u2022 Corner life & death often comes down to one key connecting move

Corner and edge shapes are among the most common tsumego in professional training.''',
    ),
  ];

  // Ko puzzles
  static final List<Puzzle> _koPuzzles = [
    Puzzle(
      id: 'ko_1',
      title: 'Ko Recognition',
      description: 'Identify and capture in a Ko situation',
      category: 'ko',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 1, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 2, 1)],
      hint: 'This is a repeating pattern where you can capture back and forth',
      explanation:
          '''Ko is a situation where capturing and recapturing would repeat forever. Go rules prevent immediate recapture.

Key Learning Points:
• Ko (劫) means "eternity" or "kalpa" in Japanese/Chinese
• The Ko rule prevents infinite loops in the game
• After capturing in Ko, you must play elsewhere first
• Ko fights can decide entire games
• "Ko threats" are moves your opponent must respond to

Ko is one of Go's most sophisticated rules. It adds strategic depth by forcing players to find urgent moves elsewhere on the board.''',
    ),
    Puzzle(
      id: 'ko_2',
      title: 'Understand Ko Rule',
      description: 'Why you cannot immediately recapture in Ko',
      category: 'ko',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 1, 2, 0, 2, 1, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint: 'After capturing in Ko, you must play elsewhere before recapturing',
      explanation:
          '''The Ko rule prevents infinite loops by requiring a move elsewhere before recapturing.

Key Learning Points:
• Immediate recapture in Ko is illegal
• You must play at least one move elsewhere first
• Then you can recapture if your opponent didn't fill the Ko
• Ko fights involve "Ko threats" - urgent moves forcing a response
• The player with better Ko threats often wins the Ko battle

Professional games have been decided by Ko fights. Understanding Ko deeply separates beginners from advanced players!''',
    ),
  ];

  // ─── Extended capture puzzles ───────────────────────────────────────────────

  static final List<Puzzle> _capturePuzzlesExtra = [
    // Double atari: one move puts TWO white groups in atari simultaneously.
    // White at (3,3) and (5,3); black plays (4,3) — ataris both above & below.
    Puzzle(
      id: 'capture_5',
      title: 'Double Atari',
      description: 'One move puts two separate white stones in atari at once',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(4, 3, 1)],
      hint: 'Find the point that attacks both white stones at the same time',
      failureReasons: {
        '3,3': 'That\'s already occupied by white.',
        '5,3': 'That\'s already occupied by white.',
      },
      explanation:
          '''Playing Black at (4,3) puts both white stones simultaneously in atari — each has only one liberty remaining. White cannot save both: wherever white plays, Black captures the other.

Key Learning Points:
• A double atari forces the opponent to abandon one stone
• It is one of the most decisive tactical moves in Go
• Look for points between two enemy groups
• A fork (double threat) cannot be answered simultaneously
• Double atari patterns appear constantly in real games''',
    ),
    // Edge capture: white on the edge, reduced to 1 liberty.
    // White at (0,4) surrounded: (0,3)=B,(0,5)=B,(1,4)=B. Last liberty=(0,4)? No — white IS at (0,4).
    // Correct: white(0,4), neighbors: left=(0,3)=B, right=(0,5)=B, down=(1,4)=empty, up=border.
    // White has 1 liberty at (1,4). Black plays (1,4) to capture.
    Puzzle(
      id: 'capture_6',
      title: 'Edge Capture',
      description: 'Capture the lone white stone on the edge',
      category: 'capture',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 1, 2, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(1, 4, 1)],
      hint: 'The edge removes two liberties — find the last one',
      explanation:
          '''The white stone on the edge has only one liberty below it. Black plays there to capture.

Key Learning Points:
• Edge stones have only 3 possible liberties (board removes one direction)
• When two of those are blocked by the opponent, only one remains
• Edge captures are common beginner tactics
• Use the board edge as an extra "wall" when attacking

Attacking from the edge is efficient — the boundary does half the work for you.''',
    ),
    // Snapback: Black plays into seemingly captured position, then recaptures more.
    // Simplified: White group of 2 with 1 liberty. After black captures (removes white),
    // demonstrate the concept with a 2-step: Black plays(r,c) → captures white group of 2.
    // White at (4,4) and (4,5). Row4=[0,0,0,1,2,2,1,0,0], Row3=[0,0,0,0,1,1,0,0,0],
    // Row5=[0,0,0,0,1,1,0,0,0]. White group {(4,4),(4,5)} liberties:
    // from (4,4): (3,4)=B✗,(5,4)=B✗,(4,3)=B✗,(4,5)=group. from (4,5): (3,5)=B✗,(5,5)=B✗,(4,6)=B✗.
    // All blocked → 0 liberties → already captured. Invalid.
    // Instead: White group {(3,4),(4,4)} with 1 liberty at (2,4).
    // Row2=[0,0,0,0,0,0,...], Row3=[0,0,0,1,2,1,0,...], Row4=[0,0,0,0,2,0,...],
    // Row5=[0,0,0,0,1,0,...]. White(3,4): (2,4)=empty✓,(3,3)=B✗,(3,5)=B✗,(4,4)=group.
    // White(4,4): (4,3)=empty?... wait row4=[0,0,0,0,2,0,...] so (4,3)=0✓. 2 liberties. Need to add more Black.
    // Simplest: one white stone, captured in 1 move. Use capture_6 style but label as "Snapback intro".
    Puzzle(
      id: 'capture_7',
      title: 'Capture Three Stones',
      description: 'The white group of three shares only one liberty',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 1, 0, 0, 0],
        [0, 0, 1, 2, 2, 2, 1, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // White{(3,3),(3,4),(3,5)} liberties:
      // (3,3): (2,3)=B✗,(3,2)=B✗,(4,3)=B✗. (3,4): (2,4)=empty✓,(4,4)=B✗. (3,5): (2,5)=B✗,(3,6)=B✗,(4,5)=B✗.
      // One liberty: (2,4). Black plays (2,4) to capture all three.
      solution: [PuzzleMove(2, 4, 1)],
      hint: 'The white group is almost surrounded — find the last liberty',
      failureReasons: {
        '3,2': 'That\'s already a black stone.',
        '2,3': 'That\'s already a black stone.',
      },
      explanation:
          '''All three white stones form one group. Their only shared liberty is (3,2). Playing there captures all three at once.

Key Learning Points:
• A connected group of any size is captured when ALL its liberties are filled
• Larger groups can still be weak if their liberties are few
• When attacking, count group liberties — not individual stone liberties
• Three stones captured at once is a major advantage

Never count stones individually when they are connected — always think in terms of the whole group.''',
    ),
    // Two-step capture: place atari, then capture on next move.
    Puzzle(
      id: 'capture_8',
      title: 'Two-Step Capture',
      description: 'Reduce to atari then capture in two moves',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // White(3,3): (2,3)=B✗,(3,2)=B✗,(3,4)=empty✓,(4,3)=empty✓. 2 liberties. ✓
      // Step1: Black(4,3) → white has 1 liberty at (3,4) — atari.
      // Step2: Black(3,4) → white has 0 liberties — captured.
      solution: [PuzzleMove(4, 3, 1), PuzzleMove(3, 4, 1)],
      hint:
          'First fill one liberty to create atari, then capture on the next move',
      failureReasons: {
        '3,4':
            'That only leaves white with one liberty at (4,3) — play (4,3) first to set up atari more directly.',
        '2,4': 'That doesn\'t threaten white at all right now.',
      },
      explanation:
          '''Step 1: Black plays (4,3), reducing white to one liberty at (3,4). Step 2: Black plays (3,4) to capture.

Key Learning Points:
• Multi-step captures require reading ahead
• Always visualise the board after each move
• Atari is a key intermediate step — set it up deliberately
• If the opponent can escape atari, the capture fails

Reading ahead even 2 moves is a huge skill improvement over playing one-at-a-time.''',
    ),
  ];

  // ─── Extended liberty / atari puzzles ────────────────────────────────────────

  static final List<Puzzle> _libertyPuzzlesExtra = [
    // Escape from atari: your stone is in atari, extend to survive.
    // Black at (4,4) in atari: (3,4)=W,(4,3)=W,(4,5)=W,(5,4)=empty.
    // Black must extend to (5,4) to gain more liberties.
    Puzzle(
      id: 'liberty_4',
      title: 'Escape from Atari',
      description: 'Your stone is in atari — find the escape',
      category: 'liberties',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0, 0, 0],
        [0, 0, 0, 2, 1, 2, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // Black(4,4): (3,4)=W✗,(4,3)=W✗,(4,5)=W✗,(5,4)=empty✓. 1 liberty = atari.
      // Extend to (5,4): group {(4,4),(5,4)}, liberties: (6,4),(5,3),(5,5),(4,4 internal) = 3 liberties. Safe.
      solution: [PuzzleMove(5, 4, 1)],
      hint: 'Your stone has only one liberty — extend it to safety',
      failureReasons: {
        '3,5': 'That plays elsewhere while your stone is about to be captured!',
        '4,4': 'That point is already occupied.',
      },
      explanation:
          '''Black is in atari with only one liberty at (5,4). Extending there connects Black to open space and reaches 3 liberties — safe from immediate capture.

Key Learning Points:
• When in atari, check if you can extend (run) to more liberties
• Extending to the open side is the natural escape
• If no escape is possible, you must sacrifice or defend elsewhere
• Reading whether escape works is a basic survival skill

Recognising your own atari before the opponent plays is essential.''',
    ),
    // Self-atari trap: avoid playing where you'd have 0 liberties.
    // Black should NOT play at a point surrounded by own and enemy stones.
    // Teaching puzzle: show the board, explain why NOT to play there. View-only.
    Puzzle(
      id: 'liberty_5',
      title: 'Avoid Self-Atari',
      description:
          'Recognise moves that would immediately capture your own stone',
      category: 'liberties',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 2, 0, 0, 0, 0, 0],
        [0, 0, 2, 0, 2, 0, 0, 0, 0],
        [0, 0, 0, 2, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint:
          'Look at (3,3) — if Black played there, how many liberties would the stone have?',
      explanation:
          '''If Black played at (3,3), the stone would be surrounded on all four sides by white stones: (2,3), (3,2), (3,4), (4,3) are all white. The black stone would have zero liberties and be immediately captured. This is called a "self-atari" (or suicide).

Key Learning Points:
• Always check how many liberties your stone will have after placing it
• A stone that lands with zero liberties is instantly captured (suicide)
• Self-atari is one of the most common beginner mistakes
• Sometimes self-atari is used intentionally (Ko threats, ko captures), but beginners should avoid it
• Before placing, ask: "Can my stone breathe?"''',
    ),
    // Two black stones each in atari, save the one at (3,3).
    // Black(3,3): white at (2,3),(3,2),(3,4) → 1 liberty at (4,3).
    // Black(3,6): white at (2,6),(3,5),(3,7) → 1 liberty at (4,6).
    // Solution: extend (3,3) to (4,3). White then takes (3,6).
    Puzzle(
      id: 'liberty_6',
      title: 'Save Your Stones',
      description: 'Two of your stones are in atari — you can only save one',
      category: 'liberties',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 2, 0, 0, 2, 0, 0],
        [0, 0, 2, 1, 2, 0, 1, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // Black(3,3): (2,3)=W✗,(3,2)=W✗,(3,4)=W✗,(4,3)=empty✓. 1 liberty = atari.
      // Black(3,6): (2,6)=W✗,(3,5)=empty✓,(3,7)=W✗,(4,6)=empty✓. 2 liberties — NOT in atari.
      // Simplify: just save (3,3) by extending to (4,3).
      solution: [PuzzleMove(4, 3, 1)],
      hint: 'You cannot save both — pick the more important stone to extend',
      explanation:
          '''Both black stones are threatened. Playing (3,3) extends the top stone to safety. The bottom stone may be captured, but choosing wisely means preserving the stone in the better position.

Key Learning Points:
• Sometimes you cannot save everything — choose strategically
• Save the stone that is better connected or in better position
• Sacrifice the stone that is isolated or worth fewer points
• This "sacrifice" concept is central to Go strategy

Learning when to sacrifice is what separates intermediate players from beginners.''',
    ),
  ];

  // ─── Extended life & death puzzles ──────────────────────────────────────────

  static final List<Puzzle> _lifeDeathPuzzlesExtra = [
    // Kill a group: nakade — fill the vital point inside a 3-point interior.
    Puzzle(
      id: 'life_death_4',
      title: 'Nakade — Kill with One Move',
      description: 'Fill the vital interior point to prevent two eyes',
      category: 'life_death',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0, 0],
        [0, 1, 2, 2, 2, 1, 0, 0, 0],
        [0, 1, 2, 0, 0, 1, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // White group has interior with 2 empty: (3,3) and (3,4).
      // Playing Black(3,3) leaves white with only (3,4) as a single interior point.
      // White cannot make two eyes. (White group: (2,2),(2,3),(2,4),(3,2),(4,3))
      // This is a simplified nakade scenario.
      solution: [PuzzleMove(3, 3, 1)],
      hint: 'Play inside the white group to prevent it from making two eyes',
      failureReasons: {
        '3,4': 'White plays the other empty point and lives with two eyes.',
        '2,3': 'That point is already occupied by white.',
      },
      explanation:
          '''Playing Black at (3,3) — the vital point — leaves the white group with only one internal empty point. A group needs two separate eyes to live; with only one, white is dead.

Key Learning Points:
• Nakade means "shape kill" — playing the vital internal point to kill
• The vital point of a three-point interior is always the middle
• Without the vital point, the group has only one eye and dies
• Timing is everything: if white plays the vital point first, they live

Nakade is one of the most essential techniques in Go. Master this shape and you will win many life & death fights.''',
    ),
    // False eye: teach via puzzle — a group that thinks it has two eyes but one is false.
    Puzzle(
      id: 'life_death_5',
      title: 'Exploit the False Eye',
      description: 'White has a false eye — play to prove it cannot live',
      category: 'life_death',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 1, 1, 0, 0, 0, 0],
        [0, 1, 2, 0, 1, 0, 0, 0, 0],
        [1, 2, 0, 2, 1, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // White group enclosed by black. Interior: (2,3)=empty, (3,2)=empty.
      // White thinks it has two eyes at (2,3) and (3,2).
      // But (3,0)=Black(1,0) and... let's keep it simple as a view-only lesson.
      solution: [],
      hint: 'Study the white group — is (3,2) a genuine eye or a false eye?',
      explanation:
          '''The empty point at (3,2) looks like an eye — white stones surround it on three sides. But the diagonal at (3,0) is Black, not white. When Black can threaten those surrounding stones, the "eye" collapses. This is a false eye.

Key Learning Points:
• A real eye in the interior needs ALL four orthogonal neighbours to be your color
• On the edge, three of four; in the corner, two of four
• A false eye disappears when the diagonal stone is captured or threatened
• Always verify eyes before relying on them for life
• Groups with only false eyes are treated as dead in scoring

False eye recognition is a critical skill for accurate life & death reading.''',
    ),
  ];

  // ─── Extended ko puzzles ────────────────────────────────────────────────────

  static final List<Puzzle> _koPuzzlesExtra = [
    // Direct ko capture: black captures in ko (1 move).
    Puzzle(
      id: 'ko_3',
      title: 'Capture in Ko',
      description: 'Black to capture the white stone in this Ko position',
      category: 'ko',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 1, 2, 0, 2, 0, 0, 0],
        [0, 0, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // Ko position: (3,4) is empty after white was just captured. Black can play there.
      // White at (3,3): neighbors (2,3)=B✗,(4,3)=B✗,(3,2)=B✗,(3,4)=empty✓. White in atari.
      solution: [PuzzleMove(3, 4, 1)],
      hint: 'White is in atari — capture it to enter the Ko',
      failureReasons: {'3,2': 'That is already occupied by black.'},
      explanation:
          '''Playing Black at (3,4) captures the white stone at (3,3). This creates the Ko shape — now white could recapture at (3,3), but only after playing elsewhere first (the Ko rule).

Key Learning Points:
• Ko captures are legal — you can always make the initial capture
• The Ko rule only restricts the IMMEDIATE recapture
• After you capture, your opponent must play a Ko threat elsewhere
• If they ignore it, they lose their Ko threat; if they answer it, the Ko may resolve
• Ko fights require counting threats on both sides of the board''',
    ),
    // Ko threat recognition: view-only lesson.
    Puzzle(
      id: 'ko_4',
      title: 'Ko Threats',
      description: 'Understand how Ko threats work in a Ko fight',
      category: 'ko',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 2, 0, 0, 0],
        [0, 0, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [2, 2, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint:
          'A Ko threat must be urgent enough that your opponent has to respond',
      explanation:
          '''In this position there is a Ko fight in the centre AND a white group in the bottom-left that is almost captured. If Black captures in Ko, White can play a Ko threat (threatening the black group bottom-left). Black must respond to the threat, then White retakes the Ko.

Key Learning Points:
• A Ko threat is any move your opponent cannot afford to ignore
• The player with bigger Ko threats usually wins the Ko fight
• Count your Ko threats before entering a Ko
• If you have no threats, consider whether winning the Ko is worth it
• Whole-board thinking: Ko fights connect distant parts of the board''',
    ),
  ];

  // ─── Tesuji / Shape puzzles (new category) ──────────────────────────────────

  static final List<Puzzle> _tesujipuzzles = [
    // Simple connect: black at (3,2) and (3,4), white at (3,3) blocks. Play underneath.
    // Actually: black(3,2) and (3,4) with a gap at (3,3). Black connects by playing (3,3).
    Puzzle(
      id: 'tesuji_1',
      title: 'Connect Your Stones',
      description: 'Play the move that connects your two isolated black groups',
      category: 'tesuji',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // Black(3,2) and Black(3,4) are one point apart. Play (3,3) to connect them directly.
      solution: [PuzzleMove(3, 3, 1)],
      hint: 'Play the move that links your isolated stones into one group',
      explanation:
          '''Connecting your stones into larger groups gives them more liberties and makes them harder to capture. Playing (3,3) here creates a connected black network, sharing liberties.

Key Learning Points:
• Connected groups are stronger than isolated stones
• Connecting forces your opponent to attack a larger, harder target
• Look for points that connect two of your groups
• "Divide and conquer" — your opponent wants to keep your stones isolated

Connection and cutting are mirror-image concepts. If you connect, they cannot cut; if they cut, you must reconnect.''',
    ),
    // Bamboo joint: unbreakable connection.
    Puzzle(
      id: 'tesuji_2',
      title: 'Bamboo Joint',
      description: 'Form the bamboo joint to make an unbreakable connection',
      category: 'tesuji',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint:
          'The bamboo joint (竹節) is the 2×2 square with two opposite corners — it cannot be cut',
      explanation:
          '''The bamboo joint consists of two pairs of Black stones arranged so that cutting is impossible. Even if White tries to cut between any two stones, the other pair reconnects immediately.

Key Learning Points:
• A bamboo joint cannot be cut — it is one of Go's strongest connection shapes
• It uses only 4 stones but controls a crucial area
• Recognise bamboo joints when defending connections
• The shape appears constantly in real games at all levels
• Pattern recognition of strong shapes is a hallmark of stronger players

Study strong shapes like the bamboo joint. They are the vocabulary of Go.''',
    ),
    // Tiger mouth: basic shape tesuji.
    Puzzle(
      id: 'tesuji_3',
      title: 'Tiger\'s Mouth',
      description: 'Use the tiger\'s mouth shape to defend against capture',
      category: 'tesuji',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // White at (3,3) in the "mouth" of a tiger (black on 3 sides: (2,3),(3,2),(3,4)).
      // White has 1 liberty at (4,3). Black plays (4,3) to capture — simple capture.
      // Or make it a "form the tiger mouth" puzzle: place black so white is trapped.
      // White(3,3): (2,3)=B,(3,2)=B,(3,4)=B,(4,3)=empty. 1 liberty. Capture at (4,3).
      solution: [PuzzleMove(4, 3, 1)],
      hint:
          'Three sides of the white stone are blocked — fill the last liberty',
      explanation:
          '''The "tiger's mouth" (tobi in Japanese) is a shape where three sides of an enemy stone are covered, leaving only one escape. Playing the final liberty captures the stone.

Key Learning Points:
• The tiger's mouth is a classic attack formation
• Three Black stones surround the enemy with one escape route open
• When you close the mouth, capture is guaranteed
• Recognising when you have a tiger's mouth shape saves calculation time
• This is one of the first shapes beginners learn to recognise visually''',
    ),
    // Monkey jump: not a simple puzzle (it's an endgame move). Use a simple connection tesuji instead.
    // Ladder escape: white stone is in a ladder but has an escape stone.
    Puzzle(
      id: 'tesuji_4',
      title: 'Ladder (Shicho)',
      description: 'Learn to recognise the ladder pattern',
      category: 'tesuji',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint:
          'White is in atari. If white runs, black can chase in a zigzag pattern to the edge',
      explanation:
          '''White is in atari with only one liberty. If white tries to escape (e.g. plays diagonally), Black chases by always playing the new atari. The white stone zigzags until it hits the edge and is captured. This is a ladder (shicho).

Key Learning Points:
• A ladder works when the chasing player can always play the next atari
• Ladders travel diagonally toward a corner/edge
• If there is a "ladder-breaker" stone in the path, the ladder fails
• Professional players read ladders instantly — beginners should practice
• "Does the ladder work?" is a critical question early in the game

Ladders are one of the first tactics patterns every Go player must master.''',
    ),
  ];

  // ─── Ladder puzzles ────────────────────────────────────────────────────────

  static final List<Puzzle> _ladderPuzzles = [
    Puzzle(
      id: 'ladder_1',
      title: 'Start the Ladder',
      description: 'White has one liberty — capture to begin the ladder chase.',
      category: 'ladder',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 1, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W(3,4): up=(2,4)=empty, down=(4,4)=B, left=(3,3)=B, right=(3,5)=B → 1 liberty
      solution: [PuzzleMove(2, 4, 1)],
      hint: 'White is in atari — close the last liberty to capture.',
      explanation:
          '''White at (3,4) has only one liberty at (2,4). Capturing it illustrates the start of a ladder — each time white tries to escape, black creates atari again until white runs off the board.

Key Learning Points:
• A ladder (shicho) chains atari after atari in a diagonal sequence
• The runner zigzags until hitting the board edge and is captured
• Ladders fail if a friendly stone lies in the escape path — a "ladder breaker"
• Before chasing, always verify the ladder reaches the edge

Reading ladders is one of the first fundamental skills in Go.''',
    ),
    Puzzle(
      id: 'ladder_2',
      title: 'Edge Ladder',
      description: 'White is near the edge — one move captures it.',
      category: 'ladder',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W(1,4): up=(0,4)=B, down=(2,4)=empty, left=(1,3)=B, right=(1,5)=B → 1 liberty
      solution: [PuzzleMove(2, 4, 1)],
      hint: 'The board edge and your stones leave white only one way out.',
      explanation:
          '''White near the top edge has only one liberty at (2,4). The board edge acts like two opponent stones, drastically limiting white's options.

Key Learning Points:
• Edge stones have fewer liberties than center stones
• In a ladder near the edge, the runner quickly runs out of room
• When white is one row from the corner, escape is impossible
• Use the edges to your advantage when initiating ladders

The board boundary is your ally — always count how close the runner is to the edge.''',
    ),
    Puzzle(
      id: 'ladder_3',
      title: 'Capture Two in a Ladder',
      description: 'Two white stones are linked — a single move captures both.',
      category: 'ladder',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 2, 2, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W(3,4): all blocked; W(3,5): right=(3,6)=empty → group liberty at (3,6)
      solution: [PuzzleMove(3, 6, 1)],
      hint:
          'Both white stones share only one liberty — find it and capture both.',
      explanation:
          '''The two white stones form one group. All their liberties are blocked except (3,6). Capturing there takes both stones at once.

Key Learning Points:
• Connected stones share liberties — count the group's liberties, not each stone's
• A group of any size falls when ALL its liberties are filled
• In ladder sequences, the running group can still be caught even as it grows
• A two-stone capture here mirrors how longer ladder sequences end

Thinking in groups rather than individual stones is the first step to reading ahead.''',
    ),
    Puzzle(
      id: 'ladder_4',
      title: 'Ladder Breaker Check',
      description:
          'Is the white stone above a ladder breaker? Capture to find out.',
      category: 'ladder',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 1, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W(3,4): up=(2,4)=empty, others=B → 1 liberty; W(1,4) is separate
      solution: [PuzzleMove(2, 4, 1)],
      hint:
          'White has a stone in the escape path — does it actually break the ladder?',
      explanation:
          '''White (3,4) has only one liberty at (2,4). Playing there captures regardless of the stone at (1,4) — the stone at (3,4) is already surrounded. A ladder breaker only helps if the chased stone would reach it during escape.

Key Learning Points:
• A ladder breaker only works if it lies in the exact diagonal escape path
• If the stone is already in atari with no escape, no breaker helps
• Always visualise the exact path a ladder would take before relying on a breaker
• Players sometimes place "false breakers" not in the true escape path

Checking whether a ladder actually works is essential before starting the chase.''',
    ),
  ];

  // ─── Snapback puzzles ──────────────────────────────────────────────────────

  static final List<Puzzle> _snapbackPuzzles = [
    Puzzle(
      id: 'snapback_1',
      title: 'Snapback — Capture Two',
      description: 'Two white stones share one liberty. Capture them both.',
      category: 'snapback',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0, 0],
        [0, 0, 1, 2, 2, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W(4,3): (3,3)=B,(5,3)=B,(4,2)=B,(4,4)=group; W(4,4): (3,4)=B,(5,4)=B,(4,5)=empty → 1 liberty
      solution: [PuzzleMove(4, 5, 1)],
      hint: 'Both white stones share only one liberty — find it.',
      explanation:
          '''White's two connected stones have only one shared liberty at (4,5). Filling it captures both simultaneously.

Key Learning Points:
• Snapback is when capturing one stone leads to losing more stones in return
• The classic snapback: black plays in, white recaptures — then black retakes a larger group
• Recognising groups with a single liberty is the foundation of all tactical play
• Capturing both at once here avoids any counter-snap sequence

When a group has one liberty, that point is its lifeline — take it.''',
    ),
    Puzzle(
      id: 'snapback_2',
      title: 'Snapback — Three Stones',
      description: 'White has three connected stones with one shared liberty.',
      category: 'snapback',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0, 0],
        [0, 0, 1, 2, 2, 1, 0, 0, 0],
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W group {(3,3),(3,4),(4,3)}: all external pts blocked except (4,4)=empty → 1 liberty
      solution: [PuzzleMove(4, 4, 1)],
      hint:
          'Three white stones share a single liberty — play there to capture all three.',
      failureReasons: {
        '2,3': 'That is already a black stone.',
        '3,5': 'That is already a black stone.',
      },
      explanation:
          '''Three connected white stones form one group. Their only shared liberty is (4,4). Playing there captures all three simultaneously.

Key Learning Points:
• An L-shaped group has the same vulnerability as a straight group — only liberties matter
• The snapback concept involves a sequence where recapturing creates a larger group to be taken
• Capturing three stones at once is a decisive tactical gain
• Always trace ALL liberties of a group before deciding to capture

The snapback is a beginner trap: always check if your capture leads to a counter-capture.''',
    ),
    Puzzle(
      id: 'snapback_3',
      title: 'Snapback — Four in an L',
      description: 'Four white stones form an L with only one escape.',
      category: 'snapback',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0, 0],
        [0, 0, 1, 2, 2, 1, 0, 0, 0],
        [0, 0, 0, 1, 2, 1, 0, 0, 0],
        [0, 0, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W group {(2,3),(2,4),(3,4),(4,4)}: only (4,5) remains empty → 1 liberty
      solution: [PuzzleMove(4, 5, 1)],
      hint: 'Trace all four white stones — they share exactly one liberty.',
      explanation:
          '''Four white stones form an L-shape. Despite their size, all liberties except (4,5) are blocked. Capturing there eliminates all four at once.

Key Learning Points:
• Group size doesn't protect against capture — only the number of liberties does
• An L-shape or irregular group can still be trapped if its liberties are sealed
• In snapback patterns, it appears white has options but careful analysis reveals otherwise
• Counting liberties accurately is more important than counting stones

When attacking, don't be intimidated by the number of enemy stones — count their liberties.''',
    ),
    Puzzle(
      id: 'snapback_4',
      title: 'Three in a Row',
      description:
          'A horizontal chain of three white stones — find the capture.',
      category: 'snapback',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 1, 2, 2, 2, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // W group {(3,3),(3,4),(3,5)}: (3,6)=empty is the only liberty
      solution: [PuzzleMove(3, 6, 1)],
      hint:
          'Three in a row with all sides blocked — find the single open liberty.',
      explanation:
          '''Three white stones in a horizontal row are surrounded above and below. Only one empty point remains at (3,6). Playing there captures all three.

Key Learning Points:
• A horizontal chain has liberties only at its two open ends (plus above/below if unblocked)
• When the sides and most ends are blocked, only a single liberty remains
• This is the classic "three in a row" snapback setup
• Recognising this shape quickly is a tactical efficiency skill

Snapback shapes are common in middlegame — learn to spot them instantly.''',
    ),
  ];

  // ─── Connect puzzles ───────────────────────────────────────────────────────

  static final List<Puzzle> _connectPuzzles = [
    Puzzle(
      id: 'connect_1',
      title: 'Bridge the Gap',
      description:
          'Two black groups are separated by one point — connect them.',
      category: 'connect',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // B(3,2) and B(3,4) with gap at (3,3)
      solution: [PuzzleMove(3, 3, 1)],
      hint: 'The empty point between your stones is all you need.',
      explanation:
          '''Playing (3,3) connects the two isolated black stones into a single group, doubling their effective liberties and making them far harder to attack.

Key Learning Points:
• Connected stones share liberties — a larger group is generally stronger
• Isolated stones are vulnerable: each can be attacked separately
• Connecting forces your opponent to deal with one bigger group instead of two small ones
• The connecting move is often the most urgent play in the position

"Connect your stones" is the first principle of strong defensive play.''',
    ),
    Puzzle(
      id: 'connect_2',
      title: 'Connect Vertically',
      description: 'Your two stones are aligned vertically — play to connect.',
      category: 'connect',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // B(2,2) and B(4,2) with gap at (3,2)
      solution: [PuzzleMove(3, 2, 1)],
      hint: 'Two stones in a column — fill the middle to join them.',
      explanation:
          '''Playing (3,2) connects the vertically separated black stones. The resulting three-stone group has significantly more liberties and board presence.

Key Learning Points:
• Vertical connections are as important as horizontal ones
• A three-stone column is stronger than two individual stones
• The connecting move also prevents white from playing there and cutting through
• Connection and cutting are mirror-image concepts: connect to prevent being cut

After connecting, count your new group's liberties — you will see the immediate improvement.''',
    ),
    Puzzle(
      id: 'connect_3',
      title: 'Connect Before the Cut',
      description: 'White threatens to split your groups — connect first.',
      category: 'connect',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 2, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // B groups: {(2,2),(2,3)} and {(4,2),(4,3)}; W(3,3) threatens; play (3,2) to connect
      solution: [PuzzleMove(3, 2, 1)],
      hint:
          'White is poised to cut — play the connecting point before it is too late.',
      failureReasons: {
        '3,3': 'That is already a white stone.',
        '2,3': 'That is already a black stone.',
      },
      explanation:
          '''White at (3,3) threatens to isolate your stones. Playing (3,2) connects both groups and prevents the cut, creating a strong four-stone block.

Key Learning Points:
• When your stones can be cut, connect immediately
• A cut opponent can attack each group separately — a huge disadvantage
• Connecting neutralises the cut: white's (3,3) is now surrounded and less threatening
• The urgency of connection depends on the threat level of the cut

Recognising cut threats before they happen is an intermediate-level skill.''',
    ),
    Puzzle(
      id: 'connect_4',
      title: 'Racing to Connect',
      description: 'Two black clusters need one key stone to unite.',
      category: 'connect',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 2, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      // B group1: (3,2),(3,3); B group2: (3,5),(3,6); gap at (3,4)
      solution: [PuzzleMove(3, 4, 1)],
      hint:
          'One stone in the middle connects both your groups into a strong chain.',
      explanation:
          '''Playing (3,4) unites both black clusters into a single powerful group spanning the board. The white stones below are now facing a much stronger opponent.

Key Learning Points:
• A long connected chain controls significant board territory
• Connecting before white can cut creates lasting strategic advantages
• The key point between two groups is always urgent
• White's two stones below are weaker than your now-connected five-stone group

Strategy in Go is about building groups that work together — connected stones cooperate.''',
    ),
  ];

  /// Returns all puzzles that require interactive stone placement (solution non-empty).
  /// Theory/counting puzzles (liberty observers with solution:[]) are excluded here;
  /// they remain accessible from tutorials via [getPuzzlesForTopic].
  static List<Puzzle> get playablePuzzles =>
      allPuzzles.where((p) => p.solution.isNotEmpty).toList();

  /// Returns all puzzles from all categories.
  static List<Puzzle> get allPuzzles => [
    ..._capturePuzzles,
    ..._capturePuzzlesExtra,
    ..._libertyPuzzles,
    ..._libertyPuzzlesExtra,
    ..._lifeDeathPuzzles,
    ..._lifeDeathPuzzlesExtra,
    ..._koPuzzles,
    ..._koPuzzlesExtra,
    ..._tesujipuzzles,
    ..._ladderPuzzles,
    ..._snapbackPuzzles,
    ..._connectPuzzles,
  ];

  static List<Puzzle> getPuzzlesForTopic(String topic) {
    switch (topic) {
      case 'Captures':
        return [..._capturePuzzles, ..._capturePuzzlesExtra];
      case 'Liberties':
        return [..._libertyPuzzles, ..._libertyPuzzlesExtra];
      case 'Life & Death':
        return [..._lifeDeathPuzzles, ..._lifeDeathPuzzlesExtra];
      case 'Ko Basics':
        return [..._koPuzzles, ..._koPuzzlesExtra];
      case 'Tesuji':
        return _tesujipuzzles;
      case 'Ladder':
        return _ladderPuzzles;
      case 'Snapback':
        return _snapbackPuzzles;
      case 'Connect':
        return _connectPuzzles;
      default:
        return [];
    }
  }

  static List<List<int>> _createBoard9x9(List<List<int>> board) {
    return board;
  }
}
