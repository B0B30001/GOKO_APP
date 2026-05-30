import 'package:flutter/material.dart';

import 'garden_theme.dart';

const _themeAssetNames = <String>[
  'stone_forest',
  'crystal_cave',
  'copper_peaks',
  'diamond_tundra',
  'jade_highlands',
];

/// Tries to load the Canva-designed background PNG for the given theme. If
/// the asset isn't bundled, falls back to the procedural parallax
/// [GardenBackgroundPainter] so the screen always has something to render.
///
/// To swap a background in: drop `assets/backgrounds/<theme>.png` into the
/// repo (see `assets/backgrounds/README.md`). No code change needed.
class ThemedBackground extends StatelessWidget {
  final int themeIdx;

  /// Scroll offset for parallax effect. Typically from ScrollController.offset
  /// or scroll notification. Defaults to 0 for static background.
  final double scrollOffset;

  const ThemedBackground({
    super.key,
    required this.themeIdx,
    this.scrollOffset = 0.0,
  });

  String get _assetPath {
    final name =
        _themeAssetNames[themeIdx.clamp(0, _themeAssetNames.length - 1)];
    return 'assets/backgrounds/$name.png';
  }

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      painter: GardenBackgroundPainter(
        themeIdx: themeIdx,
        scrollOffset: scrollOffset,
      ),
      size: Size.infinite,
    );
    // `Image.asset` throws asynchronously on missing files; route the error
    // to the painter so we never see a broken image icon.
    return Image.asset(
      _assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => painter,
    );
  }
}

/// Procedural background painter with parallax scrolling support.
///
/// Draws a sky gradient, a soft sun/moon halo, three layered mountain ridges,
/// mid-ground rolling hills, and a foreground ground band with grass speckles.
///
/// **Parallax Effect**:
/// Each layer (sky, mountains, hills, ground) shifts vertically based on the
/// scroll offset, creating a 3D depth illusion. Layers closer to the camera
/// (foreground) move faster than distant layers (background).
///
/// All colours come from the [gardenThemes] entry for [themeIdx].
class GardenBackgroundPainter extends CustomPainter {
  final int themeIdx;
  final double scrollOffset;

