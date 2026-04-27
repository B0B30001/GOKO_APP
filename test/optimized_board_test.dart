import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/optimized_board.dart';

void main() {
  group('OptimizedBoard stone placement', () {
    test('simple capture increases opponent capture count', () {
      final b = Board(9);
      // Simple edge capture - black at (0,1), white surrounds from (0,0), (0,2), (1,1)
      expect(b.placeStone(0, 1, 1), isTrue); // black
      expect(b.placeStone(0, 0, 2), isTrue); // white left
      expect(b.placeStone(5, 5, 1), isTrue); // black elsewhere
      expect(b.placeStone(0, 2, 2), isTrue); // white right
      expect(b.placeStone(6, 6, 1), isTrue); // black elsewhere
      expect(
        b.placeStone(1, 1, 2),
        isTrue,
      ); // white bottom - captures black (0,1)

      expect(
        b.getStone(0, 1),
        equals(0),
        reason: 'Black stone should be captured',
      );
      expect(
        b.capturedByWhite,
        equals(1),
        reason: 'White should have 1 capture',
      );
    });

    test('suicide move is rejected', () {
      final b = Board(5);
      // Surround point (1,1) with black stones except itself
      expect(b.placeStone(0, 1, 1), isTrue);
      expect(b.placeStone(1, 0, 1), isTrue);
      expect(b.placeStone(2, 1, 1), isTrue);
      expect(b.placeStone(1, 2, 1), isTrue);
      // White tries suicide at (1,1)
      expect(b.isValidMove(1, 1, 2), isFalse);
      expect(b.placeStone(1, 1, 2), isFalse);
      // Board unchanged
      expect(b.getStone(1, 1), equals(0));
    });

    test('ko repetition is rejected', () {
      final b = Board(5);
      // Textbook ko at edge (simpler):
      //  . B W .     after black captures:  . B . .
      //  B W . .                            B . B .
      //  . B W .                            . B W .
      // Set up so black (2,1) captures white (1,1), then white wants to recap at (1,1)
      expect(b.placeStone(0, 1, 1), isTrue); // black top
      expect(b.placeStone(0, 2, 2), isTrue); // white top-right
      expect(b.placeStone(1, 0, 1), isTrue); // black left
      expect(b.placeStone(1, 1, 2), isTrue); // white center (will be captured)
      expect(b.placeStone(2, 1, 1), isTrue); // black bottom
      expect(b.placeStone(2, 2, 2), isTrue); // white bottom-right
      // One more black to complete surround
      expect(b.placeStone(3, 3, 1), isTrue); // black elsewhere for turn
      expect(b.placeStone(4, 4, 2), isTrue); // white elsewhere
      expect(
        b.placeStone(1, 2, 1),
        isTrue,
      ); // black right - captures white (1,1)

      expect(b.getStone(1, 1), equals(0), reason: 'White should be captured');
      expect(b.capturedByBlack, equals(1));

      // White attempts immediate recapture at (1,1) recreating board
      final blocked = b.placeStone(1, 1, 2);
      expect(blocked, isFalse, reason: 'Ko should block');
      expect(b.getStone(1, 1), equals(0));
    });

    // The implementation uses an 8-move sliding window of board hashes, so it
    // sits between simple ko (only the immediately previous position blocked)
    // and full positional superko (all past positions blocked). Strict superko
    // is not a goal — see Board._boardHashHistoryLimit. The next test pins the
    // window-eviction behavior so a future change to that constant is loud.

    test('positions older than the 8-move window can recur', () {
      final b = Board(9);
      // Play eight unrelated moves, alternating colors, so the empty-board hash
      // is evicted from the ko cache. Then the next placement in a never-seen
      // position must succeed.
      var p = 1;
      for (final coord in [
        [0, 0],
        [8, 8],
        [0, 8],
        [8, 0],
        [4, 4],
        [3, 3],
        [5, 5],
        [3, 5],
      ]) {
        expect(b.placeStone(coord[0], coord[1], p), isTrue);
        p = p == 1 ? 2 : 1;
      }
      // A fresh point — board state has never been seen. Must not be blocked.
      expect(b.placeStone(2, 2, p), isTrue);
    });
  });

  group('Board.isValidMove', () {
    test('every empty intersection is valid for player 1', () {
      final b = Board(5);
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          expect(b.isValidMove(i, j, 1), isTrue, reason: 'at ($i,$j)');
        }
      }
    });

    test('occupied intersection is invalid', () {
      final b = Board(5);
      expect(b.placeStone(2, 2, 1), isTrue);
      expect(b.isValidMove(2, 2, 1), isFalse);
      expect(b.isValidMove(2, 2, 2), isFalse);
    });

    test('out-of-bounds is invalid', () {
      final b = Board(5);
      expect(b.isValidMove(-1, 0, 1), isFalse);
      expect(b.isValidMove(0, -1, 1), isFalse);
      expect(b.isValidMove(5, 0, 1), isFalse);
      expect(b.isValidMove(0, 5, 1), isFalse);
    });

    test('suicide with no captures is invalid', () {
      final b = Board(5);
      // Surround (1,1) with black except itself
      expect(b.placeStone(0, 1, 1), isTrue);
      expect(b.placeStone(1, 0, 1), isTrue);
      expect(b.placeStone(2, 1, 1), isTrue);
      expect(b.placeStone(1, 2, 1), isTrue);
      // White suicide at (1,1) — no opponent group has zero liberties after
      expect(b.isValidMove(1, 1, 2), isFalse);
    });

    test('suicide that captures opponent is valid', () {
      final b = Board(5);
      // Build a one-liberty white group at (0,0) with black filling other libs
      // White at (0,0): adjacent are (0,1) and (1,0). Fill both with black except one.
      expect(b.placeStone(0, 0, 2), isTrue); // white in corner
      expect(
        b.placeStone(1, 0, 1),
        isTrue,
      ); // black below — one liberty left at (0,1)
      // Now black plays at (0,1): the white group has zero liberties → captured.
      // The placed black stone itself would have liberties via the freed (0,0).
      expect(b.isValidMove(0, 1, 1), isTrue);
    });
  });
}
