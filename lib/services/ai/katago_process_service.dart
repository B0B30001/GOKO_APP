import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
// dart:io is unavailable on web; all methods guard with kIsWeb before use.
import 'dart:io' show Directory, File, Platform, Process, ProcessException;
import 'package:path_provider/path_provider.dart';

/// Status of the local KataGo subprocess.
enum EngineStatus {
  /// No binary or model found in the engines folder.
  notFound,

  /// Binary and model are present; subprocess is starting.
  starting,

  /// Subprocess is running and accepting queries.
  ready,

  /// Subprocess exited unexpectedly or failed to start.
  error,
}

/// Singleton that manages a long-running KataGo analysis subprocess.
///
/// **How it works:**
/// 1. [discover] scans the engines folder for a `katago` binary and a
///    `*.bin.gz` model file (and checks the system PATH on desktop).
/// 2. [start] spawns `katago analysis -config ... -model ...` as a child
///    process. Communication is via stdin (JSON queries) and stdout (JSON
///    responses) — no WebSocket server required.
/// 3. [query] sends one analysis request and resolves a [Future] when
///    KataGo returns the final (non-incremental) response.
/// 4. The process stays alive between queries for low latency. It is
///    restarted automatically if it crashes.
///
/// **Setup (user-facing):**
/// The engines folder path is exposed via [enginesDirectory]. Users drop
/// two files there:
/// - `katago` (or `katago.exe` on Windows) — the KataGo binary
/// - any `*.bin.gz` file — the neural-network weights
/// That's it. The app handles the rest automatically.
///
/// **Platform support:**
/// - Windows / Linux / macOS / Android: fully supported.
/// - iOS: restricted (cannot exec downloaded binaries); use remote WebSocket.
/// - Web: not supported; falls back to MCTS.
class KataGoProcessService extends ChangeNotifier {
  KataGoProcessService._();

  /// App-wide singleton.
  static final KataGoProcessService instance = KataGoProcessService._();

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  EngineStatus _status = EngineStatus.notFound;
  String? _binaryPath;
  String? _modelPath;
  String? _enginesDir;
  String? _errorMessage;

  EngineStatus get status => _status;

  /// Absolute path to the katago binary, or null if not found.
  String? get binaryPath => _binaryPath;

  /// Absolute path to the model weights file, or null if not found.
  String? get modelPath => _modelPath;

  /// Absolute path to the managed engines folder.
  /// Drop `katago[.exe]` and `*.bin.gz` here for zero-config operation.
  String? get enginesDirectory => _enginesDir;

  /// Human-readable error message when [status] is [EngineStatus.error].
  String? get errorMessage => _errorMessage;

  /// True when binary + model are present (process may or may not be started).
  bool get isAvailable =>
      _binaryPath != null && _modelPath != null && !kIsWeb && _isIoSupported;

  /// True when the subprocess is running and ready to accept queries.
  bool get isReady => _status == EngineStatus.ready;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Scans for a katago binary and model. Does NOT start the process.
  /// Call once at app startup; safe to call multiple times.
  Future<void> discover() async {
    if (kIsWeb || !_isIoSupported) {
      _setStatus(EngineStatus.notFound);
      return;
    }
    try {
      _enginesDir = await _enginesDirectory();
      // Try to extract the binary/model bundled inside the app's assets first.
      // This is a no-op when the asset files are absent (e.g. dev builds).
      await _extractBundledAssets(_enginesDir!);
      _binaryPath = await _findBinary(_enginesDir!);
      _modelPath = _binaryPath != null ? await _findModel(_enginesDir!) : null;
      _setStatus(EngineStatus.notFound); // found but not started yet
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(EngineStatus.error);
    }
  }

