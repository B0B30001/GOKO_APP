import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/utils/sgf_coords.dart';

void main() {
  group('encodeMove', () {
    test('canonical examples', () {
      expect(encodeMove(0, 0), 'aa');
      expect(encodeMove(3, 3), 'dd');
      expect(encodeMove(18, 18), 'ss');
    });

    test('does not skip the letter i (OGS convention)', () {
      expect(encodeMove(8, 8), 'ii');
    });

    test('column comes before row in encoded string', () {
      expect(encodeMove(0, 3), 'da');
      expect(encodeMove(3, 0), 'ad');
    });

    test('returns ".." for negative coordinates (pass)', () {
      expect(encodeMove(-1, -1), '..');
      expect(encodeMove(-1, 0), '..');
      expect(encodeMove(0, -1), '..');
    });

    test('returns ".." for out-of-range coordinates', () {
      expect(encodeMove(19, 0), '..');
      expect(encodeMove(0, 19), '..');
      expect(encodeMove(100, 100), '..');
    });
  });

  group('decodeSGF', () {
    test('canonical examples', () {
      expect(decodeSGF('aa'), [0, 0]);
      expect(decodeSGF('dd'), [3, 3]);
      expect(decodeSGF('ss'), [18, 18]);
    });

    test('column-first decoding', () {
      expect(decodeSGF('da'), [0, 3]);
      expect(decodeSGF('ad'), [3, 0]);
    });

    test('returns [-1, -1] for pass', () {
      expect(decodeSGF('..'), [-1, -1]);
    });

    test('returns [-1, -1] for empty / short input', () {
      expect(decodeSGF(''), [-1, -1]);
      expect(decodeSGF('a'), [-1, -1]);
    });

    test('returns [-1, -1] for invalid letters', () {
      expect(decodeSGF('zz'), [-1, -1]);
    });
  });

  group('round trip', () {
    test('encode then decode is identity for in-range coords', () {
      for (final size in [9, 13, 19]) {
        for (var r = 0; r < size; r++) {
          for (var c = 0; c < size; c++) {
            final encoded = encodeMove(r, c);
            expect(decodeSGF(encoded), [
              r,
              c,
            ], reason: 'failed for ($r, $c) on $size×$size');
          }
        }
      }
    });

    test('pass round-trips', () {
      expect(decodeSGF(encodeMove(-1, -1)), [-1, -1]);
    });
  });
}
