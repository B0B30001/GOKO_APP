import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/utils/stone_shader_warmup.dart';
import 'package:zaibal/screens/learn_screen.dart';
import 'package:zaibal/screens/profile_screen.dart';
import 'package:zaibal/screens/puzzles_hub_screen.dart';
import 'package:zaibal/screens/settings_screen.dart';
import 'package:zaibal/screens/history_screen.dart';
import 'package:zaibal/screens/bots_screen.dart';
import 'package:zaibal/screens/auth_gate_screen.dart';
import 'package:zaibal/widgets/app_shell.dart';
import 'package:zaibal/theme/go_theme.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/services/ogs_service.dart';
import 'package:zaibal/services/user_service.dart';
import 'package:zaibal/services/subscription_service.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted settings before runApp so the first frame uses the user's
  // saved theme, board variant, etc.
  await AppSettings.load();

  // GOKO is fully free — no IAP / RevenueCat init needed.

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
  final progressService = ProgressService();

  await Future.wait([
    userService.load(),
    subscriptionService.load(),
    matchHistoryService.load(),
    ogsService.tryAutoLogin(),
    progressService.load(),
  ]);

  final app = GokoApp(
    userService: userService,
    subscriptionService: subscriptionService,
    matchHistoryService: matchHistoryService,
    ogsService: ogsService,
    progressService: progressService,
  );

  // Crash / error reporting. Enabled only when a DSN is supplied at build time
  // (`--dart-define=SENTRY_DSN=...`); with no DSN the app runs normally with no
  // reporting and zero overhead, so debug/local builds are unaffected.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn.isEmpty) {
    runApp(app);
  } else {
    await SentryFlutter.init((options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.1;
    }, appRunner: () => runApp(app));
  }
}

class GokoApp extends StatefulWidget {
  final UserService userService;
  final SubscriptionService subscriptionService;
  final MatchHistoryService matchHistoryService;
  final OgsService ogsService;
  final ProgressService progressService;

  const GokoApp({
    super.key,
    required this.userService,
    required this.subscriptionService,
    required this.matchHistoryService,
    required this.ogsService,
    required this.progressService,
  });

  @override
  State<GokoApp> createState() => _GokoAppState();
}

class _GokoAppState extends State<GokoApp> {
  /// Mirrors [AppSettings.guestMode]. When true (or the user is authenticated)
  /// the sign-in gate is skipped and the main shell is shown. Set by tapping
  /// "Continue offline" on the [AuthGateScreen].
  bool _guest = AppSettings.guestMode;

  /// Enters offline (guest) mode: skips the sign-in gate so the user can play
  /// 2-player, vs-AI, and puzzles without an OGS account. Persisted so the gate
  /// isn't shown again on the next launch. Online play still prompts for login.
  void _continueOffline() {
    setState(() => _guest = true);
    AppSettings.guestMode = true;
    AppSettings.save();
  }

  void _setTheme(bool isDark) {
    setState(() {
      AppSettings.themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      // Sync the preset to the requested brightness so the visual change is
      // immediate (both `theme` and `darkTheme` resolve to the same preset,
      // so we must actually switch the preset, not just ThemeMode).
      final preset = ThemePresetIds.toEnum(AppSettings.themePresetId);
      final isCurrentlyLight =
          preset == ThemePreset.classicWood ||
          preset == ThemePreset.lightMode ||
          preset == ThemePreset.winter;
      if (isDark && isCurrentlyLight) {
        AppSettings.themePresetId = ThemePresetIds.darkBlue;
      } else if (!isDark && !isCurrentlyLight) {
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
          preset == ThemePreset.classicWood ||
          preset == ThemePreset.lightMode ||
          preset == ThemePreset.winter;
      AppSettings.themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
    });
    AppSettings.save();
  }

  void _setLanguage(String code) {
    setState(() {
      AppSettings.languageCode = code;
      // User-driven choice — lock it in so future system-locale changes
      // don't override the explicit preference.
      AppSettings.userPickedLanguage = true;
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
        ChangeNotifierProvider.value(value: widget.ogsService),
        ChangeNotifierProvider.value(value: widget.userService),
        ChangeNotifierProvider.value(value: widget.subscriptionService),
        ChangeNotifierProvider.value(value: widget.matchHistoryService),
        ChangeNotifierProvider.value(value: widget.progressService),
      ],
      child: MaterialApp(
        title: 'GOKO',
        theme: activeTheme,
        darkTheme: activeTheme,
        themeMode: AppSettings.themeMode,
        // When the user hasn't picked a language explicitly, pass null so
        // MaterialApp resolves against the OS locale via supportedLocales —
        // this is what flips the app to German on a German phone on first
        // launch (and lets it follow system-locale changes thereafter).
        locale: AppSettings.userPickedLanguage
            ? Locale(AppSettings.languageCode)
            : null,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
          Locale('zh'),
          Locale('ru'),
          Locale('ja'),
          Locale('ko'),
        ],
        // Sign-in gate: shown until the user authenticates with OGS OR chooses
        // "Continue offline". GOKO is offline-first, so the gate must never trap
        // a user who only wants local play — online features prompt for login at
        // the point of use instead.
        home: Consumer<OgsService>(
          builder: (_, ogs, __) => (ogs.isAuthenticated || _guest)
              ? AppShell(onThemeToggle: _toggleTheme)
              : AuthGateScreen(onContinueOffline: _continueOffline),
        ),
        routes: {
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
          ),
          '/puzzles': (context) => const PuzzlesHubScreen(),
          '/bots': (context) => const BotsScreen(),
        },
      ),
    );
  }
}
