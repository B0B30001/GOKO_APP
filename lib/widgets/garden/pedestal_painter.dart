import 'package:flutter/material.dart';

/// Paints the 3/4-perspective level pedestal used by the gamified maps.
///
/// Renders a "thick coin viewed from slightly above" — cast shadow on the
/// ground, dark side band for thickness, lighter top face with a soft radial
/// gradient, rim highlight on the top arc, and an inner ring for the
/// Mario/Candy Crush "stepped pedestal" look.
///
/// Used by both the Puzzle Garden (level tiles) and Learn Garden (lesson
/// tiles). The `baseColor` typically comes from the active GardenTheme.
class PedestalPainter extends CustomPainter {
  final Color baseColor;
  final bool unlocked;
  const PedestalPainter({required this.baseColor, required this.unlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cast shadow on the ground (under the pedestal). Wider than the
    // pedestal so it reads as ambient occlusion.
    final shadowRect = Rect.fromLTWH(w * 0.08, h * 0.88, w * 0.84, h * 0.18);
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = Colors.black.withValues(alpha: unlocked ? 0.30 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Side band — darker shade, visible as the "thickness" of the coin.
    final sideRect = Rect.fromLTWH(0, h * 0.30, w, h * 0.70);
    final sideColor = Color.lerp(baseColor, Colors.black, 0.42)!;
    canvas.drawOval(sideRect, Paint()..color = sideColor);

    // Top face — slightly smaller oval, sits on the upper portion of the
    // pedestal. Radial gradient lit from upper-left.
    final topRect = Rect.fromLTWH(0, 0, w, h * 0.62);
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.95,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.20)!,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.18)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(topRect);
    canvas.drawOval(topRect, topPaint);

    // Rim highlight along the top edge — thin arc of light.
    final rimRect = Rect.fromLTWH(w * 0.06, h * 0.02, w * 0.88, h * 0.38);
    canvas.drawArc(
      rimRect,
      3.14, // π — start from left
      3.14, // sweep 180° (top half only)
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // Inner ring on the top face — gives the "stepped pedestal" / power-up
    // platform look reminiscent of Mario / Candy Crush map tiles.
    final innerRect = Rect.fromLTWH(w * 0.20, h * 0.10, w * 0.60, h * 0.42);
    canvas.drawOval(
      innerRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant PedestalPainter old) =>
      old.baseColor != baseColor || old.unlocked != unlocked;
}
