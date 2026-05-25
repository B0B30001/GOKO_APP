import 'dart:ui' show PlatformDispatcher;

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

/// Identifiers for stone-color variants (chess.com-style). Resolved via
/// StoneColorPreset.byId(...) in `theme/go_theme.dart`.
class StoneColorId {
  static const classic = 'classic'; // black + ivory
  static const jade = 'jade';
  static const amber = 'amber';
  static const cobalt = 'cobalt';
  static const crimson = 'crimson';
  static const mono = 'mono';

  static const all = <String>[classic, jade, amber, cobalt, crimson, mono];
}

/// Global, app-wide settings.
///
/// Static fields preserve compatibility with existing call sites
/// (e.g. `AppSettings.showCoordinates`). [revision] is bumped when any field
/// changes so widgets that need to react to settings changes can rebuild via a
/// `ValueListenableBuilder`. Persistence is via shared_preferences.
class AppSettings {
  // ----- Existing fields -----
  static bool showCoordinates = true;
  static bool forceLightThemeInGame = true;
  static bool verboseLogs = false;

  // ----- New fields -----
  static ThemeMode themeMode = ThemeMode.dark;
  static String boardThemeId = BoardThemeId.classic;
  static String backgroundThemeId = BackgroundThemeId.standard;

  /// Top-level theme preset id (see [ThemePresetIds] in `theme/go_theme.dart`).
  /// Defaults to the new Chess.com-style dark blue preset.
  static String themePresetId = 'darkBlue';

  /// BCP-47 language code used for the app locale.  Supported: 'en', 'zh', 'ru', 'ja', 'ko', 'de'.
  ///
  /// Resolution order on startup:
  ///   1. Stored user preference (set the moment the user picks a language
  ///      in Settings, see [userPickedLanguage])
  ///   2. The device's system locale, intersected with [supportedCodes]
  ///   3. 'en' as final fallback
  ///
  /// When the user has not made an explicit choice, [userPickedLanguage]
  /// stays false and MaterialApp is given a null [locale] so it flows
  /// through the system-locale resolver — this lets a user who later
  /// switches their phone's language see the app follow along.
  static String languageCode = 'en';

  /// True once the user has explicitly picked a language in Settings. Until
  /// then we treat [languageCode] as a system-resolved suggestion and pass
  /// null to MaterialApp.locale so future OS-locale changes flow through.
  static bool userPickedLanguage = false;

  /// The full set of locales the app ships translations for. Mirrors the
  /// MaterialApp supportedLocales list and the ARB files under lib/l10n/.
  static const supportedCodes = <String>{'en', 'de', 'ru', 'zh', 'ja', 'ko'};

  /// Stone color preset id (see [StoneColorId]). Defaults to classic black+ivory.
  static String stoneColorId = StoneColorId.classic;

  /// Whether in-game sound effects are enabled (stone placement, captures,
  /// puzzle feedback, completion fanfares).
  static bool soundEnabled = true;

  /// Whether short haptic feedback fires on puzzle solve, capture, etc.
  /// Vibration motor only; ignored on devices without one (web, desktop).
  static bool hapticsEnabled = true;

  /// Bumped on every save so listeners can rebuild.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const _kShowCoordinates = 'showCoordinates';
  // Bumped to force `showCoordinates = true` once on existing installs that
  // were defaulting to false. Users can still toggle off in Settings after.
  static const _kCoordsMigratedV2 = 'coordsMigratedV2';
  static const _kForceLightInGame = 'forceLightThemeInGame';
  static const _kThemeMode = 'themeMode';
  static const _kBoardThemeId = 'boardThemeId';
  static const _kBackgroundThemeId = 'backgroundThemeId';
  static const _kThemePresetId = 'themePresetId';
  static const _kLanguageCode = 'languageCode';
  static const _kUserPickedLanguage = 'userPickedLanguage';
  static const _kSoundEnabled = 'soundEnabled';
  static const _kHapticsEnabled = 'hapticsEnabled';
  static const _kStoneColorId = 'stoneColorId';

  /// Reads persisted values into the static fields. Must be called once at
  /// startup before runApp().
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // One-shot migration: force coordinates ON for users who installed
    // before this default flip. They can still toggle off afterwards.
    final coordsMigrated = prefs.getBool(_kCoordsMigratedV2) ?? false;
    if (!coordsMigrated) {
      showCoordinates = true;
      await prefs.setBool(_kShowCoordinates, true);
      await prefs.setBool(_kCoordsMigratedV2, true);
    } else {
      showCoordinates = prefs.getBool(_kShowCoordinates) ?? showCoordinates;
    }
    forceLightThemeInGame =
        prefs.getBool(_kForceLightInGame) ?? forceLightThemeInGame;
    themeMode = _decodeThemeMode(prefs.getString(_kThemeMode)) ?? themeMode;
    boardThemeId = prefs.getString(_kBoardThemeId) ?? boardThemeId;
    backgroundThemeId =
        prefs.getString(_kBackgroundThemeId) ?? backgroundThemeId;
    themePresetId = prefs.getString(_kThemePresetId) ?? themePresetId;
    final storedLang = prefs.getString(_kLanguageCode);
    userPickedLanguage = prefs.getBool(_kUserPickedLanguage) ?? false;
    if (storedLang != null && userPickedLanguage) {
      languageCode = storedLang;
    } else {
      // First launch (or pre-flag install): try to match the OS locale to
      // one of our supported ARB files. Falls back to 'en' when no match.
      final systemCode = PlatformDispatcher.instance.locale.languageCode;
      languageCode = supportedCodes.contains(systemCode) ? systemCode : 'en';
    }
    soundEnabled = prefs.getBool(_kSoundEnabled) ?? soundEnabled;
    hapticsEnabled = prefs.getBool(_kHapticsEnabled) ?? hapticsEnabled;
    stoneColorId = prefs.getString(_kStoneColorId) ?? stoneColorId;
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
    await prefs.setBool(_kUserPickedLanguage, userPickedLanguage);
    await prefs.setBool(_kSoundEnabled, soundEnabled);
    await prefs.setBool(_kHapticsEnabled, hapticsEnabled);
    await prefs.setString(_kStoneColorId, stoneColorId);
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
