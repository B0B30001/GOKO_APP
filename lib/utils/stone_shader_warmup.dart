import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Pre-compiles the shaders used by `_StonePainter` (white-stone radial
/// gradient + soft shadow) so the first stone placement doesn't pay a
/// shader-compile frame drop.
///
/// This is a Skia-era optimization. Impeller compiles shaders ahead of time
/// at app build, so on Impeller-enabled platforms (iOS, increasingly Android)
/// this is a benign no-op.
class StoneShaderWarmUp extends ShaderWarmUp {
  const StoneShaderWarmUp();

  @override
  Future<bool> warmUpOnCanvas(ui.Canvas canvas) async {
    const center = Offset(50, 50);
    const radius = 20.0;

    // Shadow (matches _StonePainter)
    final shadow = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(2, 2), radius, shadow);

    // Solid stone fills
    canvas.drawCircle(center, radius, Paint()..color = Colors.black);
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Radial highlight on white stone
    final highlight = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset.zero, radius: radius * 0.8),
          );
    canvas.save();
    canvas.translate(center.dx - radius * 0.3, center.dy - radius * 0.3);
    canvas.drawCircle(Offset.zero, radius, highlight);
    canvas.restore();

    return true;
  }
}
