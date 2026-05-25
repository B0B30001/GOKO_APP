import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/services/subscription_service.dart';

/// Unit tests for the [PremiumPlan] anchor / discount math. The actual prices
/// shown to users come from StoreKit/Play Billing at runtime via RevenueCat —
/// these tests cover the static fallback values + the savings percentages
/// the UI displays as a "Save X%" pill on each tier card.
void main() {
  group('PremiumPlan', () {
    test('every plan has a distinct, non-empty product ID', () {
      final ids = PremiumPlan.values.map((p) => p.productId).toList();
      expect(
        ids.toSet().length,
        equals(ids.length),
        reason: 'duplicate productId',
      );
      for (final id in ids) {
        expect(id, isNotEmpty);
      }
    });

    test('product IDs follow the goko_premium_* convention', () {
      for (final p in PremiumPlan.values) {
        expect(
          p.productId,
          startsWith('goko_premium_'),
          reason: 'productId ${p.productId} breaks the naming convention',
        );
      }
    });

    test('every plan has a fallback price + anchor price', () {
      for (final p in PremiumPlan.values) {
        expect(p.fallbackPrice, startsWith('\$'));
        expect(p.anchorPrice, startsWith('\$'));
      }
    });

    test('savings percent is positive and < 100 for every plan', () {
      for (final p in PremiumPlan.values) {
        expect(p.savePercent, greaterThan(0));
        expect(p.savePercent, lessThan(100));
      }
    });

    test('annual savings beats monthly savings (anchoring rule)', () {
      // The whole point of the annual tier being "MOST POPULAR" is that it
      // shows the biggest discount — if monthly accidentally surpassed it,
      // users would pick monthly and the LTV math breaks.
      expect(
        PremiumPlan.annual.savePercent,
        greaterThan(PremiumPlan.monthly.savePercent),
      );
    });
  });
}
