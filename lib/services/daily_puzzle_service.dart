import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/puzzle.dart';

/// Chess.com-style 5-puzzles-per-UTC-day track.
///
/// Behavior:
/// - All devices see the same 5 puzzles on a given UTC date (seeded by date).
/// - The user can **swap** an unwanted slot for another puzzle, capped at
///   [maxSwapsPerDay] for free users (premium gets unlimited but the gating
///   lives in the calling UI, not here, since this service has no auth context).
/// - Solved state and swap state are persisted in SharedPreferences scoped to
///   the current `dailySet_dateKey` — when the UTC date rolls over, all
///   per-day state is dropped on the next load.
class DailyPuzzleService extends ChangeNotifier {
  /// Number of daily puzzles surfaced per day.
  static const int dailyCount = 5;

  /// Free-tier swap cap. Premium UIs may ignore this.
  static const int maxSwapsPerDay = 2;

  // SharedPreferences keys (date-scoped — see [_dateKey]).
  static const _kDateKey = 'dailySet_dateKey';
  static const _kSlotIds = 'dailySet_slotIds';
  static const _kSolvedIds = 'dailySet_solvedIds';
  static const _kSwapsUsed = 'dailySet_swapsUsed';
  static const _kCursor = 'dailySet_cursor';

  /// Injectable clock so tests can advance time without sleeping.
  final DateTime Function() _now;

  DailyPuzzleService({DateTime Function()? now})
    : _now = now ?? (() => DateTime.now().toUtc());

  /// Cached state for the current UTC day. Lazy-loaded.
  String? _loadedDateKey;
  List<String> _slotIds = const [];
  Set<String> _solvedIds = const {};
  int _swapsUsed = 0;
  int _cursor = dailyCount;

  Future<void> _ensureLoaded() async {
    final today = _dateKey(_now());
    if (_loadedDateKey == today) return;

    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_kDateKey);

    if (storedDate == today) {
      // Same UTC day — restore prior state.
      _slotIds = prefs.getStringList(_kSlotIds) ?? const [];
      _solvedIds = (prefs.getStringList(_kSolvedIds) ?? const []).toSet();
      _swapsUsed = prefs.getInt(_kSwapsUsed) ?? 0;
      _cursor = prefs.getInt(_kCursor) ?? _slotIds.length;
    } else {
      // New day (or first ever run) — seed fresh.
      final shuffled = _shuffledForDay(today);
      _slotIds = shuffled.take(dailyCount).toList();
      _solvedIds = <String>{};
      _swapsUsed = 0;
      _cursor = dailyCount;
      await _persist(prefs, dateKey: today);
    }
    _loadedDateKey = today;
  }

  /// Today's 5 puzzles, deterministic per UTC date and stable until midnight.
  Future<List<Puzzle>> todaysPuzzles() async {
    await _ensureLoaded();
    return _slotIds.map(_lookupPuzzle).whereType<Puzzle>().toList();
  }

  /// Set of puzzle ids solved today.
  Future<Set<String>> solvedIds() async {
    await _ensureLoaded();
    return Set.unmodifiable(_solvedIds);
  }

  /// Convenience counter for the header.
  Future<int> solvedCountForToday() async {
    final ids = await solvedIds();
    return ids.length;
  }

  /// Number of swaps still available today.
  Future<int> remainingSwaps() async {
    await _ensureLoaded();
    return (maxSwapsPerDay - _swapsUsed).clamp(0, maxSwapsPerDay);
  }

  /// Mark a puzzle as solved. Idempotent.
  Future<void> markSolved(String puzzleId) async {
    await _ensureLoaded();
    if (_solvedIds.contains(puzzleId)) return;
    _solvedIds = {..._solvedIds, puzzleId};
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs, dateKey: _loadedDateKey!);
    notifyListeners();
  }

  /// Replace the puzzle at [slotIndex] with the next puzzle in today's
  /// shuffled order. Returns true if the swap happened, false if blocked
  /// (out-of-range index, no swaps remaining, or no more candidates).
  Future<bool> swap(int slotIndex) async {
    await _ensureLoaded();
    if (slotIndex < 0 || slotIndex >= _slotIds.length) return false;
    if (_swapsUsed >= maxSwapsPerDay) return false;

    final today = _loadedDateKey!;
    final shuffled = _shuffledForDay(today);
    // Find the next puzzle not already in the slots.
    String? next;
    var cursor = _cursor;
    while (cursor < shuffled.length) {
      final candidate = shuffled[cursor];
      cursor++;
      if (!_slotIds.contains(candidate)) {
        next = candidate;
        break;
      }
    }
    if (next == null) return false;

    _slotIds = List.of(_slotIds)..[slotIndex] = next;
    _cursor = cursor;
    _swapsUsed++;
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs, dateKey: today);
    notifyListeners();
    return true;
  }

  // ---- internals ----

  Future<void> _persist(
    SharedPreferences prefs, {
    required String dateKey,
  }) async {
    await prefs.setString(_kDateKey, dateKey);
    await prefs.setStringList(_kSlotIds, _slotIds);
    await prefs.setStringList(_kSolvedIds, _solvedIds.toList());
    await prefs.setInt(_kSwapsUsed, _swapsUsed);
    await prefs.setInt(_kCursor, _cursor);
  }

  /// Deterministic shuffle of all puzzle ids seeded by the UTC date string.
  /// Same input → same output across every device.
  List<String> _shuffledForDay(String dateKey) {
    final all = PuzzleData.playablePuzzles.map((p) => p.id).toList();
    // Seed = hash of date key (year-month-day) so a calendar day yields one
    // permutation. The `hashCode` of the string is platform-stable for this
    // use (only used to seed Random; we don't compare across platforms).
    final rng = Random(dateKey.hashCode);
    all.shuffle(rng);
    return all;
  }

  Puzzle? _lookupPuzzle(String id) {
    for (final p in PuzzleData.playablePuzzles) {
      if (p.id == id) return p;
    }
    return null;
  }

  static String _dateKey(DateTime now) {
    final utc = now.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
