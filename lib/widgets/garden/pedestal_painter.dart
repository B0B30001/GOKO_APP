import 'package:flutter/material.dart';

/// Claymorphism tile painter shared by both gamified gardens.
///
/// Per the ui-ux-pro-max design system recommendation for "gamified puzzle apps":
/// clay-style, soft, bubbly, highly rounded tiles with multi-layer shadows that
/// give a physical, pressable feel — not a flat card and not a heavy 3D coin.
///
/// Layers (back to front):
///   1. Coloured drop shadow (large, soft, same hue as tile) — the "clay" depth
///   2. Dark bottom edge (~8% of height) — the "under-surface" of the clay disc
///   3. Main tile face (very round, slightly lighter than base)
///   4. Inner highlight stroke — white arc at top, fades to transparent at sides
///   5. Outer white hairline — lifts tile off the scenery
class PuzzlePedestalPainter extends CustomPainter {
  final Color baseColor;
  final bool unlocked;

  const PuzzlePedestalPainter({
    required this.baseColor,
    required this.unlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Very round pill/disc geometry — claymorphism uses borderRadius 40-50%
    // of the shorter dimension so tiles feel like physical buttons, not cards.
    final radius = Radius.circular(w * 0.40);
    // Face occupies the upper 68% of the allocated height; the bottom 32% is
    // breathing room for the clay shadow that "grounds" the tile.
    final faceRect = Rect.fromLTWH(w * 0.06, h * 0.02, w * 0.88, h * 0.68);
    final faceRRect = RRect.fromRectAndRadius(faceRect, radius);

    final alpha = unlocked ? 1.0 : 0.55;

    // ── Layer 1: Clay drop shadow ─────────────────────────────────────────
    // A single large, coloured, blurred oval below and slightly behind the
    // face — the defining "clay" depth cue that makes the tile feel physical.
    final shadowColor = Color.lerp(
      baseColor,
      Colors.black,
      0.38,
    )!.withValues(alpha: unlocked ? 0.55 : 0.25);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.10, faceRect.bottom - h * 0.04, w * 0.80, h * 0.22),
      Paint()
        ..color = shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // ── Layer 2: Bottom edge "rim" ────────────────────────────────────────
    // A slightly darker, slightly lower rrect — simulates the underside of
    // a thick clay disc (avoids any sharp extrusion / coin look).
    final rimColor = Color.lerp(
      baseColor,
      Colors.black,
      0.34,
    )!.withValues(alpha: alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect.translate(0, h * 0.055), radius),
      Paint()..color = rimColor,
    );

    // ── Layer 3: Main face ────────────────────────────────────────────────
    // Slightly lightened at the top-centre so it catches imaginary overhead
    // light — the "puffy" clay look. Very subtle gradient; mostly flat.
    final faceTopColor = Color.lerp(
      baseColor,
      Colors.white,
      0.22,
    )!.withValues(alpha: alpha);
    final faceBotColor = Color.lerp(
      baseColor,
      Colors.black,
      0.06,
    )!.withValues(alpha: alpha);
    canvas.drawRRect(
      faceRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [faceTopColor, faceBotColor],
          stops: const [0.0, 1.0],
        ).createShader(faceRect),
    );

    // ── Layer 4: Inner highlight arc ──────────────────────────────────────
    // A thin white stroke that hugs the top portion of the tile — the
    // specular "catch light" that sells the clay/ceramic material feel.
    canvas.save();
    canvas.clipRRect(faceRRect);
    final hlRect = faceRect.deflate(w * 0.055);
    canvas.drawArc(
      Rect.fromLTWH(
        hlRect.left,
        hlRect.top,
        hlRect.width,
        hlRect.height * 0.70,
      ),
      3.14, // start from left
      3.14, // sweep 180° (top half only)
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.restore();

    // ── Layer 5: Outer hairline ───────────────────────────────────────────
    // A crisp white ring around the face at full opacity — makes the tile
    // pop cleanly off any background without heavy borders.
    canvas.drawRRect(
      faceRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: unlocked ? 0.50 : 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant PuzzlePedestalPainter old) =>
      old.baseColor != baseColor || old.unlocked != unlocked;
}
