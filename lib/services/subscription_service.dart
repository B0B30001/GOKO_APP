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

  static const _kTier = 'subscriptionTier';
  static const _kSolved = 'dailyPuzzlesSolved';
  static const _kResetAt = 'dailyResetAtMillis';

  SubscriptionTier _tier = SubscriptionTier.free;
  int _dailyPuzzlesSolved = 0;
  DateTime _dailyResetAt = _nextUtcMidnight(DateTime.now().toUtc());

  SubscriptionTier get tier => _tier;
  int get dailyPuzzlesSolved => _dailyPuzzlesSolved;
  int get dailyPuzzlesRemaining => (freeDailyPuzzleQuota - _dailyPuzzlesSolved)
      .clamp(0, freeDailyPuzzleQuota);
  bool get isPremium => _tier == SubscriptionTier.premium;
  Entitlements get entitlements =>
      isPremium ? Entitlements.premium : Entitlements.free;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final tierName = prefs.getString(_kTier);
    _tier = SubscriptionTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => SubscriptionTier.free,
    );
    _dailyPuzzlesSolved = prefs.getInt(_kSolved) ?? 0;
    final resetMillis = prefs.getInt(_kResetAt);
    _dailyResetAt = resetMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(resetMillis, isUtc: true)
        : _nextUtcMidnight(DateTime.now().toUtc());
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
    final nowUtc = DateTime.now().toUtc();
    if (!nowUtc.isBefore(_dailyResetAt)) {
      _dailyPuzzlesSolved = 0;
      _dailyResetAt = _nextUtcMidnight(nowUtc);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTier, _tier.name);
    await prefs.setInt(_kSolved, _dailyPuzzlesSolved);
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
