import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;

/// Web stub for [KataGoFfiEngine]. `dart:ffi` does not exist in the browser,
/// so this stub reports the engine as unloadable and the factory falls
/// through to MCTS.
class KataGoFfiEngine implements AIEngine {
  KataGoFfiEngine._();

  static KataGoFfiEngine? tryCreate() => null;

  static bool get isLoadable => false;

  @override
  String get name => 'katago-ffi';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) async => null;
}
