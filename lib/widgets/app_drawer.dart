import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'app_shell.dart';

/// Identifies which main screen the drawer was opened from, so the
/// matching item is highlighted.
enum AppDrawerSection { home, learn, puzzles, bots, history, settings }

/// App-wide hamburger drawer. Pulls items from the route table — tapping an
/// item closes the drawer and pushes the named route (or stays put if the
/// user is already on that section).
class AppDrawer extends StatelessWidget {
  final AppDrawerSection active;

  const AppDrawer({required this.active, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Drawer(
      backgroundColor:
          Theme.of(context).drawerTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, cs),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home,
              label: l.home,
              selected: active == AppDrawerSection.home,
              onTap: () => _go(context, '/home', AppDrawerSection.home),
            ),
            _DrawerItem(
              icon: Icons.book,
              label: l.learn,
              selected: active == AppDrawerSection.learn,
              onTap: () => _go(context, '/learn', AppDrawerSection.learn),
            ),
            _DrawerItem(
              icon: Icons.extension,
              label: l.puzzles,
              selected: active == AppDrawerSection.puzzles,
              onTap: () => _go(context, '/puzzles', AppDrawerSection.puzzles),
            ),
            _DrawerItem(
              icon: Icons.smart_toy,
              label: l.playVsBot,
              selected: active == AppDrawerSection.bots,
              onTap: () => _go(context, '/bots', AppDrawerSection.bots),
            ),
            _DrawerItem(
              icon: Icons.history,
              label: l.history,
              selected: active == AppDrawerSection.history,
              onTap: () => _go(context, '/history', AppDrawerSection.history),
            ),
            const Divider(height: 24),
            _DrawerItem(
              icon: Icons.settings,
              label: l.settings,
              selected: active == AppDrawerSection.settings,
              onTap: () => _go(context, '/settings', AppDrawerSection.settings),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'GOKO',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Text(
            'GOKO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Go Game',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, String route, AppDrawerSection target) {
    Navigator.pop(context); // close drawer
    if (active == target) return;

    // Main tab destinations live inside AppShell — switch the tab index and
    // pop back to the shell root rather than pushing a standalone route.
    switch (target) {
      case AppDrawerSection.home:
        appShellTabIndex.value = 0;
        Navigator.of(context).popUntil((r) => r.isFirst);
      case AppDrawerSection.learn:
        appShellTabIndex.value = 1;
        Navigator.of(context).popUntil((r) => r.isFirst);
      case AppDrawerSection.puzzles:
        appShellTabIndex.value = 2;
        Navigator.of(context).popUntil((r) => r.isFirst);
      default:
        // Secondary screens (bots, history, settings) push normally.
        Navigator.pushNamed(context, route);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: selected ? cs.primary : null),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? cs.primary : null,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
