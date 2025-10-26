import 'package:flutter/material.dart';
import 'package:zaibal/screens/home_screen.dart';
import 'package:zaibal/screens/learn_screen.dart';
import 'package:zaibal/screens/history_screen.dart';
import 'package:zaibal/screens/profile_screen.dart';
import 'package:zaibal/screens/settings_screen.dart';
import 'package:zaibal/theme/go_theme.dart';

void main() {
  runApp(const ZaibalApp());
}

class ZaibalApp extends StatefulWidget {
  const ZaibalApp({super.key});

  @override
  State<ZaibalApp> createState() => _ZaibalAppState();
}

class _ZaibalAppState extends State<ZaibalApp> {
  bool _isDarkTheme = false;

  void toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaibal',
      theme: GoTheme.light,
      darkTheme: GoTheme.dark,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(onThemeToggle: toggleTheme),
        '/learn': (context) => const LearnScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}