import 'package:flutter/material.dart';

import '../../gen/l10n/app_localizations.dart';
import '../../models/app_settings.dart';

/// Visual palette for a band of the gamified map (sky, hills, foreground,
/// accent colour used for level tiles + world gates).
///
/// Used by both the Puzzle Garden (which rotates through `gardenThemes` as the
/// player climbs XP bands) and the Learn Garden (which picks ONE theme based
/// on [AppSettings.backgroundThemeId] — see [themeForUserPalette]).
class GardenTheme {
  final Color skyTop;
  final Color skyBottom;
  final Color hillTop;
  final Color hillBottom;
  final Color tileBase;
  final IconData icon;
  const GardenTheme({
    required this.skyTop,
    required this.skyBottom,
    required this.hillTop,
    required this.hillBottom,
    required this.tileBase,
    required this.icon,
  });
}

/// Five XP-band themes the Puzzle Garden cycles through every 5 levels.
/// LearnGardenScreen picks ONE based on the user's chosen palette.
const gardenThemes = <GardenTheme>[
  GardenTheme(
    // Stone Forest — Levels 1-5 (also the default bright palette).
    skyTop: Color(0xFFB8DCF0),
    skyBottom: Color(0xFFF5E6C8),
    hillTop: Color(0xFFA5C99B),
    hillBottom: Color(0xFF5C8E4F),
    tileBase: Color(0xFF388E3C),
    icon: Icons.park,
  ),
  GardenTheme(
    // Crystal Cave — Levels 6-10
    skyTop: Color(0xFF1A1A2E),
    skyBottom: Color(0xFF16213E),
    hillTop: Color(0xFF2D3561),
    hillBottom: Color(0xFF0F3460),
    tileBase: Color(0xFF7C4DFF),
    icon: Icons.diamond,
  ),
  GardenTheme(
    // Copper Peaks — Levels 11-15
    skyTop: Color(0xFFFF8C42),
    skyBottom: Color(0xFFFFD700),
    hillTop: Color(0xFFCD7F32),
    hillBottom: Color(0xFF8B4513),
    tileBase: Color(0xFFE65100),
    icon: Icons.terrain,
  ),
  GardenTheme(
    // Diamond Tundra — Levels 16-20
    skyTop: Color(0xFFB3E5FC),
    skyBottom: Color(0xFFE3F2FD),
    hillTop: Color(0xFF80D8FF),
    hillBottom: Color(0xFF29B6F6),
    tileBase: Color(0xFF0288D1),
    icon: Icons.ac_unit,
  ),
  GardenTheme(
    // Jade Highlands — Levels 21+
    skyTop: Color(0xFF2E7D32),
    skyBottom: Color(0xFF4CAF50),
    hillTop: Color(0xFF1B5E20),
    hillBottom: Color(0xFF33691E),
    tileBase: Color(0xFF00BFA5),
    icon: Icons.landscape,
  ),
];

/// Localized name of the i-th theme. The 5 names match the band order
/// (Stone Forest, Crystal Cave, Copper Peaks, Diamond Tundra, Jade Highlands).
String gardenThemeName(int themeIdx, AppLocalizations l) => switch (themeIdx) {
  0 => l.worldStoneForest,
  1 => l.worldCrystalCave,
  2 => l.worldCopperPeaks,
  3 => l.worldDiamondTundra,
  _ => l.worldJadeHighlands,
};

/// Picks the theme that best matches the user's chosen `backgroundThemeId`.
///
/// The Learn page uses a single consistent theme (lessons are grouped by
/// category, not by climb progress) and binds it to the user's setting so the
/// look matches their global preference. Falls back to Stone Forest (bright,
/// readable, beginner-friendly) when the setting doesn't map to a known band.
GardenTheme themeForUserPalette(String backgroundThemeId) {
  switch (backgroundThemeId) {
    case 'minimal':
      return gardenThemes[3]; // Diamond Tundra — light, clean
    case 'warm':
      return gardenThemes[2]; // Copper Peaks — warm orange/gold
    case 'cool':
      return gardenThemes[1]; // Crystal Cave — cool blue/purple
    case 'standard':
    default:
      return gardenThemes[0]; // Stone Forest — bright + readable default
  }
}

/// Same as above but reads the live [AppSettings] static state.
GardenTheme themeForCurrentSettings() =>
    themeForUserPalette(AppSettings.backgroundThemeId);
