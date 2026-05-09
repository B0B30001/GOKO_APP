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
import 'package:zaibal/screens/puzzles_hub_screen.dart';
import 'package:zaibal/theme/go_theme.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/services/ogs_service.dart';
import 'package:zaibal/services/user_service.dart';
import 'package:zaibal/services/subscription_service.dart';
import 'package:zaibal/services/match_history_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted settings before runApp so the first frame uses the user's
  // saved theme, board variant, etc.
  await AppSettings.load();

  // Trim logs in release or when verboseLogs is false
  if (kReleaseMode || !AppSettings.verboseLogs) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Pre-compile the radial-gradient + shadow shaders used by stones so the
  // first stone placement doesn't drop a frame. No-op on Impeller.
  PaintingBinding.shaderWarmUp = const StoneShaderWarmUp();

  final userService = UserService();
  final subscriptionService = SubscriptionService();
  final matchHistoryService = MatchHistoryService();

  await Future.wait([
    userService.load(),
    subscriptionService.load(),
    matchHistoryService.load(),
  ]);

  runApp(
    GokoApp(
      userService: userService,
      subscriptionService: subscriptionService,
      matchHistoryService: matchHistoryService,
    ),
  );
}

class GokoApp extends StatefulWidget {
  final UserService userService;
  final SubscriptionService subscriptionService;
  final MatchHistoryService matchHistoryService;

  const GokoApp({
    super.key,
    required this.userService,
    required this.subscriptionService,
    required this.matchHistoryService,
  });

  @override
  State<GokoApp> createState() => _GokoAppState();
}

class _GokoAppState extends State<GokoApp> {
  void _setTheme(bool isDark) {
    setState(() {
      AppSettings.themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    AppSettings.save();
  }

  void _toggleTheme() {
    _setTheme(AppSettings.themeMode != ThemeMode.dark);
  }

  void _onCoordinatesChanged(bool v) {
    setState(() {
      AppSettings.showCoordinates = v;
    });
    AppSettings.save();
  }

  void _onForceLightGameChanged(bool v) {
    setState(() {
      AppSettings.forceLightThemeInGame = v;
    });
    AppSettings.save();
  }

  void _onBoardThemeChanged(String id) {
    setState(() {
      AppSettings.boardThemeId = id;
    });
    AppSettings.save();
  }

  void _onBackgroundThemeChanged(String id) {
    setState(() {
      AppSettings.backgroundThemeId = id;
    });
    AppSettings.save();
  }

  void _onThemePresetChanged(String id) {
    setState(() {
      AppSettings.themePresetId = id;
      // Sync ThemeMode to whatever the preset's brightness is, so the rest of
      // Flutter (status bar, system UI overlays) stays consistent.
      final preset = ThemePresetIds.toEnum(id);
      final isLight =
          preset == ThemePreset.classicWood || preset == ThemePreset.lightMode;
      AppSettings.themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
    });
    AppSettings.save();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSettings.themeMode == ThemeMode.dark;
    final preset = ThemePresetIds.toEnum(AppSettings.themePresetId);
    final activeTheme = GoTheme.fromPreset(preset);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OgsService()),
        ChangeNotifierProvider.value(value: widget.userService),
        ChangeNotifierProvider.value(value: widget.subscriptionService),
        ChangeNotifierProvider.value(value: widget.matchHistoryService),
      ],
      child: MaterialApp(
        title: 'GOKO',
        // Both `theme` and `darkTheme` resolve to the user's preset; ThemeMode
        // selects between them but we want the same preset to win regardless.
        theme: activeTheme,
        darkTheme: activeTheme,
        themeMode: AppSettings.themeMode,
        initialRoute: '/home',
        routes: {
          '/home': (context) => HomeScreen(onThemeToggle: _toggleTheme),
          '/learn': (context) => const LearnScreen(),
          '/history': (context) => const HistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => SettingsScreen(
            isDark: isDark,
            onThemeChanged: _setTheme,
            showCoordinates: AppSettings.showCoordinates,
            onCoordinatesChanged: _onCoordinatesChanged,
            forceLightGame: AppSettings.forceLightThemeInGame,
            onForceLightGameChanged: _onForceLightGameChanged,
            boardThemeId: AppSettings.boardThemeId,
            onBoardThemeChanged: _onBoardThemeChanged,
            backgroundThemeId: AppSettings.backgroundThemeId,
            onBackgroundThemeChanged: _onBackgroundThemeChanged,
            themePresetId: AppSettings.themePresetId,
            onThemePresetChanged: _onThemePresetChanged,
          ),
          '/topic': (context) => const TopicDetailScreen(),
          '/puzzles': (context) => const PuzzlesHubScreen(),
        },
      ),
    );
  }
}
