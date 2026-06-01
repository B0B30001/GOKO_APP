import 'package:flutter/material.dart';

/// Tile pedestal painter shared by the gamified Learn and Puzzle gardens.
///
/// [PuzzlePedestalPainter] renders one clean "jade paver": a rounded-square top
/// face with a thin extruded edge, a soft cast shadow, a subtle bevel highlight,
/// and a white outer hairline so it reads cleanly over illustrated scenery.
/// Both gardens use the same painter so the maps share one tile language.
///
/// `baseColor` typically comes from the active GardenTheme; `unlocked`
/// dims/darkens the shadow when the tile isn't yet reachable.

/// Soft elliptical ambient-occlusion shadow on the ground below a pedestal.
/// Shared between both painter variants so they ground-attach the same way.
void _drawPedestalShadow(Canvas canvas, Size size, bool unlocked) {
  final w = size.width;
  final h = size.height;
  final shadowRect = Rect.fromLTWH(w * 0.08, h * 0.88, w * 0.84, h * 0.18);
  canvas.drawOval(
    shadowRect,
    Paint()
      ..color = Colors.black.withValues(alpha: unlocked ? 0.30 : 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
  );
}

/// Paints an extruded rounded-square "stone tile" pedestal used by the Puzzle
/// Garden — the look of the Gemini garden mockups (Candy Crush / chess.com
/// learning-path tiles).
///
/// Composition (back-to-front): ground cast shadow, a single extruded
/// silhouette filled with the dark side colour (top rrect ∪ a copy shifted
/// down by `depth`), then the lit top face with a top-left radial gradient, a
/// bevel highlight tracing the top + upper sides, and a faint inset for the
/// "carved stone" rim.
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

    _drawPedestalShadow(canvas, size, unlocked);

    // Top face geometry — a rounded square in the upper portion so the screen's
    // number/icon (anchored ~0.30h from the bottom) lands on the lit face.
    final radius = Radius.circular(w * 0.24);
    final topRect = Rect.fromLTWH(w * 0.10, h * 0.02, w * 0.80, h * 0.62);
    final topRRect = RRect.fromRectAndRadius(topRect, radius);

    // Extrusion: an identical rrect shifted down. The union of the two is the
    // full side-wall silhouette (they overlap since depth < face height).
    // Kept thin (flat-design per ui-ux-pro-max) — a clean paver with a hint of
    // edge, not a heavy 3D coin.
    final depth = h * 0.12;
    final sideRRect = RRect.fromRectAndRadius(
      topRect.translate(0, depth),
      radius,
    );
    final sideColor = Color.lerp(baseColor, Colors.black, 0.46)!;
    final silhouette = Path.combine(
      PathOperation.union,
      Path()..addRRect(topRRect),
      Path()..addRRect(sideRRect),
    );
    canvas.drawPath(silhouette, Paint()..color = sideColor);

    // A subtle vertical gradient on the side wall to round the extrusion.
    canvas.drawPath(
      silhouette,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.18),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5)),
    );

    // Lit top face — soft, near-flat gradient (subtle top-left light) for a
    // calm premium read rather than a glossy bubble.
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.45),
        radius: 1.05,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.16)!,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.08)!,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(topRect);
    canvas.drawRRect(topRRect, topPaint);

    // Bevel highlight — a bright stroke along the top and upper-side edges.
    final bevel = RRect.fromRectAndRadius(
      topRect.deflate(w * 0.04),
      Radius.circular(w * 0.20),
    );
    canvas.save();
    canvas.clipRRect(topRRect);
    canvas.drawRRect(
      bevel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.restore();

    // Subtle white outer hairline so the node pops cleanly on busy
    // illustrated scenery without adding visual bulk.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        topRect.inflate(1.3),
        Radius.circular(w * 0.24 + 1.3),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // Crisp dark inner rim for definition against busy backgrounds.
    canvas.drawRRect(
      topRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.black.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant PuzzlePedestalPainter old) =>
      old.baseColor != baseColor || old.unlocked != unlocked;
}