  const GardenBackgroundPainter({
    required this.themeIdx,
    this.scrollOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final theme = gardenThemes[themeIdx.clamp(0, gardenThemes.length - 1)];
    final w = size.width;
    final h = size.height;

    // Parallax factors for each layer (0 = no movement, 1 = full scroll movement)
    // Distant layers move slower, creating depth illusion
    const skyParallax = 0.1; // Sky barely moves
    const mountainParallax = 0.3; // Far mountains move slowly
    const hillsParallax = 0.6; // Mid hills move moderately
    const groundParallax = 1.0; // Foreground moves fastest

    // Sky gradient with parallax — soft three-stop blend for natural light depth.
    final skyOffset = scrollOffset * skyParallax;
    final skyMid = Color.lerp(theme.skyTop, theme.skyBottom, 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, -skyOffset, w, h + skyOffset * 2),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.skyTop, skyMid, theme.skyBottom],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, -skyOffset, w, h + skyOffset * 2)),
    );

    // Soft sun/moon halo near the upper-right — adds focal light without
    // looking like a hard disc. Subtle parallax movement.
    final sunOffset = scrollOffset * skyParallax;
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.16 - sunOffset),
      80,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(w * 0.78, h * 0.16 - sunOffset),
                radius: 80,
              ),
            )
        ..blendMode = BlendMode.plus,
    );

    // Three layered mountain ridges with cubic-Bezier silhouettes.
    // Each ridge gets progressively more parallax offset for depth.
    final mountainOffset = scrollOffset * mountainParallax;
    for (int layer = 0; layer < 3; layer++) {
      final yBase = h * (0.30 + layer * 0.08) - mountainOffset;
      final amplitude = 28.0 + layer * 16.0;
      final opacity = 0.30 + layer * 0.18;
      final ridgePaint = Paint()
        ..color = theme.hillTop.withValues(alpha: opacity);
      final path = Path()
        ..moveTo(0, h)
        ..lineTo(0, yBase);

      final peaks = 4 + layer;
      final dx = w / peaks;
      double prevX = 0;
      const prevY = 0.0; // unused — control points carry the curve
      for (int p = 0; p < peaks; p++) {
        final x1 = prevX + dx * 0.35;
        final x2 = prevX + dx * 0.65;
        final endX = prevX + dx;
        final dipAmount = ((p + layer) % 2 == 0) ? amplitude : amplitude * 0.55;
        final y1 = yBase - dipAmount;
        final y2 = yBase - dipAmount * 0.85;
        path.cubicTo(x1, y1, x2, y2, endX, yBase + prevY);
        prevX = endX;
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(path, ridgePaint);
    }

    // Atmospheric haze band between distant ridges and mid hills — sells
    // depth without competing with the animated clouds drawn separately by
    // AmbientDecorations. Parallax sits between mountain (0.3) and hills
    // (0.6) for a believable middle layer.
    const hazeParallax = 0.45;
    final hazeOffset = scrollOffset * hazeParallax;
    final hazeRect = Rect.fromLTWH(
      0,
      h * 0.38 - hazeOffset,
      w,
      h * 0.14 + hazeOffset,
    );
    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(hazeRect),
    );

    // Mid-ground rolling hills — quadratic Bezier curves with parallax offset.
    final hillsOffset = scrollOffset * hillsParallax;
    final hills = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.62 - hillsOffset);
    const hillPeaks = 5;
    final hdx = w / hillPeaks;
    double prevX = 0;
    for (int p = 0; p < hillPeaks; p++) {
      final endX = prevX + hdx;
      final midX = prevX + hdx / 2;
      final dip = h * 0.62 - (p.isEven ? 28.0 : 18.0) - hillsOffset;
      hills.quadraticBezierTo(midX, dip, endX, h * 0.62 - hillsOffset);
      prevX = endX;
    }
    hills
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hills, Paint()..color = theme.hillTop);

    // Foreground ground band gradient with parallax offset.
    final groundOffset = scrollOffset * groundParallax;
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.74 - groundOffset, w, h * 0.26 + groundOffset),
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.hillTop,
                Color.lerp(theme.hillTop, theme.hillBottom, 0.5)!,
                theme.hillBottom,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromLTWH(
                0,
                h * 0.74 - groundOffset,
                w,
                h * 0.26 + groundOffset,
              ),
            ),
    );

    // Zen paving grid on the foreground — a faint isometric diamond lattice
    // that reads as a tiled stone courtyard (the Gemini-mockup garden floor)
    // instead of random grass grain. Clipped to the ground band and parallaxed
    // with the foreground so it scrolls believably.
    final groundTop = h * 0.74 - groundOffset;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, groundTop, w, h - groundTop + 40));
    final paving = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.08);
    final step = w / 7;
    // Two crossing families of diagonals → diamond tiles.
    for (double x = -h; x < w + h; x += step) {
      canvas.drawLine(Offset(x, groundTop), Offset(x + h, h + 40), paving);
      canvas.drawLine(Offset(x, groundTop), Offset(x - h, h + 40), paving);
    }
    canvas.restore();

    // A soft reflective water band at the very foot — hints at the koi pond in
    // the mockups without needing illustrated art.
    final pondTop = h * 0.92 - groundOffset * 0.3;
    final pondRect = Rect.fromLTWH(0, pondTop, w, h - pondTop + 40);
    if (pondRect.height > 0) {
      final water = Color.lerp(theme.skyBottom, theme.hillBottom, 0.4)!;
      canvas.drawRect(
        pondRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              water.withValues(alpha: 0.0),
              water.withValues(alpha: 0.55),
            ],
          ).createShader(pondRect),
      );
      // Two faint ripple lines.
      final ripple = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.14);
      canvas.drawLine(
        Offset(w * 0.12, pondTop + pondRect.height * 0.4),
        Offset(w * 0.42, pondTop + pondRect.height * 0.4),
        ripple,
      );
      canvas.drawLine(
        Offset(w * 0.58, pondTop + pondRect.height * 0.6),
        Offset(w * 0.86, pondTop + pondRect.height * 0.6),
        ripple,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GardenBackgroundPainter old) =>
      old.themeIdx != themeIdx || old.scrollOffset != scrollOffset;
}
