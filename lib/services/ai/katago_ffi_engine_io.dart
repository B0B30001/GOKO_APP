import 'dart:ffi';
import 'dart:io' show Platform;

import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;

/// FFI engine for a bundled KataGo C++ build (non-web platforms).
///
/// Status: **scaffolding only.** No `libkatago.so`/`.dylib` is shipped with
/// the app. To actually run with this engine you must build KataGo from
/// source for your target platform and place the resulting shared library
/// where the runtime linker can find it. See
/// [`assets/engines/README.md`](../../../assets/engines/README.md).
class KataGoFfiEngine implements AIEngine {
  KataGoFfiEngine._();

  static KataGoFfiEngine? _instance;

  static KataGoFfiEngine? tryCreate() {
    if (_instance != null) return _instance;
    if (!isLoadable) return null;
    _instance = KataGoFfiEngine._();
    return _instance;
  }

  static bool? _loadableCache;
  static bool get isLoadable {
    final cached = _loadableCache;
    if (cached != null) return cached;
    try {
      final lib = DynamicLibrary.open(_libName());
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
    // No native binary bundled yet — signal "no move available" so the
    // factory falls through to another engine.
    return null;
  }
}

/// Native entrypoint signature the bundled C library is expected to expose:
/// ```c
/// int32_t katago_predict(uint8_t* board, int32_t size, int32_t player);
/// ```
typedef _KataGoPredictNative =
    Int32 Function(Pointer<Uint8> board, Int32 size, Int32 player);
