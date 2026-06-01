import 'package:flutter/material.dart';

/// Per-world wrapper for the gamified gardens. Insets a world band's content
/// (its `WorldGate` + tiles + path connectors) so tiles don't touch the screen
/// edge, while the global procedural [GardenBackgroundPainter] shows full-bleed
/// behind it. (Illustrated PNG backdrops were dropped in favour of the calm
/// procedural scene, so this is now a thin layout wrapper.)
class GardenWorldPanel extends StatelessWidget {
  /// The world's content column, already ordered for the list's scroll direction.
  final Widget child;

  /// Horizontal inset for the content; the scene behind stays full-bleed.
  final double horizontalInset;

  const GardenWorldPanel({
    super.key,
    required this.child,
    this.horizontalInset = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: child,
    );
  }
}
