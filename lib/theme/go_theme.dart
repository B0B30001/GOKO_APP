import 'package:flutter/material.dart';

/// Top-level visual presets the user can switch between in Settings.
/// Each preset bundles a brightness, a scaffold/surface palette, and an
/// accent color. The board (stones, wood, lines) is themed separately via
/// [GoBoardTheme] so users can mix-and-match.
enum ThemePreset {
  /// Chess.com-style premium dark navy. New default — deep blue background
  /// with a vivid blue accent for active states / primary buttons.
  darkBlue,

  /// True black for OLED screens. Same blue accent.
  oledBlack,

  /// Warm wood tones. Light brightness. Browns and tans.
  classicWood,

  /// Clean light mode with deep blue accents.
  lightMode,
}

class ThemePresetIds {
  static const darkBlue = 'darkBlue';
  static const oledBlack = 'oledBlack';
  static const classicWood = 'classicWood';
  static const lightMode = 'lightMode';

  static const all = <String>[darkBlue, oledBlack, classicWood, lightMode];

  static ThemePreset toEnum(String id) => switch (id) {
    oledBlack => ThemePreset.oledBlack,
    classicWood => ThemePreset.classicWood,
    lightMode => ThemePreset.lightMode,
    _ => ThemePreset.darkBlue,
  };

  static String fromEnum(ThemePreset p) => switch (p) {
    ThemePreset.darkBlue => darkBlue,
    ThemePreset.oledBlack => oledBlack,
    ThemePreset.classicWood => classicWood,
    ThemePreset.lightMode => lightMode,
  };

  /// Display name shown in the Settings preset picker.
  static String displayName(ThemePreset p) => switch (p) {
    ThemePreset.darkBlue => 'Dark Blue',
    ThemePreset.oledBlack => 'OLED Black',
    ThemePreset.classicWood => 'Classic Wood',
    ThemePreset.lightMode => 'Light Mode',
  };
}

