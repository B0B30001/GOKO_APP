import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaibal/services/daily_puzzle_service.dart';
import 'package:zaibal/models/puzzle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DailyPuzzleService', () {
    test('returns 5 puzzles drawn from the puzzle library', () async {
      final svc = DailyPuzzleService(now: () => DateTime.utc(2026, 5, 10));
      final today = await svc.todaysPuzzles();
      expect(today.length, equals(DailyPuzzleService.dailyCount));
      final allIds = PuzzleData.allPuzzles.map((p) => p.id).toSet();
      for (final p in today) {
        expect(allIds.contains(p.id), isTrue);
      }
    });

    test('same UTC day yields identical 5 puzzles across instances', () async {
      DateTime fixedNow() => DateTime.utc(2026, 5, 10, 9, 30);
      final first = await DailyPuzzleService(now: fixedNow).todaysPuzzles();
      final second = await DailyPuzzleService(now: fixedNow).todaysPuzzles();
      expect(
        first.map((p) => p.id).toList(),
        equals(second.map((p) => p.id).toList()),
      );
    });

    test('UTC date change reseeds the slot list', () async {
      final mondayIds = (await DailyPuzzleService(
        now: () => DateTime.utc(2026, 5, 10),
      ).todaysPuzzles()).map((p) => p.id).toList();
      // Wipe in-memory prefs to simulate process restart on the new day.
      SharedPreferences.setMockInitialValues({});
      final tuesdayIds = (await DailyPuzzleService(
        now: () => DateTime.utc(2026, 5, 11),
      ).todaysPuzzles()).map((p) => p.id).toList();
      // Hash-seeded shuffles of different keys almost certainly differ;
      // assert at least one slot differs (very loose, robust to coincidence).
      expect(mondayIds.toString() == tuesdayIds.toString(), isFalse);
    });

    test(
      'swap replaces only the chosen slot and decrements remaining swaps',
      () async {
        final svc = DailyPuzzleService(
          now: () => DateTime.utc(2026, 5, 10, 12),
        );
        final before = (await svc.todaysPuzzles()).map((p) => p.id).toList();
        expect(await svc.remainingSwaps(), equals(2));
        final ok = await svc.swap(2);
        expect(ok, isTrue);
        final after = (await svc.todaysPuzzles()).map((p) => p.id).toList();
        expect(after[0], equals(before[0]));
        expect(after[1], equals(before[1]));
        expect(after[3], equals(before[3]));
        expect(after[4], equals(before[4]));
        expect(after[2], isNot(equals(before[2])));
        expect(await svc.remainingSwaps(), equals(1));
      },
    );

    test('swap cap blocks the 3rd swap', () async {
      final svc = DailyPuzzleService(now: () => DateTime.utc(2026, 5, 10));
      await svc.todaysPuzzles(); // ensure load
      expect(await svc.swap(0), isTrue);
      expect(await svc.swap(1), isTrue);
      expect(await svc.swap(2), isFalse);
      expect(await svc.remainingSwaps(), equals(0));
    });

    test('markSolved is idempotent and persists across instances', () async {
      DateTime fixedNow() => DateTime.utc(2026, 5, 10);
      final a = DailyPuzzleService(now: fixedNow);
      final today = await a.todaysPuzzles();
      await a.markSolved(today.first.id);
      await a.markSolved(today.first.id); // idempotent
      expect(await a.solvedCountForToday(), equals(1));

      final b = DailyPuzzleService(now: fixedNow);
      expect(await b.solvedCountForToday(), equals(1));
    });
  });
}
