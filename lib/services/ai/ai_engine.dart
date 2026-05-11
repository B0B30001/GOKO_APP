import 'go_ai_service.dart' show AIDifficulty;

/// Contract every Go-move engine must satisfy. Lets the app swap MCTS for
/// KataGo (or any other engine) without touching call sites.
///
/// Implementations live alongside this file: [`MctsEngine`](mcts_engine.dart),
/// [`KataGoEngine`](katago_engine.dart). [`AIEngineFactory`](ai_engine_factory.dart)
/// picks the active one based on a compile-time flag.
abstract class AIEngine {
  /// Identifier shown in debug overlays / logs — e.g. `'mcts'`, `'katago'`.
  String get name;

  /// Returns `[row, col]` of the chosen move, or `null` to pass.
  /// Must be safe to await from the UI thread — implementations are expected
  /// to offload heavy work (e.g. via `compute`).
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  });
}
