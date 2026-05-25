import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/league_tier.dart';

void main() {
  group('LeagueTier.forRating', () {
    test('returns Rookie below Bronze threshold', () {
      final t = LeagueTier.forRating(1000);
      expect(t.threshold, 1000);
      // The rookie tier is the first in the list.
      expect(t, LeagueTier.tiers.first);
    });

    test('returns Bronze at exactly 1050', () {
      expect(LeagueTier.forRating(1050).threshold, 1050);
    });

    test('returns Silver at 1100, Gold at 1150', () {
      expect(LeagueTier.forRating(1100).threshold, 1100);
      expect(LeagueTier.forRating(1149).threshold, 1100);
      expect(LeagueTier.forRating(1150).threshold, 1150);
    });

    test('clamps to top tier (Diamond) at very high ratings', () {
      expect(LeagueTier.forRating(9999).threshold, 1300);
    });

    test('returns Rookie below the Rookie threshold too', () {
      // 999 is technically below Rookie's 1000 threshold but Rookie is the
      // floor — players never display "below Rookie".
      expect(LeagueTier.forRating(999), LeagueTier.tiers.first);
    });
  });

  group('LeagueTier.nextAbove', () {
    test('returns the next tier above the player', () {
      expect(LeagueTier.nextAbove(1000)?.threshold, 1050);
      expect(LeagueTier.nextAbove(1049)?.threshold, 1050);
      expect(LeagueTier.nextAbove(1050)?.threshold, 1100);
      expect(LeagueTier.nextAbove(1299)?.threshold, 1300);
    });

    test('returns null when the player is at or above the top tier', () {
      expect(LeagueTier.nextAbove(1300), isNull);
      expect(LeagueTier.nextAbove(9999), isNull);
    });
  });

  group('XP -> rating -> tier integration', () {
    // ProgressService computes rating as 1000 + (xp / 3). Verify the tier
    // boundaries the Garden's "+X XP to next league" hint relies on.
    int ratingFor(int xp) => 1000 + (xp ~/ 3).clamp(0, 2400);

    test('Bronze unlocks at 150 XP (rating 1050)', () {
      expect(ratingFor(149), 1049);
      expect(ratingFor(150), 1050);
      expect(LeagueTier.forRating(ratingFor(150)).threshold, 1050);
    });

    test('Silver unlocks at 300 XP (rating 1100)', () {
      expect(ratingFor(300), 1100);
      expect(LeagueTier.forRating(ratingFor(300)).threshold, 1100);
    });

    test('Diamond reachable from 900 XP', () {
      expect(ratingFor(900), 1300);
      expect(LeagueTier.forRating(ratingFor(900)).threshold, 1300);
    });
  });
}
