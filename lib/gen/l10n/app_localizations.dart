import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'GOKO'**
  String get appName;

  /// Play tab label
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Learn tab label
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// Puzzles tab label
  ///
  /// In en, this message translates to:
  /// **'Puzzles'**
  String get puzzles;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Home screen section header
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Quick action: practice vs computer
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// Quick action: play against a bot
  ///
  /// In en, this message translates to:
  /// **'Play vs Bot'**
  String get playVsBot;

  /// Quick action: open tutorials
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// Daily challenge card title
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// Home screen section header
  ///
  /// In en, this message translates to:
  /// **'Recent Games'**
  String get recentGames;

  /// Hero banner primary text
  ///
  /// In en, this message translates to:
  /// **'Play • Learn • Improve'**
  String get heroPrimary;

  /// Hero banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Everything works offline – no account needed!'**
  String get heroSub;

  /// Modal title for game mode picker
  ///
  /// In en, this message translates to:
  /// **'Select Game Mode'**
  String get selectGameMode;

  /// Game mode option
  ///
  /// In en, this message translates to:
  /// **'vs Computer'**
  String get vsComputer;

  /// Game mode option
  ///
  /// In en, this message translates to:
  /// **'vs Friend (Same Device)'**
  String get vsFriend;

  /// Game mode option
  ///
  /// In en, this message translates to:
  /// **'vs Online'**
  String get vsOnline;

  /// Modal title for board size picker
  ///
  /// In en, this message translates to:
  /// **'Select Board Size'**
  String get selectBoardSize;

  /// Difficulty picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// Learn screen title
  ///
  /// In en, this message translates to:
  /// **'Learn Go'**
  String get learnGo;

  /// Learn tab: Lessons
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// Learn tab: Practice
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTab;

  /// Profile stats section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get winRate;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Puzzle rating'**
  String get puzzleRating;

  /// Settings: language section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings: language picker tile
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Settings: dark mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark themes'**
  String get darkModeSubtitle;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Show board coordinates'**
  String get showCoordinates;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Light theme in game'**
  String get lightThemeInGame;

  /// Settings: light-in-game subtitle
  ///
  /// In en, this message translates to:
  /// **'Force light theme on the Game screen'**
  String get lightThemeInGameSubtitle;

  /// Puzzle success message
  ///
  /// In en, this message translates to:
  /// **'Puzzle Solved!'**
  String get puzzleSolved;

  /// Puzzle failure message
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get notQuite;

  /// Puzzle hint label
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Give up button
  ///
  /// In en, this message translates to:
  /// **'Give up'**
  String get giveUp;

  /// Undo last move button
  ///
  /// In en, this message translates to:
  /// **'Step back'**
  String get stepBack;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// Chains to the next puzzle in a sequence
  ///
  /// In en, this message translates to:
  /// **'Next puzzle'**
  String get nextPuzzle;

  /// Puzzle theory section title
  ///
  /// In en, this message translates to:
  /// **'Theory & Explanation'**
  String get theoryExplanation;

  /// Theory section subtitle when locked
  ///
  /// In en, this message translates to:
  /// **'Solve to unlock'**
  String get solveToUnlock;

  /// Theory section subtitle when unlocked
  ///
  /// In en, this message translates to:
  /// **'Learn why this works'**
  String get learnWhyThisWorks;

  /// Prefix before concept title
  ///
  /// In en, this message translates to:
  /// **'Key Concept: '**
  String get keyConceptPrefix;

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'Game History'**
  String get gameHistory;

  /// Empty state for history
  ///
  /// In en, this message translates to:
  /// **'No recent games'**
  String get noRecentGames;

  /// Drawer item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Drawer item
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Bots screen title
  ///
  /// In en, this message translates to:
  /// **'Play vs Bot'**
  String get playVsBotTitle;

  /// Settings section for KataGo
  ///
  /// In en, this message translates to:
  /// **'AI / KataGo'**
  String get kataGoSection;

  /// Settings label for KataGo URL
  ///
  /// In en, this message translates to:
  /// **'KataGo Server URL'**
  String get kataGoServerUrl;

  /// KataGo URL helper text
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use built-in MCTS engine offline.'**
  String get kataGoHint;

  /// Settings label for Leela Zero / GTP engine URL
  ///
  /// In en, this message translates to:
  /// **'Leela Zero / GTP Server URL'**
  String get leelaServerUrl;

  /// Leela Zero URL helper text
  ///
  /// In en, this message translates to:
  /// **'Connect any GTP-over-WebSocket engine (Leela Zero, ELF OpenGo). Ignored when KataGo URL is set.'**
  String get leelaHint;

  /// Settings tile and screen title for local KataGo process
  ///
  /// In en, this message translates to:
  /// **'Local AI Engine'**
  String get localEngineTitle;

  /// Settings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Auto-managed KataGo (no server needed)'**
  String get localEngineSubtitle;

  /// Engine status: process running
  ///
  /// In en, this message translates to:
  /// **'KataGo ready'**
  String get engineStatusReady;

  /// Engine status: process starting
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get engineStatusStarting;

  /// Engine status: binary not found
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get engineStatusNotFound;

  /// Engine status: process errored
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get engineStatusError;

  /// Label for the engines directory path
  ///
  /// In en, this message translates to:
  /// **'Engines Folder'**
  String get enginesFolderLabel;

  /// Button to open KataGo download page
  ///
  /// In en, this message translates to:
  /// **'Download KataGo'**
  String get downloadKataGo;

  /// Button to restart the KataGo process
  ///
  /// In en, this message translates to:
  /// **'Restart Engine'**
  String get engineRestartButton;

  /// Previous step button
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// Next step button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Play move-by-move demo button
  ///
  /// In en, this message translates to:
  /// **'Play demo'**
  String get playDemo;

  /// Replay demo button
  ///
  /// In en, this message translates to:
  /// **'Replay demo'**
  String get replayDemo;

  /// Demo playback status label
  ///
  /// In en, this message translates to:
  /// **'Playing…'**
  String get playingDemo;

  /// Tutorial: interactive step hint
  ///
  /// In en, this message translates to:
  /// **'Interactive — tap the board'**
  String get interactiveTapBoard;

  /// Tutorial source attribution prefix
  ///
  /// In en, this message translates to:
  /// **'Source: '**
  String get sourcePrefix;

  /// Tutorial step progress indicator
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepXofY(int current, int total);

  /// Daily puzzles section heading
  ///
  /// In en, this message translates to:
  /// **'Daily Puzzles'**
  String get dailyPuzzles;

  /// Puzzle collections section heading
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// Puzzle categories section heading
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Captures'**
  String get captures;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Liberties'**
  String get liberties;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Life & Death'**
  String get lifeDeath;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Ko Basics'**
  String get koBasics;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Tesuji'**
  String get tesuji;

  /// Swap daily puzzle button
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// Daily swap counter
  ///
  /// In en, this message translates to:
  /// **'{count} swaps left'**
  String swapsLeft(int count);

  /// Daily puzzles solved counter
  ///
  /// In en, this message translates to:
  /// **'{solved}/{total} solved'**
  String solvedCount(int solved, int total);

  /// Learn screen section
  ///
  /// In en, this message translates to:
  /// **'Learning Path'**
  String get learningPath;

  /// Learn screen section
  ///
  /// In en, this message translates to:
  /// **'All Tutorials'**
  String get allTutorials;

  /// Learn screen section header
  ///
  /// In en, this message translates to:
  /// **'By Level'**
  String get byLevel;

  /// Difficulty tier
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Difficulty tier
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Difficulty tier
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Puzzle info card label
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get objective;

  /// Puzzle info card label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Puzzle info card label
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get yourTurn;

  /// Puzzle moves counter label
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get moves;

  /// Puzzle: mark theory-only as learned
  ///
  /// In en, this message translates to:
  /// **'Mark as Learned ✓'**
  String get markAsLearned;

  /// Whose turn label
  ///
  /// In en, this message translates to:
  /// **'Black to play'**
  String get blackToPlay;

  /// Whose turn label
  ///
  /// In en, this message translates to:
  /// **'White to play'**
  String get whiteToPlay;

  /// Coming soon chip on Bots screen
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Settings: sound subtitle
  ///
  /// In en, this message translates to:
  /// **'Play sounds during the game'**
  String get soundEffectsSubtitle;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Settings: vibration subtitle
  ///
  /// In en, this message translates to:
  /// **'Vibrate on move'**
  String get vibrationSubtitle;

  /// Settings toggle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Settings: notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Get notified about your games'**
  String get pushNotificationsSubtitle;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Settings tile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Settings tile
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About tile
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Settings tile
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Settings tile
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Settings: theme picker section label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// Settings: board theme section label
  ///
  /// In en, this message translates to:
  /// **'Board theme'**
  String get boardThemeLabel;

  /// Settings: background section label
  ///
  /// In en, this message translates to:
  /// **'Background theme'**
  String get backgroundThemeLabel;

  /// Theme preset name
  ///
  /// In en, this message translates to:
  /// **'Dark Blue'**
  String get themeDarkBlue;

  /// Theme preset name
  ///
  /// In en, this message translates to:
  /// **'OLED Black'**
  String get themeOledBlack;

  /// Theme preset name
  ///
  /// In en, this message translates to:
  /// **'Classic Wood'**
  String get themeClassicWood;

  /// Theme preset name
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLightMode;

  /// Seasonal theme preset name
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get themeHalloween;

  /// Seasonal theme preset name
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get themeWinter;

  /// Seasonal theme preset name
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// Board theme variant
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get boardClassic;

  /// Board theme variant
  ///
  /// In en, this message translates to:
  /// **'Walnut'**
  String get boardWalnut;

  /// Board theme variant
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get boardSlate;

  /// Board theme variant
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get boardNight;

  /// Background variant
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get bgStandard;

  /// Background variant
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get bgMinimal;

  /// Background variant
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get bgWarm;

  /// Background variant
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get bgCool;

  /// Puzzle concept name
  ///
  /// In en, this message translates to:
  /// **'Liberties & Captures'**
  String get conceptLibertiesCaptures;

  /// Puzzle concept name
  ///
  /// In en, this message translates to:
  /// **'Liberty Counting'**
  String get conceptLibertyCounting;

  /// Puzzle concept name
  ///
  /// In en, this message translates to:
  /// **'Life & Death - Two Eyes'**
  String get conceptLifeDeathTwoEyes;

  /// Puzzle concept name
  ///
  /// In en, this message translates to:
  /// **'Ko Rule'**
  String get conceptKoRule;

  /// Concept body text
  ///
  /// In en, this message translates to:
  /// **'Stones are captured when all their liberties (adjacent empty points) are occupied by enemy stones. Connected stones share liberties as a single group.'**
  String get conceptLibertiesCapturesDesc;

  /// Concept body text
  ///
  /// In en, this message translates to:
  /// **'Each empty point adjacent to a stone or group is a liberty. Connected stones form one group and share all their liberties. When a group has only one liberty left, it\'s in \"atari\" (check).'**
  String get conceptLibertyCountingDesc;

  /// Concept body text
  ///
  /// In en, this message translates to:
  /// **'A group with two separate eyes cannot be captured because the opponent cannot fill both eyes simultaneously. This is fundamental to understanding which groups are alive and which can be killed.'**
  String get conceptLifeDeathDesc;

  /// Concept body text
  ///
  /// In en, this message translates to:
  /// **'The Ko rule prevents infinite loops by prohibiting immediate recapture in a repeating position. After capturing in Ko, you must play elsewhere before you can recapture.'**
  String get conceptKoRuleDesc;

  /// Analysis screen title
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisPanelTitle;

  /// Tooltip: turn on KataGo analysis
  ///
  /// In en, this message translates to:
  /// **'Enable Analysis'**
  String get analysisOn;

  /// Tooltip: turn off KataGo analysis
  ///
  /// In en, this message translates to:
  /// **'Disable Analysis'**
  String get analysisOff;

  /// Warning shown when KataGo URL is empty
  ///
  /// In en, this message translates to:
  /// **'Configure a KataGo server in Settings to enable analysis.'**
  String get noServerForAnalysis;

  /// Move quality label
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get moveQualityBest;

  /// Move quality label
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moveQualityGood;

  /// Move quality label
  ///
  /// In en, this message translates to:
  /// **'Inaccuracy'**
  String get moveQualityInaccuracy;

  /// Move quality label
  ///
  /// In en, this message translates to:
  /// **'Mistake'**
  String get moveQualityMistake;

  /// Move quality label
  ///
  /// In en, this message translates to:
  /// **'Blunder'**
  String get moveQualityBlunder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
