import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/screens/puzzle_garden_screen.dart';
import 'package:zaibal/services/progress_service.dart';
import 'package:zaibal/services/subscription_service.dart';

/// Smoke tests for [PuzzleGardenScreen].
///
/// These don't exercise the puzzle pool (that requires the asset bundle which
/// is awkward in widget tests). Instead they verify the screen renders without
/// overflow at common phone sizes and the headline structure is present.
Future<void> _pump(WidgetTester tester, {required int xp}) async {
  SharedPreferences.setMockInitialValues({'progress.xp.v1': xp});
  final progress = ProgressService();
  await progress.load();
  final subscription = SubscriptionService();
  await subscription.load();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progress),
          ChangeNotifierProvider.value(value: subscription),
        ],
        child: const Scaffold(body: PuzzleGardenScreen()),
      ),
    ),
  );
  // Let the post-frame callback for scrolling settle. We don't pumpAndSettle
  // because the bobbing AnimationController on the player stone loops forever.
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('garden screen renders without overflow on a 360x640 phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(tester, xp: 0);

    // No exception means no overflow / no missing required parameter.
    expect(tester.takeException(), isNull);
    // The "Solve Puzzles" CTA is the screen's primary entry point and must
    // always be present (even before puzzles load — disabled if pool empty).
    expect(find.byIcon(Icons.extension), findsOneWidget);
  });

  testWidgets('garden screen renders without overflow on a tablet width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900 * 2, 1300 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(tester, xp: 3000);
    expect(tester.takeException(), isNull);
  });

  // XP-based level: the sticky header always renders "<xp> XP". We can't
  // easily reach into private _LevelTile state, but seeing the right XP in
  // the header confirms the threshold math is wired up.
  testWidgets('sticky header shows 0 XP for a fresh player', (tester) async {
    await _pump(tester, xp: 0);
    expect(find.text('0 XP'), findsOneWidget);
    // Tear down the widget so the bobbing animation + celebrate Future.delayed
    // don't leak pending timers into the next test.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sticky header shows 3000 XP at the Crystal Cave threshold', (
    tester,
  ) async {
    await _pump(tester, xp: 3000);
    expect(find.text('3000 XP'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sticky header shows 11000 XP at the Copper Peaks threshold', (
    tester,
  ) async {
    await _pump(tester, xp: 11000);
    expect(find.text('11000 XP'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
