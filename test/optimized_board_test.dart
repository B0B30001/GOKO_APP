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
      expect(b.placeStone(1, 1, 2), isTrue); // white bottom - captures black (0,1)

      expect(b.getStone(0, 1), equals(0), reason: 'Black stone should be captured');
      expect(b.capturedByWhite, equals(1), reason: 'White should have 1 capture');
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
      expect(b.placeStone(1, 2, 1), isTrue); // black right - captures white (1,1)
      
      expect(b.getStone(1, 1), equals(0), reason: 'White should be captured');
      expect(b.capturedByBlack, equals(1));
      
      // White attempts immediate recapture at (1,1) recreating board
      final blocked = b.placeStone(1, 1, 2);
      expect(blocked, isFalse, reason: 'Ko should block');
      expect(b.getStone(1, 1), equals(0));
    });

    // TODO: Add test for simple ko (only immediate repetition blocked) vs positional superko
    // Current implementation uses 8-move window which partially enforces positional superko.
  });
}
