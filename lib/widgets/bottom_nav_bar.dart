import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF262522)
          : Colors.white,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]
          : Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          activeIcon: Icon(Icons.play_circle_filled),
          label: 'Play',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}