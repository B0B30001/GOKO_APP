import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../widgets/app_drawer.dart';
import '../widgets/app_shell.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/menu_fab.dart';
import 'puzzle_garden_screen.dart';

/// Top-level Puzzles tab. Thin wrapper around [PuzzleGardenScreen] that
/// supplies the AppBar, drawer, bottom nav, and FAB so the Garden screen
/// itself can stay focused on the gameplay surface.
///
/// The v1 Map/List toggle is gone — the Garden replaces both views.
class PuzzlesHubScreen extends StatelessWidget {
  /// When false the screen is hosted inside [AppShell]; suppress per-screen nav.
  final bool showBottomNav;

  const PuzzlesHubScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.puzzles),
      appBar: AppBar(title: Text(l.puzzleGardenTitle), centerTitle: true),
      floatingActionButton: showBottomNav ? const MenuFab() : null,
      body: const PuzzleGardenScreen(),
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(
              currentIndex: 2,
              onTap: (index) {
                if (index == 2) return;
                appShellTabIndex.value = index;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            )
          : null,
    );
  }
}
