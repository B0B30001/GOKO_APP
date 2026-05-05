import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/optimized_board.dart';
import 'package:zaibal/models/puzzle.dart';

/// Pure-logic counterpart of the gate added in [`puzzle_screen.dart`].
/// Re-tested here without the Flutter widget tree.
({bool solved, bool legal}) attemptMove(
  Board board,
  Puzzle puzzle,
  int moveIndex,
  int row,
  int col,
) {
  final expected = puzzle.solution[moveIndex];
  if (row != expected.row || col != expected.col) {
    return (solved: false, legal: true);
  }
  final placed = board.placeStone(row, col, puzzle.playerColor);
  if (!placed) {
    return (solved: false, legal: false);
  }
  final sequenceComplete = moveIndex + 1 >= puzzle.solution.length;
  final winSatisfied = puzzle.winCondition.isSatisfied(board.board);
  return (solved: sequenceComplete && winSatisfied, legal: true);
}

void main() {
  group('Puzzle validation gate', () {
    test('solves only when the recorded sequence is played', () {
      final puzzle = Puzzle(
        id: 't1',
        title: 'simple',
        description: '',
        category: 'capture',
        difficulty: 1,
        boardSize: 5,
        initialBoard: [
          [0, 0, 0, 0, 0],
          [0, 0, 2, 1, 0],
          [0, 1, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ],
        playerColor: 1,
        solution: [PuzzleMove(0, 2, 1)],
        hint: '',
      );
      final b = Board(5);
      // Replay the initial position onto the board.
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          if (puzzle.initialBoard[i][j] != 0) {
            b.setStone(i, j, puzzle.initialBoard[i][j]);
          }
        }
      }
      final result = attemptMove(b, puzzle, 0, 0, 2);
      expect(result.solved, isTrue);
      expect(result.legal, isTrue);
    });

    test('illegal Ko move at the correct coordinate fails (does not solve)',
        () {
      // Build a real ko on a 5x5 board, then craft a puzzle whose solution
      // is the FORBIDDEN immediate-recapture move. The validation gate must
      // refuse it because placeStone() returns false.
      final b = Board(5);
      expect(b.placeStone(0, 1, 1), isTrue); // black
      expect(b.placeStone(0, 2, 2), isTrue); // white
      expect(b.placeStone(1, 0, 1), isTrue); // black
      expect(b.placeStone(1, 1, 2), isTrue); // white center
      expect(b.placeStone(2, 1, 1), isTrue); // black
      expect(b.placeStone(2, 2, 2), isTrue); // white
      expect(b.placeStone(3, 3, 1), isTrue); // filler
      expect(b.placeStone(4, 4, 2), isTrue); // filler
      expect(b.placeStone(1, 2, 1), isTrue); // captures (1,1)

      final puzzle = Puzzle(
        id: 'ko-bad',
        title: 'ko-trap',
        description: '',
        category: 'ko',
        difficulty: 2,
        boardSize: 5,
        initialBoard: List.generate(5, (_) => List.filled(5, 0)),
        playerColor: 2,
        // Solution = white tries the immediate ko recapture (illegal).
        solution: [PuzzleMove(1, 1, 2)],
        hint: '',
      );

      final result = attemptMove(b, puzzle, 0, 1, 1);
      expect(
        result.legal,
        isFalse,
        reason: 'Engine must reject the ko recapture',
      );
      expect(
        result.solved,
        isFalse,
        reason: 'Coord-only match must NOT solve the puzzle when illegal',
      );
    });

    test('CaptureGroup win condition requires target stone to leave board',
        () {
      // 3x3 micro-board: white at (1,1) with one liberty; black plays it.
      final b = Board(3);
      expect(b.placeStone(0, 1, 1), isTrue); // black
      expect(b.placeStone(1, 1, 2), isTrue); // white
      expect(b.placeStone(1, 0, 1), isTrue); // black
      expect(b.placeStone(2, 2, 2), isTrue); // white elsewhere
      expect(b.placeStone(2, 1, 1), isTrue); // black, white still has 1 lib

      final puzzle = Puzzle(
        id: 'cap-group',
        title: 'kill it',
        description: '',
        category: 'capture',
        difficulty: 1,
        boardSize: 3,
        initialBoard: List.generate(3, (_) => List.filled(3, 0)),
        playerColor: 1,
        solution: [PuzzleMove(1, 2, 1)],
        hint: '',
        winCondition: CaptureGroup([PuzzleMove(1, 1, 2)]),
      );

      final result = attemptMove(b, puzzle, 0, 1, 2);
      expect(result.legal, isTrue);
      expect(
        result.solved,
        isTrue,
        reason: 'Target white stone is removed from the board',
      );
      expect(b.getStone(1, 1), equals(0));
    });
  });
}
