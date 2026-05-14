// lib/services/sfx_service.dart

import 'package:audioplayers/audioplayers.dart';
import '../models/app_settings.dart';

/// All named sound effects used across the app.
enum SfxSound {
  /// Soft click when a stone is placed on the board.
  stonePlace,

  /// Heavier thud when one or more stones are captured.
  capture,

  /// Rising ding — correct puzzle move (Duolingo-style).
  correct,

  /// Low thud/buzz — wrong puzzle move or mistake.
  wrong,

  /// Short fanfare — puzzle or drill completed successfully.
  complete,

  /// Longer celebration — tutorial / lesson finished.
  lessonComplete,
}

/// Singleton service that plays short sound effects.
///
/// Usage:
/// ```dart
/// SfxService.instance.play(SfxSound.correct);
/// ```
///
/// All playback is silently skipped when [AppSettings.soundEnabled] is false.
/// Place audio files in `assets/sounds/` with the names listed in [_assetFor].
class SfxService {
  SfxService._();

  static final SfxService instance = SfxService._();

  /// Separate player per sound so rapid overlapping effects don't cut each other.
  final _players = <SfxSound, AudioPlayer>{};

  /// Maps each sound to its asset filename inside `assets/sounds/`.
  static String _assetFor(SfxSound sound) => switch (sound) {
    SfxSound.stonePlace => 'assets/sounds/stone_place.wav',
    SfxSound.capture => 'assets/sounds/capture.wav',
    SfxSound.correct => 'assets/sounds/correct.wav',
    SfxSound.wrong => 'assets/sounds/wrong.wav',
    SfxSound.complete => 'assets/sounds/complete.wav',
    SfxSound.lessonComplete => 'assets/sounds/lesson_complete.wav',
  };

  /// Plays [sound] unless [AppSettings.soundEnabled] is false.
  /// Silently swallowed if the asset file is missing.
  Future<void> play(SfxSound sound) async {
    if (!AppSettings.soundEnabled) return;
    try {
      final player = _players.putIfAbsent(sound, AudioPlayer.new);
      await player.play(
        AssetSource(_assetFor(sound).replaceFirst('assets/', '')),
      );
    } catch (_) {
      // Missing audio file or platform error — degrade gracefully.
    }
  }

  /// Releases all [AudioPlayer] instances. Call on app exit if needed.
  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}
