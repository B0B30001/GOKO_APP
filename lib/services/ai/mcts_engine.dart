import 'package:flutter/foundation.dart';

import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;
import 'mcts.dart';

/// Existing Monte Carlo Tree Search engine, repackaged behind the [AIEngine]
/// interface. Behavior is identical to the pre-refactor `GoAIService.getBestMove`:
/// `compute()` isolate, simulation count derived from [AIDifficulty.simulations].
class MctsEngine implements AIEngine {
  const MctsEngine();

  @override
  String get name => 'mcts';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) {
    // Cap simulations on large boards. A 19×19 MCTS expands a search tree
    // ~4× deeper than 9×9 per simulation, so the same sim count multiplies
    // wall-time. Hard 2500 sims on 19×19 was the source of UI freezes when
    // the isolate result arrived late; 1200 keeps strength acceptable for
    // amateur play and halves move latency.
    var sims = difficulty.simulations;
    if (boardSize >= 19 && sims > 1200) {
      sims = 1200;
    } else if (boardSize >= 13 && sims > 1800) {
      sims = 1800;
    }
    return compute(_runMcts, [board, boardSize, player, sims]);
  }
}

/// Top-level function required by `compute()`. Cannot be a class member.
List<int>? _runMcts(List<dynamic> args) {
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
