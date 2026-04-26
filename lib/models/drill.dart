import 'puzzle.dart';

/// A timed drill containing multiple puzzles
class Drill {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int timeLimit; // seconds
  final int targetCount; // number of puzzles to solve
  final DrillType type;
  final List<Puzzle> puzzles;
  final int minDifficulty;
  final int maxDifficulty;

  Drill({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.timeLimit,
    required this.targetCount,
    required this.type,
    required this.puzzles,
    required this.minDifficulty,
    required this.maxDifficulty,
  });

  /// Calculate score based on performance
  int calculateScore({
    required int solved,
    required int timeRemaining,
    required int mistakes,
  }) {
    // Base score: 100 points per puzzle solved
    int baseScore = solved * 100;
    
    // Time bonus: up to 50 points per puzzle for speed
    int timeBonus = (timeRemaining * 50 / timeLimit).round();
    
    // Accuracy penalty: -20 points per mistake
    int accuracyPenalty = mistakes * 20;
    
    return (baseScore + timeBonus - accuracyPenalty).clamp(0, 99999);
  }

  /// Get star rating (1-3 stars)
  int getStarRating(int score, int targetCount) {
    double percentage = score / (targetCount * 100);
    if (percentage >= 0.9) return 3;
    if (percentage >= 0.7) return 2;
    if (percentage >= 0.5) return 1;
    return 0;
  }
}

enum DrillType {
  capture,
  lifeAndDeath,
  ko,
  tesuji,
  mixed,
}

class DrillData {
  static final List<Drill> allDrills = [
    _captureRush,
    _lifeDeathSprint,
    _koMaster,
    _tesujiBlit,
    _beginnerMix,
    _speedCapture,
    _survivalDrill,
    _tacticalBlitz,
  ];

  static Drill getDrillById(String id) {
    return allDrills.firstWhere(
      (drill) => drill.id == id,
      orElse: () => _captureRush,
    );
  }

  static List<Drill> getDrillsByType(DrillType type) {
    return allDrills.where((drill) => drill.type == type).toList();
  }

  // Capture Rush - 2 min, 10 puzzles
  static final Drill _captureRush = Drill(
    id: 'capture_rush',
    title: 'Capture Rush',
    subtitle: '2 min • 10 puzzles',
    description: 'Race against time to capture stones quickly!',
    timeLimit: 120,
    targetCount: 10,
    type: DrillType.capture,
    minDifficulty: 1,
    maxDifficulty: 2,
    puzzles: [
      ...PuzzleData.getPuzzlesForTopic('Captures'),
      // Generate variations
      ..._generateCapturePuzzleVariations(),
    ],
  );

  // Life & Death Sprint - 3 min, 5 puzzles
  static final Drill _lifeDeathSprint = Drill(
    id: 'life_death_sprint',
    title: 'Life & Death Sprint',
    subtitle: '3 min • 5 puzzles',
    description: 'Make two eyes or kill opponent groups under pressure!',
    timeLimit: 180,
    targetCount: 5,
    type: DrillType.lifeAndDeath,
    minDifficulty: 2,
    maxDifficulty: 3,
    puzzles: PuzzleData.getPuzzlesForTopic('Life & Death'),
  );

  // Ko Master - 90 sec, 8 puzzles
  static final Drill _koMaster = Drill(
    id: 'ko_master',
    title: 'Ko Master',
    subtitle: '90 sec • 8 puzzles',
    description: 'Master the Ko rule with quick recognition drills!',
    timeLimit: 90,
    targetCount: 8,
    type: DrillType.ko,
    minDifficulty: 2,
    maxDifficulty: 3,
    puzzles: [
      ...PuzzleData.getPuzzlesForTopic('Ko Basics'),
      ..._generateKoPuzzleVariations(),
    ],
  );

  // Tesuji Blitz - 5 min, 15 puzzles
  static final Drill _tesujiBlit = Drill(
    id: 'tesuji_blitz',
    title: 'Tesuji Blitz',
    subtitle: '5 min • 15 puzzles',
    description: 'Find brilliant tactical moves in rapid succession!',
    timeLimit: 300,
    targetCount: 15,
    type: DrillType.tesuji,
    minDifficulty: 1,
    maxDifficulty: 3,
    puzzles: _generateMixedPuzzles(15, 1, 3),
  );

  // Beginner Mix - 3 min, 8 puzzles
  static final Drill _beginnerMix = Drill(
    id: 'beginner_mix',
    title: 'Beginner Mix',
    subtitle: '3 min • 8 puzzles',
    description: 'Perfect for newcomers - covers all basics!',
    timeLimit: 180,
    targetCount: 8,
    type: DrillType.mixed,
    minDifficulty: 1,
    maxDifficulty: 1,
    puzzles: _generateMixedPuzzles(8, 1, 1),
  );

  // Speed Capture - 60 sec, 5 puzzles
  static final Drill _speedCapture = Drill(
    id: 'speed_capture',
    title: 'Speed Capture',
    subtitle: '60 sec • 5 puzzles',
    description: 'Ultra-fast capture drill for sharp reflexes!',
    timeLimit: 60,
    targetCount: 5,
    type: DrillType.capture,
    minDifficulty: 1,
    maxDifficulty: 1,
    puzzles: PuzzleData.getPuzzlesForTopic('Captures').take(5).toList(),
  );

