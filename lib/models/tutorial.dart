/// A single placement in a step-by-step animated demo sequence.
/// Used to illustrate concepts like ladders, ko, and shapes by playing
/// moves out in order.
class DemoMove {
  final int row;
  final int col;

  /// 1 = black, 2 = white.
  final int color;

  /// Caption shown while this move is on screen. Empty = reuse step body.
  final String caption;

  /// Milliseconds to wait before placing this move (after the prior one).
  final int delayMs;

  const DemoMove({
    required this.row,
    required this.col,
    required this.color,
    this.caption = '',
    this.delayMs = 700,
  });

  factory DemoMove.fromJson(Map<String, dynamic> json) => DemoMove(
    row: (json['row'] as num).toInt(),
    col: (json['col'] as num).toInt(),
    color: (json['color'] as num).toInt(),
    caption: json['caption']?.toString() ?? '',
    delayMs: json['delayMs'] is num ? (json['delayMs'] as num).toInt() : 700,
  );
}

/// Kinds of tutorial steps. `demo` is a passive read-and-watch step,
/// `tapTarget` asks the player to tap a specific intersection, and `quiz`
/// presents a multiple-choice question. New JSON content can specify the
/// kind explicitly; legacy content (no `kind` field) is inferred from the
/// presence of `correctMove` / `quizChoices`.
enum TutorialStepKind { demo, tapTarget, quiz }

/// One discrete step within a [Tutorial].
class TutorialStep {
  final String title;

  /// 0=empty, 1=black, 2=white. Square grid; size = boardSize.
  final List<List<int>> board;

  /// Optional row/col coordinates to highlight as "the move just played".
  final int? markedRow;
  final int? markedCol;

  /// Prose explaining this step.
  final String body;

  /// What sort of interaction this step expects.
  final TutorialStepKind kind;

  /// `[row, col]` of the correct tap target. Required when [kind] is
  /// [TutorialStepKind.tapTarget]; null otherwise.
  final List<int>? correctMove;

  /// Optional move sequence to animate on top of [board]. When non-null, the
  /// tutorial screen shows a Play button that plays these moves in order.
  final List<DemoMove>? demoMoves;

  // Quiz fields — populated only when [kind] is [TutorialStepKind.quiz].
  final String? quizQuestion;
  final List<String>? quizChoices;
  final int? quizCorrectIndex;
  final String? quizExplanation;

  /// Backwards-compat shim — old callers ask "is this interactive?" without
  /// caring whether it's a tap target or a quiz.
  bool get interactive =>
      kind == TutorialStepKind.tapTarget || kind == TutorialStepKind.quiz;

  const TutorialStep({
    required this.title,
    required this.board,
    required this.body,
    this.kind = TutorialStepKind.demo,
    this.markedRow,
    this.markedCol,
    this.correctMove,
    this.demoMoves,
    this.quizQuestion,
    this.quizChoices,
    this.quizCorrectIndex,
    this.quizExplanation,
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
    final demoRaw = json['demoMoves'];
    final demo = demoRaw is List
        ? demoRaw.cast<Map<String, dynamic>>().map(DemoMove.fromJson).toList()
        : null;

    final quizRaw = json['quizChoices'];
    final quizChoices = quizRaw is List
        ? quizRaw.map((e) => e.toString()).toList()
        : null;
    final quizCorrect = json['quizCorrectIndex'] is num
        ? (json['quizCorrectIndex'] as num).toInt()
        : null;

    final kind = _decodeKind(
      json['kind']?.toString(),
      interactive: json['interactive'] == true,
      hasQuiz: quizChoices != null,
    );

    return TutorialStep(
      title: json['title']?.toString() ?? '',
      board: board,
      body: json['body']?.toString() ?? '',
      kind: kind,
      markedRow: json['markedRow'] is num
          ? (json['markedRow'] as num).toInt()
          : null,
      markedCol: json['markedCol'] is num
          ? (json['markedCol'] as num).toInt()
          : null,
      correctMove: correct,
      demoMoves: demo,
      quizQuestion: json['quizQuestion']?.toString(),
      quizChoices: quizChoices,
      quizCorrectIndex: quizCorrect,
      quizExplanation: json['quizExplanation']?.toString(),
    );
  }

  static TutorialStepKind _decodeKind(
    String? raw, {
    required bool interactive,
    required bool hasQuiz,
  }) {
    switch (raw) {
      case 'quiz':
        return TutorialStepKind.quiz;
      case 'tapTarget':
      case 'interactive':
        return TutorialStepKind.tapTarget;
      case 'demo':
        return TutorialStepKind.demo;
    }
    if (hasQuiz) return TutorialStepKind.quiz;
    if (interactive) return TutorialStepKind.tapTarget;
    return TutorialStepKind.demo;
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

  /// Optional ordered list of puzzle ids to run as practice after the lesson
  /// ends. Resolved against `PuzzleData.allPuzzles` at runtime by the
  /// practice-sequence screen. Empty = no follow-up practice.
  final List<String> practicePuzzleIds;

  /// Maximum XP awarded for a flawless run (no hints, no retries on quizzes).
  /// Defaults to 20 (matching the prior fixed reward).
  final int xpReward;

  /// Optional estimate shown on the lesson card ("~5 min").
  final int? estimatedMinutes;

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
    this.practicePuzzleIds = const [],
    this.xpReward = 20,
    this.estimatedMinutes,
    int? difficulty,
  }) : _explicitDifficulty = difficulty;

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    final stepsJson = (json['steps'] as List).cast<Map<String, dynamic>>();
    final practiceRaw = json['practicePuzzleIds'];
    final practiceIds = practiceRaw is List
        ? practiceRaw.map((e) => e.toString()).toList()
        : const <String>[];
    return Tutorial(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      boardSize: (json['boardSize'] as num).toInt(),
      steps: stepsJson.map(TutorialStep.fromJson).toList(),
      source: json['source']?.toString() ?? '',
      practicePuzzleIds: practiceIds,
      xpReward: json['xpReward'] is num
          ? (json['xpReward'] as num).toInt()
          : 20,
      estimatedMinutes: json['estimatedMinutes'] is num
          ? (json['estimatedMinutes'] as num).toInt()
          : null,
      difficulty: json['difficulty'] is num
          ? (json['difficulty'] as num).toInt()
          : null,
    );
  }
}
