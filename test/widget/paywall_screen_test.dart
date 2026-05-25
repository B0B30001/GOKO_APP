import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/screens/paywall_screen.dart';
import 'package:zaibal/services/subscription_service.dart';

/// Verifies the premium paywall renders all three tier cards, the Restore
/// button is always visible, and the contextual banner is wired to the
/// PaywallReason that triggered the screen.
Future<void> _pump(
  WidgetTester tester, {
  PaywallReason reason = PaywallReason.generic,
}) async {
  // Larger viewport so the 3 pricing cards in a Row + the SingleChildScrollView
  // don't trip the layout. Real phones are taller than 600 px (the test default).
  tester.view.physicalSize = const Size(700 * 2, 1400 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final subscription = SubscriptionService();
  await subscription.load();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider.value(
        value: subscription,
        child: PaywallScreen(reason: reason),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('renders three pricing tier cards with strikethrough prices', (
    tester,
  ) async {
    await _pump(tester);

    // Strikethrough anchor prices for each tier (from PremiumPlanX.anchorPrice).
    expect(find.text('\$9.99'), findsOneWidget);
    expect(find.text('\$119.88'), findsOneWidget);
    expect(find.text('\$99.99'), findsOneWidget);
  });

  testWidgets('renders restore-purchases button', (tester) async {
    await _pump(tester);
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l.restorePurchases), findsOneWidget);
  });

  testWidgets('shows reason banner for puzzleDailyQuota', (tester) async {
    await _pump(tester, reason: PaywallReason.puzzleDailyQuota);
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l.puzzleDailyQuotaReached), findsOneWidget);
  });

  testWidgets('shows reason banner for advancedBots', (tester) async {
    await _pump(tester, reason: PaywallReason.advancedBots);
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l.advancedBotsLocked), findsOneWidget);
  });

  testWidgets('hero title is present in every locale-agnostic test', (
    tester,
  ) async {
    await _pump(tester);
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l.paywallHeroTitle), findsOneWidget);
  });
}
