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

  /// Seasonal: deep purple + pumpkin orange.
  halloween,

  /// Seasonal: icy blues + cool whites.
  winter,

  /// Seasonal: deep forest green + amber.
  forest,
}

class ThemePresetIds {
  static const darkBlue = 'darkBlue';
  static const oledBlack = 'oledBlack';
  static const classicWood = 'classicWood';
  static const lightMode = 'lightMode';
  static const halloween = 'halloween';
  static const winter = 'winter';
  static const forest = 'forest';

  static const all = <String>[
    darkBlue,
    oledBlack,
    classicWood,
    lightMode,
    halloween,
    winter,
    forest,
  ];

  static ThemePreset toEnum(String id) => switch (id) {
    oledBlack => ThemePreset.oledBlack,
    classicWood => ThemePreset.classicWood,
    lightMode => ThemePreset.lightMode,
    halloween => ThemePreset.halloween,
    winter => ThemePreset.winter,
    forest => ThemePreset.forest,
    _ => ThemePreset.darkBlue,
  };

  static String fromEnum(ThemePreset p) => switch (p) {
    ThemePreset.darkBlue => darkBlue,
    ThemePreset.oledBlack => oledBlack,
    ThemePreset.classicWood => classicWood,
    ThemePreset.lightMode => lightMode,
    ThemePreset.halloween => halloween,
    ThemePreset.winter => winter,
    ThemePreset.forest => forest,
  };

  /// Display name shown in the Settings preset picker.
  static String displayName(ThemePreset p) => switch (p) {
    ThemePreset.darkBlue => 'Dark Blue',
    ThemePreset.oledBlack => 'OLED Black',
    ThemePreset.classicWood => 'Classic Wood',
    ThemePreset.lightMode => 'Light Mode',
    ThemePreset.halloween => 'Halloween',
    ThemePreset.winter => 'Winter',
    ThemePreset.forest => 'Forest',
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
      case ThemePreset.halloween:
        return _buildHalloween();
      case ThemePreset.winter:
        return _buildWinter();
      case ThemePreset.forest:
        return _buildForest();
    }
  }

  /// Backward-compatible default light theme — alias of Light Mode preset.
  static ThemeData get light => _buildLightMode();

  /// Backward-compatible default dark theme — alias of Dark Blue preset.
  static ThemeData get dark => _buildDarkBlue();

  // ----- Preset builders -----

  /// Trust-blue: minimal, low-saturation navy that reads as serious and
  /// dependable. Flat cards (zero elevation), single accent color, generous
  /// padding. Tuned to match chess.com's premium feel.
  static ThemeData _buildDarkBlue() {
    const scaffold = Color(0xFF0F1729); // deeper, less-saturated navy
    const surface = Color(0xFF192237); // card / app-bar surface
    const primary = Color(0xFF3B82F6); // single trust-blue accent
    const onSurface = Color(0xFFE7EBF5);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF60A5FA),
        surface: surface,
        onSurface: onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF26334D), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        bodyMedium: TextStyle(height: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF26334D), space: 1),
    );
  }

  static ThemeData _buildHalloween() {
    const scaffold = Color(0xFF1A0B2E); // deep purple
    const surface = Color(0xFF2D1B47);
    const primary = Color(0xFFFF8C00); // pumpkin orange
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.black,
        secondary: Color(0xFFFFC857),
        surface: surface,
        onSurface: Color(0xFFFFE9C4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: Color(0xFFFFE9C4),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData _buildWinter() {
    const scaffold = Color(0xFFEAF4FB); // icy blue-white
    const surface = Color(0xFFFFFFFF);
    const primary = Color(0xFF2C7DA0); // glacier blue
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF89C2D9),
        surface: surface,
        onSurface: Color(0xFF1A3A52),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: Color(0xFF1A3A52),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 2),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData _buildForest() {
    const scaffold = Color(0xFF14241B); // deep forest
    const surface = Color(0xFF1F3328);
    const primary = Color(0xFFE4A82C); // amber
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.black,
        secondary: Color(0xFF6FB17C),
        surface: surface,
        onSurface: Color(0xFFE6F2E6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: Color(0xFFE6F2E6),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface, elevation: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
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

/// Chess.com-style stone color variants. Overrides the board theme's default
/// black/white stones with a paired palette. Selected via `AppSettings.stoneColorId`.
class StoneColorPreset {
  final String id;
  final Color dark;
  final Color light;
  final Color darkHighlight;
  final Color lightHighlight;

  const StoneColorPreset({
    required this.id,
    required this.dark,
    required this.light,
    required this.darkHighlight,
    required this.lightHighlight,
  });

  static const classic = StoneColorPreset(
    id: 'classic',
    dark: Color(0xFF111111),
    light: Color(0xFFF6F0DC),
    darkHighlight: Color(0xFF3A3A3A),
    lightHighlight: Color(0xFFFFFFFF),
  );

  static const jade = StoneColorPreset(
    id: 'jade',
    dark: Color(0xFF0E3B2A),
    light: Color(0xFFE9F3DC),
    darkHighlight: Color(0xFF1F6E4F),
    lightHighlight: Color(0xFFFFFFFF),
  );

  static const amber = StoneColorPreset(
    id: 'amber',
    dark: Color(0xFF3D2110),
    light: Color(0xFFFFC857),
    darkHighlight: Color(0xFF6B3D1F),
    lightHighlight: Color(0xFFFFE08A),
  );

  static const cobalt = StoneColorPreset(
    id: 'cobalt',
    dark: Color(0xFF0B1F45),
    light: Color(0xFFBFE3FF),
    darkHighlight: Color(0xFF1E3D7A),
    lightHighlight: Color(0xFFE3F2FF),
  );

  static const crimson = StoneColorPreset(
    id: 'crimson',
    dark: Color(0xFF4A0E1E),
    light: Color(0xFFFFD6E0),
    darkHighlight: Color(0xFF7A1F3A),
    lightHighlight: Color(0xFFFFEAF0),
  );

  static const mono = StoneColorPreset(
    id: 'mono',
    dark: Color(0xFF2E2E2E),
    light: Color(0xFFFAFAFA),
    darkHighlight: Color(0xFF505050),
    lightHighlight: Color(0xFFFFFFFF),
  );

  static const all = <StoneColorPreset>[
    classic,
    jade,
    amber,
    cobalt,
    crimson,
    mono,
  ];

  static StoneColorPreset byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return classic;
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
