import 'package:flutter/material.dart';

/// The player's Go-stone avatar rendered from a slight 3/4 perspective so it
/// looks like a real stone sitting on top of a pedestal, not a flat disc
/// floating above the board.
///
/// Composition (bottom-to-top in the Stack):
///   1. Cast shadow ellipse on the pedestal top (compressed, dark, blurred)
///   2. Stone body — width > height (perspective compression), 3-stop radial
///      gradient with the bright spot near the upper-left
///   3. Specular highlight — small white flare at the top-left to imply
///      polished glass
///
/// Subtle 4px bob on a 1600ms loop so the avatar feels alive without
/// distracting from the level number underneath.
class PlayerStone3D extends StatefulWidget {
  /// 1 = black stone, 2 = white stone.
  final int color;
  const PlayerStone3D({super.key, required this.color});

  @override
  State<PlayerStone3D> createState() => _PlayerStone3DState();
}

class _PlayerStone3DState extends State<PlayerStone3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stone is rendered as an oval (perspective-compressed) to read as a
    // real Go stone viewed from 3/4 above. Width:height ≈ 1.45:1.
    const stoneW = 42.0;
    const stoneH = 30.0;
    const shadowW = 36.0;
    const shadowH = 9.0;
    final isBlack = widget.color == 1;
    final baseColors = isBlack
        ? const [Color(0xFFA0A0A0), Color(0xFF2A2A2A), Color(0xFF050505)]
        : const [Color(0xFFFFFFFF), Color(0xFFE6E6E6), Color(0xFFA8A8A8)];

    return AnimatedBuilder(
      animation: _bob,
      builder: (ctx, child) {
        // Subtle bob — the stone "breathes" on the pedestal but stays planted.
        final t = Curves.easeInOut.transform(_bob.value);
        final dy = -2.0 - 3.0 * (1 - t);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: SizedBox(
        width: stoneW,
        height: stoneH + shadowH + 4,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Cast shadow on the pedestal top — drawn first so the stone
            // sits over it. Slight Y-offset down so it reads as on the
            // surface, not under it.
            Positioned(
              bottom: 0,
              child: Container(
                width: shadowW,
                height: shadowH,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(shadowW, shadowH),
                  ),
                  color: Colors.black.withValues(alpha: 0.42),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            // Stone body — oval with 3-stop radial gradient.
            Positioned(
              top: 0,
              child: Container(
                width: stoneW,
                height: stoneH,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(stoneW, stoneH),
                  ),
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.45),
                    radius: 0.95,
                    colors: baseColors,
                    stops: const [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
            // Specular highlight — small bright flare near the upper-left.
            Positioned(
              top: stoneH * 0.12,
              left: stoneW * 0.18,
              child: Container(
                width: stoneW * 0.32,
                height: stoneH * 0.30,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.elliptical(14, 5)),
                  gradient: RadialGradient(
                    colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
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