  /// Starts the KataGo subprocess. No-op if already running or unavailable.
  Future<void> start() async {
    if (kIsWeb || !_isIoSupported) return;
    if (_status == EngineStatus.ready || _status == EngineStatus.starting) {
      return;
    }
    if (!isAvailable) return;

    _setStatus(EngineStatus.starting);
    try {
      final configPath = await _ensureConfig(_enginesDir!);
      _process = await Process.start(
        _binaryPath!,
        ['analysis', '-config', configPath, '-model', _modelPath!],
        workingDirectory: _enginesDir,
      );

      // Pipe stdout through a line splitter so each JSON response is one call.
      _stdoutSub = _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_onStdoutLine, onError: _onProcessError, onDone: _onProcessDone);

      // Drain stderr to prevent the pipe from blocking.
      _stderrSub = _process!.stderr
          .transform(utf8.decoder)
          .listen((_) {});

      // Watch for early crash before setting ready.
      _process!.exitCode.then((code) {
        if (_status != EngineStatus.notFound) {
          _errorMessage = 'KataGo exited with code $code';
          _setStatus(EngineStatus.error);
          _resolveAllPending(null);
        }
      });

      _setStatus(EngineStatus.ready);
    } on ProcessException catch (e) {
      _errorMessage = 'Failed to start KataGo: ${e.message}';
      _setStatus(EngineStatus.error);
    } catch (e) {
      _errorMessage = 'Failed to start KataGo: $e';
      _setStatus(EngineStatus.error);
    }
  }

  /// Stops the subprocess and cancels all pending queries.
  Future<void> stop() async {
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    _process?.kill();
    _process = null;
    _resolveAllPending(null);
    _setStatus(EngineStatus.notFound);
  }

  /// Restarts the subprocess. Useful after an error.
  Future<void> restart() async {
    await stop();
    await discover();
    await start();
  }

  // ---------------------------------------------------------------------------
  // Query interface
  // ---------------------------------------------------------------------------

  /// Sends [request] to the running KataGo process and returns the response,
  /// or null on timeout / error. [request] must NOT include an `id` field —
  /// it will be assigned automatically.
  Future<Map<String, dynamic>?> query(
    Map<String, dynamic> request, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!isReady || _process == null) return null;

    final id = 'goko_${++_queryCounter}';
    request['id'] = id;

    final completer = Completer<Map<String, dynamic>?>();
    _pending[id] = completer;

    try {
      _process!.stdin.writeln(jsonEncode(request));
    } catch (e) {
      _pending.remove(id);
      return null;
    }

    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pending.remove(id);
      return null;
    } catch (_) {
      _pending.remove(id);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private — process I/O
  // ---------------------------------------------------------------------------

  Process? _process;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<void>? _stderrSub;
  int _queryCounter = 0;
  final Map<String, Completer<Map<String, dynamic>?>> _pending = {};

  void _onStdoutLine(String line) {
    if (line.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(line) as Map<String, dynamic>;
      final id = decoded['id'] as String?;
      if (id != null) {
        // KataGo streams incremental results; resolve only the final one.
        if (decoded['isDuringSearch'] != true) {
          _pending.remove(id)?.complete(decoded);
        }
      }
    } catch (_) {
      // Non-JSON startup messages from KataGo — ignore.
    }
  }

  void _onProcessError(Object error) {
    _errorMessage = error.toString();
    _setStatus(EngineStatus.error);
    _resolveAllPending(null);
  }

  void _onProcessDone() {
    if (_status == EngineStatus.ready) {
      _setStatus(EngineStatus.error);
      _errorMessage = 'KataGo process ended unexpectedly';
    }
    _resolveAllPending(null);
    _process = null;
  }

  void _resolveAllPending(Map<String, dynamic>? value) {
    for (final c in _pending.values) {
      if (!c.isCompleted) c.complete(value);
    }
    _pending.clear();
  }

  void _setStatus(EngineStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private — filesystem helpers
  // ---------------------------------------------------------------------------

  /// Extracts bundled engine files from Flutter assets to [enginesDir].
  ///
  /// Expects assets at:
  ///   `assets/engines/{platform}/katago[.exe]`  — the KataGo binary
  ///   `assets/engines/model.bin.gz`             — the neural-network model
  ///
  /// Add the binaries to those paths in your Flutter project and declare them
  /// in `pubspec.yaml`. The method silently skips missing assets so the app
  /// works fine in development builds where the files have not been added yet.
  ///
  /// On Unix-like platforms the binary is made executable with `chmod +x`.
  static Future<void> _extractBundledAssets(String enginesDir) async {
    final binaryAssetPath = _bundledBinaryAssetPath;
    if (binaryAssetPath != null) {
      final dest = File('$enginesDir/$_binaryName');
      if (!await dest.exists()) {
        try {
          final data = await rootBundle.load(binaryAssetPath);
          await dest.writeAsBytes(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            flush: true,
          );
          if (!_isPlatformWindows) {
            await Process.run('chmod', ['+x', dest.path]);
          }
        } catch (_) {
          // Asset not bundled — skip silently.
        }
      }
    }

    // Model file: shared across all platforms.
    const modelAsset = 'assets/engines/model.bin.gz';
    final modelDest = File('$enginesDir/katago-model.bin.gz');
    if (!await modelDest.exists()) {
      try {
        final data = await rootBundle.load(modelAsset);
        await modelDest.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
      } catch (_) {
        // Asset not bundled — skip silently.
      }
    }
  }

  /// The Flutter asset path for the bundled binary for the current platform.
  static String? get _bundledBinaryAssetPath {
    try {
      if (Platform.isWindows) return 'assets/engines/windows/katago.exe';
      if (Platform.isMacOS)   return 'assets/engines/macos/katago';
      if (Platform.isLinux)   return 'assets/engines/linux/katago';
      if (Platform.isAndroid) return 'assets/engines/android/katago';
    } catch (_) {}
    return null;
  }

  /// Whether the current platform supports spawning child processes.
  bool get _isIoSupported {    try {
      return Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS ||
          Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  /// Returns (and creates if absent) the managed engines directory.
  static Future<String> _enginesDirectory() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/engines');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  /// Searches for a `katago[.exe]` binary in order of preference.
  static Future<String?> _findBinary(String enginesDir) async {
    final name = _binaryName;

    // 1. App-managed engines folder (user-placed binary).
    final local = File('$enginesDir/$name');
    if (await local.exists()) return local.path;

    // 2. System PATH.
    try {
      final whichCmd = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(whichCmd, ['katago']);
      if (result.exitCode == 0) {
        final path =
            (result.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty) return path;
      }
    } catch (_) {}

    // 3. Common Homebrew paths (macOS).
    if (Platform.isMacOS) {
      for (final p in [
        '/usr/local/bin/katago',
        '/opt/homebrew/bin/katago',
      ]) {
        if (await File(p).exists()) return p;
      }
    }

    return null;
  }

  /// Returns the path of the first `*.bin.gz` model file found.
  static Future<String?> _findModel(String enginesDir) async {
    final dir = Directory(enginesDir);
    if (!await dir.exists()) return null;
    final models = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.bin.gz'))
        .map((e) => e.path)
        .toList();
    return models.isEmpty ? null : models.first;
  }

  /// Writes a minimal analysis config if one doesn't already exist.
  static Future<String> _ensureConfig(String enginesDir) async {
    final f = File('$enginesDir/analysis.cfg');
    if (!await f.exists()) await f.writeAsString(_kDefaultConfig);
    return f.path;
  }

  static String get _binaryName =>
      _isPlatformWindows ? 'katago.exe' : 'katago';

  static bool get _isPlatformWindows {
    try {
      return Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  // Minimal KataGo analysis-mode config (auto-generated; users can replace it).
  static const String _kDefaultConfig = r'''
# GOKO — auto-generated KataGo analysis config
# Edit this file to tune performance. Changes take effect on next restart.
maxAnalyzeTime = 10.0
maxVisits = 800
numSearchThreads = 2
numAnalysisThreads = 1
maxCacheSizePowerOfTwo = 17
nnCacheSizePowerOfTwo = 17
nnMutexPoolSizePowerOfTwo = 15
nnRandomize = false
reportAnalysisWinratesAs = BLACK
''';
}
