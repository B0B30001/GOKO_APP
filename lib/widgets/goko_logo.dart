import 'package:flutter/material.dart';

/// Reusable GOKO brand mark. Renders the logo PNG at the requested size,
/// optionally followed by the "GOKO" wordmark.
///
/// Asset: [assets/logo/goko_logo.png] (registered in pubspec.yaml under
/// `assets/logo/`). Falls back to a tinted `Icons.grid_on` if the asset is
/// missing so screens that mount the logo never blank-screen.
class GokoLogo extends StatelessWidget {
  /// Height of the icon in logical pixels.
  final double size;

  /// When true, renders "GOKO" text next to the icon.
  final bool showWordmark;

  /// Color of the wordmark; defaults to the active text color.
  final Color? wordmarkColor;

  /// When true, adds ~18% internal padding so the edge-to-edge logo PNG
  /// doesn't get its corners cropped when placed inside a circular frame.
  /// Use for `CircleAvatar`, circular Container backgrounds, etc.
  final bool inCircle;

  const GokoLogo({
    super.key,
    this.size = 32,
    this.showWordmark = false,
    this.wordmarkColor,
    this.inCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final asset = Image.asset(
      'assets/logo/goko_logo.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.grid_on,
        size: size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
    // Wrap in inset padding so the round corners of the host circle don't
    // chop visible logo content. Keep the outer SizedBox at `size` so callers
    // can size predictably.
    final logo = inCircle
        ? SizedBox(
            width: size,
            height: size,
            child: Padding(padding: EdgeInsets.all(size * 0.18), child: asset),
          )
        : asset;
    if (!showWordmark) return logo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(width: size * 0.28),
        Text(
          'GOKO',
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.w900,
            letterSpacing: size * 0.06,
            color: wordmarkColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
