import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/utils/stone_shader_warmup.dart';
import 'package:zaibal/screens/learn_screen.dart';
import 'package:zaibal/screens/profile_screen.dart';
import 'package:zaibal/screens/puzzles_hub_screen.dart';
import 'package:zaibal/screens/settings_screen.dart';
import 'package:zaibal/screens/history_screen.dart';
import 'package:zaibal/screens/bots_screen.dart';
import 'package:zaibal/widgets/app_shell.dart';
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
  final ogsService = OgsService();

  await Future.wait([
    userService.load(),
    subscriptionService.load(),
    matchHistoryService.load(),
    ogsService.tryAutoLogin(),
  ]);

  runApp(
    GokoApp(
      userService: userService,
      subscriptionService: subscriptionService,
      matchHistoryService: matchHistoryService,
      ogsService: ogsService,
    ),
  );
}

class GokoApp extends StatefulWidget {
  final UserService userService;
  final SubscriptionService subscriptionService;
  final MatchHistoryService matchHistoryService;
  final OgsService ogsService;

  const GokoApp({
    super.key,
    required this.userService,
    required this.subscriptionService,
    required this.matchHistoryService,
    required this.ogsService,
  });

  @override
  State<GokoApp> createState() => _GokoAppState();
}

class _GokoAppState extends State<GokoApp> {
  void _setTheme(bool isDark) {
    setState(() {
      AppSettings.themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      // Sync the preset to the requested brightness so the visual change is
      // immediate (both `theme` and `darkTheme` resolve to the same preset,
      // so we must actually switch the preset, not just ThemeMode).
      final preset = ThemePresetIds.toEnum(AppSettings.themePresetId);
      if (isDark &&
          (preset == ThemePreset.classicWood ||
              preset == ThemePreset.lightMode)) {
        AppSettings.themePresetId = ThemePresetIds.darkBlue;
      } else if (!isDark &&
          (preset == ThemePreset.darkBlue || preset == ThemePreset.oledBlack)) {
        AppSettings.themePresetId = ThemePresetIds.lightMode;
      }
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
      // Sync ThemeMode to the preset's brightness so status-bar overlays stay right.
      final preset = ThemePresetIds.toEnum(id);
      final isLight =
          preset == ThemePreset.classicWood || preset == ThemePreset.lightMode;
      AppSettings.themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
    });
    AppSettings.save();
  }

  void _setLanguage(String code) {
    setState(() => AppSettings.languageCode = code);
    AppSettings.save();
  }

  void _onKataGoServerUrlChanged(String url) {
    AppSettings.kataGoServerUrl = url;
    AppSettings.save();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSettings.themeMode == ThemeMode.dark;
    final preset = ThemePresetIds.toEnum(AppSettings.themePresetId);
    final activeTheme = GoTheme.fromPreset(preset);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.ogsService),
        ChangeNotifierProvider.value(value: widget.userService),
        ChangeNotifierProvider.value(value: widget.subscriptionService),
        ChangeNotifierProvider.value(value: widget.matchHistoryService),
      ],
      child: MaterialApp(
        title: 'GOKO',
        theme: activeTheme,
        darkTheme: activeTheme,
        themeMode: AppSettings.themeMode,
        locale: Locale(AppSettings.languageCode),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('zh'),
          Locale('ru'),
          Locale('ja'),
          Locale('ko'),
        ],
        initialRoute: '/home',
        routes: {
          '/home': (context) => AppShell(onThemeToggle: _toggleTheme),
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
            languageCode: AppSettings.languageCode,
            onLanguageChanged: _setLanguage,
            kataGoServerUrl: AppSettings.kataGoServerUrl,
            onKataGoServerUrlChanged: _onKataGoServerUrlChanged,
          ),
          '/puzzles': (context) => const PuzzlesHubScreen(),
          '/bots': (context) => const BotsScreen(),
        },
      ),
    );
  }
}
