import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/services/ai/ai_engine.dart';
import 'package:zaibal/services/ai/ai_engine_factory.dart';
import 'package:zaibal/services/ai/go_ai_service.dart';
import 'package:zaibal/services/ai/mcts_engine.dart';
import 'package:zaibal/services/ai/katago_engine.dart';

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
    test('default factory returns MctsEngine when KataGo flag is off', () {
      AIEngineFactory.setTestOverride(null);
      expect(AIEngineFactory.current(), isA<MctsEngine>());
    });

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

    test(
      'KataGoEngine falls back gracefully when server URL is empty',
      () async {
        // With no KataGo server URL configured, the engine falls back to the
        // built-in MCTS engine and returns a move or null — never throws.
        final engine = const KataGoEngine();
        expect(
          () => engine.getBestMove(
            board: const [],
            boardSize: 0,
            player: 1,
            difficulty: AIDifficulty.easy,
          ),
          returnsNormally,
        );
      },
    );
  });
}
