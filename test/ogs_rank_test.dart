import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/utils/ogs_rank.dart';

void main() {
  group('OgsRank.fromRating', () {
    test('low rating maps to 30k floor', () {
      expect(OgsRank.fromRating(100), equals('30k'));
      expect(OgsRank.fromRating(525), equals('30k'));
    });

    test('mid-kyu rating', () {
      // 1525 → idx = (1525-525)/100 = 10 → 30-10 = 20k
      expect(OgsRank.fromRating(1525), equals('20k'));
      // 2025 → idx = 15 → 15k
      expect(OgsRank.fromRating(2025), equals('15k'));
      // 2425 → idx = 19 → 11k? Actually idx=19 → 30-19=11k
      expect(OgsRank.fromRating(2425), equals('11k'));
    });

    test('1-dan boundary at idx 30', () {
      // 525 + 30*100 = 3525 → 1d
      expect(OgsRank.fromRating(3525), equals('1d'));
      // 3625 → 2d
      expect(OgsRank.fromRating(3625), equals('2d'));
    });

    test('caps at 9d', () {
      expect(OgsRank.fromRating(99999), equals('9d'));
    });

    test('invalid inputs', () {
      expect(OgsRank.fromRating(0), equals('?'));
      expect(OgsRank.fromRating(double.nan), equals('?'));
    });
  });

  group('OgsRank.bestLabel', () {
    test('prefers rank-shaped string', () {
      expect(OgsRank.bestLabel(rankString: '5k', rating: 9999), equals('5k'));
      expect(OgsRank.bestLabel(rankString: '2d', rating: 9999), equals('2d'));
    });

    test('falls back to rating when rankString is just numeric', () {
      expect(OgsRank.bestLabel(rankString: '30', rating: 1525), equals('20k'));
    });

    test('returns null when nothing usable', () {
      expect(OgsRank.bestLabel(rankString: null, rating: null), isNull);
    });
  });
}
