import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/learn_screen.dart';
import '../screens/puzzles_hub_screen.dart';
import '../screens/profile_screen.dart';

/// Global tab-index notifier. Any widget in the tree can switch the shell's
/// active tab by writing:
///   appShellTabIndex.value = 2; // jump to Puzzles
///
/// The shell listens to this notifier and calls setState accordingly.
final ValueNotifier<int> appShellTabIndex = ValueNotifier<int>(0);

/// Persistent navigation shell built with [IndexedStack].
///
/// All four main-tab screens are kept alive simultaneously so scroll positions
/// and transient state are preserved between tab switches.
///
/// The [NavigationBar] lives in [Scaffold.bottomNavigationBar] so Flutter's
/// Scaffold automatically handles system-gesture insets and SafeArea — this
/// fixes the overlap with the Android gesture bar and iPhone home indicator
/// that existed when the nav bar was placed inside the body Column.
class AppShell extends StatefulWidget {
  final Function onThemeToggle;

  const AppShell({super.key, required this.onThemeToggle});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    appShellTabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    appShellTabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final index = appShellTabIndex.value;
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          HomeScreen(onThemeToggle: widget.onThemeToggle, showBottomNav: false),
          const LearnScreen(showBottomNav: false),
          const PuzzlesHubScreen(showBottomNav: false),
          const ProfileScreen(showBottomNav: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => appShellTabIndex.value = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_filled),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension),
            label: 'Puzzles',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
