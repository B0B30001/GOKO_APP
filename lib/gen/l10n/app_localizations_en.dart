// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GOKO';

  @override
  String get play => 'Play';

  @override
  String get learn => 'Learn';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get practice => 'Practice';

  @override
  String get playVsBot => 'Play vs Bot';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get recentGames => 'Recent Games';

  @override
  String get heroPrimary => 'Play • Learn • Improve';

  @override
  String get heroSub => 'Everything works offline – no account needed!';

  @override
  String get selectGameMode => 'Select Game Mode';

  @override
  String get vsComputer => 'vs Computer';

  @override
  String get vsFriend => 'vs Friend (Same Device)';

  @override
  String get vsOnline => 'vs Online';

  @override
  String get selectBoardSize => 'Select Board Size';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get learnGo => 'Learn Go';

  @override
  String get lessons => 'Lessons';

  @override
  String get practiceTab => 'Practice';

  @override
  String get statistics => 'Statistics';

  @override
  String get games => 'Games';

  @override
  String get winRate => 'Win rate';

  @override
  String get puzzleRating => 'Puzzle rating';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Switch between light and dark themes';

  @override
  String get showCoordinates => 'Show board coordinates';

  @override
  String get lightThemeInGame => 'Light theme in game';

  @override
  String get lightThemeInGameSubtitle => 'Force light theme on the Game screen';

  @override
  String get puzzleSolved => 'Puzzle Solved!';

  @override
  String get notQuite => 'Not quite';

  @override
  String get hint => 'Hint';

  @override
  String get reset => 'Reset';

  @override
  String get tryAgain => 'Try again';

  @override
  String get giveUp => 'Give up';

  @override
  String get stepBack => 'Step back';

  @override
  String get continue_ => 'Continue';

  @override
  String get nextPuzzle => 'Next puzzle';

  @override
  String get theoryExplanation => 'Theory & Explanation';

  @override
  String get solveToUnlock => 'Solve to unlock';

  @override
  String get learnWhyThisWorks => 'Learn why this works';

  @override
  String get keyConceptPrefix => 'Key Concept: ';

  @override
  String get gameHistory => 'Game History';

  @override
  String get noRecentGames => 'No recent games';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get playVsBotTitle => 'Play vs Bot';

  @override
  String get kataGoSection => 'AI / KataGo';

  @override
  String get kataGoServerUrl => 'KataGo Server URL';

  @override
  String get kataGoHint => 'Leave empty to use built-in MCTS engine offline.';

  @override
  String get leelaServerUrl => 'Leela Zero / GTP Server URL';

  @override
  String get leelaHint =>
      'Connect any GTP-over-WebSocket engine (Leela Zero, ELF OpenGo). Ignored when KataGo URL is set.';

  @override
  String get localEngineTitle => 'Local AI Engine';

  @override
  String get localEngineSubtitle => 'Auto-managed KataGo (no server needed)';

  @override
  String get engineStatusReady => 'KataGo ready';

  @override
  String get engineStatusStarting => 'Starting…';

  @override
  String get engineStatusNotFound => 'Not installed';

  @override
  String get engineStatusError => 'Error';

  @override
  String get enginesFolderLabel => 'Engines Folder';

  @override
  String get downloadKataGo => 'Download KataGo';

  @override
  String get engineRestartButton => 'Restart Engine';

  @override
  String get prev => 'Prev';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get playDemo => 'Play demo';

  @override
  String get replayDemo => 'Replay demo';

  @override
  String get playingDemo => 'Playing…';

  @override
  String get interactiveTapBoard => 'Interactive — tap the board';

  @override
  String get sourcePrefix => 'Source: ';

  @override
  String stepXofY(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get dailyPuzzles => 'Daily Puzzles';

  @override
  String get collections => 'Collections';

  @override
  String get categories => 'Categories';

  @override
  String get captures => 'Captures';

  @override
  String get liberties => 'Liberties';

  @override
  String get lifeDeath => 'Life & Death';

  @override
  String get koBasics => 'Ko Basics';

  @override
  String get tesuji => 'Tesuji';

  @override
  String get swap => 'Swap';

  @override
  String swapsLeft(int count) {
    return '$count swaps left';
  }

  @override
  String solvedCount(int solved, int total) {
    return '$solved/$total solved';
  }

  @override
  String get learningPath => 'Learning Path';

  @override
  String get allTutorials => 'All Tutorials';

  @override
  String get byLevel => 'By Level';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get objective => 'Objective';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get yourTurn => 'Your Turn';

  @override
  String get moves => 'Moves';

  @override
  String get markAsLearned => 'Mark as Learned ✓';

  @override
  String get blackToPlay => 'Black to play';

  @override
  String get whiteToPlay => 'White to play';

  @override
  String get comingSoon => 'Soon';

  @override
  String get general => 'General';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsSubtitle => 'Play sounds during the game';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Vibrate on move';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Get notified about your games';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get themeLabel => 'Theme';

  @override
  String get boardThemeLabel => 'Board theme';

  @override
  String get backgroundThemeLabel => 'Background theme';

  @override
  String get themeDarkBlue => 'Dark Blue';

  @override
  String get themeOledBlack => 'OLED Black';

  @override
  String get themeClassicWood => 'Classic Wood';

  @override
  String get themeLightMode => 'Light Mode';

  @override
  String get themeHalloween => 'Halloween';

  @override
  String get themeWinter => 'Winter';

  @override
  String get themeForest => 'Forest';

  @override
  String get boardClassic => 'Classic';

  @override
  String get boardWalnut => 'Walnut';

  @override
  String get boardSlate => 'Slate';

  @override
  String get boardNight => 'Night';

  @override
  String get bgStandard => 'Standard';

  @override
  String get bgMinimal => 'Minimal';

  @override
  String get bgWarm => 'Warm';

  @override
  String get bgCool => 'Cool';

  @override
  String get conceptLibertiesCaptures => 'Liberties & Captures';

  @override
  String get conceptLibertyCounting => 'Liberty Counting';

  @override
  String get conceptLifeDeathTwoEyes => 'Life & Death - Two Eyes';

  @override
  String get conceptKoRule => 'Ko Rule';

  @override
  String get conceptLibertiesCapturesDesc =>
      'Stones are captured when all their liberties (adjacent empty points) are occupied by enemy stones. Connected stones share liberties as a single group.';

  @override
  String get conceptLibertyCountingDesc =>
      'Each empty point adjacent to a stone or group is a liberty. Connected stones form one group and share all their liberties. When a group has only one liberty left, it\'s in \"atari\" (check).';

  @override
  String get conceptLifeDeathDesc =>
      'A group with two separate eyes cannot be captured because the opponent cannot fill both eyes simultaneously. This is fundamental to understanding which groups are alive and which can be killed.';

  @override
  String get conceptKoRuleDesc =>
      'The Ko rule prevents infinite loops by prohibiting immediate recapture in a repeating position. After capturing in Ko, you must play elsewhere before you can recapture.';

  @override
  String get analysisPanelTitle => 'Analysis';

  @override
  String get analysisOn => 'Enable Analysis';

  @override
  String get analysisOff => 'Disable Analysis';

  @override
  String get noServerForAnalysis =>
      'Configure a KataGo server in Settings to enable analysis.';

  @override
  String get moveQualityBest => 'Best';

  @override
  String get moveQualityGood => 'Good';

  @override
  String get moveQualityInaccuracy => 'Inaccuracy';

  @override
  String get moveQualityMistake => 'Mistake';

  @override
  String get moveQualityBlunder => 'Blunder';

  @override
  String get moveQualityExcellent => 'Excellent';

  @override
  String get cancel => 'Cancel';

  @override
  String get aiThinking => 'AI thinking…';

  @override
  String get noLegalMoves =>
      'No legal moves available. Press Pass to continue.';

  @override
  String get useHintTitle => 'Use a hint?';

  @override
  String useHintContent(int remaining) {
    return 'Reveal the best move. Costs 1 ★ ($remaining left).';
  }

  @override
  String get showHint => 'Show hint';

  @override
  String get noHintAvailable => 'No hint available — try passing.';

  @override
  String get resignTitle => 'Resign this game?';

  @override
  String get resignConfirmBot => 'Your opponent will win by resignation.';

  @override
  String resignConfirmLocal(String side) {
    return '$side resigns. The other side wins.';
  }

  @override
  String get resign => 'Resign';

  @override
  String get gameReview => 'Game Review';

  @override
  String get rematch => 'Rematch';

  @override
  String get close => 'Close';

  @override
  String get noHintsRemaining => 'No hints remaining';

  @override
  String get showBestMove => 'Show best move (-1 ★)';

  @override
  String get noHintsUsed => 'No hints used';

  @override
  String hintsUsed(int count) {
    return '$count hint(s) used';
  }

  @override
  String get resumeLesson => 'Resume lesson?';

  @override
  String resumeLessonContent(int step) {
    return 'Continue from step $step?';
  }

  @override
  String get startOver => 'Start over';

  @override
  String get resume => 'Resume';

  @override
  String get notQuiteTapHint => 'Not quite — try a different point.';

  @override
  String get hintShownTapHint => 'Hint: follow the marker.';

  @override
  String get lessonComplete => 'Lesson complete!';

  @override
  String dayStreak(int count) {
    return '$count day streak';
  }

  @override
  String get master => 'Master';

  @override
  String get quickDrills => 'Quick Drills';

  @override
  String get score => 'Score';

  @override
  String get black => 'Black';

  @override
  String get white => 'White';

  @override
  String get you => 'You';

  @override
  String get computer => 'Computer';

  @override
  String get whiteWinsByResignation => 'White wins by resignation';

  @override
  String get blackWinsByResignation => 'Black wins by resignation';

  @override
  String blackWinsByPoints(int points) {
    return 'Black wins by $points points!';
  }

  @override
  String whiteWinsByPoints(int points) {
    return 'White wins by $points points!';
  }

  @override
  String get gameTied => 'Game is tied!';

  @override
  String get gameReviewComingSoon => 'Game Review coming soon';

  @override
  String get rating => 'Rating';

  @override
  String get today => 'Today';

  @override
  String get streak => 'Streak';

  @override
  String get xp => 'XP';

  @override
  String get seeAll => 'See all';

  @override
  String get save => 'Save';

  @override
  String get swapPuzzle => 'Swap puzzle';

  @override
  String get replay => 'Replay';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get noLessonsYet => 'No lessons yet';

  @override
  String get finishPreviousLesson =>
      'Finish the previous lesson to unlock this.';

  @override
  String get noGamesYet => 'No games yet — finish one to see it here.';

  @override
  String get premium => 'Premium';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get youArePremium => 'You are Premium';

  @override
  String get unlockGokoPremium => 'Unlock GOKO Premium';

  @override
  String get paywallTagline =>
      'Train deeper. Play stronger. Unlock everything.';

  @override
  String get unlimitedPuzzles => 'Unlimited puzzles';

  @override
  String get freePuzzleLimit => 'Free users get 3 puzzles per day';

  @override
  String get allBotsAndLessons => 'All bots & lessons';

  @override
  String get allBotsAndLessonsDesc =>
      'Beginner bots and first 4 lessons are free';

  @override
  String get postGameAnalysis => 'Post-game analysis';

  @override
  String get postGameAnalysisDesc =>
      'Deep review of any finished game (coming soon)';

  @override
  String get profileFlair => 'Profile flair';

  @override
  String get profileFlairDesc => 'Premium badges and avatar borders';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get puzzleDailyQuotaReached =>
      'You\'ve used today\'s 3 free puzzles. Upgrade for unlimited.';

  @override
  String get advancedBotsLocked =>
      'Intermediate, Advanced, and Master bots require Premium.';

  @override
  String get premiumLessonsLocked => 'Lessons 5 and beyond require Premium.';

  @override
  String seeAllLessons(int count) {
    return 'See all $count lessons';
  }

  @override
  String get dayStreakLabel => 'Day Streak';

  @override
  String get snapback => 'Snapback';

  @override
  String get ladder => 'Ladder';

  @override
  String get connect => 'Connect';

  @override
  String get lockedPremium => 'Premium';

  @override
  String get stoneColors => 'Stone Colors';

  @override
  String get stoneColorClassic => 'Classic';

  @override
  String get stoneColorJade => 'Jade';

  @override
  String get stoneColorAmber => 'Amber';

  @override
  String get stoneColorCobalt => 'Cobalt';

  @override
  String get stoneColorCrimson => 'Crimson';

  @override
  String get stoneColorMono => 'Mono';

  @override
  String get freeTrialBadge => '7-day free trial';

  @override
  String get freeTrialSubtitle => 'Cancel anytime';

  @override
  String get ogsLogin => 'OGS Login';

  @override
  String get onlineGoServer => 'Online Go Server';

  @override
  String get signInWithOgsAccount => 'Sign in with your OGS account';

  @override
  String get signIn => 'Sign In';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get enterUsernamePassword => 'Please enter username and password';

  @override
  String get loginFailed => 'Login failed. Check your credentials.';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up on OGS';

  @override
  String get onlinePlay => 'Online Play';

  @override
  String get onlineStatusConnected => 'Online';

  @override
  String get onlineStatusOffline => 'Offline';

  @override
  String get ogsPlayer => 'OGS Player';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get pleaseLogInToPlayOnline => 'Please log in with OGS to play online';

  @override
  String get goBack => 'Go Back';

  @override
  String get appTagline => 'Master the ancient game of Go';

  @override
  String get featurePlayBots => 'Play vs KataGo & online bots';

  @override
  String get featurePuzzlesLessons => 'Puzzles, lessons & daily drills';

  @override
  String get featureLiveGames => 'Live games on Online Go Server';

  @override
  String get signInWithOgs => 'Sign in with OGS';

  @override
  String get createOgsAccount => 'Create free OGS account';

  @override
  String get displayName => 'Display name';

  @override
  String get attributionAvatars => 'Bot avatars: OpenMoji (CC BY-SA 4.0)';
}
