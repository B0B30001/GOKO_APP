import 'ai_engine.dart';
import 'katago_engine.dart';
import 'katago_ffi_engine.dart';
import 'katago_local_engine.dart';
import 'katago_process_service.dart';
import 'leela_engine.dart';
import 'mcts_engine.dart';
import '../../models/app_settings.dart';

/// Selects the active [AIEngine] at runtime.
///
/// Priority (highest to lowest):
/// 1. Test override injected via [setTestOverride].
/// 2. [KataGoLocalEngine] when [KataGoProcessService] has a binary + model
///    installed and is ready (or available to auto-start). This requires the
///    user to have placed `katago[.exe]` and a `*.bin.gz` model in the app's
///    engines folder — fully automatic once the files are present.
/// 3. [KataGoEngine] (remote WebSocket) when [AppSettings.kataGoServerUrl] is
///    non-empty, or when forced via `--dart-define=ENABLE_KATAGO=true`.
/// 4. [LeelaEngine] (GTP over WebSocket) when [AppSettings.leelaServerUrl] is
///    non-empty.
/// 5. [MctsEngine] — built-in, offline, always available.
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

    // FFI-bundled KataGo. Highest priority when the user opted into it AND
    // the native library actually loads (so a missing `.so`/`.dylib` never
    // blocks playable AI).
    if (AppSettings.kataGoMode == 'native' && KataGoFfiEngine.isLoadable) {
      final ffi = KataGoFfiEngine.tryCreate();
      if (ffi != null) return ffi;
    }

    // Local KataGo process — zero config for the end-user once files are in place.
    if (KataGoProcessService.instance.isAvailable ||
        KataGoProcessService.instance.isReady) {
      return const KataGoLocalEngine();
    }

    // Remote KataGo WebSocket (power-user / developer override).
    if (_kataGoEnabled || AppSettings.kataGoServerUrl.trim().isNotEmpty) {
      return const KataGoEngine();
    }

    // Remote Leela Zero / GTP WebSocket.
    if (AppSettings.leelaServerUrl.trim().isNotEmpty) {
      return const LeelaEngine();
    }

    return const MctsEngine();
  }
}
