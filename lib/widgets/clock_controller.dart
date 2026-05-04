import 'dart:async';

import 'package:flutter/foundation.dart';

/// Simple per-player countdown clock controller.
///
/// Used by local 2-player and AI games for an optional fixed time control.
/// Online games drive their clocks from OGS clock events instead and do not
/// use this controller. [activeColor] selects which player's clock ticks down.
///
/// Resolution: 100 ms tick, no period/byo-yomi support yet (sudden death only).
class ClockController extends ChangeNotifier {
  Duration _blackRemaining;
  Duration _whiteRemaining;
  int _activeColor; // 1 = black, 2 = white, 0 = paused

  Timer? _timer;
  DateTime? _lastTick;

  ClockController({required Duration mainTime, int startingColor = 1})
    : _blackRemaining = mainTime,
      _whiteRemaining = mainTime,
      _activeColor = startingColor;

  Duration get blackRemaining => _blackRemaining;
  Duration get whiteRemaining => _whiteRemaining;
  int get activeColor => _activeColor;
  bool get isRunning => _timer != null;
  bool get blackFlagged => _blackRemaining <= Duration.zero;
  bool get whiteFlagged => _whiteRemaining <= Duration.zero;

  void start() {
    if (_timer != null) return;
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _onTick);
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    _lastTick = null;
    notifyListeners();
  }

  void switchTurn(int newActiveColor) {
    _activeColor = newActiveColor;
    _lastTick = DateTime.now();
    notifyListeners();
  }

  void _onTick(Timer t) {
    final now = DateTime.now();
    final delta = _lastTick != null
        ? now.difference(_lastTick!)
        : Duration.zero;
    _lastTick = now;
    if (_activeColor == 1) {
      _blackRemaining -= delta;
      if (_blackRemaining <= Duration.zero) {
        _blackRemaining = Duration.zero;
        pause();
      }
    } else if (_activeColor == 2) {
      _whiteRemaining -= delta;
      if (_whiteRemaining <= Duration.zero) {
        _whiteRemaining = Duration.zero;
        pause();
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
