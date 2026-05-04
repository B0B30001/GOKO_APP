import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Origin of a saved match.
enum MatchSource { local, ai, ogs }

/// One move within a saved match. (row, col) is 0-indexed; color is 1=black,
/// 2=white, 0=pass. Mirrors the encoding used by [OptimizedBoard].
class HistoryMove {
  final int row;
  final int col;
  final int color;

  HistoryMove(this.row, this.col, this.color);

  Map<String, dynamic> toJson() => {'r': row, 'c': col, 'k': color};

  static HistoryMove fromJson(Map<String, dynamic> j) => HistoryMove(
    (j['r'] as num).toInt(),
    (j['c'] as num).toInt(),
    (j['k'] as num).toInt(),
  );
}

/// Outcome of a finished match from the local player's perspective.
enum MatchResult { win, loss, draw, unfinished }

class MatchRecord {
  final String id;
  final DateTime playedAt;
  final String opponent;
  final int boardSize;
  final MatchResult result;
  final List<HistoryMove> moves;
  final MatchSource source;

  /// Optional original SGF for OGS-sourced games — preserves exact move data.
  final String? sgf;

  MatchRecord({
    required this.id,
    required this.playedAt,
    required this.opponent,
    required this.boardSize,
    required this.result,
    required this.moves,
    required this.source,
    this.sgf,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'playedAt': playedAt.toIso8601String(),
    'opponent': opponent,
    'boardSize': boardSize,
    'result': result.name,
    'moves': moves.map((m) => m.toJson()).toList(),
    'source': source.name,
    'sgf': sgf,
  };

  static MatchRecord fromJson(Map<String, dynamic> j) => MatchRecord(
    id: j['id'] as String,
    playedAt: DateTime.parse(j['playedAt'] as String),
    opponent: j['opponent'] as String? ?? 'Unknown',
    boardSize: (j['boardSize'] as num).toInt(),
    result: MatchResult.values.firstWhere(
      (r) => r.name == j['result'],
      orElse: () => MatchResult.unfinished,
    ),
    moves: (j['moves'] as List)
        .map((m) => HistoryMove.fromJson(m as Map<String, dynamic>))
        .toList(),
    source: MatchSource.values.firstWhere(
      (s) => s.name == j['source'],
      orElse: () => MatchSource.local,
    ),
    sgf: j['sgf'] as String?,
  );
}

/// Aggregated stats for the profile screen.
class MatchAggregate {
  final int total;
  final int wins;
  final int losses;
  final int draws;
  const MatchAggregate({
    required this.total,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  double get winRate => total == 0 ? 0 : wins / total;
}

/// Local-first match history. Persists to shared_preferences as a JSON array
/// (capped at [maxRecords]). OGS-sourced games are upserted by id so re-pulls
/// don't duplicate.
class MatchHistoryService extends ChangeNotifier {
  static const _kHistoryJson = 'matchHistory.v1';
  static const int maxRecords = 200;

  final List<MatchRecord> _records = [];

  /// Newest-first.
  List<MatchRecord> get records => List.unmodifiable(_records);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistoryJson);
    _records.clear();
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        for (final entry in list) {
          _records.add(MatchRecord.fromJson(entry as Map<String, dynamic>));
        }
      } catch (_) {
        // Corrupt history — discard and start fresh.
      }
    }
    _sortNewestFirst();
    notifyListeners();
  }

  Future<void> add(MatchRecord record) async {
    final existing = _records.indexWhere((r) => r.id == record.id);
    if (existing >= 0) {
      _records[existing] = record;
    } else {
      _records.insert(0, record);
    }
    _sortNewestFirst();
    if (_records.length > maxRecords) {
      _records.removeRange(maxRecords, _records.length);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> addAll(Iterable<MatchRecord> incoming) async {
    for (final r in incoming) {
      final existing = _records.indexWhere((x) => x.id == r.id);
      if (existing >= 0) {
        _records[existing] = r;
      } else {
        _records.add(r);
      }
    }
    _sortNewestFirst();
    if (_records.length > maxRecords) {
      _records.removeRange(maxRecords, _records.length);
    }
    await _persist();
    notifyListeners();
  }

  MatchRecord? findById(String id) {
    for (final r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  MatchAggregate aggregate() {
    int wins = 0, losses = 0, draws = 0, total = 0;
    for (final r in _records) {
      if (r.result == MatchResult.unfinished) continue;
      total++;
      switch (r.result) {
        case MatchResult.win:
          wins++;
          break;
        case MatchResult.loss:
          losses++;
          break;
        case MatchResult.draw:
          draws++;
          break;
        case MatchResult.unfinished:
          break;
      }
    }
    return MatchAggregate(
      total: total,
      wins: wins,
      losses: losses,
      draws: draws,
    );
  }

  void _sortNewestFirst() {
    _records.sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_records.map((r) => r.toJson()).toList());
    await prefs.setString(_kHistoryJson, encoded);
  }
}
