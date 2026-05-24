import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the player's overall learning progress across puzzles and lessons.
///
/// Persists solved puzzle IDs, completed lesson IDs, total XP, a daily streak
/// (counts on any puzzle solve or lesson completion), and per-lesson resume
/// bookmarks so users can pick up mid-lesson on a later session.
class ProgressService extends ChangeNotifier {
  // SharedPreferences keys — never change these without a migration.
  static const _kSolvedPuzzles = 'progress.solvedPuzzles.v1';
  static const _kCompletedLessons = 'progress.completedLessons.v1';
  static const _kXp = 'progress.xp.v1';
  static const _kStreak = 'progress.streak.v1';
  static const _kLastStreakDate = 'progress.lastStreakDate.v1';
  static const _kRatingHistory = 'progress.ratingHistory.v1';
  static const _kLessonBookmarks = 'progress.lessonBookmarks.v1';
  static const _kBestPuzzleStreak = 'progress.bestPuzzleStreak.v1';

  /// Hard cap on stored rating snapshots — keeps SharedPreferences small.
  static const int _maxRatingHistory = 50;

  Set<String> _solvedPuzzles = {};
  Set<String> _completedLessons = {};
  int _xp = 0;
  int _streak = 0;
  int _bestPuzzleStreak = 0;
  List<int> _ratingHistory = [];

  /// Per-lesson last-viewed step index (0-based). Lesson screen reads on
  /// entry to offer "Resume" and writes on every step navigation.
  Map<String, int> _lessonBookmarks = {};

  // ── Public getters ──────────────────────────────────────────────────────────

  Set<String> get solvedPuzzles => Set.unmodifiable(_solvedPuzzles);
  Set<String> get completedLessons => Set.unmodifiable(_completedLessons);
  int get xp => _xp;
  int get streak => _streak;
  int get bestPuzzleStreak => _bestPuzzleStreak;
  int get puzzleRating => 1000 + (_xp ~/ 3).clamp(0, 2400);
  List<int> get ratingHistory => List.unmodifiable(_ratingHistory);
  int get solvedCount => _solvedPuzzles.length;
  int get lessonsCompleted => _completedLessons.length;

  bool isPuzzleSolved(String id) => _solvedPuzzles.contains(id);
  bool isLessonCompleted(String id) => _completedLessons.contains(id);

  /// Returns the saved step index for [lessonId], or null if the player has
  /// never entered the lesson (or has completed and cleared it).
  int? getLessonBookmark(String lessonId) => _lessonBookmarks[lessonId];

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _solvedPuzzles = (prefs.getStringList(_kSolvedPuzzles) ?? []).toSet();
    _completedLessons = (prefs.getStringList(_kCompletedLessons) ?? []).toSet();
    _xp = prefs.getInt(_kXp) ?? 0;
    _streak = prefs.getInt(_kStreak) ?? 0;
    _bestPuzzleStreak = prefs.getInt(_kBestPuzzleStreak) ?? 0;
    _ratingHistory = (prefs.getStringList(_kRatingHistory) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    final raw = prefs.getString(_kLessonBookmarks);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _lessonBookmarks = decoded.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          );
        }
      } catch (_) {
        _lessonBookmarks = {};
      }
    }
  }

  // ── State mutations ─────────────────────────────────────────────────────────

  /// Record that the player solved [puzzleId]. Idempotent — calling again for
  /// the same ID awards no additional XP.
  Future<void> markPuzzleSolved(String puzzleId) async {
    if (_solvedPuzzles.contains(puzzleId)) return;
    _solvedPuzzles.add(puzzleId);
    _xp += 10;
    _pushRatingSnapshot();
    _updateStreak();
    await _save();
    notifyListeners();
  }

  /// Record that the player completed lesson/tutorial [lessonId].
  ///
  /// [xpAward] defaults to 20 (legacy); callers can pass a star-scaled value
  /// (e.g. 30 for a no-hint run) so XP reflects performance.
  Future<void> markLessonCompleted(String lessonId, {int xpAward = 20}) async {
    if (_completedLessons.contains(lessonId)) {
      // Already completed before — still clear any stale bookmark so the
      // lesson re-opens at step 0 next time.
      _lessonBookmarks.remove(lessonId);
      await _save();
      notifyListeners();
      return;
    }
    _completedLessons.add(lessonId);
    _xp += xpAward;
    _lessonBookmarks.remove(lessonId);
    _pushRatingSnapshot();
    _updateStreak();
    await _save();
    notifyListeners();
  }

  /// Persist a per-lesson resume bookmark. The lesson screen calls this on
  /// every advance so an unexpected exit restores the user to where they were.
  /// Clears automatically on lesson completion via [markLessonCompleted].
  Future<void> setLessonBookmark(String lessonId, int stepIndex) async {
    if (stepIndex <= 0) {
      _lessonBookmarks.remove(lessonId);
    } else {
      _lessonBookmarks[lessonId] = stepIndex;
    }
    await _save();
    // Bookmark changes don't affect any visible UI today — skip notify to
    // avoid pointless rebuilds during scrubbing through lesson steps.
  }

  /// Drop a bookmark explicitly (e.g. user picked "Start over").
  Future<void> clearLessonBookmark(String lessonId) async {
    if (_lessonBookmarks.remove(lessonId) != null) {
      await _save();
    }
  }

  /// Record the best puzzle streak achieved in a single Puzzle Streak run.
  Future<void> updateBestPuzzleStreak(int streak) async {
    if (streak <= _bestPuzzleStreak) return;
    _bestPuzzleStreak = streak;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBestPuzzleStreak, _bestPuzzleStreak);
    notifyListeners();
  }

  void _pushRatingSnapshot() {
    _ratingHistory.add(puzzleRating);
    if (_ratingHistory.length > _maxRatingHistory) {
      _ratingHistory.removeRange(0, _ratingHistory.length - _maxRatingHistory);
    }
  }

  // ── Streak logic ────────────────────────────────────────────────────────────

  void _updateStreak() {
    // Increment streak if this is the first qualifying activity today; reset
    // if a day was skipped. Uses a simple UTC-date key comparison.
    final today = _todayKey();
    SharedPreferences.getInstance().then((prefs) {
      final last = prefs.getString(_kLastStreakDate);
      if (last == today) return; // Already counted today.
      final yesterday = _dayKey(
        DateTime.now().toUtc().subtract(const Duration(days: 1)),
      );
      if (last == yesterday) {
        _streak++;
      } else {
        _streak = 1; // Streak broken.
      }
      prefs.setString(_kLastStreakDate, today);
      prefs.setInt(_kStreak, _streak);
    });
  }

  static String _todayKey() => _dayKey(DateTime.now().toUtc());
  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setStringList(_kSolvedPuzzles, _solvedPuzzles.toList()),
      prefs.setStringList(_kCompletedLessons, _completedLessons.toList()),
      prefs.setInt(_kXp, _xp),
      prefs.setInt(_kStreak, _streak),
      prefs.setStringList(
        _kRatingHistory,
        _ratingHistory.map((r) => r.toString()).toList(),
      ),
      prefs.setString(_kLessonBookmarks, jsonEncode(_lessonBookmarks)),
    ]);
  }
}
