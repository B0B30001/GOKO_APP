import 'package:flutter/material.dart';

/// Bottom-right floating action button that opens the app drawer.
///
/// Replaces the conventional top-left hamburger on main screens per design
/// request — thumb-reach on mobile. Sits above the BottomNavBar via the
/// default `endFloat` location; a `mini` style keeps it from dominating.
class MenuFab extends StatelessWidget {
  const MenuFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => FloatingActionButton(
        heroTag: 'menu-fab',
        onPressed: () => Scaffold.of(ctx).openDrawer(),
        tooltip: 'Menu',
        child: const Icon(Icons.menu),
      ),
    );
  }
}
