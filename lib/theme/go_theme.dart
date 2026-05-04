import 'package:flutter/material.dart';

class GoTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      // Light, friendly blue palette
      primaryColor: const Color(0xFF42A5F5), // Blue 400
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF42A5F5),
        secondary: Color(0xFF90CAF9), // Blue 200
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2C2C2C),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF2C2C2C),
        secondary: Colors.grey[700]!,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          elevation: 4,
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
