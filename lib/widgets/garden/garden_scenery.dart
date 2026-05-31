import 'package:flutter/material.dart';

/// Per-world scenery panel for the gamified gardens.
///
/// Wraps one "world band" (a `WorldGate` plus its tiles and path connectors)
/// and paints that world's illustrated scenery PNG **behind** the content,
/// scrolling with it as part of the list — the fix for the old approach where
/// a single image was stretched across a fixed viewport layer.
///
/// Key sizing choice: the scenery uses `BoxFit.fitWidth` (+ `ImageRepeat.repeatY`),
/// so it scales to the panel width and tiles vertically — it is **never
/// horizontally stretched**, whatever the band's height or the device aspect.
///
/// If the world PNG is absent the panel renders nothing of its own
/// (transparent), letting the global procedural background show through, so
/// the app looks fine before any art is dropped in.
///
/// Asset convention (one per theme band, drop into `assets/backgrounds/`):
///   0 stone_forest · 1 crystal_cave · 2 copper_peaks · 3 diamond_tundra · 4 jade_highlands
class GardenWorldPanel extends StatelessWidget {
  /// Theme-band index (0..4); selects which scenery asset to look for.
  final int themeIdx;

  /// The world's content column (gate + tiles + connectors), already ordered
  /// for the parent list's scroll direction.
  final Widget child;

  /// Horizontal inset applied to the content so tiles/gate don't touch the
  /// screen edge while the scenery stays full-bleed behind them.
  final double horizontalInset;

  const GardenWorldPanel({
    super.key,
    required this.themeIdx,
    required this.child,
    this.horizontalInset = 16,
  });

  static const _names = <String>[
    'stone_forest',
    'crystal_cave',
    'copper_peaks',
    'diamond_tundra',
    'jade_highlands',
  ];

  String get _assetPath =>
      'assets/backgrounds/${_names[themeIdx.clamp(0, _names.length - 1)]}.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-bleed scenery behind the (inset) content. fitWidth + repeatY ⇒
        // no horizontal stretch; tiles down to cover any band height. Missing
        // asset ⇒ transparent, so the global procedural background shows through.
        Positioned.fill(
          child: Image.asset(
            _assetPath,
            fit: BoxFit.fitWidth,
            repeat: ImageRepeat.repeatY,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: child,
        ),
      ],
    );
  }
}
