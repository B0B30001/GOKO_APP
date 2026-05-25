import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Layered ambient overlay that softens the painted environment so it reads
/// as a living scene rather than flat geometry. Each theme band has its own
/// drifting motifs — petals in the forest, sparkles in the cave, embers in
/// the peaks, snowflakes on the tundra, leaves in the highlands.
class AmbientDecorations extends StatefulWidget {
  final int themeIdx;
  const AmbientDecorations({super.key, required this.themeIdx});

  @override
  State<AmbientDecorations> createState() => _AmbientDecorationsState();
}

class _AmbientDecorationsState extends State<AmbientDecorations>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _AmbientPainter(themeIdx: widget.themeIdx, t: _ctrl.value),
        );
      },
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final int themeIdx;
  final double t;
  const _AmbientPainter({required this.themeIdx, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Clouds drift gently across all themes — varying opacity per theme.
    final cloudOpacity = switch (themeIdx) {
      1 => 0.10, // crystal cave — dim
      _ => 0.45,
    };
    _paintClouds(canvas, w, h, cloudOpacity);

    // Theme-specific drifting motifs.
    switch (themeIdx) {
      case 0:
        _paintMotifs(canvas, w, h, motif: _Motif.petal, count: 12);
        break;
      case 1:
        _paintMotifs(canvas, w, h, motif: _Motif.sparkle, count: 18);
        break;
      case 2:
        _paintMotifs(canvas, w, h, motif: _Motif.ember, count: 14);
        break;
      case 3:
        _paintMotifs(canvas, w, h, motif: _Motif.snow, count: 16);
        break;
      default:
        _paintMotifs(canvas, w, h, motif: _Motif.leaf, count: 10);
    }
  }

  void _paintClouds(Canvas canvas, double w, double h, double opacity) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final positions = [(0.6, 0.10, 1.0), (0.3, 0.18, 0.6), (0.85, 0.28, 0.45)];
    for (int i = 0; i < positions.length; i++) {
      final (yFrac, sizeFrac, speed) = (
        positions[i].$2,
        positions[i].$3,
        0.4 + i * 0.15,
      );
      final cx = ((positions[i].$1 + t * speed) % 1.2 - 0.1) * w;
      final cy = yFrac * h;
      final radius = 32.0 * sizeFrac;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: radius * 3,
          height: radius * 1.4,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - radius, cy + 4),
          width: radius * 1.8,
          height: radius,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + radius, cy + 6),
          width: radius * 1.5,
          height: radius * 0.9,
        ),
        paint,
      );
    }
  }

  void _paintMotifs(
    Canvas canvas,
    double w,
    double h, {
    required _Motif motif,
    required int count,
  }) {
    final rng = math.Random(motif.index * 1000 + 7);
    for (int i = 0; i < count; i++) {
      final baseX = rng.nextDouble();
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble();
      final yProg = ((t * speed + phase) % 1.0);
      final cx = (baseX * w) + math.sin((t + phase) * math.pi * 2) * 12;
      final cy = motif == _Motif.ember
          ? h *
                (1.0 - yProg) // embers float up
          : h * yProg; // others drift down
      final scale = 0.5 + rng.nextDouble() * 0.6;
      _paintMotif(canvas, motif, Offset(cx, cy), scale);
    }
  }

  void _paintMotif(Canvas canvas, _Motif motif, Offset c, double scale) {
    switch (motif) {
      case _Motif.petal:
        final p = Paint()
          ..color = const Color(0xFFFFC1CC).withValues(alpha: 0.7);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 8 * scale, height: 5 * scale),
          p,
        );
        break;
      case _Motif.sparkle:
        final p = Paint()
          ..color = const Color(0xFFE1BEE7).withValues(alpha: 0.85);
        canvas.drawCircle(c, 1.5 * scale, p);
        canvas.drawCircle(
          c,
          0.8 * scale,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
        break;
      case _Motif.ember:
        final p = Paint()
          ..color = const Color(0xFFFFAB40).withValues(alpha: 0.75);
        canvas.drawCircle(c, 2 * scale, p);
        canvas.drawCircle(
          c,
          1 * scale,
          Paint()..color = const Color(0xFFFFE0B2).withValues(alpha: 0.7),
        );
        break;
      case _Motif.snow:
        final p = Paint()..color = Colors.white.withValues(alpha: 0.8);
        canvas.drawCircle(c, 2.2 * scale, p);
        break;
      case _Motif.leaf:
        final p = Paint()
          ..color = const Color(0xFFAED581).withValues(alpha: 0.7);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 7 * scale, height: 4 * scale),
          p,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) =>
      old.t != t || old.themeIdx != themeIdx;
}

enum _Motif { petal, sparkle, ember, snow, leaf }
