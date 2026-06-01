import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'garden_theme.dart';

/// Full-screen procedural backdrop for the gamified gardens.
///
/// Drawn as a proper layered scene — sky, clouds, mountains, world-specific
/// motifs, an isometric stone courtyard floor — so tiles feel grounded in a
/// real place. Each of the 5 worlds has distinct colours, shapes and motifs.
/// Parallax is applied per layer so the scene feels alive as the user scrolls.
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

  @override
  void paint(Canvas canvas, Size size) {
    final t = themeIdx.clamp(0, gardenThemes.length - 1);
    final theme = gardenThemes[t];
    final w = size.width;
    final h = size.height;

    // Parallax offsets per depth layer.
    final skyOff = scrollOffset * 0.06;
    final cloudOff = scrollOffset * 0.14;
    final mtnFarOff = scrollOffset * 0.22;
    final mtnNearOff = scrollOffset * 0.38;
    final groundOff = scrollOffset * 0.70;

    // ── 1. Sky ──────────────────────────────────────────────────────────────
    _drawSky(canvas, w, h, theme, t, skyOff);

    // ── 2. Sun / moon ───────────────────────────────────────────────────────
    _drawSun(canvas, w, h, t, skyOff);

    // ── 3. Clouds ───────────────────────────────────────────────────────────
    _drawClouds(canvas, w, h, t, cloudOff);

    // ── 4. Far mountains ────────────────────────────────────────────────────
    _drawMountains(canvas, w, h, theme, t, mtnFarOff, mtnNearOff);

    // ── 5. World-specific mid-ground motifs ─────────────────────────────────
    _drawWorldMotifs(canvas, w, h, t, theme, mtnNearOff);

    // ── 6. Ground & isometric courtyard floor ───────────────────────────────
    _drawGround(canvas, w, h, theme, t, groundOff);

    // ── 7. Vignette frame ───────────────────────────────────────────────────
    _drawVignette(canvas, w, h);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sky
  // ─────────────────────────────────────────────────────────────────────────

  void _drawSky(
    Canvas canvas,
    double w,
    double h,
    GardenTheme theme,
    int t,
    double off,
  ) {
    final rect = Rect.fromLTWH(0, -off, w, h * 0.70 + off);
    // Richer 3-stop gradients per world.
    final colors = switch (t) {
      0 => [
        const Color(0xFFF7E8D4), // warm dawn peach at top
        const Color(0xFFB8DCF5), // soft sky blue mid
        const Color(0xFFDFF2D8), // pale green at horizon
      ],
      1 => [
        const Color(0xFF0B0B2A),
        const Color(0xFF1A1060),
        const Color(0xFF2D1B6E),
      ],
      2 => [
        const Color(0xFFFB923C),
        const Color(0xFFF97316),
        const Color(0xFFFFBF60),
      ],
      3 => [
        const Color(0xFFDCF0FB),
        const Color(0xFFB3D9F5),
        const Color(0xFFE8F5FF),
      ],
      _ => [
        const Color(0xFF1B4332),
        const Color(0xFF2D6A4F),
        const Color(0xFF52B788),
      ],
    };
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.50, 1.0],
        ).createShader(rect),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sun / moon
  // ─────────────────────────────────────────────────────────────────────────

  void _drawSun(Canvas canvas, double w, double h, int t, double off) {
    final cx = w * 0.76;
    final cy = h * 0.14 - off;
    final r = w * 0.09;

    if (t == 1) {
      // Crystal Cave — full moon, cool glow.
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = const Color(0xFFE8E0FF),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        r * 1.8,
        Paint()
          ..color = const Color(0x335C4D9E)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    } else {
      // Sun — warm glow disc.
      final sunColor = switch (t) {
        2 => const Color(0xFFFFF176),
        3 => const Color(0xFFFFFFFF),
        4 => const Color(0xFFA5D6A7),
        _ => const Color(0xFFFFF9C4),
      };
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [sunColor, sunColor.withValues(alpha: 0.0)],
            stops: const [0.55, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
      // Outer soft halo.
      canvas.drawCircle(
        Offset(cx, cy),
        r * 2.4,
        Paint()
          ..color = sunColor.withValues(alpha: 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clouds — proper rounded blob shapes, not gradients
  // ─────────────────────────────────────────────────────────────────────────

  void _drawClouds(Canvas canvas, double w, double h, int t, double off) {
    if (t == 4) {
      // Jade Highlands — low mist bands instead of distinct clouds.
      for (int i = 0; i < 3; i++) {
        final y = h * (0.28 + i * 0.07) - off;
        final mist = Rect.fromLTWH(0, y, w, h * 0.05);
        canvas.drawRect(
          mist,
          Paint()
            ..shader = LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(mist),
        );
      }
      return;
    }

    final cloudColor = switch (t) {
      1 => const Color(0x883A2D8C),
      2 => const Color(0xCCFEB47B),
      3 => const Color(0xFFFFFFFF),
      _ => const Color(0xFFFFFFFF),
    };
    final alpha = t == 1 ? 0.45 : (t == 2 ? 0.70 : 0.88);

    // Three cloud groups at different heights and x positions.
    final groups = [
      (w * 0.10, h * 0.12 - off, w * 0.28),
      (w * 0.55, h * 0.19 - off, w * 0.22),
      (w * 0.75, h * 0.08 - off, w * 0.18),
    ];

    for (final (cx, cy, span) in groups) {
      _drawCloudBlob(canvas, cx, cy, span, cloudColor.withValues(alpha: alpha));
    }
  }

  void _drawCloudBlob(
    Canvas canvas,
    double cx,
    double cy,
    double span,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final r = span * 0.22;
    // Five overlapping circles → classic fluffy cloud.
    final offsets = [
      Offset(cx, cy),
      Offset(cx - span * 0.28, cy + r * 0.4),
      Offset(cx + span * 0.28, cy + r * 0.4),
      Offset(cx - span * 0.48, cy + r * 0.75),
      Offset(cx + span * 0.48, cy + r * 0.75),
    ];
    final radii = [r * 1.1, r * 0.9, r * 0.9, r * 0.75, r * 0.75];
    for (int i = 0; i < offsets.length; i++) {
      canvas.drawCircle(offsets[i], radii[i], paint);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mountains — 2 layers, per-world shapes
  // ─────────────────────────────────────────────────────────────────────────

  void _drawMountains(
    Canvas canvas,
    double w,
    double h,
    GardenTheme theme,
    int t,
    double farOff,
    double nearOff,
  ) {
    // Far range — lighter, fewer peaks.
    _drawRidge(
      canvas,
      w,
      h,
      baseY: h * 0.42 - farOff,
      peakCount: t == 1 ? 3 : 4,
      amplitude: h * 0.12,
      color: t == 1
          ? const Color(0xFF1E1660).withValues(alpha: 0.7)
          : Color.lerp(
              theme.skyBottom,
              theme.hillTop,
              0.35,
            )!.withValues(alpha: 0.55),
    );
    // Near range — darker, more defined.
    _drawRidge(
      canvas,
      w,
      h,
      baseY: h * 0.52 - nearOff,
      peakCount: t == 1 ? 4 : 5,
      amplitude: h * 0.14,
      color: t == 1
          ? const Color(0xFF150F55).withValues(alpha: 0.9)
          : theme.hillTop.withValues(alpha: 0.85),
    );
  }

  void _drawRidge(
    Canvas canvas,
    double w,
    double h, {
    required double baseY,
    required int peakCount,
    required double amplitude,
    required Color color,
  }) {
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, baseY);
    final dx = w / peakCount;
    double x = 0;
    for (int i = 0; i < peakCount; i++) {
      final px = x + dx * 0.5;
      final py = baseY - amplitude * (0.7 + 0.3 * ((i * 7 + 3) % 5) / 4.0);
      final endX = x + dx;
      path.quadraticBezierTo(px, py, endX, baseY);
      x = endX;
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // World-specific mid-ground motifs
  // ─────────────────────────────────────────────────────────────────────────

  void _drawWorldMotifs(
    Canvas canvas,
    double w,
    double h,
    int t,
    GardenTheme theme,
    double off,
  ) {
    final baseY = h * 0.56 - off;
    switch (t) {
      case 0:
        _drawSakuraTrees(canvas, w, h, baseY);
        _drawTorii(canvas, w, h, baseY);
      case 1:
        _drawCrystals(canvas, w, h, baseY);
      case 2:
        _drawMapleTrees(canvas, w, h, baseY);
      case 3:
        _drawIceFormations(canvas, w, h, baseY);
      default:
        _drawBamboo(canvas, w, h, baseY);
    }
  }

  // ── Sakura trees (World 0) ────────────────────────────────────────────────
  void _drawSakuraTrees(Canvas canvas, double w, double h, double baseY) {
    void tree(double cx, double scale) {
      final th = h * 0.16 * scale;
      final tw = w * 0.016 * scale;
      // Trunk.
      canvas.drawRect(
        Rect.fromLTWH(cx - tw / 2, baseY - th, tw, th),
        Paint()..color = const Color(0xFF8B5A2B).withValues(alpha: 0.75),
      );
      // Blossom canopy — layered circles.
      final bPaint = Paint()
        ..color = const Color(0xFFF48FAB).withValues(alpha: 0.80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final br = w * 0.09 * scale;
      canvas.drawCircle(Offset(cx, baseY - th - br * 0.55), br, bPaint);
      canvas.drawCircle(
        Offset(cx - br * 0.6, baseY - th - br * 0.2),
        br * 0.75,
        bPaint,
      );
      canvas.drawCircle(
        Offset(cx + br * 0.6, baseY - th - br * 0.2),
        br * 0.75,
        bPaint,
      );
      // Highlight on top.
      canvas.drawCircle(
        Offset(cx, baseY - th - br * 0.85),
        br * 0.45,
        Paint()
          ..color = const Color(0xFFFFC0CB).withValues(alpha: 0.50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    tree(w * 0.18, 1.0);
    tree(w * 0.35, 0.75);
    tree(w * 0.82, 0.85);
  }

  // ── Torii gate (World 0) ─────────────────────────────────────────────────
  void _drawTorii(Canvas canvas, double w, double h, double baseY) {
    final paint = Paint()
      ..color = const Color(0xFFB03A2E).withValues(alpha: 0.82);
    final gh = h * 0.16;
    final cx = w * 0.62;
    final spread = w * 0.06;
    final pw = w * 0.018;

    // Two posts.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - spread - pw / 2, baseY - gh, pw, gh),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + spread - pw / 2, baseY - gh, pw, gh),
        const Radius.circular(2),
      ),
      paint,
    );
    // Lower tie beam.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - spread - pw,
          baseY - gh * 0.60,
          spread * 2 + pw * 2,
          pw * 0.9,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    // Top lintel with slight upward curves.
    final lintel = Path();
    final lw = spread * 2.4 + pw * 2;
    final lh = pw * 1.1;
    lintel
      ..moveTo(cx - lw / 2, baseY - gh + lh * 0.3)
      ..quadraticBezierTo(
        cx,
        baseY - gh - lh,
        cx + lw / 2,
        baseY - gh + lh * 0.3,
      )
      ..lineTo(cx + lw / 2, baseY - gh + lh * 1.3)
      ..quadraticBezierTo(cx, baseY - gh, cx - lw / 2, baseY - gh + lh * 1.3)
      ..close();
    canvas.drawPath(lintel, paint);
  }

  // ── Crystal formations (World 1) ─────────────────────────────────────────
  void _drawCrystals(Canvas canvas, double w, double h, double baseY) {
    final positions = [
      (w * 0.12, 1.0, const Color(0xFF7B68EE)),
      (w * 0.28, 0.7, const Color(0xFF9B59B6)),
      (w * 0.68, 1.15, const Color(0xFF6C5CE7)),
      (w * 0.82, 0.65, const Color(0xFF8E44AD)),
      (w * 0.50, 0.5, const Color(0xFFAA99FF)),
    ];
    for (final (cx, scale, col) in positions) {
      _drawCrystal(canvas, cx, baseY, h * 0.18 * scale, col);
    }
  }

  void _drawCrystal(
    Canvas canvas,
    double cx,
    double baseY,
    double ch,
    Color col,
  ) {
    final cw = ch * 0.28;
    final crystal = Path()
      ..moveTo(cx, baseY - ch)
      ..lineTo(cx - cw, baseY - ch * 0.35)
      ..lineTo(cx - cw * 0.6, baseY)
      ..lineTo(cx + cw * 0.6, baseY)
      ..lineTo(cx + cw, baseY - ch * 0.35)
      ..close();
    canvas.drawPath(crystal, Paint()..color = col.withValues(alpha: 0.65));
    // Bright face highlight.
    final face = Path()
      ..moveTo(cx, baseY - ch)
      ..lineTo(cx + cw * 0.15, baseY - ch * 0.35)
      ..lineTo(cx + cw * 0.5, baseY - ch * 0.4)
      ..close();
    canvas.drawPath(
      face,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    // Glow.
    canvas.drawCircle(
      Offset(cx, baseY - ch * 0.55),
      cw * 1.5,
      Paint()
        ..color = col.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  // ── Maple trees (World 2) ─────────────────────────────────────────────────
  void _drawMapleTrees(Canvas canvas, double w, double h, double baseY) {
    void maple(double cx, double scale) {
      final th = h * 0.18 * scale;
      final tw = w * 0.016 * scale;
      canvas.drawRect(
        Rect.fromLTWH(cx - tw / 2, baseY - th, tw, th),
        Paint()..color = const Color(0xFF5D3A1A).withValues(alpha: 0.80),
      );
      // Fan-shaped foliage in amber/red.
      final layers = [
        (0.0, 1.0, const Color(0xFFE65100)),
        (-0.5, 0.75, const Color(0xFFFF6D00)),
        (0.5, 0.75, const Color(0xFFD84315)),
        (0.0, 0.5, const Color(0xFFFFB300)),
      ];
      final br = w * 0.10 * scale;
      for (final (dx, s, col) in layers) {
        canvas.drawCircle(
          Offset(cx + br * dx * 0.6, baseY - th - br * s * 0.3),
          br * s,
          Paint()
            ..color = col.withValues(alpha: 0.75)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    maple(w * 0.20, 1.0);
    maple(w * 0.72, 0.80);
    maple(w * 0.88, 0.60);
  }

  // ── Ice formations (World 3) ──────────────────────────────────────────────
  void _drawIceFormations(Canvas canvas, double w, double h, double baseY) {
    final icePaint = Paint()
      ..color = const Color(0xFFB3E5FC).withValues(alpha: 0.70);
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.55);

    void icicle(double cx, double height, double width) {
      final path = Path()
        ..moveTo(cx - width / 2, baseY)
        ..lineTo(cx - width * 0.15, baseY - height)
        ..lineTo(cx + width * 0.15, baseY - height)
        ..lineTo(cx + width / 2, baseY)
        ..close();
      canvas.drawPath(path, icePaint);
      canvas.drawLine(
        Offset(cx - width * 0.1, baseY - height * 0.8),
        Offset(cx + width * 0.05, baseY - height * 0.3),
        shinePaint..strokeWidth = width * 0.12,
      );
    }

    final spikes = [
      (w * 0.10, h * 0.20, w * 0.07),
      (w * 0.22, h * 0.14, w * 0.05),
      (w * 0.32, h * 0.17, w * 0.06),
      (w * 0.65, h * 0.22, w * 0.08),
      (w * 0.78, h * 0.13, w * 0.05),
      (w * 0.88, h * 0.18, w * 0.07),
    ];
    for (final (cx, hh, ww) in spikes) {
      icicle(cx, hh, ww);
    }
  }

  // ── Bamboo (World 4) ──────────────────────────────────────────────────────
  void _drawBamboo(Canvas canvas, double w, double h, double baseY) {
    void stalk(double cx, double height, double width) {
      final stalks = [
        const Color(0xFF2D6A4F),
        const Color(0xFF40916C),
        const Color(0xFF52B788),
      ];
      // Stalk segments.
      for (int i = 0; i < 5; i++) {
        final segH = height / 5;
        final y = baseY - i * segH;
        canvas.drawRect(
          Rect.fromLTWH(cx - width / 2, y - segH, width, segH * 0.94),
          Paint()..color = stalks[i % stalks.length].withValues(alpha: 0.85),
        );
        // Node ring.
        canvas.drawRect(
          Rect.fromLTWH(
            cx - width * 0.65,
            y - width * 0.35,
            width * 1.3,
            width * 0.35,
          ),
          Paint()..color = const Color(0xFF1B4332).withValues(alpha: 0.60),
        );
      }
      // Top leaves.
      final leafPaint = Paint()
        ..color = const Color(0xFF52B788).withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      for (int i = 0; i < 4; i++) {
        final angle = math.pi * 0.3 * i - math.pi * 0.4;
        final lx = cx + math.cos(angle) * width * 2.5;
        final ly = (baseY - height) + math.sin(angle) * width * 2.5;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(lx, ly),
            width: width * 4,
            height: width * 1.2,
          ),
          leafPaint,
        );
      }
    }

    final canes = [
      (w * 0.12, h * 0.28, w * 0.022),
      (w * 0.20, h * 0.24, w * 0.018),
      (w * 0.28, h * 0.30, w * 0.020),
      (w * 0.70, h * 0.26, w * 0.020),
      (w * 0.78, h * 0.32, w * 0.024),
      (w * 0.86, h * 0.24, w * 0.018),
    ];
    for (final (cx, ch, cw) in canes) {
      stalk(cx, ch, cw);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ground + isometric courtyard
  // ─────────────────────────────────────────────────────────────────────────

  void _drawGround(
    Canvas canvas,
    double w,
    double h,
    GardenTheme theme,
    int t,
    double off,
  ) {
    final groundY = h * 0.60 - off;

    // Ground fill gradient.
    final groundColors = switch (t) {
      0 => [const Color(0xFFE8D5B7), const Color(0xFFD4B896)], // warm stone
      1 => [const Color(0xFF16103A), const Color(0xFF0B0822)], // deep dark
      2 => [const Color(0xFF8B4513), const Color(0xFF6B3310)], // copper earth
      3 => [const Color(0xFFCEE5F5), const Color(0xFFADD8E6)], // icy blue
      _ => [const Color(0xFF1A4731), const Color(0xFF103726)], // dark jade
    };
    final groundRect = Rect.fromLTWH(0, groundY, w, h - groundY + 60);
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: groundColors,
        ).createShader(groundRect),
    );

    // Isometric tile floor — diamond grid so tiles appear to sit on a paved
    // courtyard rather than floating on a flat gradient. Subtler on dark worlds.
    _drawIsoFloor(canvas, w, h, t, groundY);

    // Water/pond feature at the very base.
    _drawPond(canvas, w, h, t, off);
  }

  void _drawIsoFloor(Canvas canvas, double w, double h, int t, double groundY) {
    final tileAlpha = switch (t) {
      1 => 0.08,
      2 => 0.10,
      4 => 0.09,
      _ => 0.14,
    };
    final tileColor = switch (t) {
      1 => Colors.white,
      3 => Colors.white,
      _ => Colors.white,
    };

    final lineP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = tileColor.withValues(alpha: tileAlpha);

    // Horizontal lines (perspective-compressed).
    final rows = 12;
    final rowH = (h - groundY + 40) / rows;
    for (int i = 0; i <= rows; i++) {
      final y = groundY + i * rowH;
      // Perspective: lines converge toward center.
      final shrink = i.toDouble() / rows;
      final x0 = w * 0 - w * 0.1 * shrink;
      final x1 = w * 1 + w * 0.1 * shrink;
      canvas.drawLine(Offset(x0, y), Offset(x1, y), lineP);
    }

    // Vertical lines at an angle to fake isometric depth.
    final cols = 9;
    final colW = w / cols;
    for (int i = -2; i <= cols + 2; i++) {
      final xBase = i * colW;
      canvas.drawLine(
        Offset(xBase, groundY),
        Offset(xBase + w * 0.08, h + 40),
        lineP,
      );
    }

    // Subtle shading on alternating tiles.
    if (t != 1) {
      final tileShade = Paint()..color = Colors.black.withValues(alpha: 0.03);
      for (int r = 0; r < rows; r++) {
        for (int c = -2; c < cols + 2; c++) {
          if ((r + c) % 2 == 0) {
            final y0 = groundY + r * rowH;
            final x0l = c * colW + r * colW * 0.08 / rows;
            final x0r = (c + 1) * colW + r * colW * 0.08 / rows;
            final y1 = y0 + rowH;
            final x1l = c * colW + (r + 1) * colW * 0.08 / rows;
            final x1r = (c + 1) * colW + (r + 1) * colW * 0.08 / rows;
            final path = Path()
              ..moveTo(x0l, y0)
              ..lineTo(x0r, y0)
              ..lineTo(x1r, y1)
              ..lineTo(x1l, y1)
              ..close();
            canvas.drawPath(path, tileShade);
          }
        }
      }
    }
  }

  void _drawPond(Canvas canvas, double w, double h, int t, double off) {
    final pondY = h * 0.88 - off * 0.2;
    if (pondY > h) return;

    final pondColor = switch (t) {
      0 => const Color(0xFF7EC8E3).withValues(alpha: 0.55),
      1 => const Color(0xFF1A0E6B).withValues(alpha: 0.70),
      2 => const Color(0xFF8B4513).withValues(alpha: 0.40),
      3 => const Color(0xFFADD8E6).withValues(alpha: 0.65),
      _ => const Color(0xFF004D40).withValues(alpha: 0.60),
    };

    final pondRect = Rect.fromLTWH(0, pondY, w, h - pondY + 40);
    canvas.drawRect(
      pondRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pondColor.withValues(alpha: 0.0), pondColor],
        ).createShader(pondRect),
    );

    // Ripple lines.
    if (t != 1) {
      final ripple = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.18);
      canvas.drawLine(
        Offset(w * 0.10, pondY + (h - pondY) * 0.4),
        Offset(w * 0.45, pondY + (h - pondY) * 0.4),
        ripple,
      );
      canvas.drawLine(
        Offset(w * 0.55, pondY + (h - pondY) * 0.65),
        Offset(w * 0.88, pondY + (h - pondY) * 0.65),
        ripple,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vignette
  // ─────────────────────────────────────────────────────────────────────────

  void _drawVignette(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.28),
          ],
          stops: const [0.0, 0.60, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant GardenBackgroundPainter old) =>
      old.themeIdx != themeIdx || old.scrollOffset != scrollOffset;
}
