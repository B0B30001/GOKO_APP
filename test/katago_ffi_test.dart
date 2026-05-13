import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/services/ai/ai_engine_factory.dart';
import 'package:zaibal/services/ai/katago_ffi_engine.dart';
import 'package:zaibal/services/ai/mcts_engine.dart';
import 'package:zaibal/models/app_settings.dart';

void main() {
  group('KataGoFfiEngine fallback safety', () {
    test(
      'without the native binary bundled, isLoadable returns false (no crash)',
      () {
        // Test runner has no libkatago.so / katago.dylib bundled, so the
        // probe must return false. If this ever returns true in test, the
        // build is shipping native code unexpectedly — fail loudly.
        expect(KataGoFfiEngine.isLoadable, isFalse);
      },
    );

    test(
      'factory does not pick FFI engine when isLoadable is false even if mode = native',
      () {
        AppSettings.kataGoMode = 'native';
        AIEngineFactory.setTestOverride(null);
        final engine = AIEngineFactory.current();
        expect(engine, isNot(isA<KataGoFfiEngine>()));
        // The factory eventually falls to MctsEngine when nothing else is set up.
        expect(engine, isA<MctsEngine>());
        AppSettings.kataGoMode = 'off';
      },
    );

    test('tryCreate returns null without the native library', () {
      expect(KataGoFfiEngine.tryCreate(), isNull);
    });
  });
}
