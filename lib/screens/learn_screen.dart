import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../widgets/app_drawer.dart';
import '../widgets/app_shell.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/goko_logo.dart';
import '../widgets/menu_fab.dart';
import 'learn_garden_screen.dart';

/// Learn tab host. Owns the app chrome (drawer, app bar, bottom nav, FAB) and
/// delegates the body to [LearnGardenScreen] — the new gamified 3D map that
/// replaces the prior 838-line collapsible-list layout.
///
/// Routes that used to push the legacy `_LevelSection` / `_DrillGrid` /
/// `_UnlockLessonsCard` widgets now reach the same lessons via the garden
/// path tiles. Drills are accessible via [TutorialScreen]'s practice-puzzle
/// follow-ups; standalone drill modes will be reintroduced in a later phase
/// if usage data shows demand.
class LearnScreen extends StatelessWidget {
  /// When false the screen is hosted inside [AppShell]; suppress per-screen nav.
  final bool showBottomNav;

  const LearnScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      drawer: const AppDrawer(active: AppDrawerSection.learn),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GokoLogo(size: 22),
            const SizedBox(width: 8),
            Text(l.learnGo),
          ],
        ),
      ),
      body: const LearnGardenScreen(),
      floatingActionButton: showBottomNav ? const MenuFab() : null,
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 1) return;
                appShellTabIndex.value = index;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            )
          : null,
    );
  }
}
