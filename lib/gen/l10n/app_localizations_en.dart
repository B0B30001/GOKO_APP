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
  String get illegalMoveFeedback =>
      'Illegal move (Ko / suicide) — try another point.';

  @override
  String get wrongMoveFeedback => 'Not the right move — try again!';

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
  String get comingSoon => 'Coming Soon';

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
      'Replay every move and rewind any finished game.';

  @override
  String get profileFlair => 'Profile flair';

  @override
  String get profileFlairDesc => 'Premium badges and avatar borders';

  @override
  String get restorePurchases => 'Restore Purchases';

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
  String get ogsLogin => 'Sign in to OGS';

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
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithOgs => 'Continue with OGS (Google, etc.)';

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

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get unranked => 'Unranked';

  @override
  String get friendComputerOnline => 'Friend, Computer, or Online';

  @override
  String get dailyPuzzle => 'Daily Puzzle';

  @override
  String get playBot => 'Play Bot';

  @override
  String get vsComputerSubtitle => 'Pick a bot — offline AI';

  @override
  String get vsFriendSubtitle => 'Same device, pass-and-play';

  @override
  String get vsOnlineSubtitle => 'Live games via OGS';

  @override
  String get playFirstGameHint =>
      'Play your first game — it will show up here.';

  @override
  String get puzzleStreak => 'Puzzle Streak';

  @override
  String get puzzleStreakSubtitle => 'Solve until you miss';

  @override
  String get currentStreak => 'Streak';

  @override
  String get bestLabel => 'Best';

  @override
  String get streakEndedTitle => 'Streak Ended';

  @override
  String get newRecord => 'New Record!';

  @override
  String get puzzleModes => 'Puzzle Modes';

  @override
  String get leagueLabel => 'League';

  @override
  String get leagueRookie => 'Rookie';

  @override
  String get leagueBronze => 'Bronze';

  @override
  String get leagueSilver => 'Silver';

  @override
  String get leagueGold => 'Gold';

  @override
  String get leaguePlatinum => 'Platinum';

  @override
  String get leagueDiamond => 'Diamond';

  @override
  String get puzzleMap => 'Map';

  @override
  String get puzzleList => 'List';

  @override
  String get world1Beginner => 'Beginner Garden';

  @override
  String get world2Intermediate => 'Intermediate Lake';

  @override
  String get world3Advanced => 'Advanced Volcano';

  @override
  String get coachStreakIntro1 => 'Ready to start a streak?';

  @override
  String get coachStreakIntro2 => 'How long can you go today?';

  @override
  String get coachStreakIntro3 => 'Beat your best — give it a shot.';

  @override
  String get coachStreakIntro4 => 'One miss ends the run. No pressure!';

  @override
  String get coachStreakIntro5 => 'Daily practice keeps the mind sharp.';

  @override
  String get coachSolve1 => 'Nice!';

  @override
  String get coachSolve2 => 'Brilliant!';

  @override
  String get coachSolve3 => 'Streak going!';

  @override
  String get coachSolve4 => 'That was tough!';

  @override
  String get coachSolve5 => 'Perfect read.';

  @override
  String get coachSolve6 => 'Keep it up!';

  @override
  String get openLesson => 'Open';

  @override
  String get puzzleGardenTitle => 'Beginner Garden';

  @override
  String get coachLeagueRookieUnlocked =>
      'Welcome, Rookie! Let\'s grow that rating.';

  @override
  String get coachLeagueBronzeUnlocked =>
      'Bronze League! You\'re on the board.';

  @override
  String get coachLeagueSilverUnlocked =>
      'Silver League! Reading the board now.';

  @override
  String get coachLeagueGoldUnlocked => 'Gold League! Real fighter.';

  @override
  String get coachLeaguePlatinumUnlocked =>
      'Platinum League! Few make it this far.';

  @override
  String get coachLeagueDiamondUnlocked => 'Diamond League! Master class.';

  @override
  String get coachKeepGoing => 'Tap the next stone — keep climbing!';

  @override
  String get coachTryAgain => 'No worries — try a different point.';

  @override
  String xpToNextLeague(int count, String league) {
    return '$count XP to $league';
  }

  @override
  String gateLockedUnlockAt(int xp) {
    return 'Unlock at $xp XP';
  }

  @override
  String get solvePuzzles => 'Solve Puzzles';

  @override
  String levelN(int n) {
    return 'Level $n';
  }

  @override
  String get puzzleBestMove => 'Find the best move';

  @override
  String xpToUnlock(int xp) {
    return '+$xp XP';
  }

  @override
  String get worldStoneForest => 'Stone Forest';

  @override
  String get worldCrystalCave => 'Crystal Cave';

  @override
  String get worldCopperPeaks => 'Copper Peaks';

  @override
  String get worldDiamondTundra => 'Diamond Tundra';

  @override
  String get worldJadeHighlands => 'Jade Highlands';

  @override
  String get quit => 'Quit';

  @override
  String get drillCompleteTitle => 'Drill Complete';

  @override
  String get backToLearn => 'Back to Learn';

  @override
  String get quitDrillTitle => 'Quit Drill?';

  @override
  String get quitDrillBody =>
      'Your progress will not be saved if you quit now.';

  @override
  String get resignGameTitle => 'Resign Game?';

  @override
  String get resignGameBody => 'Are you sure you want to resign?';

  @override
  String get undoRequestTitle => 'Undo Request';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get gameInfoTitle => 'Game Info';

  @override
  String get leaveGame => 'Leave Game';

  @override
  String get connectionTestTitle => 'Connection Test';

  @override
  String get runConnectionTest => 'Run Connection Test';

  @override
  String get findOpponentSubtitle =>
      'Find an opponent instantly for a quick game';

  @override
  String get startMatchHint => 'Start a quick match to begin!';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get tutorialsTitle => 'Tutorials';

  @override
  String get learnGardenTitle => 'Learn';

  @override
  String get categoryFundamentals => 'Fundamentals';

  @override
  String get categoryRules => 'Rules';

  @override
  String get categoryLifeDeath => 'Life & Death';

  @override
  String get categoryStrategy => 'Strategy';

  @override
  String lessonsInCategoryCount(int count) {
    return '$count lessons';
  }

  @override
  String get continueLessonCta => 'Continue Lesson';

  @override
  String get startLessonCta => 'Start First Lesson';

  @override
  String get lessonLocked => 'Premium lesson';

  @override
  String get coachLearnIntro1 => 'Where to next?';

  @override
  String get coachLearnIntro2 => 'One lesson a day keeps your brain sharp.';

  @override
  String get coachLearnIntro3 =>
      'Try a quick lesson — it takes less than 5 minutes.';

  @override
  String get coachLearnIntro4 =>
      'Pick a category — every path leads somewhere fun.';

  @override
  String get coachLearnIntro5 => 'Tap a stone to start learning!';

  @override
  String get coachCategoryDone => 'Whole category cleared — incredible!';

  @override
  String get botDescPanda => 'Sweet and silly. Loves playing random moves.';

  @override
  String get botDescPup => 'Eager puppy chasing every stone. Easy to outsmart.';

  @override
  String get botDescBunny =>
      'Hops around the board with curious, unpredictable moves.';

  @override
  String get botDescKoi =>
      'Soft and steady. Loves edge play and small enclosures.';

  @override
  String get botDescTanuki =>
      'Tricky little spirit. Knows basic captures and shapes.';

  @override
  String get botDescPebble =>
      'Quiet and steady. Builds slowly toward solid frameworks.';

  @override
  String get botDescHeron => 'Patient. Picks apart loose shapes near the side.';

  @override
  String get botDescOwl =>
      'Wise and patient. Builds solid frameworks of territory.';

  @override
  String get botDescCrane =>
      'Graceful and balanced. Plays light and flexible shapes.';

  @override
  String get botDescMantis => 'Sharp and quick. Calculates tactical sequences.';

  @override
  String get botDescBadger => 'Never lets a stone go without a fight.';

  @override
  String get botDescKitsune =>
      'Cunning fox. Punishes overplays and rewards good shape.';

  @override
  String get botDescPhoenix =>
      'Rises from pressure with sharp counter-attacks.';

  @override
  String get botDescHawk => 'Pressure player. Always probing your weak groups.';

  @override
  String get botDescTiger => 'Fierce fighter. Loves to attack weak groups.';

  @override
  String get botDescOtter =>
      'Flexible and playful. Pivots between attack and defence.';

  @override
  String get botDescDragon =>
      'Powerful reading and clean endgame. Demands precision.';

  @override
  String get botDescSamurai =>
      'Honor and discipline. Strong fighting plus clean shape.';

  @override
  String get botDescTengu =>
      'Mountain spirit. Strong fighting and efficient shape.';

  @override
  String get botDescMonk =>
      'Calm, deep positional understanding. Whole-board sight.';

  @override
  String get botDescOracle =>
      'Sees variations a dozen moves ahead. Hard to fool.';

  @override
  String get botDescSensei =>
      'Wise teacher. Plays the most instructive professional moves.';

  @override
  String get botDescKataGo =>
      'Plans dozens of moves ahead with neural-network lookahead. Superhuman strategic vision.';

  @override
  String get tauntDefaultGreet => 'Let\'s play!';

  @override
  String get tauntDefaultWin => 'Good game! You earned that one.';

  @override
  String get tauntDefaultLose => 'Nicely played — better luck next time!';

  @override
  String get tauntDefaultResign => 'Thanks for the game!';

  @override
  String get tauntPandaGreet => 'Hi friend! Let\'s play!';

  @override
  String get tauntPandaWin => 'Yay! I won!';

  @override
  String get tauntPandaLose => 'You\'re really good!';

  @override
  String get undoMove => 'Undo move';

  @override
  String get passTurn => 'Pass turn';

  @override
  String get redoMove => 'Redo move';

  @override
  String get newGame => 'New game';

  @override
  String get practiceBadge => 'PRACTICE';

  @override
  String get notYourTurn => 'It\'s not your turn!';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get draws => 'Draws';

  @override
  String get winLossLabel => 'Win / Loss';

  @override
  String get playGamesHint => 'Play games to see your split here.';

  @override
  String get filterAll => 'All';

  @override
  String get noPuzzlesForFilter => 'No puzzles for this filter.';

  @override
  String tutorialsLoadError(String error) {
    return 'Failed to load tutorials: $error';
  }

  @override
  String get noTutorialsYet => 'No tutorials available yet.';

  @override
  String get practiceModeTitle => 'Practice Mode';

  @override
  String get practiceModeSubtitle =>
      'Best move shown after each turn · result is 1 ★';

  @override
  String get chooseBoardSize => 'Choose board size';

  @override
  String get undoRequestSent => 'Undo request sent';

  @override
  String get undoRequestDeclined => 'Undo request declined';

  @override
  String get undoRequestAccepted => 'Undo request accepted';

  @override
  String opponentRequestedUndo(int moveNumber) {
    return 'Your opponent requested an undo to move #$moveNumber.';
  }

  @override
  String suggestedRemovedStones(int count) {
    return 'Suggested $count removed stones';
  }

  @override
  String gameIdLabel(String id) {
    return 'Game ID: $id';
  }

  @override
  String moveLabel(int n) {
    return 'Move: $n';
  }

  @override
  String phaseLabel(String phase) {
    return 'Phase: $phase';
  }

  @override
  String boardLabel(String size) {
    return 'Board: $size';
  }

  @override
  String hintLookAt(int row, String col) {
    return 'Look at row $row, column $col — there\'s a strong move here.';
  }

  @override
  String get hintFallbackGeneric =>
      'Find the move that pressures the opposing stones — look for atari, weak groups, or eye shapes.';

  @override
  String get paywallHeroTitle => 'Unlock GOKO Premium';

  @override
  String get paywallHeroTagline => 'Master the ancient game';

  @override
  String get paywallFeatureUnlimitedPuzzles => 'Unlimited daily puzzles';

  @override
  String get paywallFeatureAllBots => 'All bots — Pup to KataGo';

  @override
  String get paywallFeatureLessons =>
      'Full lesson library + post-game analysis';

  @override
  String get paywallFeatureSync => 'Cloud sync, badges & profile flair';

  @override
  String get pricingTierMonthly => 'Monthly';

  @override
  String get pricingTierAnnual => 'Annual';

  @override
  String get pricingTierLifetime => 'Lifetime';

  @override
  String get pricingPopular => 'MOST POPULAR';

  @override
  String get pricingBestValue => 'Best value';

  @override
  String pricingSave(int percent) {
    return 'Save $percent%';
  }

  @override
  String pricingPerMonth(String price) {
    return '$price/mo';
  }

  @override
  String pricingPerYear(String price) {
    return '$price/yr';
  }

  @override
  String pricingOnce(String price) {
    return '$price once';
  }

  @override
  String get startFreeTrial => 'Start 7-day Free Trial';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String renewsAtPrice(String price) {
    return 'Renews at $price';
  }

  @override
  String trustedByPlayers(String count) {
    return 'Trusted by $count+ players';
  }

  @override
  String get freeTrialDuration => '7 days free';

  @override
  String get paywallContinueFree => 'Maybe later';

  @override
  String get scoreStonesLabel => 'Stones';

  @override
  String get scoreTerritoryLabel => 'Territory';

  @override
  String get scoreCapturedLabel => 'Captured';
}
