import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identifiers for board appearance variants. Resolved to GoBoardTheme via
/// GoBoardTheme.byId(...).
class BoardThemeId {
  static const classic = 'classic';
  static const walnut = 'walnut';
  static const slate = 'slate';
  static const night = 'night';

  static const all = <String>[classic, walnut, slate, night];
}

/// Identifiers for app background appearance variants.
class BackgroundThemeId {
  static const standard = 'standard';
  static const minimal = 'minimal';
  static const warm = 'warm';
  static const cool = 'cool';

  static const all = <String>[standard, minimal, warm, cool];
}

/// Global, app-wide settings.
///
/// Static fields preserve compatibility with existing call sites
/// (e.g. `AppSettings.showCoordinates`). [revision] is bumped when any field
/// changes so widgets that need to react to settings changes can rebuild via a
/// `ValueListenableBuilder`. Persistence is via shared_preferences.
class AppSettings {
  // ----- Existing fields -----
  static bool showCoordinates = false;
  static bool forceLightThemeInGame = true;
  static bool verboseLogs = false;

  // ----- New fields -----
  static ThemeMode themeMode = ThemeMode.dark;
  static String boardThemeId = BoardThemeId.classic;
  static String backgroundThemeId = BackgroundThemeId.standard;

  /// Top-level theme preset id (see [ThemePresetIds] in `theme/go_theme.dart`).
  /// Defaults to the new Chess.com-style dark blue preset.
  static String themePresetId = 'darkBlue';

  /// BCP-47 language code used for the app locale.  Supported: 'en', 'zh', 'ru'.
  static String languageCode = 'en';

  /// URL of a remote KataGo analysis WebSocket server.
  /// Example: 'ws://192.168.1.10:8080' or 'wss://my-katago-server.example.com'
  /// Leave empty to disable KataGo and fall back to MCTS.
  static String kataGoServerUrl = '';

  /// Bumped on every save so listeners can rebuild.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const _kShowCoordinates = 'showCoordinates';
  static const _kForceLightInGame = 'forceLightThemeInGame';
  static const _kThemeMode = 'themeMode';
  static const _kBoardThemeId = 'boardThemeId';
  static const _kBackgroundThemeId = 'backgroundThemeId';
  static const _kThemePresetId = 'themePresetId';
  static const _kLanguageCode = 'languageCode';
  static const _kKataGoServerUrl = 'kataGoServerUrl';

  /// Reads persisted values into the static fields. Must be called once at
  /// startup before runApp().
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    showCoordinates = prefs.getBool(_kShowCoordinates) ?? showCoordinates;
    forceLightThemeInGame =
        prefs.getBool(_kForceLightInGame) ?? forceLightThemeInGame;
    themeMode = _decodeThemeMode(prefs.getString(_kThemeMode)) ?? themeMode;
    boardThemeId = prefs.getString(_kBoardThemeId) ?? boardThemeId;
    backgroundThemeId =
        prefs.getString(_kBackgroundThemeId) ?? backgroundThemeId;
    themePresetId = prefs.getString(_kThemePresetId) ?? themePresetId;
    languageCode = prefs.getString(_kLanguageCode) ?? languageCode;
    kataGoServerUrl = prefs.getString(_kKataGoServerUrl) ?? kataGoServerUrl;
    revision.value++;
  }

  /// Persists all values and notifies listeners.
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowCoordinates, showCoordinates);
    await prefs.setBool(_kForceLightInGame, forceLightThemeInGame);
    await prefs.setString(_kThemeMode, _encodeThemeMode(themeMode));
    await prefs.setString(_kBoardThemeId, boardThemeId);
    await prefs.setString(_kBackgroundThemeId, backgroundThemeId);
    await prefs.setString(_kThemePresetId, themePresetId);
    await prefs.setString(_kLanguageCode, languageCode);
    await prefs.setString(_kKataGoServerUrl, kataGoServerUrl);
    revision.value++;
  }

  static String _encodeThemeMode(ThemeMode m) => switch (m) {
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
  };

  static ThemeMode? _decodeThemeMode(String? s) => switch (s) {
    'system' => ThemeMode.system,
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => null,
  };
}
