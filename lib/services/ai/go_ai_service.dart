import 'package:flutter/foundation.dart';
import 'mcts.dart';

enum AIDifficulty {
  easy(200, 'Easy'),
  medium(800, 'Medium'),
  hard(2500, 'Hard');

  const AIDifficulty(this.simulations, this.label);
  final int simulations;
  final String label;
}

class GoAIService {
  /// Returns [row, col] of the best move for [player], or null (pass).
  /// Runs in a separate isolate via compute() to keep the UI responsive.
  static Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    AIDifficulty difficulty = AIDifficulty.medium,
  }) {
    return compute(_runAI, [board, boardSize, player, difficulty.simulations]);
  }
}

// Top-level function required by compute().
List<int>? _runAI(List<dynamic> args) {
  final board = (args[0] as List)
      .map((row) => (row as List).cast<int>())
      .toList();
  final boardSize = args[1] as int;
  final player = args[2] as int;
  final simulations = args[3] as int;
  return runMCTS(
    board: board,
    boardSize: boardSize,
    player: player,
    simulations: simulations,
  );
}
