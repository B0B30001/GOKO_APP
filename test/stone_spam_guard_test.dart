import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/optimized_game.dart';

/// Regression test for the "stone spam" bug: tapping the same point twice in
/// rapid succession must NEVER place two stones.
///
/// The UI layer maintains per-frame guards (`_placingMove` in game_board_screen,
/// `_awaitingOpponent` in puzzle_screen, `_pendingMove` in online_game_screen),
/// but those guards can be weakened by a future UI refactor. The underlying
/// engine must be the last line of defense — a second `playTurn(i, j)` against
/// the same point (which is now occupied by the first stone) must return
/// `false` and leave the board unchanged.
void main() {
  group('Stone-spam protection at the engine level', () {
    test('placing twice on the same point: second call returns false', () {
      final game = Game(9);
      expect(game.playTurn(4, 4), isTrue, reason: 'first move on empty point');
      // Same coordinates — the point is now occupied by Black. The second
      // attempt must not place anything.
      final secondAccepted = game.playTurn(4, 4);
      expect(
        secondAccepted,
        isFalse,
        reason: 'spam: same-point retry must be rejected',
      );
      // Engine should have advanced exactly one turn — it's now White's turn,
      // not Black's again (which would happen if the second call had also
      // succeeded and switched the player back).
      expect(game.isBlackTurn, isFalse);
    });

    test('rapid retries on the same point never duplicate the stone', () {
      final game = Game(9);
      game.playTurn(2, 2); // Black places at (2,2)
      // Hammer the same coordinate 50 times — simulating a misbehaving
      // tap stream that races ahead of the UI guard.
      for (int i = 0; i < 50; i++) {
        expect(game.playTurn(2, 2), isFalse);
      }
      // Board state should still have exactly one black stone there and
      // no double-switches.
      expect(game.board.getStone(2, 2), 1);
      expect(game.isBlackTurn, isFalse);
    });

    test(
      'switching to a NEW empty point after a same-point spam still works',
      () {
        final game = Game(9);
        game.playTurn(3, 3); // Black
        // 10 illegal retries on the occupied point
        for (int i = 0; i < 10; i++) {
          expect(game.playTurn(3, 3), isFalse);
        }
        // White's legitimate next move on a different empty point succeeds.
        expect(game.playTurn(5, 5), isTrue);
        expect(game.board.getStone(5, 5), 2);
        expect(game.isBlackTurn, isTrue);
      },
    );
  });
}
