import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/screens/home_screen.dart';
import 'package:zaibal/screens/learn_screen.dart';
import 'package:zaibal/screens/history_screen.dart';
import 'package:zaibal/screens/profile_screen.dart';
import 'package:zaibal/screens/settings_screen.dart';
import 'package:zaibal/screens/topic_detail_screen.dart';
import 'package:zaibal/theme/go_theme.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/services/ogs_service.dart';

void main() {
  // Trim logs in release or when verboseLogs is false
  if (kReleaseMode || !AppSettings.verboseLogs) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
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

  void setTheme(bool value) {
    setState(() {
      _isDarkTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OgsService(),
      child: MaterialApp(
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
          '/settings': (context) => SettingsScreen(
            isDark: _isDarkTheme,
            onThemeChanged: setTheme,
            showCoordinates: AppSettings.showCoordinates,
            onCoordinatesChanged: (v) {
              setState(() {
                AppSettings.showCoordinates = v;
              });
            },
            forceLightGame: AppSettings.forceLightThemeInGame,
            onForceLightGameChanged: (v) {
              setState(() {
                AppSettings.forceLightThemeInGame = v;
              });
            },
          ),
          '/topic': (context) => const TopicDetailScreen(),
        },
      ),
    );
  }
}
