import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/utils/turn.dart';

void main() {
  group('nextPlayer', () {
    test('1 (black) -> 2 (white)', () {
      expect(nextPlayer(1), 2);
    });

    test('2 (white) -> 1 (black)', () {
      expect(nextPlayer(2), 1);
    });

    test('round-trips', () {
      expect(nextPlayer(nextPlayer(1)), 1);
      expect(nextPlayer(nextPlayer(2)), 2);
    });

    test('non-1 inputs default to 1 (defensive)', () {
      expect(nextPlayer(0), 1);
      expect(nextPlayer(-1), 1);
    });
  });
}
