import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/services/ai/ai_engine.dart';
import 'package:zaibal/services/ai/ai_engine_factory.dart';
import 'package:zaibal/services/ai/go_ai_service.dart';
import 'package:zaibal/services/ai/mcts_engine.dart';

class _FakeEngine implements AIEngine {
  bool called = false;

  @override
  String get name => 'fake';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) async {
    called = true;
    return [0, 0];
  }
}

void main() {
  group('AIEngine seam', () {
    test(
      'default factory returns MctsEngine when no local engine is set up',
      () {
        AIEngineFactory.setTestOverride(null);
        expect(AIEngineFactory.current(), isA<MctsEngine>());
      },
    );

    test('test override redirects GoAIService.getBestMove', () async {
      final fake = _FakeEngine();
      AIEngineFactory.setTestOverride(fake);
      addTearDown(() => AIEngineFactory.setTestOverride(null));

      final move = await GoAIService.getBestMove(
        board: List.generate(5, (_) => List.filled(5, 0)),
        boardSize: 5,
        player: 1,
        difficulty: AIDifficulty.easy,
      );
      expect(fake.called, isTrue);
      expect(move, equals([0, 0]));
    });
  });
}
