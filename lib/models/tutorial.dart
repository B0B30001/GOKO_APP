/// One discrete step within a [Tutorial]: a board snapshot with prose
/// explaining what's happening.
class TutorialStep {
  final String title;

  /// 0=empty, 1=black, 2=white. Square grid; size = boardSize.
  final List<List<int>> board;

  /// Optional row/col coordinates to highlight as "the move just played".
  final int? markedRow;
  final int? markedCol;

  /// Prose explaining this step.
  final String body;

  const TutorialStep({
    required this.title,
    required this.board,
    required this.body,
    this.markedRow,
    this.markedCol,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    final board = (json['board'] as List)
        .map<List<int>>(
          (row) => (row as List).map<int>((c) => (c as num).toInt()).toList(),
        )
        .toList();
    return TutorialStep(
      title: json['title']?.toString() ?? '',
      board: board,
      body: json['body']?.toString() ?? '',
      markedRow: json['markedRow'] is num ? (json['markedRow'] as num).toInt() : null,
      markedCol: json['markedCol'] is num ? (json['markedCol'] as num).toInt() : null,
    );
  }
}

/// A multi-step tutorial introducing a single Go concept (Liberties, Atari,
/// Ko, Eyes, False Eyes, etc.).
class Tutorial {
  final String id;
  final String title;
  final String summary;
  final String category;
  final int boardSize;
  final List<TutorialStep> steps;

  /// Source attribution — e.g. "Sensei's Library" or "Janice Kim, Vol 1 p.42".
  final String source;

  const Tutorial({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.boardSize,
    required this.steps,
    required this.source,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    final stepsJson = (json['steps'] as List).cast<Map<String, dynamic>>();
    return Tutorial(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      boardSize: (json['boardSize'] as num).toInt(),
      steps: stepsJson.map(TutorialStep.fromJson).toList(),
      source: json['source']?.toString() ?? '',
    );
  }
}
