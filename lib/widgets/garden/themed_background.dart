import 'dart:math' as math;

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
/// the asset isn't bundled, falls back to the procedural
/// [GardenBackgroundPainter] so the screen always has something to render.
///
/// To swap a background in: drop `assets/backgrounds/<theme>.png` into the
/// repo (see `assets/backgrounds/README.md`). No code change needed.
class ThemedBackground extends StatelessWidget {
  final int themeIdx;
  const ThemedBackground({super.key, required this.themeIdx});

  String get _assetPath {
    final name =
        _themeAssetNames[themeIdx.clamp(0, _themeAssetNames.length - 1)];
    return 'assets/backgrounds/$name.png';
  }

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      painter: GardenBackgroundPainter(themeIdx: themeIdx),
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

/// Procedural background painter (fallback when no PNG asset is bundled).
///
/// Draws a sky gradient, a soft sun/moon halo, three layered mountain ridges,
/// mid-ground rolling hills, and a foreground ground band with grass speckles.
/// All colours come from the [gardenThemes] entry for [themeIdx].
class GardenBackgroundPainter extends CustomPainter {
  final int themeIdx;
  const GardenBackgroundPainter({required this.themeIdx});

  @override
  void paint(Canvas canvas, Size size) {
    final theme = gardenThemes[themeIdx.clamp(0, gardenThemes.length - 1)];
    final w = size.width;
    final h = size.height;

    // Sky gradient — soft three-stop blend for natural light depth.
    final skyMid = Color.lerp(theme.skyTop, theme.skyBottom, 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.skyTop, skyMid, theme.skyBottom],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Soft sun/moon halo near the upper-right — adds focal light without
    // looking like a hard disc.
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.16),
      80,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(w * 0.78, h * 0.16), radius: 80),
            )
        ..blendMode = BlendMode.plus,
    );

    // Three layered mountain ridges with cubic-Bezier silhouettes.
    for (int layer = 0; layer < 3; layer++) {
      final yBase = h * (0.30 + layer * 0.08);
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

    // Mid-ground rolling hills — quadratic Bezier curves.
    final hills = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.62);
    const hillPeaks = 5;
    final hdx = w / hillPeaks;
    double prevX = 0;
    for (int p = 0; p < hillPeaks; p++) {
      final endX = prevX + hdx;
      final midX = prevX + hdx / 2;
      final dip = h * 0.62 - (p.isEven ? 28.0 : 18.0);
      hills.quadraticBezierTo(midX, dip, endX, h * 0.62);
      prevX = endX;
    }
    hills
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hills, Paint()..color = theme.hillTop);

    // Foreground ground band gradient.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.74, w, h * 0.26),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.hillTop, theme.hillBottom],
        ).createShader(Rect.fromLTWH(0, h * 0.74, w, h * 0.26)),
    );

    // Subtle ground-line speckles.
    final speckle = Paint()..color = theme.hillBottom.withValues(alpha: 0.4);
    final speckleRng = math.Random(themeIdx * 13 + 5);
    for (int i = 0; i < 40; i++) {
      final sx = speckleRng.nextDouble() * w;
      final sy = h * 0.76 + speckleRng.nextDouble() * (h * 0.22);
      canvas.drawCircle(
        Offset(sx, sy),
        0.8 + speckleRng.nextDouble() * 1.4,
        speckle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GardenBackgroundPainter old) =>
      old.themeIdx != themeIdx;
}
