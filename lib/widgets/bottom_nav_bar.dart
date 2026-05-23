import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

/// Four-tab Material 3 NavigationBar: Play (0) | Learn (1) | Puzzles (2) | Profile (3).
///
/// Uses [NavigationBar] (Material 3) so Flutter's Scaffold automatically
/// handles system-gesture-inset padding, eliminating the overlap with the
/// Android gesture bar and iPhone home indicator.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.play_circle_outline),
          selectedIcon: const Icon(Icons.play_circle_filled),
          label: l.play,
        ),
        NavigationDestination(
          icon: const Icon(Icons.book_outlined),
          selectedIcon: const Icon(Icons.book),
          label: l.learn,
        ),
        NavigationDestination(
          icon: const Icon(Icons.extension_outlined),
          selectedIcon: const Icon(Icons.extension),
          label: l.puzzles,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l.profile,
        ),
      ],
    );
  }
}
