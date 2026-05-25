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
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: unlocked
                ? [theme.tileBase.withValues(alpha: 0.85), theme.tileBase]
                : [Colors.grey.shade600, Colors.grey.shade800],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (unlocked ? theme.tileBase : Colors.black).withValues(
                alpha: 0.38,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              unlocked ? theme.icon : Icons.lock,
              color: Colors.white,
              size: 28,
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
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
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
