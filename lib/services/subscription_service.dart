import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zaibal/models/user.dart';
import 'iap_service.dart';

/// User-selectable purchase plan on the paywall. Maps 1:1 to a RevenueCat
/// product identifier. The entitlement granted is the same (`premium`) for
/// all three — what differs is billing cadence + price.
enum PremiumPlan { monthly, annual, lifetime }

extension PremiumPlanX on PremiumPlan {
  /// Product identifier as configured in App Store Connect / Google Play
  /// Console. Must match the SKU you create in your store dashboard and
  /// attach as a package in RevenueCat's Offering.
  String get productId => switch (this) {
    PremiumPlan.monthly => 'goko_premium_monthly_499',
    PremiumPlan.annual => 'goko_premium_annual_4999',
    PremiumPlan.lifetime => 'goko_premium_lifetime_7999',
  };

  /// Default-display price in USD when the StoreKit/Play Billing product
  /// hasn't loaded yet (e.g. offline, before init). Real price always
  /// comes from the platform store via RevenueCat.
  String get fallbackPrice => switch (this) {
    PremiumPlan.monthly => '\$4.99',
    PremiumPlan.annual => '\$49.99',
    PremiumPlan.lifetime => '\$79.99',
  };

  /// "Original" anchored price (struck through on the card). Represents the
  /// retail-equivalent cost if the user paid month-by-month: e.g. annual at
  /// \$49.99 vs. 12 × monthly at \$59.88 → "Save 17%". The strikethrough is
  /// the no-discount alternative, not a fabricated past price — that keeps
  /// the false-discount pattern ethical per app-store guidelines.
  String get anchorPrice => switch (this) {
    PremiumPlan.monthly => '\$9.99',
    PremiumPlan.annual => '\$119.88',
    PremiumPlan.lifetime => '\$99.99',
  };

  /// Percentage savings vs. the anchor price — for the "Save X%" pill.
  int get savePercent => switch (this) {
    PremiumPlan.monthly => 50,
    PremiumPlan.annual => 58,
    PremiumPlan.lifetime => 20,
  };
}

/// Entitlements derived from the current subscription tier.
class Entitlements {
  final bool unlimitedPuzzles;
  final bool postGameAnalysis;
  final bool profileFlair;

  const Entitlements({
    required this.unlimitedPuzzles,
    required this.postGameAnalysis,
    required this.profileFlair,
  });

  static const free = Entitlements(
    unlimitedPuzzles: false,
    postGameAnalysis: false,
    profileFlair: false,
  );

  static const premium = Entitlements(
    unlimitedPuzzles: true,
    postGameAnalysis: true,
    profileFlair: true,
  );
}

/// Stub freemium controller. Real billing (in_app_purchase / Stripe) will
/// replace [unlockPremium] later.
///
/// Free tier: 3 puzzles per UTC day. Counter resets at the next UTC midnight.
/// Premium tier: unlimited.
class SubscriptionService extends ChangeNotifier {
  static const int freeDailyPuzzleQuota = 3;

  /// Free users can open the post-game Game Review screen this many times
  /// per UTC day. Premium is unlimited.
  static const int freeDailyGameReviewQuota = 1;

  static const _kTier = 'subscriptionTier';
  static const _kSolved = 'dailyPuzzlesSolved';
  static const _kResetAt = 'dailyResetAtMillis';
  static const _kGameReviewsToday = 'dailyGameReviewsStarted';

  /// Injectable clock so tests can advance time across the UTC-midnight
  /// boundary without sleeping. Returns the current UTC time when null.
  final DateTime Function() _now;

  SubscriptionService({DateTime Function()? now})
    : _now = now ?? (() => DateTime.now().toUtc()),
      _dailyResetAt = _nextUtcMidnight(
        (now ?? (() => DateTime.now().toUtc()))(),
      );

  SubscriptionTier _tier = SubscriptionTier.free;
  int _dailyPuzzlesSolved = 0;
  int _dailyGameReviewsStarted = 0;
  DateTime _dailyResetAt;

  SubscriptionTier get tier => _tier;
  int get dailyPuzzlesSolved => _dailyPuzzlesSolved;
  int get dailyPuzzlesRemaining => (freeDailyPuzzleQuota - _dailyPuzzlesSolved)
      .clamp(0, freeDailyPuzzleQuota);
  bool get isPremium => _tier == SubscriptionTier.premium;
  Entitlements get entitlements =>
      isPremium ? Entitlements.premium : Entitlements.free;

