import 'dart:ffi';
import 'dart:io' show Platform;

import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;

/// FFI engine for a bundled KataGo C++ build.
///
/// Status: **scaffolding only.** No `libkatago.so`/`.dylib` is shipped with
/// the app. To actually run with this engine you must build KataGo from
/// source for your target platform and place the resulting shared library
/// at:
///
/// - Android: `android/app/src/main/jniLibs/arm64-v8a/libkatago.so`
/// - iOS: `ios/Runner/Frameworks/katago.dylib`
/// - macOS / Linux: alongside the binary, or on the dynamic linker search path
///
/// Build instructions and weight-file sources are documented in
/// [`assets/engines/README.md`](../../../assets/engines/README.md).
///
/// The class is intentionally crash-proof: when the shared library can't be
/// loaded, [isLoadable] returns false and the [AIEngineFactory] falls
/// through to the next branch (remote URL or MCTS).
class KataGoFfiEngine implements AIEngine {
  KataGoFfiEngine._();

  static KataGoFfiEngine? _instance;

  /// Lazily attempts to load the native library. Returns the engine on
  /// success, null when no compatible binary is present.
  static KataGoFfiEngine? tryCreate() {
    if (_instance != null) return _instance;
    if (!isLoadable) return null;
    _instance = KataGoFfiEngine._();
    return _instance;
  }

  /// `true` when a native KataGo library exists on the runtime's dynamic
  /// linker search path. Probed once; cached. Does not throw.
  static bool? _loadableCache;
  static bool get isLoadable {
    final cached = _loadableCache;
    if (cached != null) return cached;
    try {
      _libName(); // throws on web (no dart:io) — handled below
      final lib = DynamicLibrary.open(_libName());
      // Sanity-probe a known symbol so we fail fast on stripped builds.
      lib.lookup<NativeFunction<_KataGoPredictNative>>('katago_predict');
      _loadableCache = true;
    } catch (_) {
      _loadableCache = false;
    }
    return _loadableCache!;
  }

  static String _libName() {
    if (Platform.isAndroid || Platform.isLinux) return 'libkatago.so';
    if (Platform.isMacOS || Platform.isIOS) return 'katago.dylib';
    if (Platform.isWindows) return 'katago.dll';
    throw UnsupportedError('KataGo FFI unsupported on this platform');
  }

  @override
  String get name => 'katago-ffi';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) async {
    // Real implementation would marshal the board into a Uint8List, call
    // the C entrypoint, decode the (row, col) result, and return it. With
    // no native binary bundled, signal "no move available" so the factory
    // (or caller fallback) can route to another engine.
    return null;
  }
}

/// Signature of the native entrypoint we expect the C library to expose:
/// ```c
/// // Returns row*size + col, or -1 if no legal move.
/// int32_t katago_predict(uint8_t* board, int32_t size, int32_t player);
/// ```
typedef _KataGoPredictNative =
    Int32 Function(Pointer<Uint8> board, Int32 size, Int32 player);
