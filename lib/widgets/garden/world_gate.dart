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
    // Vertically lit gradient (top highlight → base → darker foot) reads as a
    // carved-stone banner rather than a flat pill.
    final top = Color.lerp(base, Colors.white, 0.22)!;
    final bottom = Color.lerp(base, Colors.black, 0.30)!;

    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, base, bottom],
            stops: const [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          // Light inner top edge + dark foot = embossed/engraved look.
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Frosted circular icon badge.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Icon(
                unlocked ? theme.icon : Icons.lock,
                color: Colors.white,
                size: 24,
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