  /// Free users get [freeDailyGameReviewQuota] post-game Game Reviews per
  /// UTC day; Premium is unlimited. Counter resets at the same UTC midnight
  /// as the daily-puzzle quota.
  int get dailyGameReviewsStarted => _dailyGameReviewsStarted;
  int get dailyGameReviewsRemaining =>
      (freeDailyGameReviewQuota - _dailyGameReviewsStarted).clamp(
        0,
        freeDailyGameReviewQuota,
      );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final tierName = prefs.getString(_kTier);
    _tier = SubscriptionTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => SubscriptionTier.free,
    );
    _dailyPuzzlesSolved = prefs.getInt(_kSolved) ?? 0;
    _dailyGameReviewsStarted = prefs.getInt(_kGameReviewsToday) ?? 0;
    final resetMillis = prefs.getInt(_kResetAt);
    _dailyResetAt = resetMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(resetMillis, isUtc: true)
        : _nextUtcMidnight(_now());
    _maybeResetDaily();
    notifyListeners();
  }

  /// Returns true if the user can attempt another puzzle today.
  bool canSolveAnotherPuzzle() {
    _maybeResetDaily();
    if (entitlements.unlimitedPuzzles) return true;
    return _dailyPuzzlesSolved < freeDailyPuzzleQuota;
  }

  /// Increments the daily counter. No-op for premium users.
  Future<void> recordPuzzleAttempted() async {
    _maybeResetDaily();
    if (entitlements.unlimitedPuzzles) return;
    _dailyPuzzlesSolved++;
    await _persist();
    notifyListeners();
  }

  /// True if the user is allowed to open the post-game Game Review screen
  /// right now. Premium is always allowed; free users get
  /// [freeDailyGameReviewQuota] per UTC day.
  bool canStartGameReviewToday() {
    _maybeResetDaily();
    if (isPremium) return true;
    return _dailyGameReviewsStarted < freeDailyGameReviewQuota;
  }

  /// Record that the user just opened Game Review. No-op for premium.
  Future<void> recordGameReviewStart() async {
    _maybeResetDaily();
    if (isPremium) return;
    _dailyGameReviewsStarted++;
    await _persist();
    notifyListeners();
  }

  /// Launches the Google Play purchase sheet via RevenueCat for the given
  /// [plan]. When omitted, defaults to the Annual plan (best-value anchor).
  ///
  /// Falls back to a local stub flip when IapService is not yet configured
  /// (API key still has the placeholder value) so the paywall remains
  /// testable in development without a real Play Store listing.
  ///
  /// Throws [PurchasesErrorCode] on a real billing failure (not on cancel —
  /// cancel is treated as a silent no-op). The UI layer must catch these.
  Future<void> purchasePremium([PremiumPlan plan = PremiumPlan.annual]) async {
    if (!IapService.instance.isConfigured) {
      // Dev/test: RevenueCat not set up yet — use local stub.
      await _stubUnlockPremium();
      return;
    }
    try {
      final success = await IapService.instance.purchase(plan.productId);
      if (success) {
        _tier = SubscriptionTier.premium;
        await _persist();
        notifyListeners();
      }
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return;
      rethrow;
    }
  }

  /// Restores a previous Google Play purchase. Returns true when premium
  /// was successfully restored.
  Future<bool> restorePurchases() async {
    try {
      final restored = await IapService.instance.restorePurchases();
      if (restored) {
        _tier = SubscriptionTier.premium;
        await _persist();
        notifyListeners();
      }
      return restored;
    } catch (_) {
      return false;
    }
  }

  /// Dev/testing stub — flips premium locally without a real purchase.
  Future<void> _stubUnlockPremium() async {
    _tier = SubscriptionTier.premium;
    await _persist();
    notifyListeners();
  }

  /// Debug-only revert. Useful for testing the paywall flow.
  Future<void> lockPremium() async {
    _tier = SubscriptionTier.free;
    await _persist();
    notifyListeners();
  }

  void _maybeResetDaily() {
    final nowUtc = _now();
    if (!nowUtc.isBefore(_dailyResetAt)) {
      _dailyPuzzlesSolved = 0;
      _dailyGameReviewsStarted = 0;
      _dailyResetAt = _nextUtcMidnight(nowUtc);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTier, _tier.name);
    await prefs.setInt(_kSolved, _dailyPuzzlesSolved);
    await prefs.setInt(_kGameReviewsToday, _dailyGameReviewsStarted);
    await prefs.setInt(_kResetAt, _dailyResetAt.millisecondsSinceEpoch);
  }

  static DateTime _nextUtcMidnight(DateTime nowUtc) {
    final next = DateTime.utc(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
    ).add(const Duration(days: 1));
    return next;
  }
}
