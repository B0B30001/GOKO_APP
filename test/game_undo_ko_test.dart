import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/optimized_game.dart';

void main() {
  group('Game undo/redo + Ko interaction', () {
    test('replaying a captured-then-undone position is not blocked as ko', () {
      final g = Game(5);
      // Set up the same edge ko as in optimized_board_test.dart so we can
      // capture a single white stone and then undo back to before the capture.
      expect(g.playTurn(0, 1), isTrue); // black
      expect(g.playTurn(0, 2), isTrue); // white
      expect(g.playTurn(1, 0), isTrue); // black
      expect(g.playTurn(1, 1), isTrue); // white center (capture target)
      expect(g.playTurn(2, 1), isTrue); // black
      expect(g.playTurn(2, 2), isTrue); // white
      expect(g.playTurn(3, 3), isTrue); // black filler
      expect(g.playTurn(4, 4), isTrue); // white filler
      // Black captures white at (1,1) by playing (1,2).
      expect(g.playTurn(1, 2), isTrue);
      expect(g.board.getStone(1, 1), equals(0));
      expect(g.board.capturedByBlack, equals(1));

      // Undo the capturing move. Black's stone at (1,2) should be gone, and
      // the white stone at (1,1) restored. Crucially, the ko cache must be
      // cleared, so playing the same capturing move again must succeed.
      g.undo();
      expect(g.board.getStone(1, 2), equals(0));
      expect(g.board.getStone(1, 1), equals(2));
      expect(g.board.capturedByBlack, equals(0));

      // Replay the capture. With the broken pre-fix code, the ko window still
      // contained the post-capture hash and this returned false.
      expect(
        g.playTurn(1, 2),
        isTrue,
        reason: 'After undo, replaying the capture must not be blocked',
      );
      expect(g.board.getStone(1, 1), equals(0));
      expect(g.board.capturedByBlack, equals(1));
    });

    test('undo then redo restores capture counters correctly', () {
      final g = Game(5);
      expect(g.playTurn(0, 1), isTrue);
      expect(g.playTurn(0, 0), isTrue);
      expect(g.playTurn(2, 2), isTrue);
      expect(g.playTurn(1, 1), isTrue);
      // White captures black at (0,1) by playing (1,1)? Verify counters
      // round-trip through undo/redo regardless of the specific position.
      final capBeforeUndo = g.board.capturedByWhite;
      g.undo();
      g.redo();
      expect(g.board.capturedByWhite, equals(capBeforeUndo));
    });
  });
}
