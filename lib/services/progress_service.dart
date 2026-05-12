import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the player's overall learning progress across puzzles and lessons.
///
/// Persists solved puzzle IDs, completed lesson IDs, total XP, and a
/// daily-puzzle streak. XP is used to derive a puzzle "rating" similar to
/// chess.com — 1 000 base + 10 per solved puzzle + 20 per completed lesson.
///
/// This service is a [ChangeNotifier] so any widget can rebuild when progress
/// changes. Register it as a [ChangeNotifierProvider] in main.dart and call
/// [load] on startup before [runApp].
class ProgressService extends ChangeNotifier {
  // SharedPreferences keys — never change these without a migration.
  static const _kSolvedPuzzles = 'progress.solvedPuzzles.v1';
  static const _kCompletedLessons = 'progress.completedLessons.v1';
  static const _kXp = 'progress.xp.v1';
  static const _kStreak = 'progress.streak.v1';
  static const _kLastStreakDate = 'progress.lastStreakDate.v1';

  Set<String> _solvedPuzzles = {};
  Set<String> _completedLessons = {};
  int _xp = 0;
  int _streak = 0;

  // ── Public getters ──────────────────────────────────────────────────────────

  /// IDs of puzzles the player has solved at least once.
  Set<String> get solvedPuzzles => Set.unmodifiable(_solvedPuzzles);

  /// IDs of tutorials/lessons the player has marked complete.
  Set<String> get completedLessons => Set.unmodifiable(_completedLessons);

  /// Total experience points earned.
  int get xp => _xp;

  /// Current consecutive-day puzzle streak.
  int get streak => _streak;

  /// Estimated puzzle rating (chess.com style: 1 000 base + XP bonus).
  int get puzzleRating => 1000 + (_xp ~/ 3).clamp(0, 2400);

  /// Number of puzzles solved.
  int get solvedCount => _solvedPuzzles.length;

  /// Number of lessons completed.
  int get lessonsCompleted => _completedLessons.length;

  bool isPuzzleSolved(String id) => _solvedPuzzles.contains(id);
  bool isLessonCompleted(String id) => _completedLessons.contains(id);

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Load persisted state. Must be awaited before first UI frame.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _solvedPuzzles =
        (prefs.getStringList(_kSolvedPuzzles) ?? []).toSet();
    _completedLessons =
        (prefs.getStringList(_kCompletedLessons) ?? []).toSet();
    _xp = prefs.getInt(_kXp) ?? 0;
    _streak = prefs.getInt(_kStreak) ?? 0;
    // No need to notify on load — widgets haven't built yet.
  }

  // ── State mutations ─────────────────────────────────────────────────────────

  /// Record that the player solved [puzzleId]. Idempotent — calling again for
  /// the same ID awards no additional XP.
  Future<void> markPuzzleSolved(String puzzleId) async {
    if (_solvedPuzzles.contains(puzzleId)) return;
    _solvedPuzzles.add(puzzleId);
    _xp += 10;
    _updateStreak();
    await _save();
    notifyListeners();
  }

  /// Record that the player completed lesson/tutorial [lessonId].
  Future<void> markLessonCompleted(String lessonId) async {
    if (_completedLessons.contains(lessonId)) return;
    _completedLessons.add(lessonId);
    _xp += 20;
    await _save();
    notifyListeners();
  }

  // ── Streak logic ────────────────────────────────────────────────────────────

  void _updateStreak() {
    // Increment streak if this is the first solve today; reset if a day was
    // skipped. Uses a simple UTC-date key comparison.
    final today = _todayKey();
    SharedPreferences.getInstance().then((prefs) {
      final last = prefs.getString(_kLastStreakDate);
      if (last == today) return; // Already counted today.
      final yesterday = _dayKey(DateTime.now().toUtc().subtract(
        const Duration(days: 1),
      ));
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
    ]);
  }
}
