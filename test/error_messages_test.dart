import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/utils/error_messages.dart';

void main() {
  group('mapGameError', () {
    test('turn-related', () {
      expect(mapGameError('not_your_turn'), "It's not your turn");
      expect(mapGameError('out_of_turn'), "It's not your turn");
    });

    test('occupied', () {
      expect(mapGameError('stone_already_placed_here'), 'A stone is already there');
      expect(mapGameError('occupied'), 'A stone is already there');
    });

    test('illegal move', () {
      expect(mapGameError('illegal_move'), 'Illegal move');
    });

    test('self-capture / suicide', () {
      expect(mapGameError('self_capture'), 'Self-capture is not allowed');
      expect(mapGameError('suicide'), 'Self-capture is not allowed');
    });

    test('ko violation', () {
      expect(mapGameError('ko violation'), 'Ko rule violation');
      expect(mapGameError('ko illegal'), 'Ko rule violation');
    });

    test('out of bounds', () {
      expect(mapGameError('out_of_bounds'), 'Move is out of bounds');
    });

    test('busy / rate limit', () {
      expect(mapGameError('server busy'), 'Server is busy, please try again');
      expect(mapGameError('rate limit exceeded'), 'Server is busy, please try again');
    });

    test('timeouts', () {
      expect(mapGameError('timeout'), 'Out of time');
      expect(mapGameError('out_of_time'), 'Out of time');
    });

    test('play phase', () {
      expect(mapGameError('game_is_not_in_play_phase'), 'Game is not in play phase');
      expect(mapGameError('not in play'), 'Game is not in play phase');
    });

    test('fallback', () {
      expect(mapGameError('unknown_error_code_123'), 'unknown_error_code_123');
    });
  });
}
