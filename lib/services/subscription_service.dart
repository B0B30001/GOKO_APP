import 'package:flutter/foundation.dart';

/// All-free stub. GOKO is currently a 100% free app — no in-app purchases,
/// no daily quotas, no premium gates. This stub keeps the [SubscriptionService]
/// type that the rest of the app reads (`isPremium`, `canSolveAnotherPuzzle`,
/// etc.) so we don't have to touch every callsite, but every accessor returns
/// the equivalent of "user is premium with unlimited everything."
///
/// If monetization is reintroduced later, the path is:
///   1. Re-add `purchases_flutter` to pubspec
///   2. Bring back `RevenueCatService` (was `IapService`) to wrap the SDK
///   3. Replace these stub bodies with real entitlement checks
///   4. Restore `PaywallScreen` + the gates that push it
///
/// Keeping the class shape stable now means none of that future re-add work
/// has to touch the calling screens.
class SubscriptionService extends ChangeNotifier {
  /// Always reports premium. No daily-quota throttling.
  bool get isPremium => true;

  /// Always returns true — there's no daily puzzle limit any more.
  bool canSolveAnotherPuzzle() => true;

  /// Always returns true — game-review usage is uncapped.
  bool canStartGameReviewToday() => true;

  /// Kept for compatibility with calling screens that want to display a
  /// "puzzles remaining today" badge. Now always 0 (i.e. "unlimited" — the
  /// UI generally hides the badge when no quota is active).
  int get dailyPuzzlesSolved => 0;
  int get dailyPuzzlesRemaining => 0;
  int get dailyGameReviewsStarted => 0;
  int get dailyGameReviewsRemaining => 0;

  /// No-op: nothing to load.
  Future<void> load() async {}

  /// No-op: there is no quota to record against.
  Future<void> recordPuzzleAttempted() async {}

  /// No-op: there is no quota to record against.
  Future<void> recordGameReviewStart() async {}
}