  // Survival Drill - 4 min, 6 puzzles
  static final Drill _survivalDrill = Drill(
    id: 'survival_drill',
    title: 'Survival Drill',
    subtitle: '4 min • 6 puzzles',
    description: 'Save your groups from death!',
    timeLimit: 240,
    targetCount: 6,
    type: DrillType.lifeAndDeath,
    minDifficulty: 2,
    maxDifficulty: 3,
    puzzles: PuzzleData.getPuzzlesForTopic('Life & Death'),
  );

  // Tactical Blitz - 2 min, 10 puzzles
  static final Drill _tacticalBlitz = Drill(
    id: 'tactical_blitz',
    title: 'Tactical Blitz',
    subtitle: '2 min • 10 puzzles',
    description: 'Mixed tactics at lightning speed!',
    timeLimit: 120,
    targetCount: 10,
    type: DrillType.mixed,
    minDifficulty: 1,
    maxDifficulty: 2,
    puzzles: _generateMixedPuzzles(10, 1, 2),
  );

  // Helper to generate puzzle variations
  static List<Puzzle> _generateCapturePuzzleVariations() {
    // Return variations of capture puzzles
    return [
      Puzzle(
        id: 'capture_var_1',
        title: 'Edge Capture',
        description: 'Capture stones on the edge',
        category: 'capture',
        difficulty: 1,
        boardSize: 9,
        initialBoard: _createBoard9x9([
          [0, 1, 2, 1, 0, 0, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ]),
        playerColor: 1,
        solution: [PuzzleMove(0, 2, 1)],
        hint: 'Fill the last liberty on the edge',
        explanation: 'Edge captures are easier due to fewer liberties.',
      ),
      Puzzle(
        id: 'capture_var_2',
        title: 'Three Stone Capture',
        description: 'Capture three connected stones',
        category: 'capture',
        difficulty: 2,
        boardSize: 9,
        initialBoard: _createBoard9x9([
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 2, 2, 2, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ]),
        playerColor: 1,
        solution: [PuzzleMove(2, 1, 1)],
        hint: 'All three white stones share this liberty',
        explanation: 'Larger groups can be captured all at once.',
      ),
    ];
  }

  static List<Puzzle> _generateKoPuzzleVariations() {
    return [
      Puzzle(
        id: 'ko_var_1',
        title: 'Ko Shape Recognition',
        description: 'Spot the Ko pattern',
        category: 'ko',
        difficulty: 2,
        boardSize: 9,
        initialBoard: _createBoard9x9([
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 1, 2, 1, 0, 0, 0, 0, 0],
          [0, 2, 0, 2, 1, 0, 0, 0, 0],
          [0, 1, 2, 1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ]),
        playerColor: 1,
        solution: [PuzzleMove(2, 2, 1)],
        hint: 'This creates a Ko situation',
        explanation: 'Ko creates a repeating pattern.',
      ),
    ];
  }

  static List<Puzzle> _generateMixedPuzzles(
      int count, int minDiff, int maxDiff) {
    List<Puzzle> mixed = [];
    
    // Get puzzles from different categories
    mixed.addAll(PuzzleData.getPuzzlesForTopic('Captures')
        .where((p) => p.difficulty >= minDiff && p.difficulty <= maxDiff));
    mixed.addAll(PuzzleData.getPuzzlesForTopic('Liberties')
        .where((p) => p.difficulty >= minDiff && p.difficulty <= maxDiff));
    mixed.addAll(PuzzleData.getPuzzlesForTopic('Life & Death')
        .where((p) => p.difficulty >= minDiff && p.difficulty <= maxDiff));
    mixed.addAll(PuzzleData.getPuzzlesForTopic('Ko Basics')
        .where((p) => p.difficulty >= minDiff && p.difficulty <= maxDiff));
    
    // Shuffle and take requested count
    mixed.shuffle();
    return mixed.take(count).toList();
  }

  static List<List<int>> _createBoard9x9(List<List<int>> board) {
    return board;
  }
}

/// Tracks drill performance history
class DrillResult {
  final String drillId;
  final DateTime completedAt;
  final int score;
  final int solved;
  final int total;
  final int timeUsed; // seconds
  final int mistakes;
  final int stars;

  DrillResult({
    required this.drillId,
    required this.completedAt,
    required this.score,
    required this.solved,
    required this.total,
    required this.timeUsed,
    required this.mistakes,
    required this.stars,
  });

  Map<String, dynamic> toJson() => {
        'drillId': drillId,
        'completedAt': completedAt.toIso8601String(),
        'score': score,
        'solved': solved,
        'total': total,
        'timeUsed': timeUsed,
        'mistakes': mistakes,
        'stars': stars,
      };

  factory DrillResult.fromJson(Map<String, dynamic> json) => DrillResult(
        drillId: json['drillId'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
        score: json['score'] as int,
        solved: json['solved'] as int,
        total: json['total'] as int,
        timeUsed: json['timeUsed'] as int,
        mistakes: json['mistakes'] as int,
        stars: json['stars'] as int,
      );
}
