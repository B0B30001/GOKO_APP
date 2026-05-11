/// A curated, named bundle of puzzles ("First Captures", "Atari Mastery",
/// etc.). Lives in `assets/content/collections.json`; loaded via
/// [ContentService.loadCollections]. Puzzle ids reference rows in
/// [`PuzzleData.allPuzzles`](lib/models/puzzle.dart).
class PuzzleCollection {
  final String id;
  final String title;
  final String description;

  /// Identifier mapped to a Material icon at render time. Keeps the JSON
  /// schema serializable without committing to a particular icon font.
  final String iconKey;

  /// Ordered list of `Puzzle.id` strings. Resolved against `PuzzleData`.
  final List<String> puzzleIds;

  const PuzzleCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.puzzleIds,
  });

  factory PuzzleCollection.fromJson(Map<String, dynamic> json) {
    return PuzzleCollection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconKey: json['iconKey']?.toString() ?? 'extension',
      puzzleIds: (json['puzzleIds'] as List).map((e) => e.toString()).toList(),
    );
  }
}
