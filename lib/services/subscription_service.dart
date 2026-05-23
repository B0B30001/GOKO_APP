import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zaibal/models/user.dart';

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

  /// Stub purchase flow. Flips the local flag.
  Future<void> unlockPremium() async {
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
