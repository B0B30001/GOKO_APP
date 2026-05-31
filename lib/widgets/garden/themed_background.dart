import 'package:flutter/material.dart';

import 'garden_theme.dart';

/// Global procedural backdrop for the gamified gardens — a parallax sky →
/// hills → ground → pond scene painted from the active [GardenTheme].
///
/// This is the *base* layer behind the scroll. Illustrated per-world scenery
/// PNGs are layered on top inside the scroll by [GardenWorldPanel] (see
/// `garden_scenery.dart`), which scroll with the path and never stretch. This
/// widget intentionally no longer loads a full-screen background image: a
/// single image stretched across a fixed viewport behind a long scroll was the
/// source of the distortion the painter never had.
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

    // Distant 3-tier pagoda silhouette resting on the hill line — a far-off
    // temple that grounds the scene in the zen-garden world of the mockups.
    // Drawn as a low-opacity dark-hill tone so it reads as atmosphere, never
    // crude clip-art.
    _drawPagoda(canvas, w, h, theme, h * 0.60 - hillsOffset);

    // Companion scenery on the same hill line — a vermilion torii gate and a
    // cluster of evergreen pines — to make the world read as an intentional
    // zen garden rather than a bare gradient.
    _drawSceneryProps(canvas, w, h, theme, h * 0.615 - hillsOffset);

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

  /// Draws a far-off 3-tier pagoda silhouette centred near the right third of
  /// the hill line at [baseY]. Each tier is a curved-eave roof over a slim body,
  /// shrinking as it rises, topped with a finial.
  void _drawPagoda(
    Canvas canvas,
    double w,
    double h,
    GardenTheme theme,
    double baseY,
  ) {
    final cx = w * 0.72;
    final unit = (h * 0.012).clamp(3.0, 9.0);
    final paint = Paint()
      ..color = Color.lerp(
        theme.hillBottom,
        Colors.black,
        0.30,
      )!.withValues(alpha: 0.42);

    double y = baseY;
    double halfW = unit * 3.2;
    double roofH = unit * 1.7;
    double bodyH = unit * 1.5;

    for (int tier = 0; tier < 3; tier++) {
      // Slim body wall under this tier's roof.
      canvas.drawRect(
        Rect.fromLTWH(cx - halfW * 0.55, y - bodyH, halfW * 1.1, bodyH),
        paint,
      );
      // Curved-eave roof: ridge up to the centre, eaves drooping at the ends.
      final roof = Path()
        ..moveTo(cx - halfW, y - bodyH)
        ..quadraticBezierTo(cx, y - bodyH - roofH, cx + halfW, y - bodyH)
        ..quadraticBezierTo(cx, y - bodyH + roofH * 0.22, cx - halfW, y - bodyH)
        ..close();
      canvas.drawPath(roof, paint);

      y = y - bodyH - roofH * 0.55;
      halfW *= 0.74;
      roofH *= 0.82;
      bodyH *= 0.82;
    }
    // Finial spire on top.
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, y - unit * 0.4),
        width: unit * 0.34,
        height: unit * 1.3,
      ),
      paint,
    );
    canvas.drawCircle(Offset(cx, y - unit * 1.1), unit * 0.42, paint);
  }

  /// Draws a vermilion torii gate (left) and a small cluster of evergreen
  /// pines along the hill line at [baseY]. Moderate alpha so they read as
  /// distant scenery in any theme palette.
  void _drawSceneryProps(
    Canvas canvas,
    double w,
    double h,
    GardenTheme theme,
    double baseY,
  ) {
    final unit = (h * 0.012).clamp(3.0, 9.0);

    // ── Evergreen pines (stacked triangles) ──────────────────────────────
    final pineColor = Color.lerp(
      theme.hillBottom,
      Colors.black,
      0.25,
    )!.withValues(alpha: 0.55);
    final trunkColor = const Color(0xFF5A3A22).withValues(alpha: 0.55);
    void pine(double cx, double scale) {
      final s = unit * scale;
      canvas.drawRect(
        Rect.fromLTWH(cx - s * 0.18, baseY - s * 0.9, s * 0.36, s * 0.9),
        Paint()..color = trunkColor,
      );
      for (int i = 0; i < 3; i++) {
        final tierBase = baseY - s * 0.7 - i * s * 1.1;
        final halfW = (1.7 - i * 0.45) * s;
        final tierH = 1.6 * s;
        final p = Path()
          ..moveTo(cx, tierBase - tierH)
          ..lineTo(cx - halfW, tierBase)
          ..lineTo(cx + halfW, tierBase)
          ..close();
        canvas.drawPath(p, Paint()..color = pineColor);
      }
    }

    pine(w * 0.30, 1.0);
    pine(w * 0.40, 0.78);
    pine(w * 0.88, 0.9);

    // ── Torii gate (vermilion silhouette) ────────────────────────────────
    final torii = Paint()
      ..color = const Color(0xFF9E3B2E).withValues(alpha: 0.62);
    final cx = w * 0.16;
    final gh = unit * 2.6; // gate height
    final spread = unit * 1.7; // half distance between posts
    final postW = unit * 0.42;
    final topY = baseY - gh;
    canvas.drawRect(
      Rect.fromLTWH(cx - spread - postW / 2, topY, postW, gh),
      torii,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + spread - postW / 2, topY, postW, gh),
      torii,
    );
    // Lower tie beam (nuki).
    canvas.drawRect(
      Rect.fromLTWH(
        cx - spread - unit * 0.3,
        topY + gh * 0.30,
        spread * 2 + unit * 0.6,
        unit * 0.42,
      ),
      torii,
    );
    // Top lintel (kasagi) — overhangs the posts.
    canvas.drawRect(
      Rect.fromLTWH(
        cx - spread - unit * 0.9,
        topY,
        spread * 2 + unit * 1.8,
        unit * 0.55,
      ),
      torii,
    );
  }

  @override
  bool shouldRepaint(covariant GardenBackgroundPainter old) =>
      old.themeIdx != themeIdx || old.scrollOffset != scrollOffset;
}
