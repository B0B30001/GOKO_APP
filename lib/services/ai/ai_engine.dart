import 'go_ai_service.dart' show AIDifficulty;

/// Contract every Go-move engine must satisfy. Lets the app swap MCTS for
/// KataGo (or any other engine) without touching call sites.
///
/// Implementations live alongside this file: [`MctsEngine`](mcts_engine.dart),
/// [`KataGoLocalEngine`](katago_local_engine.dart), and
/// [`KataGoFfiEngine`](katago_ffi_engine.dart). [`AIEngineFactory`] picks
/// the active one based on local engine availability.
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
