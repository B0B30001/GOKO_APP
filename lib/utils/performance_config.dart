// Performance configuration for the app
class PerformanceConfig {
  // Reduce shadow blur for better performance
  static const double stoneShadowBlur = 2.0; // Reduced from 3.0

  // Cache keys for paint objects
  static const bool enablePaintCaching = true;

  // Reduce antialiasing for better performance on low-end devices
  static const bool enableAntiAlias = true;

  // Enable RepaintBoundary widgets
  static const bool useRepaintBoundaries = true;

  // Debounce hover events (milliseconds)
  static const int hoverDebounceMs = 16; // ~60fps

  // Maximum cached boards in memory
  static const int maxCachedBoards = 3;

  // Use hardware acceleration when available
  static const bool preferHardwareAcceleration = true;

  // Simplify board background gradient
  static const bool useSimpleGradient = false;

  // Stone rendering quality
  static const double stoneQualityFactor = 1.0; // 1.0 = full quality
}
