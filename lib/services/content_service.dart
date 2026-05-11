import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/puzzle.dart';
import '../models/puzzle_collection.dart';
import '../models/tutorial.dart';

/// Loads tutorials and puzzles from `assets/content/*.json`. Cached after
/// first load — content is read-only at runtime.
class ContentService {
  static List<Tutorial>? _tutorials;
  static List<Puzzle>? _jsonPuzzles;
  static List<PuzzleCollection>? _collections;

  /// Lazy-load and cache the curated puzzle collections.
  static Future<List<PuzzleCollection>> loadCollections() async {
    if (_collections != null) return _collections!;
    final raw = await rootBundle.loadString('assets/content/collections.json');
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    _collections = list.map(PuzzleCollection.fromJson).toList();
    return _collections!;
  }

  /// Lazy-load and cache the tutorial JSON.
  static Future<List<Tutorial>> loadTutorials() async {
    if (_tutorials != null) return _tutorials!;
    final raw = await rootBundle.loadString('assets/content/tutorials.json');
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    _tutorials = list.map(Tutorial.fromJson).toList();
    return _tutorials!;
  }

  /// Lazy-load and cache the JSON puzzle set. These are content-curated
  /// puzzles separate from the legacy hard-coded [PuzzleData] set; both can
  /// coexist while content migrates.
  static Future<List<Puzzle>> loadPuzzles() async {
    if (_jsonPuzzles != null) return _jsonPuzzles!;
    final raw = await rootBundle.loadString('assets/content/puzzles.json');
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    _jsonPuzzles = list.map(_puzzleFromJson).toList();
    return _jsonPuzzles!;
  }

  static Puzzle _puzzleFromJson(Map<String, dynamic> json) {
    final initialBoard = (json['initialBoard'] as List)
        .map<List<int>>(
          (row) => (row as List).map<int>((c) => (c as num).toInt()).toList(),
        )
        .toList();
    final solution = (json['solution'] as List).map<PuzzleMove>((m) {
      final row = (m['row'] as num).toInt();
      final col = (m['col'] as num).toInt();
      final color = (m['color'] as num).toInt();
      return PuzzleMove(row, col, color);
    }).toList();
    final winCondition = _winConditionFromJson(json['winCondition']);
    return Puzzle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      boardSize: (json['boardSize'] as num).toInt(),
      initialBoard: initialBoard,
      playerColor: (json['playerColor'] as num).toInt(),
      solution: solution,
      hint: json['hint']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      winCondition: winCondition,
    );
  }

  static WinCondition _winConditionFromJson(dynamic raw) {
    if (raw is! Map) return const ExactSequence();
    final type = raw['type']?.toString();
    switch (type) {
      case 'captureGroup':
        final stones = (raw['stones'] as List)
            .map<PuzzleMove>(
              (s) => PuzzleMove(
                (s['row'] as num).toInt(),
                (s['col'] as num).toInt(),
                (s['color'] as num).toInt(),
              ),
            )
            .toList();
        return CaptureGroup(stones);
      case 'exactSequence':
      default:
        return const ExactSequence();
    }
  }
}
