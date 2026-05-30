import 'package:flutter/material.dart';

/// Animated character mascot that perches on the player's **current** tile in
/// the gamified gardens, replacing the abstract Go-stone marker with a real
/// figure (a robed monk by default — `assets/avatars/monk.png`). This is the
/// "monk instead of a pawn" piece the Gemini mockups call for.
///
/// Composition (bottom-to-top): a soft elliptical ground shadow, then the
/// avatar image with a gentle bob so it feels alive on the pedestal. If the
/// asset is missing on a given build the [errorBuilder] falls back to a simple
/// stone disc so the map never shows a broken-image icon.
class GardenMascot extends StatefulWidget {
  /// Avatar asset to render. Defaults to the monk; any `assets/avatars/*.png`
  /// works (tengu, tanuki, kitsune, panda…) since that folder is bundled.
  final String asset;

  /// Rendered height of the figure in logical pixels.
  final double size;

  const GardenMascot({
    super.key,
    this.asset = 'assets/avatars/monk.png',
    this.size = 48,
  });

  @override
  State<GardenMascot> createState() => _GardenMascotState();
}

class _GardenMascotState extends State<GardenMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size;
    final shadowW = w * 0.62;

    return AnimatedBuilder(
      animation: _bob,
      builder: (ctx, child) {
        // Gentle 4px bob — the mascot "breathes" but stays planted on the tile.
        final t = Curves.easeInOut.transform(_bob.value);
        final dy = -1.0 - 3.0 * (1 - t);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: SizedBox(
        width: w,
        height: w + 8,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Soft ground shadow under the figure.
            Positioned(
              bottom: 0,
              child: Container(
                width: shadowW,
                height: shadowW * 0.26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(shadowW, shadowW * 0.26),
                  ),
                  color: Colors.black.withValues(alpha: 0.34),
                  boxShadow: const [
                    BoxShadow(color: Color(0x44000000), blurRadius: 4),
                  ],
                ),
              ),
            ),
            // The character art.
            Positioned(
              bottom: shadowW * 0.10,
              child: Image.asset(
                widget.asset,
                width: w,
                height: w,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => Container(
                  width: w * 0.7,
                  height: w * 0.5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.elliptical(30, 20)),
                    gradient: RadialGradient(
                      center: Alignment(-0.25, -0.45),
                      colors: [Color(0xFF555555), Color(0xFF111111)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
