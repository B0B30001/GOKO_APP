import 'ai_engine.dart';
import 'katago_engine.dart';
import 'mcts_engine.dart';

/// Selects the active [AIEngine] for this build. Default: [MctsEngine].
/// Set `--dart-define=ENABLE_KATAGO=true` at build/run time to opt into the
/// (currently stubbed) [KataGoEngine].
class AIEngineFactory {
  static const bool _kataGoEnabled = bool.fromEnvironment(
    'ENABLE_KATAGO',
    defaultValue: false,
  );

  static AIEngine? _override;

  /// Tests can inject a fake engine; pass `null` to restore the default.
  static void setTestOverride(AIEngine? engine) {
    _override = engine;
  }

  /// Returns the engine to use for the current move request.
  static AIEngine current() {
    if (_override != null) return _override!;
    if (_kataGoEnabled) return const KataGoEngine();
    return const MctsEngine();
  }
}
