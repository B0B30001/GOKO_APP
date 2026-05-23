import 'ai_engine.dart';
import 'mcts_engine.dart';

/// Returns the active [AIEngine] for the current build.
///
/// Cloud analysis has been removed; the app always uses the built-in MCTS
/// engine. The [setTestOverride] hook is retained so unit tests can inject a
/// fake engine without touching global state.
class AIEngineFactory {
  static AIEngine? _override;

  static void setTestOverride(AIEngine? engine) {
    _override = engine;
  }

  static AIEngine current() {
    if (_override != null) return _override!;
    return const MctsEngine();
  }
}
