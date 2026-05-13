import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/optimized_board.dart';

void main() {
  group('Board.board view caching', () {
    test('two reads without a mutation return the same List reference', () {
      final b = Board(19);
      final first = b.board;
      final second = b.board;
      // identical() — pointer equality. If this fails, the getter is
      // allocating fresh Lists per read, which is the pathology that
      // caused 13x13/19x19 lag.
      expect(identical(first, second), isTrue);
    });

    test('a placed stone invalidates the cached view', () {
      final b = Board(9);
      final before = b.board;
      expect(b.placeStone(4, 4, 1), isTrue);
      final after = b.board;
      expect(identical(before, after), isFalse);
      expect(after[4][4], equals(1));
    });

    test('setStone invalidates the cached view', () {
      final b = Board(9);
      final before = b.board;
      b.setStone(0, 0, 2);
      final after = b.board;
      expect(identical(before, after), isFalse);
      expect(after[0][0], equals(2));
    });

    test('resetToSnapshot invalidates the cached view', () {
      final b = Board(5);
      final before = b.board;
      final snap = List.generate(5, (_) => List.filled(5, 0));
      snap[2][2] = 1;
      b.resetToSnapshot(snap, capturedByBlack: 0, capturedByWhite: 0);
      final after = b.board;
      expect(identical(before, after), isFalse);
      expect(after[2][2], equals(1));
    });
  });
}
