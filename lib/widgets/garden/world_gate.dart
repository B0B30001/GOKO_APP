import 'package:flutter/material.dart';

import 'garden_theme.dart';

/// A banner that announces a new "world" (theme band / lesson category) on the
/// gamified map. Renders as a gradient pill with the theme's icon, an
/// upper-case title, and an optional subtitle (typically the XP-unlock hint
/// when the world is locked).
class WorldGate extends StatelessWidget {
  final GardenTheme theme;
  final String title;
  final bool unlocked;

  /// Small line under the title. Common uses: "Unlock at 3000 XP" when locked,
  /// "8 lessons" for category banners on the Learn page, or null for none.
  final String? subtitle;

  const WorldGate({
    super.key,
    required this.theme,
    required this.title,
    required this.unlocked,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final base = unlocked ? theme.tileBase : Colors.blueGrey.shade600;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          // Translucent frosted pill — the world art shows through so the gate
          // reads as a light label, not a heavy opaque banner.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: 0.34),
              Colors.black.withValues(alpha: 0.42),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Small frosted icon badge.
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.3,
                ),
              ),
              child: Icon(
                unlocked ? theme.icon : Icons.lock,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
