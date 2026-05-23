import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaibal/services/subscription_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SubscriptionService free tier', () {
    test('blocks the 4th puzzle of the day', () async {
      final svc = SubscriptionService(now: () => DateTime.utc(2026, 5, 10, 12));
      await svc.load();
      for (var i = 0; i < SubscriptionService.freeDailyPuzzleQuota; i++) {
        expect(svc.canSolveAnotherPuzzle(), isTrue, reason: 'attempt $i');
        await svc.recordPuzzleAttempted();
      }
      expect(svc.canSolveAnotherPuzzle(), isFalse);
    });

    test('counter resets after UTC midnight rollover', () async {
      var now = DateTime.utc(2026, 5, 10, 23, 30);
      final svc = SubscriptionService(now: () => now);
      await svc.load();
      // Burn the quota.
      for (var i = 0; i < SubscriptionService.freeDailyPuzzleQuota; i++) {
        await svc.recordPuzzleAttempted();
      }
      expect(svc.canSolveAnotherPuzzle(), isFalse);

      // Advance past UTC midnight.
      now = DateTime.utc(2026, 5, 11, 0, 5);
      expect(
        svc.canSolveAnotherPuzzle(),
        isTrue,
        reason: 'counter should reset after midnight',
      );
      expect(
        svc.dailyPuzzlesRemaining,
        equals(SubscriptionService.freeDailyPuzzleQuota),
      );
    });
  });

  group('SubscriptionService premium tier', () {
    test('unlimited attempts after unlockPremium', () async {
      final svc = SubscriptionService(now: () => DateTime.utc(2026, 5, 10));
      await svc.load();
      await svc.purchasePremium();
      expect(svc.isPremium, isTrue);
      for (var i = 0; i < 100; i++) {
        expect(svc.canSolveAnotherPuzzle(), isTrue);
        await svc.recordPuzzleAttempted();
      }
      // Counter must not advance for premium users.
      expect(svc.dailyPuzzlesSolved, equals(0));
    });
  });
}
