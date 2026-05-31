import 'package:flutter/material.dart';

/// Animated character mascot that perches on the player's **current** tile in
/// the gamified gardens, replacing the abstract Go-stone marker with a real
/// figure — a **panda** by default (`assets/avatars/panda.png`).
///
/// Premium presentation (back-to-front): a soft radial glow "platform" that
/// makes the figure pop off busy scenery, an elliptical ground shadow, then the
/// avatar with a gentle bob + subtle scale-pulse so it feels alive. If a build
/// ships a dedicated 3D render at `assets/mascot/panda_3d.png` it is preferred;
/// otherwise the panda avatar is used, and a missing asset falls back to a
/// simple stone disc so the map never shows a broken-image icon.
class GardenMascot extends StatefulWidget {
  /// Avatar asset to render. Defaults to the panda; any `assets/avatars/*.png`
  /// works (tengu, tanuki, kitsune, monk…) since that folder is bundled.
  final String asset;

  /// Rendered height of the figure in logical pixels.
  final double size;

  /// Accent colour for the soft glow platform under the figure.
  final Color glow;

  const GardenMascot({
    super.key,
    this.asset = 'assets/avatars/panda.png',
    this.size = 56,
    this.glow = const Color(0xFFFFE08A),
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
    final shadowW = w * 0.60;

    return SizedBox(
      width: w * 1.2,
      height: w + 12,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Soft radial glow "platform" — static, makes the figure pop off
          // busy illustrated scenery.
          Positioned(
            bottom: -2,
            child: SizedBox(
              width: w * 1.15,
              height: w * 0.55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      widget.glow.withValues(alpha: 0.55),
                      widget.glow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Ground contact shadow — static.
          Positioned(
            bottom: 2,
            child: Container(
              width: shadowW,
              height: shadowW * 0.24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(shadowW, shadowW * 0.24),
                ),
                color: Colors.black.withValues(alpha: 0.32),
                boxShadow: const [
                  BoxShadow(color: Color(0x44000000), blurRadius: 4),
                ],
              ),
            ),
          ),
          // The character — bobs + subtly scale-pulses above the static glow.
          Positioned(
            bottom: shadowW * 0.10,
            child: AnimatedBuilder(
              animation: _bob,
              builder: (ctx, child) {
                final t = Curves.easeInOut.transform(_bob.value);
                final dy = -1.0 - 3.0 * (1 - t);
                final scale = 1.0 + 0.02 * t;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: _figure(w),
            ),
          ),
        ],
      ),
    );
  }

  /// Prefers a dedicated 3D render (`assets/mascot/panda_3d.png`) when shipped,
  /// then the configured [widget.asset], then a plain stone disc — so the map
  /// never shows a broken-image icon regardless of which art is bundled.
  Widget _figure(double w) {
    return Image.asset(
      'assets/mascot/panda_3d.png',
      width: w,
      height: w,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => Image.asset(
        widget.asset,
        width: w,
        height: w,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => Container(
          width: w * 0.7,
          height: w * 0.5,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(30, 20)),
            gradient: RadialGradient(
              center: Alignment(-0.25, -0.45),
              colors: [Color(0xFF555555), Color(0xFF111111)],
            ),
          ),
        ),
      ),
    );
  }
}
