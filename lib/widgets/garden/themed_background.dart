import 'package:flutter/material.dart';

/// Calm, premium backdrop for the gamified gardens.
///
/// Deliberately minimal — a smooth per-world vertical gradient, a few large
/// very-soft blurred "bokeh" orbs for gentle depth, and a light edge vignette.
/// No literal scenery: restraint reads far more premium than procedural props
/// (trees / mountains / floors), which always end up looking like clip-art.
/// Tiles, the winding path and the mascot are the focal content on top.
class ThemedBackground extends StatelessWidget {
  final int themeIdx;
  final double scrollOffset;

  const ThemedBackground({
    super.key,
    required this.themeIdx,
    this.scrollOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GardenBackgroundPainter(
        themeIdx: themeIdx,
        scrollOffset: scrollOffset,
      ),
      size: Size.infinite,
    );
  }
}

class GardenBackgroundPainter extends CustomPainter {
  final int themeIdx;
  final double scrollOffset;

  const GardenBackgroundPainter({
    required this.themeIdx,
    this.scrollOffset = 0.0,
  });

  /// Calm 3-stop gradient per world (top → mid → bottom). Muted, premium tones
  /// — not the saturated tile palette. Index matches the 5 garden theme bands.
  static const _palettes = <List<Color>>[
    [
      Color(0xFFEAF3E7),
      Color(0xFFCFE3D0),
      Color(0xFFA7CDB0),
    ], // Stone Forest — soft sage
    [
      Color(0xFF1A1A38),
      Color(0xFF272253),
      Color(0xFF3E3576),
    ], // Crystal Cave — indigo night
    [
      Color(0xFFF6E3CB),
      Color(0xFFE9C39B),
      Color(0xFFD49C6E),
    ], // Copper Peaks — warm sand
    [
      Color(0xFFEDF6FC),
      Color(0xFFD3E8F6),
      Color(0xFFAFD3EC),
    ], // Diamond Tundra — ice
    [
      Color(0xFFDCEEE1),
      Color(0xFFAED6BB),
      Color(0xFF74B492),
    ], // Jade Highlands — green
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final idx = themeIdx.clamp(0, _palettes.length - 1);
    final p = _palettes[idx];
    final w = size.width;
    final h = size.height;
    final off = scrollOffset * 0.08;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // ── Gradient fill ────────────────────────────────────────────────────
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: p,
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // ── Soft bokeh orbs — large, very low-alpha, heavily blurred ──────────
    final isDark = idx == 1;
    final light = (isDark ? Colors.white : Colors.white).withValues(
      alpha: isDark ? 0.06 : 0.16,
    );
    final accent = Color.lerp(
      p[2],
      Colors.white,
      0.30,
    )!.withValues(alpha: isDark ? 0.10 : 0.14);
    final orb = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);
    canvas.drawCircle(
      Offset(w * 0.22, h * 0.16 - off),
      w * 0.40,
      orb..color = light,
    );
    canvas.drawCircle(
      Offset(w * 0.86, h * 0.42 - off * 1.4),
      w * 0.34,
      orb..color = accent,
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.84 - off * 1.8),
      w * 0.46,
      orb..color = accent,
    );

    // ── Gentle edge vignette ──────────────────────────────────────────────
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.05,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: isDark ? 0.22 : 0.14),
          ],
          stops: const [0.0, 0.66, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant GardenBackgroundPainter old) =>
      old.themeIdx != themeIdx || old.scrollOffset != scrollOffset;
}
