import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
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
    Locale('de'),
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

  /// Snackbar shown when player attempts an illegal move in a puzzle
  ///
  /// In en, this message translates to:
  /// **'Illegal move (Ko / suicide) — try another point.'**
  String get illegalMoveFeedback;

  /// Snackbar shown when player makes a wrong move in a puzzle
  ///
  /// In en, this message translates to:
  /// **'Not the right move — try again!'**
  String get wrongMoveFeedback;

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
  /// **'Coming Soon'**
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

  /// Move quality label
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get moveQualityExcellent;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Chip shown while AI is computing a move
  ///
  /// In en, this message translates to:
  /// **'AI thinking…'**
  String get aiThinking;

  /// Snackbar when human player has no moves
  ///
  /// In en, this message translates to:
  /// **'No legal moves available. Press Pass to continue.'**
  String get noLegalMoves;

  /// Hint dialog title
  ///
  /// In en, this message translates to:
  /// **'Use a hint?'**
  String get useHintTitle;

  /// Hint dialog body
  ///
  /// In en, this message translates to:
  /// **'Reveal the best move. Costs 1 ★ ({remaining} left).'**
  String useHintContent(int remaining);

  /// Hint dialog confirm button
  ///
  /// In en, this message translates to:
  /// **'Show hint'**
  String get showHint;

  /// Snackbar when hint returns no move
  ///
  /// In en, this message translates to:
  /// **'No hint available — try passing.'**
  String get noHintAvailable;

  /// Resign dialog title
  ///
  /// In en, this message translates to:
  /// **'Resign this game?'**
  String get resignTitle;

  /// Resign dialog body in vs-AI mode
  ///
  /// In en, this message translates to:
  /// **'Your opponent will win by resignation.'**
  String get resignConfirmBot;

  /// Resign dialog body in local 2-player mode
  ///
  /// In en, this message translates to:
  /// **'{side} resigns. The other side wins.'**
  String resignConfirmLocal(String side);

  /// Resign confirm button
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get resign;

  /// Game-over overlay: primary CTA label
  ///
  /// In en, this message translates to:
  /// **'Game Review'**
  String get gameReview;

  /// Game-over overlay: play again button
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// Game-over overlay: close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Hint button tooltip when exhausted
  ///
  /// In en, this message translates to:
  /// **'No hints remaining'**
  String get noHintsRemaining;

  /// Hint button tooltip
  ///
  /// In en, this message translates to:
  /// **'Show best move (-1 ★)'**
  String get showBestMove;

  /// Game-over: hints counter when zero
  ///
  /// In en, this message translates to:
  /// **'No hints used'**
  String get noHintsUsed;

  /// Game-over: hints counter
  ///
  /// In en, this message translates to:
  /// **'{count} hint(s) used'**
  String hintsUsed(int count);

  /// Tutorial resume dialog title
  ///
  /// In en, this message translates to:
  /// **'Resume lesson?'**
  String get resumeLesson;

  /// Tutorial resume dialog body
  ///
  /// In en, this message translates to:
  /// **'Continue from step {step}?'**
  String resumeLessonContent(int step);

  /// Tutorial resume dialog: discard bookmark
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// Tutorial resume dialog: keep bookmark
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Tap-target step wrong-tap feedback
  ///
  /// In en, this message translates to:
  /// **'Not quite — try a different point.'**
  String get notQuiteTapHint;

  /// Tap-target step hint shown feedback
  ///
  /// In en, this message translates to:
  /// **'Hint: follow the marker.'**
  String get hintShownTapHint;

  /// Tutorial celebration overlay title
  ///
  /// In en, this message translates to:
  /// **'Lesson complete!'**
  String get lessonComplete;

  /// Streak badge in tutorial celebration
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(int count);

  /// Bots screen: Master tier label
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// Learn screen section header
  ///
  /// In en, this message translates to:
  /// **'Quick Drills'**
  String get quickDrills;

  /// Game board score panel title
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Black player label
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// White player label
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// Local human player name fallback
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// AI opponent name fallback
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// Result text when black resigns
  ///
  /// In en, this message translates to:
  /// **'White wins by resignation'**
  String get whiteWinsByResignation;

  /// Result text when white resigns
  ///
  /// In en, this message translates to:
  /// **'Black wins by resignation'**
  String get blackWinsByResignation;

  /// Result text when black wins on score
  ///
  /// In en, this message translates to:
  /// **'Black wins by {points} points!'**
  String blackWinsByPoints(int points);

  /// Result text when white wins on score
  ///
  /// In en, this message translates to:
  /// **'White wins by {points} points!'**
  String whiteWinsByPoints(int points);

  /// Result text when scores are equal
  ///
  /// In en, this message translates to:
  /// **'Game is tied!'**
  String get gameTied;

  /// Stat column label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Puzzle hub: today's solved count label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Stat column label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Experience points label
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// Generic see-all link text
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Daily tile swap tooltip
  ///
  /// In en, this message translates to:
  /// **'Swap puzzle'**
  String get swapPuzzle;

  /// Completed lesson replay button
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// In-progress lesson continue button
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// Learn screen empty state
  ///
  /// In en, this message translates to:
  /// **'No lessons yet'**
  String get noLessonsYet;

  /// Lesson locked tooltip
  ///
  /// In en, this message translates to:
  /// **'Finish the previous lesson to unlock this.'**
  String get finishPreviousLesson;

  /// History/profile empty state
  ///
  /// In en, this message translates to:
  /// **'No games yet — finish one to see it here.'**
  String get noGamesYet;

  /// Premium tier label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Paywall CTA button
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// Paywall: already premium state
  ///
  /// In en, this message translates to:
  /// **'You are Premium'**
  String get youArePremium;

  /// Paywall screen title
  ///
  /// In en, this message translates to:
  /// **'Unlock GOKO Premium'**
  String get unlockGokoPremium;

  /// Paywall subtitle
  ///
  /// In en, this message translates to:
  /// **'Train deeper. Play stronger. Unlock everything.'**
  String get paywallTagline;

  /// Paywall feature row title
  ///
  /// In en, this message translates to:
  /// **'Unlimited puzzles'**
  String get unlimitedPuzzles;

  /// Paywall feature row subtitle
  ///
  /// In en, this message translates to:
  /// **'Free users get 3 puzzles per day'**
  String get freePuzzleLimit;

  /// Paywall feature row title
  ///
  /// In en, this message translates to:
  /// **'All bots & lessons'**
  String get allBotsAndLessons;

  /// Paywall feature row subtitle
  ///
  /// In en, this message translates to:
  /// **'Beginner bots and first 4 lessons are free'**
  String get allBotsAndLessonsDesc;

  /// Paywall feature row title
  ///
  /// In en, this message translates to:
  /// **'Post-game analysis'**
  String get postGameAnalysis;

  /// Paywall feature row subtitle
  ///
  /// In en, this message translates to:
  /// **'Replay every move and rewind any finished game.'**
  String get postGameAnalysisDesc;

  /// Paywall feature row title
  ///
  /// In en, this message translates to:
  /// **'Profile flair'**
  String get profileFlair;

  /// Paywall feature row subtitle
  ///
  /// In en, this message translates to:
  /// **'Premium badges and avatar borders'**
  String get profileFlairDesc;

  /// Paywall restore button
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Paywall banner: puzzle quota hit
  ///
  /// In en, this message translates to:
  /// **'You\'ve used today\'s 3 free puzzles. Upgrade for unlimited.'**
  String get puzzleDailyQuotaReached;

  /// Paywall banner: bot tier locked
  ///
  /// In en, this message translates to:
  /// **'Intermediate, Advanced, and Master bots require Premium.'**
  String get advancedBotsLocked;

  /// Paywall banner: lessons locked
  ///
  /// In en, this message translates to:
  /// **'Lessons 5 and beyond require Premium.'**
  String get premiumLessonsLocked;

  /// Learn screen: see-all lessons button
  ///
  /// In en, this message translates to:
  /// **'See all {count} lessons'**
  String seeAllLessons(int count);

  /// Puzzle hub: streak column label
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreakLabel;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Snapback'**
  String get snapback;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Ladder'**
  String get ladder;

  /// Puzzle category
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Lock badge label on premium-gated items
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get lockedPremium;

  /// Settings section: stone color preset picker
  ///
  /// In en, this message translates to:
  /// **'Stone Colors'**
  String get stoneColors;

  /// No description provided for @stoneColorClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get stoneColorClassic;

  /// No description provided for @stoneColorJade.
  ///
  /// In en, this message translates to:
  /// **'Jade'**
  String get stoneColorJade;

  /// No description provided for @stoneColorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get stoneColorAmber;

  /// No description provided for @stoneColorCobalt.
  ///
  /// In en, this message translates to:
  /// **'Cobalt'**
  String get stoneColorCobalt;

  /// No description provided for @stoneColorCrimson.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get stoneColorCrimson;

  /// No description provided for @stoneColorMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get stoneColorMono;

  /// Paywall: free trial badge under tagline
  ///
  /// In en, this message translates to:
  /// **'7-day free trial'**
  String get freeTrialBadge;

  /// Paywall: trial fine print
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get freeTrialSubtitle;

  /// No description provided for @ogsLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to OGS'**
  String get ogsLogin;

  /// No description provided for @onlineGoServer.
  ///
  /// In en, this message translates to:
  /// **'Online Go Server'**
  String get onlineGoServer;

  /// No description provided for @signInWithOgsAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your OGS account'**
  String get signInWithOgsAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterUsernamePassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter username and password'**
  String get enterUsernamePassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your credentials.'**
  String get loginFailed;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up on OGS'**
  String get noAccountSignUp;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithOgs.
  ///
  /// In en, this message translates to:
  /// **'Continue with OGS (Google, etc.)'**
  String get continueWithOgs;

  /// No description provided for @onlinePlay.
  ///
  /// In en, this message translates to:
  /// **'Online Play'**
  String get onlinePlay;

  /// No description provided for @onlineStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatusConnected;

  /// No description provided for @onlineStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get onlineStatusOffline;

  /// No description provided for @ogsPlayer.
  ///
  /// In en, this message translates to:
  /// **'OGS Player'**
  String get ogsPlayer;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @pleaseLogInToPlayOnline.
  ///
  /// In en, this message translates to:
  /// **'Please log in with OGS to play online'**
  String get pleaseLogInToPlayOnline;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Master the ancient game of Go'**
  String get appTagline;

  /// No description provided for @featurePlayBots.
  ///
  /// In en, this message translates to:
  /// **'Play vs KataGo & online bots'**
  String get featurePlayBots;

  /// No description provided for @featurePuzzlesLessons.
  ///
  /// In en, this message translates to:
  /// **'Puzzles, lessons & daily drills'**
  String get featurePuzzlesLessons;

  /// No description provided for @featureLiveGames.
  ///
  /// In en, this message translates to:
  /// **'Live games on Online Go Server'**
  String get featureLiveGames;

  /// No description provided for @signInWithOgs.
  ///
  /// In en, this message translates to:
  /// **'Sign in with OGS'**
  String get signInWithOgs;

  /// No description provided for @createOgsAccount.
  ///
  /// In en, this message translates to:
  /// **'Create free OGS account'**
  String get createOgsAccount;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @attributionAvatars.
  ///
  /// In en, this message translates to:
  /// **'Bot avatars: OpenMoji (CC BY-SA 4.0)'**
  String get attributionAvatars;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @unranked.
  ///
  /// In en, this message translates to:
  /// **'Unranked'**
  String get unranked;

  /// No description provided for @friendComputerOnline.
  ///
  /// In en, this message translates to:
  /// **'Friend, Computer, or Online'**
  String get friendComputerOnline;

  /// No description provided for @dailyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Daily Puzzle'**
  String get dailyPuzzle;

  /// No description provided for @playBot.
  ///
  /// In en, this message translates to:
  /// **'Play Bot'**
  String get playBot;

  /// No description provided for @vsComputerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a bot — offline AI'**
  String get vsComputerSubtitle;

  /// No description provided for @vsFriendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same device, pass-and-play'**
  String get vsFriendSubtitle;

  /// No description provided for @vsOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live games via OGS'**
  String get vsOnlineSubtitle;

  /// No description provided for @playFirstGameHint.
  ///
  /// In en, this message translates to:
  /// **'Play your first game — it will show up here.'**
  String get playFirstGameHint;

  /// No description provided for @puzzleStreak.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Streak'**
  String get puzzleStreak;

  /// No description provided for @puzzleStreakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solve until you miss'**
  String get puzzleStreakSubtitle;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get currentStreak;

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestLabel;

  /// No description provided for @streakEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Ended'**
  String get streakEndedTitle;

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get newRecord;

  /// No description provided for @puzzleModes.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Modes'**
  String get puzzleModes;

  /// No description provided for @leagueLabel.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get leagueLabel;

  /// No description provided for @leagueRookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get leagueRookie;

  /// No description provided for @leagueBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get leagueBronze;

  /// No description provided for @leagueSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get leagueSilver;

  /// No description provided for @leagueGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get leagueGold;

  /// No description provided for @leaguePlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get leaguePlatinum;

  /// No description provided for @leagueDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get leagueDiamond;

  /// No description provided for @puzzleMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get puzzleMap;

  /// No description provided for @puzzleList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get puzzleList;

  /// No description provided for @world1Beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner Garden'**
  String get world1Beginner;

  /// No description provided for @world2Intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Lake'**
  String get world2Intermediate;

  /// No description provided for @world3Advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Volcano'**
  String get world3Advanced;

  /// No description provided for @coachStreakIntro1.
  ///
  /// In en, this message translates to:
  /// **'Ready to start a streak?'**
  String get coachStreakIntro1;

  /// No description provided for @coachStreakIntro2.
  ///
  /// In en, this message translates to:
  /// **'How long can you go today?'**
  String get coachStreakIntro2;

  /// No description provided for @coachStreakIntro3.
  ///
  /// In en, this message translates to:
  /// **'Beat your best — give it a shot.'**
  String get coachStreakIntro3;

  /// No description provided for @coachStreakIntro4.
  ///
  /// In en, this message translates to:
  /// **'One miss ends the run. No pressure!'**
  String get coachStreakIntro4;

  /// No description provided for @coachStreakIntro5.
  ///
  /// In en, this message translates to:
  /// **'Daily practice keeps the mind sharp.'**
  String get coachStreakIntro5;

  /// No description provided for @coachSolve1.
  ///
  /// In en, this message translates to:
  /// **'Nice!'**
  String get coachSolve1;

  /// No description provided for @coachSolve2.
  ///
  /// In en, this message translates to:
  /// **'Brilliant!'**
  String get coachSolve2;

  /// No description provided for @coachSolve3.
  ///
  /// In en, this message translates to:
  /// **'Streak going!'**
  String get coachSolve3;

  /// No description provided for @coachSolve4.
  ///
  /// In en, this message translates to:
  /// **'That was tough!'**
  String get coachSolve4;

  /// No description provided for @coachSolve5.
  ///
  /// In en, this message translates to:
  /// **'Perfect read.'**
  String get coachSolve5;

  /// No description provided for @coachSolve6.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get coachSolve6;

  /// No description provided for @openLesson.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLesson;

  /// No description provided for @puzzleGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Beginner Garden'**
  String get puzzleGardenTitle;

  /// No description provided for @coachLeagueRookieUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Rookie! Let\'s grow that rating.'**
  String get coachLeagueRookieUnlocked;

  /// No description provided for @coachLeagueBronzeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Bronze League! You\'re on the board.'**
  String get coachLeagueBronzeUnlocked;

  /// No description provided for @coachLeagueSilverUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Silver League! Reading the board now.'**
  String get coachLeagueSilverUnlocked;

  /// No description provided for @coachLeagueGoldUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Gold League! Real fighter.'**
  String get coachLeagueGoldUnlocked;

  /// No description provided for @coachLeaguePlatinumUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Platinum League! Few make it this far.'**
  String get coachLeaguePlatinumUnlocked;

  /// No description provided for @coachLeagueDiamondUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Diamond League! Master class.'**
  String get coachLeagueDiamondUnlocked;

  /// No description provided for @coachKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Tap the next stone — keep climbing!'**
  String get coachKeepGoing;

  /// No description provided for @coachTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No worries — try a different point.'**
  String get coachTryAgain;

  /// No description provided for @xpToNextLeague.
  ///
  /// In en, this message translates to:
  /// **'{count} XP to {league}'**
  String xpToNextLeague(int count, String league);

  /// No description provided for @gateLockedUnlockAt.
  ///
  /// In en, this message translates to:
  /// **'Unlock at {xp} XP'**
  String gateLockedUnlockAt(int xp);

  /// No description provided for @solvePuzzles.
  ///
  /// In en, this message translates to:
  /// **'Solve Puzzles'**
  String get solvePuzzles;

  /// No description provided for @levelN.
  ///
  /// In en, this message translates to:
  /// **'Level {n}'**
  String levelN(int n);

  /// No description provided for @puzzleBestMove.
  ///
  /// In en, this message translates to:
  /// **'Find the best move'**
  String get puzzleBestMove;

  /// No description provided for @xpToUnlock.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpToUnlock(int xp);

  /// No description provided for @worldStoneForest.
  ///
  /// In en, this message translates to:
  /// **'Stone Forest'**
  String get worldStoneForest;

  /// No description provided for @worldCrystalCave.
  ///
  /// In en, this message translates to:
  /// **'Crystal Cave'**
  String get worldCrystalCave;

  /// No description provided for @worldCopperPeaks.
  ///
  /// In en, this message translates to:
  /// **'Copper Peaks'**
  String get worldCopperPeaks;

  /// No description provided for @worldDiamondTundra.
  ///
  /// In en, this message translates to:
  /// **'Diamond Tundra'**
  String get worldDiamondTundra;

  /// No description provided for @worldJadeHighlands.
  ///
  /// In en, this message translates to:
  /// **'Jade Highlands'**
  String get worldJadeHighlands;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @drillCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Drill Complete'**
  String get drillCompleteTitle;

  /// No description provided for @backToLearn.
  ///
  /// In en, this message translates to:
  /// **'Back to Learn'**
  String get backToLearn;

  /// No description provided for @quitDrillTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit Drill?'**
  String get quitDrillTitle;

  /// No description provided for @quitDrillBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will not be saved if you quit now.'**
  String get quitDrillBody;

  /// No description provided for @resignGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Resign Game?'**
  String get resignGameTitle;

  /// No description provided for @resignGameBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to resign?'**
  String get resignGameBody;

  /// No description provided for @undoRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo Request'**
  String get undoRequestTitle;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @gameInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Info'**
  String get gameInfoTitle;

  /// No description provided for @leaveGame.
  ///
  /// In en, this message translates to:
  /// **'Leave Game'**
  String get leaveGame;

  /// No description provided for @connectionTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Test'**
  String get connectionTestTitle;

  /// No description provided for @runConnectionTest.
  ///
  /// In en, this message translates to:
  /// **'Run Connection Test'**
  String get runConnectionTest;

  /// No description provided for @findOpponentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find an opponent instantly for a quick game'**
  String get findOpponentSubtitle;

  /// No description provided for @startMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Start a quick match to begin!'**
  String get startMatchHint;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @tutorialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialsTitle;

  /// No description provided for @learnGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnGardenTitle;

  /// No description provided for @categoryFundamentals.
  ///
  /// In en, this message translates to:
  /// **'Fundamentals'**
  String get categoryFundamentals;

  /// No description provided for @categoryRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get categoryRules;

  /// No description provided for @categoryLifeDeath.
  ///
  /// In en, this message translates to:
  /// **'Life & Death'**
  String get categoryLifeDeath;

  /// No description provided for @categoryStrategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get categoryStrategy;

  /// No description provided for @lessonsInCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String lessonsInCategoryCount(int count);

  /// No description provided for @continueLessonCta.
  ///
  /// In en, this message translates to:
  /// **'Continue Lesson'**
  String get continueLessonCta;

  /// No description provided for @startLessonCta.
  ///
  /// In en, this message translates to:
  /// **'Start First Lesson'**
  String get startLessonCta;

  /// No description provided for @lessonLocked.
  ///
  /// In en, this message translates to:
  /// **'Premium lesson'**
  String get lessonLocked;

  /// No description provided for @coachLearnIntro1.
  ///
  /// In en, this message translates to:
  /// **'Where to next?'**
  String get coachLearnIntro1;

  /// No description provided for @coachLearnIntro2.
  ///
  /// In en, this message translates to:
  /// **'One lesson a day keeps your brain sharp.'**
  String get coachLearnIntro2;

  /// No description provided for @coachLearnIntro3.
  ///
  /// In en, this message translates to:
  /// **'Try a quick lesson — it takes less than 5 minutes.'**
  String get coachLearnIntro3;

  /// No description provided for @coachLearnIntro4.
  ///
  /// In en, this message translates to:
  /// **'Pick a category — every path leads somewhere fun.'**
  String get coachLearnIntro4;

  /// No description provided for @coachLearnIntro5.
  ///
  /// In en, this message translates to:
  /// **'Tap a stone to start learning!'**
  String get coachLearnIntro5;

  /// No description provided for @coachCategoryDone.
  ///
  /// In en, this message translates to:
  /// **'Whole category cleared — incredible!'**
  String get coachCategoryDone;

  /// No description provided for @botDescPanda.
  ///
  /// In en, this message translates to:
  /// **'Sweet and silly. Loves playing random moves.'**
  String get botDescPanda;

  /// No description provided for @botDescPup.
  ///
  /// In en, this message translates to:
  /// **'Eager puppy chasing every stone. Easy to outsmart.'**
  String get botDescPup;

  /// No description provided for @botDescBunny.
  ///
  /// In en, this message translates to:
  /// **'Hops around the board with curious, unpredictable moves.'**
  String get botDescBunny;

  /// No description provided for @botDescKoi.
  ///
  /// In en, this message translates to:
  /// **'Soft and steady. Loves edge play and small enclosures.'**
  String get botDescKoi;

  /// No description provided for @botDescTanuki.
  ///
  /// In en, this message translates to:
  /// **'Tricky little spirit. Knows basic captures and shapes.'**
  String get botDescTanuki;

  /// No description provided for @botDescPebble.
  ///
  /// In en, this message translates to:
  /// **'Quiet and steady. Builds slowly toward solid frameworks.'**
  String get botDescPebble;

  /// No description provided for @botDescHeron.
  ///
  /// In en, this message translates to:
  /// **'Patient. Picks apart loose shapes near the side.'**
  String get botDescHeron;

  /// No description provided for @botDescOwl.
  ///
  /// In en, this message translates to:
  /// **'Wise and patient. Builds solid frameworks of territory.'**
  String get botDescOwl;

  /// No description provided for @botDescCrane.
  ///
  /// In en, this message translates to:
  /// **'Graceful and balanced. Plays light and flexible shapes.'**
  String get botDescCrane;

  /// No description provided for @botDescMantis.
  ///
  /// In en, this message translates to:
  /// **'Sharp and quick. Calculates tactical sequences.'**
  String get botDescMantis;

  /// No description provided for @botDescBadger.
  ///
  /// In en, this message translates to:
  /// **'Never lets a stone go without a fight.'**
  String get botDescBadger;

  /// No description provided for @botDescKitsune.
  ///
  /// In en, this message translates to:
  /// **'Cunning fox. Punishes overplays and rewards good shape.'**
  String get botDescKitsune;

  /// No description provided for @botDescPhoenix.
  ///
  /// In en, this message translates to:
  /// **'Rises from pressure with sharp counter-attacks.'**
  String get botDescPhoenix;

  /// No description provided for @botDescHawk.
  ///
  /// In en, this message translates to:
  /// **'Pressure player. Always probing your weak groups.'**
  String get botDescHawk;

  /// No description provided for @botDescTiger.
  ///
  /// In en, this message translates to:
  /// **'Fierce fighter. Loves to attack weak groups.'**
  String get botDescTiger;

  /// No description provided for @botDescOtter.
  ///
  /// In en, this message translates to:
  /// **'Flexible and playful. Pivots between attack and defence.'**
  String get botDescOtter;

  /// No description provided for @botDescDragon.
  ///
  /// In en, this message translates to:
  /// **'Powerful reading and clean endgame. Demands precision.'**
  String get botDescDragon;

  /// No description provided for @botDescSamurai.
  ///
  /// In en, this message translates to:
  /// **'Honor and discipline. Strong fighting plus clean shape.'**
  String get botDescSamurai;

  /// No description provided for @botDescTengu.
  ///
  /// In en, this message translates to:
  /// **'Mountain spirit. Strong fighting and efficient shape.'**
  String get botDescTengu;

  /// No description provided for @botDescMonk.
  ///
  /// In en, this message translates to:
  /// **'Calm, deep positional understanding. Whole-board sight.'**
  String get botDescMonk;

  /// No description provided for @botDescOracle.
  ///
  /// In en, this message translates to:
  /// **'Sees variations a dozen moves ahead. Hard to fool.'**
  String get botDescOracle;

  /// No description provided for @botDescSensei.
  ///
  /// In en, this message translates to:
  /// **'Wise teacher. Plays the most instructive professional moves.'**
  String get botDescSensei;

  /// No description provided for @botDescKataGo.
  ///
  /// In en, this message translates to:
  /// **'Plans dozens of moves ahead with neural-network lookahead. Superhuman strategic vision.'**
  String get botDescKataGo;

  /// No description provided for @tauntDefaultGreet.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play!'**
  String get tauntDefaultGreet;

  /// No description provided for @tauntDefaultWin.
  ///
  /// In en, this message translates to:
  /// **'Good game! You earned that one.'**
  String get tauntDefaultWin;

  /// No description provided for @tauntDefaultLose.
  ///
  /// In en, this message translates to:
  /// **'Nicely played — better luck next time!'**
  String get tauntDefaultLose;

  /// No description provided for @tauntDefaultResign.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the game!'**
  String get tauntDefaultResign;

  /// No description provided for @tauntPandaGreet.
  ///
  /// In en, this message translates to:
  /// **'Hi friend! Let\'s play!'**
  String get tauntPandaGreet;

  /// No description provided for @tauntPandaWin.
  ///
  /// In en, this message translates to:
  /// **'Yay! I won!'**
  String get tauntPandaWin;

  /// No description provided for @tauntPandaLose.
  ///
  /// In en, this message translates to:
  /// **'You\'re really good!'**
  String get tauntPandaLose;

  /// No description provided for @undoMove.
  ///
  /// In en, this message translates to:
  /// **'Undo move'**
  String get undoMove;

  /// No description provided for @passTurn.
  ///
  /// In en, this message translates to:
  /// **'Pass turn'**
  String get passTurn;

  /// No description provided for @redoMove.
  ///
  /// In en, this message translates to:
  /// **'Redo move'**
  String get redoMove;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @practiceBadge.
  ///
  /// In en, this message translates to:
  /// **'PRACTICE'**
  String get practiceBadge;

  /// No description provided for @notYourTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s not your turn!'**
  String get notYourTurn;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @draws.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get draws;

  /// No description provided for @winLossLabel.
  ///
  /// In en, this message translates to:
  /// **'Win / Loss'**
  String get winLossLabel;

  /// No description provided for @playGamesHint.
  ///
  /// In en, this message translates to:
  /// **'Play games to see your split here.'**
  String get playGamesHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noPuzzlesForFilter.
  ///
  /// In en, this message translates to:
  /// **'No puzzles for this filter.'**
  String get noPuzzlesForFilter;

  /// No description provided for @tutorialsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tutorials: {error}'**
  String tutorialsLoadError(String error);

  /// No description provided for @noTutorialsYet.
  ///
  /// In en, this message translates to:
  /// **'No tutorials available yet.'**
  String get noTutorialsYet;

  /// No description provided for @practiceModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceModeTitle;

  /// No description provided for @practiceModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best move shown after each turn · result is 1 ★'**
  String get practiceModeSubtitle;

  /// No description provided for @chooseBoardSize.
  ///
  /// In en, this message translates to:
  /// **'Choose board size'**
  String get chooseBoardSize;

  /// No description provided for @undoRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Undo request sent'**
  String get undoRequestSent;

  /// No description provided for @undoRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Undo request declined'**
  String get undoRequestDeclined;

  /// No description provided for @undoRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Undo request accepted'**
  String get undoRequestAccepted;

  /// No description provided for @opponentRequestedUndo.
  ///
  /// In en, this message translates to:
  /// **'Your opponent requested an undo to move #{moveNumber}.'**
  String opponentRequestedUndo(int moveNumber);

  /// No description provided for @suggestedRemovedStones.
  ///
  /// In en, this message translates to:
  /// **'Suggested {count} removed stones'**
  String suggestedRemovedStones(int count);

  /// No description provided for @gameIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Game ID: {id}'**
  String gameIdLabel(String id);

  /// No description provided for @moveLabel.
  ///
  /// In en, this message translates to:
  /// **'Move: {n}'**
  String moveLabel(int n);

  /// No description provided for @phaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase: {phase}'**
  String phaseLabel(String phase);

  /// No description provided for @boardLabel.
  ///
  /// In en, this message translates to:
  /// **'Board: {size}'**
  String boardLabel(String size);

  /// No description provided for @hintLookAt.
  ///
  /// In en, this message translates to:
  /// **'Look at row {row}, column {col} — there\'s a strong move here.'**
  String hintLookAt(int row, String col);

  /// No description provided for @hintFallbackGeneric.
  ///
  /// In en, this message translates to:
  /// **'Find the move that pressures the opposing stones — look for atari, weak groups, or eye shapes.'**
  String get hintFallbackGeneric;

  /// No description provided for @paywallHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock GOKO Premium'**
  String get paywallHeroTitle;

  /// No description provided for @paywallHeroTagline.
  ///
  /// In en, this message translates to:
  /// **'Master the ancient game'**
  String get paywallHeroTagline;

  /// No description provided for @paywallFeatureUnlimitedPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Unlimited daily puzzles'**
  String get paywallFeatureUnlimitedPuzzles;

  /// No description provided for @paywallFeatureAllBots.
  ///
  /// In en, this message translates to:
  /// **'All bots — Pup to KataGo'**
  String get paywallFeatureAllBots;

  /// No description provided for @paywallFeatureLessons.
  ///
  /// In en, this message translates to:
  /// **'Full lesson library + post-game analysis'**
  String get paywallFeatureLessons;

  /// No description provided for @paywallFeatureSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync, badges & profile flair'**
  String get paywallFeatureSync;

  /// No description provided for @pricingTierMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get pricingTierMonthly;

  /// No description provided for @pricingTierAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get pricingTierAnnual;

  /// No description provided for @pricingTierLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get pricingTierLifetime;

  /// No description provided for @pricingPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get pricingPopular;

  /// No description provided for @pricingBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get pricingBestValue;

  /// No description provided for @pricingSave.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String pricingSave(int percent);

  /// No description provided for @pricingPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price}/mo'**
  String pricingPerMonth(String price);

  /// No description provided for @pricingPerYear.
  ///
  /// In en, this message translates to:
  /// **'{price}/yr'**
  String pricingPerYear(String price);

  /// No description provided for @pricingOnce.
  ///
  /// In en, this message translates to:
  /// **'{price} once'**
  String pricingOnce(String price);

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day Free Trial'**
  String get startFreeTrial;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @renewsAtPrice.
  ///
  /// In en, this message translates to:
  /// **'Renews at {price}'**
  String renewsAtPrice(String price);

  /// No description provided for @trustedByPlayers.
  ///
  /// In en, this message translates to:
  /// **'Trusted by {count}+ players'**
  String trustedByPlayers(String count);

  /// No description provided for @freeTrialDuration.
  ///
  /// In en, this message translates to:
  /// **'7 days free'**
  String get freeTrialDuration;

  /// No description provided for @paywallContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get paywallContinueFree;

  /// No description provided for @scoreStonesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stones'**
  String get scoreStonesLabel;

  /// No description provided for @scoreTerritoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Territory'**
  String get scoreTerritoryLabel;

  /// No description provided for @scoreCapturedLabel.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get scoreCapturedLabel;

  /// Snackbar when game enters scoring phase
  ///
  /// In en, this message translates to:
  /// **'Game ended - Mark dead stones for scoring'**
  String get gameEndedMarkDeadStones;

  /// Snackbar when game is complete
  ///
  /// In en, this message translates to:
  /// **'Game finished'**
  String get gameFinished;

  /// Snackbar confirming stone removal
  ///
  /// In en, this message translates to:
  /// **'Stone removal accepted'**
  String get stoneRemovalAccepted;

  /// Snackbar when trying to move while another move pending
  ///
  /// In en, this message translates to:
  /// **'Please wait for previous move'**
  String get waitForPreviousMove;

  /// Snackbar when trying to place stone on occupied point
  ///
  /// In en, this message translates to:
  /// **'Position already occupied'**
  String get positionAlreadyOccupied;

  /// Snackbar when move violates go rules
  ///
  /// In en, this message translates to:
  /// **'Invalid move (suicide or ko rule violation)'**
  String get invalidMoveSuicideOrKo;

  /// Snackbar when move submission times out
  ///
  /// In en, this message translates to:
  /// **'Move timed out - please try again'**
  String get moveTimedOut;

  /// Low time alert
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds remaining!'**
  String timeSecondsRemaining(int seconds);

  /// Byoyomi time display
  ///
  /// In en, this message translates to:
  /// **'Period {periods} - {time}s'**
  String periodTimeRemaining(int periods, int time);

  /// Learn rank tier — 0 lessons completed
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get learningRankNovice;

  /// Learn rank tier — 3+ lessons completed
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get learningRankApprentice;

  /// Learn rank tier — 7+ lessons completed
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get learningRankScholar;

  /// Learn rank tier — 12+ lessons completed
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get learningRankMaster;

  /// Learn rank tier — 18+ lessons completed
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get learningRankGrandmaster;

  /// Sub-text on Learn header — how many more lessons until the next rank
  ///
  /// In en, this message translates to:
  /// **'{count} lessons to {rank}'**
  String lessonsToNextRank(int count, String rank);

  /// Badge on the next-up unfinished lesson/level tile
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// Tiny label above the title in the floating CTA card
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get nextUp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
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
