import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/utils/stone_shader_warmup.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  // Trim logs in release or when verboseLogs is false
  if (kReleaseMode || !AppSettings.verboseLogs) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Pre-compile the radial-gradient + shadow shaders used by stones so the
  // first stone placement doesn't drop a frame. No-op on Impeller.
  PaintingBinding.shaderWarmUp = const StoneShaderWarmUp();

  runApp(const GokoApp());
}

class GokoApp extends StatefulWidget {
  const GokoApp({super.key});

  @override
  State<GokoApp> createState() => _GokoAppState();
}

class _GokoAppState extends State<GokoApp> {
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
        title: 'GOKO',
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
