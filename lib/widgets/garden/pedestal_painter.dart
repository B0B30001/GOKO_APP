import 'package:flutter/material.dart';

/// Pedestal painters for the gamified Learn and Puzzle gardens.
///
/// Two variants share a soft cast-shadow helper but render distinct shapes
/// so the player feels they're in two different worlds:
///   - [PuzzlePedestalPainter] — a 3/4-perspective "thick coin" used by the
///     Puzzle Garden level tiles (Mario / Candy Crush vibe).
///   - [LessonPedestalPainter] — a stack of book/parchment tiers used by the
///     Learn Garden lesson tiles (library / spellbook vibe).
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
    final depth = h * 0.22;
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

    // Lit top face — radial gradient from upper-left.
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.45),
        radius: 1.05,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.28)!,
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.14)!,
        ],
        stops: const [0.0, 0.58, 1.0],
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

    // Crisp outer rim for definition against busy backgrounds.
    canvas.drawRRect(
      topRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.black.withValues(alpha: 0.10),
    );
  }

  @override
  bool shouldRepaint(covariant PuzzlePedestalPainter old) =>
      old.baseColor != baseColor || old.unlocked != unlocked;
}

/// Paints a stacked book/parchment pedestal used by the Learn Garden.
///
/// Three diminishing rounded-rectangle tiers (a stack of books), each with a
/// warm parchment side band and a darker "spine" rim. The top tier carries
/// the lesson color (book cover). A faint page-edge arc along the front of
/// each tier sells the paper texture.
class LessonPedestalPainter extends CustomPainter {
  final Color baseColor;
  final bool unlocked;
  const LessonPedestalPainter({
    required this.baseColor,
    required this.unlocked,
  });

  // Warm parchment tone blended in for side bands so all worlds read as
  // wood/paper regardless of the active garden theme.
  static const _parchment = Color(0xFFE8C580);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawPedestalShadow(canvas, size, unlocked);

    // Three book tiers stacked bottom-to-top. Bottom is widest, top is the
    // "cover" with the lesson's baseColor. Each tier has a side band
    // (darker, parchment-tinted) and a flat top face.
    final tiers = <_BookTier>[
      _BookTier(
        rect: Rect.fromLTWH(w * 0.02, h * 0.60, w * 0.96, h * 0.34),
        cover: Color.lerp(baseColor, _parchment, 0.55)!,
        side: Color.lerp(baseColor, const Color(0xFF6B4423), 0.65)!,
      ),
      _BookTier(
        rect: Rect.fromLTWH(w * 0.08, h * 0.32, w * 0.84, h * 0.32),
        cover: Color.lerp(baseColor, _parchment, 0.30)!,
        side: Color.lerp(baseColor, const Color(0xFF6B4423), 0.55)!,
      ),
      _BookTier(
        rect: Rect.fromLTWH(w * 0.16, h * 0.04, w * 0.68, h * 0.32),
        cover: baseColor,
        side: Color.lerp(baseColor, Colors.black, 0.45)!,
      ),
    ];

    for (final tier in tiers) {
      _paintBookTier(canvas, tier);
    }
  }

  void _paintBookTier(Canvas canvas, _BookTier tier) {
    final r = tier.rect;
    final radius = Radius.circular(r.height * 0.18);

    // Side / "spine" band — slightly taller than the cover and offset down,
    // gives a 3D thickness suggestion.
    final sideRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(r.left, r.top + r.height * 0.55, r.width, r.height * 0.55),
      radius,
    );
    canvas.drawRRect(sideRect, Paint()..color = tier.side);

    // Top cover face.
    final coverRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.72),
      radius,
    );
    final coverPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(tier.cover, Colors.white, 0.18)!,
          tier.cover,
          Color.lerp(tier.cover, Colors.black, 0.12)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(coverRect.outerRect);
    canvas.drawRRect(coverRect, coverPaint);

    // Thin highlight along the very top edge — the "glossy book cover" gleam.
    canvas.drawLine(
      Offset(r.left + r.width * 0.12, r.top + 1.5),
      Offset(r.right - r.width * 0.12, r.top + 1.5),
      Paint()
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.45),
    );

    // Page-edge hairlines along the front of the side band — sells "stack of
    // paper" texture. Two thin lines, slightly offset.
    final pageY1 = r.top + r.height * 0.78;
    final pageY2 = r.top + r.height * 0.88;
    final pagePaint = Paint()
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawLine(
      Offset(r.left + r.width * 0.08, pageY1),
      Offset(r.right - r.width * 0.08, pageY1),
      pagePaint,
    );
    canvas.drawLine(
      Offset(r.left + r.width * 0.10, pageY2),
      Offset(r.right - r.width * 0.10, pageY2),
      pagePaint,
    );
  }

  @override
  bool shouldRepaint(covariant LessonPedestalPainter old) =>
      old.baseColor != baseColor || old.unlocked != unlocked;
}

class _BookTier {
  final Rect rect;
  final Color cover;
  final Color side;
  const _BookTier({
    required this.rect,
    required this.cover,
    required this.side,
  });
}
