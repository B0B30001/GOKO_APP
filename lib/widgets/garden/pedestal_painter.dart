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

/// Paints the 3/4-perspective "thick coin" pedestal used by the Puzzle Garden.
///
/// Cast shadow on the ground, dark side band for thickness, lighter top face
/// with a radial gradient, rim highlight on the top arc, and an inner ring
/// for the stepped Mario / Candy Crush look.
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