class GoTheme {
  /// Builds a [ThemeData] for the given [preset]. Replaces the older
  /// static `light` / `dark` getters; those remain for back-compat below.
  static ThemeData fromPreset(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.darkBlue:
        return _buildDarkBlue();
      case ThemePreset.oledBlack:
        return _buildOledBlack();
      case ThemePreset.classicWood:
        return _buildClassicWood();
      case ThemePreset.lightMode:
        return _buildLightMode();
    }
  }

  /// Backward-compatible default light theme — alias of Light Mode preset.
  static ThemeData get light => _buildLightMode();

  /// Backward-compatible default dark theme — alias of Dark Blue preset.
  static ThemeData get dark => _buildDarkBlue();

  // ----- Preset builders -----

  static ThemeData _buildDarkBlue() {
    const scaffold = Color(0xFF0E1525);
    const surface = Color(0xFF16213E);
    const primary = Color(0xFF4F8EF7);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF7BA8F8),
        surface: surface,
        onSurface: Color(0xFFE6ECF7),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: Color(0xFFE6ECF7),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData _buildOledBlack() {
    const scaffold = Color(0xFF000000);
    const surface = Color(0xFF0E0E0E);
    const primary = Color(0xFF4F8EF7);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF7BA8F8),
        surface: surface,
        onSurface: Color(0xFFE6ECF7),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: Color(0xFFE6ECF7),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData _buildClassicWood() {
    const scaffold = Color(0xFFF4ECDB);
    const surface = Color(0xFFFFFFFF);
    const primary = Color(0xFF6B4423);
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFFB58A56),
        surface: surface,
        onSurface: Color(0xFF2A1F18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData _buildLightMode() {
    const scaffold = Color(0xFFFFFFFF);
    const surface = Color(0xFFF5F7FA);
    const primary = Color(0xFF1565C0);
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF42A5F5),
        surface: surface,
        onSurface: Color(0xFF0E1525),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class GoBoardTheme {
  final Color boardColor;
  final Color lineColor;
  final Color textColor;
  final List<Color> boardGradient;
  final Color blackStoneColor;
  final Color whiteStoneColor;
  final Color stoneShadowColor;

  const GoBoardTheme({
    required this.boardColor,
    required this.lineColor,
    required this.textColor,
    required this.boardGradient,
    required this.blackStoneColor,
    required this.whiteStoneColor,
    required this.stoneShadowColor,
  });

  static final light = GoBoardTheme(
    boardColor: const Color(0xFFDEB887),
    lineColor: Colors.black87,
    textColor: Colors.black87,
    boardGradient: [
      const Color(0xFFDEB887).withValues(alpha: 0.7),
      const Color(0xFFD2691E).withValues(alpha: 0.3),
    ],
    blackStoneColor: Colors.black,
    whiteStoneColor: Colors.white,
    stoneShadowColor: Colors.black26,
  );

  static final dark = GoBoardTheme(
    boardColor: const Color(0xFF2C2C2C),
    lineColor: Colors.white70,
    textColor: Colors.white70,
    boardGradient: [
      const Color(0xFF2C2C2C).withValues(alpha: 0.7),
      const Color(0xFF1A1A1A).withValues(alpha: 0.3),
    ],
    blackStoneColor: Colors.black,
    whiteStoneColor: Colors.white,
    stoneShadowColor: Colors.black45,
  );

  /// Named variants selectable from Settings.
  static final classic = light;

  static final walnut = GoBoardTheme(
    boardColor: const Color(0xFF8B5A2B),
    lineColor: Colors.black87,
    textColor: Colors.black87,
    boardGradient: [
      const Color(0xFF8B5A2B).withValues(alpha: 0.85),
      const Color(0xFF5C3317).withValues(alpha: 0.45),
    ],
    blackStoneColor: Colors.black,
    whiteStoneColor: Colors.white,
    stoneShadowColor: Colors.black45,
  );

  static final slate = GoBoardTheme(
    boardColor: const Color(0xFF607D8B),
    lineColor: Colors.black87,
    textColor: Colors.black87,
    boardGradient: [
      const Color(0xFF607D8B).withValues(alpha: 0.85),
      const Color(0xFF37474F).withValues(alpha: 0.45),
    ],
    blackStoneColor: Colors.black,
    whiteStoneColor: Colors.white,
    stoneShadowColor: Colors.black54,
  );

  static final night = dark;

  static GoBoardTheme byId(String id) {
    switch (id) {
      case 'walnut':
        return walnut;
      case 'slate':
        return slate;
      case 'night':
        return night;
      case 'classic':
      default:
        return classic;
    }
  }
}

/// Background appearance variants for app surfaces (scaffold/canvas behind the
/// board). Resolved by id from settings.
class GoBackgroundTheme {
  final Color scaffoldColor;
  final List<Color> gradient;

  const GoBackgroundTheme({
    required this.scaffoldColor,
    required this.gradient,
  });

  static const standard = GoBackgroundTheme(
    scaffoldColor: Color(0xFF1A1A1A),
    gradient: [Color(0xFF1A1A1A), Color(0xFF111111)],
  );

  static const minimal = GoBackgroundTheme(
    scaffoldColor: Color(0xFF202020),
    gradient: [Color(0xFF202020), Color(0xFF202020)],
  );

  static const warm = GoBackgroundTheme(
    scaffoldColor: Color(0xFF2A1F18),
    gradient: [Color(0xFF2A1F18), Color(0xFF1A130E)],
  );

  static const cool = GoBackgroundTheme(
    scaffoldColor: Color(0xFF15202B),
    gradient: [Color(0xFF15202B), Color(0xFF0E141B)],
  );

  static GoBackgroundTheme byId(String id) {
    switch (id) {
      case 'minimal':
        return minimal;
      case 'warm':
        return warm;
      case 'cool':
        return cool;
      case 'standard':
      default:
        return standard;
    }
  }
}
