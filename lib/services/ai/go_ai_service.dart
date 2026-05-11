import 'ai_engine_factory.dart';

enum AIDifficulty {
  easy(200, 'Easy'),
  medium(800, 'Medium'),
  hard(2500, 'Hard');

  const AIDifficulty(this.simulations, this.label);
  final int simulations;
  final String label;
}

/// Thin shim over [AIEngineFactory]. Existing callers don't need to know
/// which engine (MCTS / KataGo / …) is active — they hit this entry point
/// and the factory decides at build time via the `ENABLE_KATAGO` define.
class GoAIService {
  /// Returns [row, col] of the best move for [player], or `null` to pass.
  static Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    AIDifficulty difficulty = AIDifficulty.medium,
  }) {
    return AIEngineFactory.current().getBestMove(
      board: board,
      boardSize: boardSize,
      player: player,
      difficulty: difficulty,
    );
  }
}
