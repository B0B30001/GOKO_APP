import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;

/// Placeholder for a future KataGo-backed engine. Two integration paths are
/// expected and the implementation will pick one in a follow-up session:
/// (a) remote KataGo over WebSocket, (b) bundled native binary via FFI.
///
/// Until then, this class exists so the [AIEngine] seam compiles and so
/// `AIEngineFactory.current()` can route to it when the build is flagged with
/// `--dart-define=ENABLE_KATAGO=true`. Invoking it throws loudly — silent
/// fallback would mask the unfinished integration during testing.
class KataGoEngine implements AIEngine {
  const KataGoEngine();

  @override
  String get name => 'katago';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) {
    throw UnimplementedError(
      'KataGo engine is not yet integrated. Disable ENABLE_KATAGO to fall '
      'back to MCTS, or implement getBestMove in katago_engine.dart.',
    );
  }
}
