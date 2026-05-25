import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/optimized_game.dart';

/// Regression test for the standard Go pass rule: when both players pass
/// consecutively, the game ends. A single pass does not end the game; a pass
/// followed by a move (then later another pass) does not end the game either —
/// the counter must reset whenever a stone is actually placed.
///
/// This logic lives in `optimized_game.dart`:
///   - `pass()` increments `_consecutivePasses`
///   - `playTurn()` resets `_consecutivePasses` to 0 on a successful move
///   - `isGameOver` returns `_consecutivePasses >= 2`
void main() {
  group('Double-pass terminates the game', () {
    test('one pass alone does not end the game', () {
      final game = Game(9);
      game.pass();
      expect(
        game.isGameOver,
        isFalse,
        reason: 'one pass should leave the game live',
      );
    });

    test('two consecutive passes end the game', () {
      final game = Game(9);
      game.pass();
      game.pass();
      expect(
        game.isGameOver,
        isTrue,
        reason: 'double-pass must trigger game-over',
      );
    });

    test('pass → move → pass is NOT game-over (counter resets on move)', () {
      final game = Game(9);
      game.pass();
      // Some valid move on an empty board.
      final placed = game.playTurn(2, 2);
      expect(placed, isTrue);
      game.pass();
      expect(
        game.isGameOver,
        isFalse,
        reason: 'a move between passes resets the pass counter',
      );
    });

    test('pass → pass after a long mid-game sequence still terminates', () {
      final game = Game(9);
      game.playTurn(3, 3); // B
      game.playTurn(5, 5); // W
      game.playTurn(3, 5); // B
      game.playTurn(5, 3); // W
      // Now both players pass back-to-back to end the game.
      game.pass();
      game.pass();
      expect(game.isGameOver, isTrue);
    });
  });
}
