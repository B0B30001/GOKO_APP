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

  /// When true, the user must tap [correctMove] to advance. Used for
  /// "tap to capture" / "tap to atari" style interactive lessons.
  final bool interactive;

  /// `[row, col]` of the correct tap target. Required when [interactive] is
  /// true; null otherwise.
  final List<int>? correctMove;

  const TutorialStep({
    required this.title,
    required this.board,
    required this.body,
    this.markedRow,
    this.markedCol,
    this.interactive = false,
    this.correctMove,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    final board = (json['board'] as List)
        .map<List<int>>(
          (row) => (row as List).map<int>((c) => (c as num).toInt()).toList(),
        )
        .toList();
    final correctRaw = json['correctMove'];
    final correct = correctRaw is List
        ? correctRaw.map<int>((c) => (c as num).toInt()).toList()
        : null;
    return TutorialStep(
      title: json['title']?.toString() ?? '',
      board: board,
      body: json['body']?.toString() ?? '',
      markedRow: json['markedRow'] is num
          ? (json['markedRow'] as num).toInt()
          : null,
      markedCol: json['markedCol'] is num
          ? (json['markedCol'] as num).toInt()
          : null,
      interactive: json['interactive'] == true,
      correctMove: correct,
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

  /// 1 = beginner, 2 = intermediate, 3 = advanced. Optional in JSON; when
  /// absent, [difficulty] derives a default from [category] so existing
  /// content keeps working without editing.
  final int? _explicitDifficulty;

  /// Effective difficulty. Returns [_explicitDifficulty] if set, otherwise
  /// derives from [category]: `fundamentals` → 1, `rules` → 2,
  /// `life-death` → 3, anything else → 2.
  int get difficulty {
    if (_explicitDifficulty != null) return _explicitDifficulty;
    return switch (category) {
      'fundamentals' => 1,
      'rules' => 2,
      'life-death' => 3,
      _ => 2,
    };
  }

  const Tutorial({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.boardSize,
    required this.steps,
    required this.source,
    int? difficulty,
  }) : _explicitDifficulty = difficulty;

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
      difficulty: json['difficulty'] is num
          ? (json['difficulty'] as num).toInt()
          : null,
    );
  }
}
