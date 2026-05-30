// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'GOKO';

  @override
  String get play => 'Spielen';

  @override
  String get learn => 'Lernen';

  @override
  String get puzzles => 'Aufgaben';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get quickActions => 'Schnellzugriff';

  @override
  String get practice => 'Üben';

  @override
  String get playVsBot => 'Gegen Bot spielen';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get dailyChallenge => 'Tägliche Aufgabe';

  @override
  String get recentGames => 'Letzte Partien';

  @override
  String get heroPrimary => 'Spielen • Lernen • Verbessern';

  @override
  String get heroSub => 'Alles funktioniert offline – kein Konto nötig!';

  @override
  String get selectGameMode => 'Spielmodus wählen';

  @override
  String get vsComputer => 'gegen Computer';

  @override
  String get vsFriend => 'gegen Freund (gleiches Gerät)';

  @override
  String get vsOnline => 'Online spielen';

  @override
  String get selectBoardSize => 'Brettgröße wählen';

  @override
  String get selectDifficulty => 'Schwierigkeit wählen';

  @override
  String get learnGo => 'Go lernen';

  @override
  String get lessons => 'Lektionen';

  @override
  String get practiceTab => 'Üben';

  @override
  String get statistics => 'Statistik';

  @override
  String get games => 'Partien';

  @override
  String get winRate => 'Siegquote';

  @override
  String get puzzleRating => 'Aufgaben-Rating';

  @override
  String get language => 'Sprache';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get appearance => 'Darstellung';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get darkModeSubtitle => 'Zwischen hellem und dunklem Design wechseln';

  @override
  String get showCoordinates => 'Brettkoordinaten anzeigen';

  @override
  String get lightThemeInGame => 'Helles Design im Spiel';

  @override
  String get lightThemeInGameSubtitle =>
      'Im Spielbildschirm immer helles Design verwenden';

  @override
  String get puzzleSolved => 'Aufgabe gelöst!';

  @override
  String get notQuite => 'Nicht ganz';

  @override
  String get hint => 'Tipp';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get illegalMoveFeedback =>
      'Illegaler Zug (Ko / Selbstmord) — anderen Punkt wählen.';

  @override
  String get wrongMoveFeedback => 'Falscher Zug — nochmal versuchen!';

  @override
  String get giveUp => 'Aufgeben';

  @override
  String get stepBack => 'Schritt zurück';

  @override
  String get continue_ => 'Weiter';

  @override
  String get nextPuzzle => 'Nächste Aufgabe';

  @override
  String get theoryExplanation => 'Theorie & Erklärung';

  @override
  String get solveToUnlock => 'Löse zum Freischalten';

  @override
  String get learnWhyThisWorks => 'Erfahre, warum das funktioniert';

  @override
  String get keyConceptPrefix => 'Schlüsselkonzept: ';

  @override
  String get gameHistory => 'Spielverlauf';

  @override
  String get noRecentGames => 'Keine kürzlichen Partien';

  @override
  String get home => 'Start';

  @override
  String get history => 'Verlauf';

  @override
  String get playVsBotTitle => 'Gegen Bot spielen';

  @override
  String get kataGoSection => 'KI / KataGo';

  @override
  String get kataGoServerUrl => 'KataGo-Server-URL';

  @override
  String get kataGoHint =>
      'Leer lassen, um die integrierte MCTS-Engine offline zu nutzen.';

  @override
  String get leelaServerUrl => 'Leela Zero / GTP-Server-URL';

  @override
  String get leelaHint =>
      'Verbinde jede GTP-WebSocket-Engine (Leela Zero, ELF OpenGo). Wird ignoriert, wenn eine KataGo-URL gesetzt ist.';

  @override
  String get localEngineTitle => 'Lokale KI-Engine';

  @override
  String get localEngineSubtitle =>
      'Automatisch verwaltetes KataGo (kein Server nötig)';

  @override
  String get engineStatusReady => 'KataGo bereit';

  @override
  String get engineStatusStarting => 'Wird gestartet…';

  @override
  String get engineStatusNotFound => 'Nicht installiert';

  @override
  String get engineStatusError => 'Fehler';

  @override
  String get enginesFolderLabel => 'Engines-Ordner';

  @override
  String get downloadKataGo => 'KataGo herunterladen';

  @override
  String get engineRestartButton => 'Engine neu starten';

  @override
  String get prev => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get playDemo => 'Demo abspielen';

  @override
  String get replayDemo => 'Demo erneut abspielen';

  @override
  String get playingDemo => 'Wird abgespielt…';

  @override
  String get interactiveTapBoard => 'Interaktiv — tippe auf das Brett';

  @override
  String get sourcePrefix => 'Quelle: ';

  @override
  String stepXofY(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get dailyPuzzles => 'Tägliche Aufgaben';

  @override
  String get collections => 'Sammlungen';

  @override
  String get categories => 'Kategorien';

  @override
  String get captures => 'Schlagen';

  @override
  String get liberties => 'Freiheiten';

  @override
  String get lifeDeath => 'Leben & Tod';

  @override
  String get koBasics => 'Ko-Grundlagen';

  @override
  String get tesuji => 'Tesuji';

  @override
  String get swap => 'Tauschen';

  @override
  String swapsLeft(int count) {
    return '$count Tausch übrig';
  }

  @override
  String solvedCount(int solved, int total) {
    return '$solved/$total gelöst';
  }

  @override
  String get learningPath => 'Lernpfad';

  @override
  String get allTutorials => 'Alle Tutorials';

  @override
  String get byLevel => 'Nach Stufe';

  @override
  String get beginner => 'Anfänger';

  @override
  String get intermediate => 'Mittelstufe';

  @override
  String get advanced => 'Fortgeschritten';

  @override
  String get objective => 'Ziel';

  @override
  String get difficulty => 'Schwierigkeit';

  @override
  String get yourTurn => 'Du bist dran';

  @override
  String get moves => 'Züge';

  @override
  String get markAsLearned => 'Als gelernt markieren ✓';

  @override
  String get blackToPlay => 'Schwarz ist am Zug';

  @override
  String get whiteToPlay => 'Weiß ist am Zug';

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get general => 'Allgemein';

  @override
  String get gameSettings => 'Spieleinstellungen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get soundEffectsSubtitle =>
      'Soundeffekte während der Partie abspielen';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Vibration bei jedem Zug';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get pushNotificationsSubtitle =>
      'Benachrichtigungen zu deinen Partien erhalten';

  @override
  String get account => 'Konto';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get themeLabel => 'Design';

  @override
  String get boardThemeLabel => 'Brett-Design';

  @override
  String get backgroundThemeLabel => 'Hintergrund-Design';

  @override
  String get themeDarkBlue => 'Dunkelblau';

  @override
  String get themeOledBlack => 'OLED Schwarz';

  @override
  String get themeClassicWood => 'Klassisches Holz';

  @override
  String get themeLightMode => 'Heller Modus';

  @override
  String get themeHalloween => 'Halloween';

  @override
  String get themeWinter => 'Winter';

  @override
  String get themeForest => 'Wald';

  @override
  String get boardClassic => 'Klassisch';

  @override
  String get boardWalnut => 'Walnuss';

  @override
  String get boardSlate => 'Schiefer';

  @override
  String get boardNight => 'Nacht';

  @override
  String get bgStandard => 'Standard';

  @override
  String get bgMinimal => 'Minimal';

  @override
  String get bgWarm => 'Warm';

  @override
  String get bgCool => 'Kühl';

  @override
  String get conceptLibertiesCaptures => 'Freiheiten & Schlagen';

  @override
  String get conceptLibertyCounting => 'Freiheiten zählen';

  @override
  String get conceptLifeDeathTwoEyes => 'Leben & Tod – Zwei Augen';

  @override
  String get conceptKoRule => 'Ko-Regel';

  @override
  String get conceptLibertiesCapturesDesc =>
      'Steine werden geschlagen, wenn alle ihre Freiheiten (benachbarte freie Punkte) von gegnerischen Steinen besetzt sind. Verbundene Steine teilen sich ihre Freiheiten als eine Gruppe.';

  @override
  String get conceptLibertyCountingDesc =>
      'Jeder leere Punkt neben einem Stein oder einer Gruppe ist eine Freiheit. Verbundene Steine bilden eine Gruppe und teilen sich alle Freiheiten. Hat eine Gruppe nur noch eine Freiheit, steht sie im \"Atari\" (Schach).';

  @override
  String get conceptLifeDeathDesc =>
      'Eine Gruppe mit zwei separaten Augen kann nicht geschlagen werden, weil der Gegner nicht beide Augen gleichzeitig füllen kann. Das ist grundlegend dafür, welche Gruppen leben und welche getötet werden können.';

  @override
  String get conceptKoRuleDesc =>
      'Die Ko-Regel verhindert unendliche Schleifen, indem sie das sofortige Wiederschlagen in einer sich wiederholenden Position untersagt. Nach einem Ko-Schlag musst du erst woanders ziehen, bevor du zurückschlagen darfst.';

  @override
  String get analysisPanelTitle => 'Analyse';

  @override
  String get analysisOn => 'Analyse aktivieren';

  @override
  String get analysisOff => 'Analyse deaktivieren';

  @override
  String get noServerForAnalysis =>
      'Konfiguriere einen KataGo-Server in den Einstellungen, um die Analyse zu aktivieren.';

  @override
  String get moveQualityBest => 'Bester';

  @override
  String get moveQualityGood => 'Gut';

  @override
  String get moveQualityInaccuracy => 'Ungenauigkeit';

  @override
  String get moveQualityMistake => 'Fehler';

  @override
  String get moveQualityBlunder => 'Patzer';

  @override
  String get moveQualityExcellent => 'Ausgezeichnet';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get aiThinking => 'KI denkt nach…';

  @override
  String get noLegalMoves =>
      'Keine legalen Züge verfügbar. Drücke Passen, um fortzufahren.';

  @override
  String get useHintTitle => 'Tipp verwenden?';

  @override
  String useHintContent(int remaining) {
    return 'Den besten Zug aufdecken. Kostet 1 ★ ($remaining übrig).';
  }

  @override
  String get showHint => 'Tipp anzeigen';

  @override
  String get noHintAvailable => 'Kein Tipp verfügbar — versuche zu passen.';

  @override
  String get resignTitle => 'Diese Partie aufgeben?';

  @override
  String get resignConfirmBot => 'Dein Gegner gewinnt durch Aufgabe.';

  @override
  String resignConfirmLocal(String side) {
    return '$side gibt auf. Die andere Seite gewinnt.';
  }

  @override
  String get resign => 'Aufgeben';

  @override
  String get gameReview => 'Partieanalyse';

  @override
  String get rematch => 'Revanche';

  @override
  String get close => 'Schließen';

  @override
  String get noHintsRemaining => 'Keine Tipps mehr übrig';

  @override
  String get showBestMove => 'Besten Zug zeigen (-1 ★)';

  @override
  String get noHintsUsed => 'Keine Tipps genutzt';

  @override
  String hintsUsed(int count) {
    return '$count Tipp(s) verwendet';
  }

  @override
  String get resumeLesson => 'Lektion fortsetzen?';

  @override
  String resumeLessonContent(int step) {
    return 'Bei Schritt $step fortfahren?';
  }

  @override
  String get startOver => 'Von vorn beginnen';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get notQuiteTapHint => 'Nicht ganz — versuche einen anderen Punkt.';

  @override
  String get hintShownTapHint => 'Tipp: folge der Markierung.';

  @override
  String get lessonComplete => 'Lektion abgeschlossen!';

  @override
  String dayStreak(int count) {
    return '$count-Tage-Serie';
  }

  @override
  String get master => 'Meister';

  @override
  String get quickDrills => 'Schnellübungen';

  @override
  String get score => 'Punkte';

  @override
  String get black => 'Schwarz';

  @override
  String get white => 'Weiß';

  @override
  String get you => 'Du';

  @override
  String get computer => 'Computer';

  @override
  String get whiteWinsByResignation => 'Weiß gewinnt durch Aufgabe';

  @override
  String get blackWinsByResignation => 'Schwarz gewinnt durch Aufgabe';

  @override
  String blackWinsByPoints(int points) {
    return 'Schwarz gewinnt mit $points Punkten!';
  }

  @override
  String whiteWinsByPoints(int points) {
    return 'Weiß gewinnt mit $points Punkten!';
  }

  @override
  String get gameTied => 'Partie unentschieden!';

  @override
  String get rating => 'Rating';

  @override
  String get today => 'Heute';

  @override
  String get streak => 'Serie';

  @override
  String get xp => 'XP';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get save => 'Speichern';

  @override
  String get swapPuzzle => 'Aufgabe tauschen';

  @override
  String get replay => 'Wiederholen';

  @override
  String get continueLearning => 'Lernen fortsetzen';

  @override
  String get noLessonsYet => 'Noch keine Lektionen';

  @override
  String get finishPreviousLesson =>
      'Beende die vorherige Lektion, um diese freizuschalten.';

  @override
  String get noGamesYet =>
      'Noch keine Partien — beende eine, um sie hier zu sehen.';

  @override
  String get premium => 'Premium';

  @override
  String get unlockPremium => 'Premium freischalten';

  @override
  String get youArePremium => 'Du bist Premium';

  @override
  String get unlockGokoPremium => 'GOKO Premium freischalten';

  @override
  String get paywallTagline =>
      'Trainiere tiefer. Spiele stärker. Schalte alles frei.';

  @override
  String get unlimitedPuzzles => 'Unbegrenzte Aufgaben';

  @override
  String get freePuzzleLimit => 'Kostenlose Nutzer bekommen 3 Aufgaben pro Tag';

  @override
  String get allBotsAndLessons => 'Alle Bots & Lektionen';

  @override
  String get allBotsAndLessonsDesc =>
      'Anfänger-Bots und die ersten 4 Lektionen sind kostenlos';

  @override
  String get postGameAnalysis => 'Partieanalyse';

  @override
  String get postGameAnalysisDesc =>
      'Spiele jede beendete Partie Zug für Zug erneut ab.';

  @override
  String get profileFlair => 'Profil-Abzeichen';

  @override
  String get profileFlairDesc => 'Premium-Abzeichen und Avatar-Rahmen';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get puzzleDailyQuotaReached =>
      'Du hast deine 3 kostenlosen Aufgaben für heute genutzt. Premium = unbegrenzt.';

  @override
  String get advancedBotsLocked =>
      'Mittelstufen-, Fortgeschrittene- und Meister-Bots benötigen Premium.';

  @override
  String get premiumLessonsLocked => 'Lektionen ab 5 benötigen Premium.';

  @override
  String seeAllLessons(int count) {
    return 'Alle $count Lektionen anzeigen';
  }

  @override
  String get dayStreakLabel => 'Tages-Serie';

  @override
  String get snapback => 'Snapback';

  @override
  String get ladder => 'Leiter';

  @override
  String get connect => 'Verbinden';

  @override
  String get lockedPremium => 'Premium';

  @override
  String get stoneColors => 'Steinfarben';

  @override
  String get stoneColorClassic => 'Klassisch';

  @override
  String get stoneColorJade => 'Jade';

  @override
  String get stoneColorAmber => 'Bernstein';

  @override
  String get stoneColorCobalt => 'Kobalt';

  @override
  String get stoneColorCrimson => 'Karmin';

  @override
  String get stoneColorMono => 'Mono';

  @override
  String get freeTrialBadge => '7 Tage kostenlos';

  @override
  String get freeTrialSubtitle => 'Jederzeit kündbar';

  @override
  String get ogsLogin => 'OGS-Login';

  @override
  String get onlineGoServer => 'Online Go Server';

  @override
  String get signInWithOgsAccount => 'Mit deinem OGS-Konto anmelden';

  @override
  String get signIn => 'Anmelden';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get enterUsernamePassword =>
      'Bitte Benutzername und Passwort eingeben';

  @override
  String get loginFailed =>
      'Anmeldung fehlgeschlagen. Bitte Zugangsdaten prüfen.';

  @override
  String get errorPrefix => 'Fehler: ';

  @override
  String get noAccountSignUp => 'Kein Konto? Registriere dich auf OGS';

  @override
  String get orContinueWith => 'oder weiter mit';

  @override
  String get continueWithOgs => 'Mit OGS fortfahren (Google usw.)';

  @override
  String get onlinePlay => 'Online spielen';

  @override
  String get onlineStatusConnected => 'Online';

  @override
  String get onlineStatusOffline => 'Offline';

  @override
  String get ogsPlayer => 'OGS-Spieler';

  @override
  String get notLoggedIn => 'Nicht angemeldet';

  @override
  String get pleaseLogInToPlayOnline =>
      'Bitte mit OGS anmelden, um online zu spielen';

  @override
  String get goBack => 'Zurück';

  @override
  String get appTagline => 'Meistere das alte Spiel Go';

  @override
  String get featurePlayBots => 'Spiele gegen KataGo & Online-Bots';

  @override
  String get featurePuzzlesLessons => 'Aufgaben, Lektionen & tägliche Übungen';

  @override
  String get featureLiveGames => 'Live-Partien auf dem Online Go Server';

  @override
  String get signInWithOgs => 'Mit OGS anmelden';

  @override
  String get createOgsAccount => 'Kostenloses OGS-Konto erstellen';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get attributionAvatars => 'Bot-Avatare: OpenMoji (CC BY-SA 4.0)';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get unranked => 'Unbewertet';

  @override
  String get friendComputerOnline => 'Freund, Computer oder Online';

  @override
  String get dailyPuzzle => 'Tagesaufgabe';

  @override
  String get playBot => 'Bot spielen';

  @override
  String get vsComputerSubtitle => 'Bot wählen — offline KI';

  @override
  String get vsFriendSubtitle => 'Gleiches Gerät, abwechselnd spielen';

  @override
  String get vsOnlineSubtitle => 'Live-Spiele über OGS';

  @override
  String get playFirstGameHint =>
      'Spiel deine erste Partie — sie erscheint hier.';

  @override
  String get puzzleStreak => 'Rätsel-Serie';

  @override
  String get puzzleStreakSubtitle => 'Löse bis zum ersten Fehler';

  @override
  String get currentStreak => 'Serie';

  @override
  String get bestLabel => 'Beste';

  @override
  String get streakEndedTitle => 'Serie beendet';

  @override
  String get newRecord => 'Neuer Rekord!';

  @override
  String get puzzleModes => 'Rätsel-Modi';

  @override
  String get leagueLabel => 'Liga';

  @override
  String get leagueRookie => 'Neuling';

  @override
  String get leagueBronze => 'Bronze';

  @override
  String get leagueSilver => 'Silber';

  @override
  String get leagueGold => 'Gold';

  @override
  String get leaguePlatinum => 'Platin';

  @override
  String get leagueDiamond => 'Diamant';

  @override
  String get puzzleMap => 'Karte';

  @override
  String get puzzleList => 'Liste';

  @override
  String get world1Beginner => 'Anfängergarten';

  @override
  String get world2Intermediate => 'Mittelstufensee';

  @override
  String get world3Advanced => 'Fortgeschrittenen-Vulkan';

  @override
  String get coachStreakIntro1 => 'Bereit für eine Serie?';

  @override
  String get coachStreakIntro2 => 'Wie weit kommst du heute?';

  @override
  String get coachStreakIntro3 => 'Übertriff deinen Rekord!';

  @override
  String get coachStreakIntro4 => 'Ein Fehler beendet die Serie. Kein Druck!';

  @override
  String get coachStreakIntro5 => 'Tägliche Übung hält den Geist scharf.';

  @override
  String get coachSolve1 => 'Klasse!';

  @override
  String get coachSolve2 => 'Brillant!';

  @override
  String get coachSolve3 => 'Serie läuft!';

  @override
  String get coachSolve4 => 'Das war knifflig!';

  @override
  String get coachSolve5 => 'Perfekt gesehen.';

  @override
  String get coachSolve6 => 'Weiter so!';

  @override
  String get openLesson => 'Öffnen';

  @override
  String get puzzleGardenTitle => 'Anfängergarten';

  @override
  String get coachLeagueRookieUnlocked =>
      'Willkommen, Neuling! Lass uns dein Rating steigern.';

  @override
  String get coachLeagueBronzeUnlocked => 'Bronze-Liga! Du bist dabei.';

  @override
  String get coachLeagueSilverUnlocked => 'Silber-Liga! Du liest das Brett.';

  @override
  String get coachLeagueGoldUnlocked => 'Gold-Liga! Echter Kämpfer.';

  @override
  String get coachLeaguePlatinumUnlocked => 'Platin-Liga! Wenige schaffen das.';

  @override
  String get coachLeagueDiamondUnlocked => 'Diamant-Liga! Meisterklasse.';

  @override
  String get coachKeepGoing => 'Tippe den nächsten Stein — weiter so!';

  @override
  String get coachTryAgain => 'Kein Problem — probier einen anderen Punkt.';

  @override
  String xpToNextLeague(int count, String league) {
    return '$count XP bis $league';
  }

  @override
  String gateLockedUnlockAt(int xp) {
    return 'Freigeschaltet bei $xp XP';
  }

  @override
  String get solvePuzzles => 'Aufgaben lösen';

  @override
  String levelN(int n) {
    return 'Level $n';
  }

  @override
  String get puzzleBestMove => 'Finde den besten Zug';

  @override
  String xpToUnlock(int xp) {
    return '+$xp XP';
  }

  @override
  String get worldStoneForest => 'Steinwald';

  @override
  String get worldCrystalCave => 'Kristallhöhle';

  @override
  String get worldCopperPeaks => 'Kupfergipfel';

  @override
  String get worldDiamondTundra => 'Diamanttundra';

  @override
  String get worldJadeHighlands => 'Jadehochland';

  @override
  String get quit => 'Beenden';

  @override
  String get drillCompleteTitle => 'Übung abgeschlossen';

  @override
  String get backToLearn => 'Zurück zum Lernen';

  @override
  String get quitDrillTitle => 'Übung beenden?';

  @override
  String get quitDrillBody =>
      'Dein Fortschritt geht verloren, wenn du jetzt beendest.';

  @override
  String get resignGameTitle => 'Partie aufgeben?';

  @override
  String get resignGameBody => 'Möchtest du wirklich aufgeben?';

  @override
  String get undoRequestTitle => 'Rücknahme-Anfrage';

  @override
  String get decline => 'Ablehnen';

  @override
  String get accept => 'Annehmen';

  @override
  String get gameInfoTitle => 'Spielinfo';

  @override
  String get leaveGame => 'Spiel verlassen';

  @override
  String get connectionTestTitle => 'Verbindungstest';

  @override
  String get runConnectionTest => 'Test starten';

  @override
  String get findOpponentSubtitle =>
      'Finde sofort einen Gegner für ein schnelles Spiel';

  @override
  String get startMatchHint => 'Starte ein schnelles Match!';

  @override
  String get shuffle => 'Mischen';

  @override
  String get tutorialsTitle => 'Tutorials';

  @override
  String get learnGardenTitle => 'Lernen';

  @override
  String get categoryFundamentals => 'Grundlagen';

  @override
  String get categoryRules => 'Regeln';

  @override
  String get categoryLifeDeath => 'Leben & Tod';

  @override
  String get categoryStrategy => 'Strategie';

  @override
  String lessonsInCategoryCount(int count) {
    return '$count Lektionen';
  }

  @override
  String get continueLessonCta => 'Lektion fortsetzen';

  @override
  String get startLessonCta => 'Erste Lektion starten';

  @override
  String get lessonLocked => 'Premium-Lektion';

  @override
  String get coachLearnIntro1 => 'Was als Nächstes?';

  @override
  String get coachLearnIntro2 => 'Eine Lektion pro Tag hält den Geist scharf.';

  @override
  String get coachLearnIntro3 =>
      'Probier eine kurze Lektion — unter 5 Minuten.';

  @override
  String get coachLearnIntro4 =>
      'Wähl eine Kategorie — jeder Weg führt irgendwohin.';

  @override
  String get coachLearnIntro5 => 'Tipp einen Stein an, um loszulegen!';

  @override
  String get coachCategoryDone => 'Ganze Kategorie geschafft — unglaublich!';

  @override
  String get botDescPanda => 'Süß und albern. Spielt gerne zufällige Züge.';

  @override
  String get botDescPup =>
      'Eifriger Welpe, jagt jeden Stein. Leicht zu überlisten.';

  @override
  String get botDescBunny =>
      'Hüpft mit neugierigen, unvorhersehbaren Zügen übers Brett.';

  @override
  String get botDescKoi =>
      'Sanft und stetig. Liebt Randspiel und kleine Einkreisungen.';

  @override
  String get botDescTanuki =>
      'Trickreicher Geist. Kennt einfache Fänge und Formen.';

  @override
  String get botDescPebble =>
      'Ruhig und stetig. Baut langsam solide Rahmen auf.';

  @override
  String get botDescHeron => 'Geduldig. Zerlegt lose Formen am Rand.';

  @override
  String get botDescOwl => 'Weise und geduldig. Baut stabile Territorien.';

  @override
  String get botDescCrane =>
      'Anmutig und ausgewogen. Spielt leichte, flexible Formen.';

  @override
  String get botDescMantis =>
      'Scharf und schnell. Berechnet taktische Sequenzen.';

  @override
  String get botDescBadger => 'Lässt keinen Stein kampflos ziehen.';

  @override
  String get botDescKitsune =>
      'Listiger Fuchs. Bestraft Überspiel, belohnt gute Form.';

  @override
  String get botDescPhoenix =>
      'Steht aus dem Druck auf mit scharfen Gegenangriffen.';

  @override
  String get botDescHawk =>
      'Drucksspieler. Sucht ständig deine schwachen Gruppen.';

  @override
  String get botDescTiger =>
      'Wilder Kämpfer. Greift gerne schwache Gruppen an.';

  @override
  String get botDescOtter =>
      'Flexibel und verspielt. Wechselt zwischen Angriff und Verteidigung.';

  @override
  String get botDescDragon =>
      'Starkes Lesen und sauberes Endspiel. Verlangt Präzision.';

  @override
  String get botDescSamurai =>
      'Ehre und Disziplin. Starker Kampf plus klare Form.';

  @override
  String get botDescTengu => 'Berggeist. Starker Kampf und effiziente Form.';

  @override
  String get botDescMonk =>
      'Ruhiges, tiefes positionelles Verständnis. Ganz-Brett-Sicht.';

  @override
  String get botDescOracle =>
      'Sieht Varianten ein Dutzend Züge voraus. Schwer zu täuschen.';

  @override
  String get botDescSensei =>
      'Weiser Lehrer. Spielt die lehrreichsten Profizüge.';

  @override
  String get botDescKataGo =>
      'Plant Dutzende Züge voraus mit neuronaler Vorausschau. Übermenschliche Sicht.';

  @override
  String get tauntDefaultGreet => 'Lass uns spielen!';

  @override
  String get tauntDefaultWin => 'Gutes Spiel! Den hast du verdient.';

  @override
  String get tauntDefaultLose => 'Schön gespielt — beim nächsten Mal!';

  @override
  String get tauntDefaultResign => 'Danke fürs Spiel!';

  @override
  String get tauntPandaGreet => 'Hallo Freund! Lass uns spielen!';

  @override
  String get tauntPandaWin => 'Juhu! Ich habe gewonnen!';

  @override
  String get tauntPandaLose => 'Du bist richtig gut!';

  @override
  String get undoMove => 'Zug zurück';

  @override
  String get passTurn => 'Passen';

  @override
  String get redoMove => 'Zug wiederholen';

  @override
  String get newGame => 'Neues Spiel';

  @override
  String get practiceBadge => 'ÜBUNG';

  @override
  String get notYourTurn => 'Du bist nicht dran!';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get profileTooltip => 'Profil';

  @override
  String get wins => 'Siege';

  @override
  String get losses => 'Niederlagen';

  @override
  String get draws => 'Unentschieden';

  @override
  String get winLossLabel => 'Sieg / Niederlage';

  @override
  String get playGamesHint =>
      'Spiele Partien, um deine Statistik hier zu sehen.';

  @override
  String get filterAll => 'Alle';

  @override
  String get noPuzzlesForFilter => 'Keine Aufgaben für diesen Filter.';

  @override
  String tutorialsLoadError(String error) {
    return 'Tutorials konnten nicht geladen werden: $error';
  }

  @override
  String get noTutorialsYet => 'Noch keine Tutorials verfügbar.';

  @override
  String get practiceModeTitle => 'Übungsmodus';

  @override
  String get practiceModeSubtitle =>
      'Bester Zug wird nach jedem Zug gezeigt · Ergebnis ist 1 ★';

  @override
  String get chooseBoardSize => 'Brettgröße wählen';

  @override
  String get undoRequestSent => 'Rücknahme-Anfrage gesendet';

  @override
  String get undoRequestDeclined => 'Rücknahme-Anfrage abgelehnt';

  @override
  String get undoRequestAccepted => 'Rücknahme-Anfrage angenommen';

  @override
  String opponentRequestedUndo(int moveNumber) {
    return 'Dein Gegner möchte Zug #$moveNumber zurücknehmen.';
  }

  @override
  String suggestedRemovedStones(int count) {
    return '$count entfernte Steine vorgeschlagen';
  }

  @override
  String gameIdLabel(String id) {
    return 'Spiel-ID: $id';
  }

  @override
  String moveLabel(int n) {
    return 'Zug: $n';
  }

  @override
  String phaseLabel(String phase) {
    return 'Phase: $phase';
  }

  @override
  String boardLabel(String size) {
    return 'Brett: $size';
  }

  @override
  String hintLookAt(int row, String col) {
    return 'Schau auf Zeile $row, Spalte $col — hier ist ein starker Zug.';
  }

  @override
  String get hintFallbackGeneric =>
      'Finde den Zug, der die gegnerischen Steine bedrängt — achte auf Atari, schwache Gruppen oder Augenformen.';

  @override
  String get paywallHeroTitle => 'GOKO Premium freischalten';

  @override
  String get paywallHeroTagline => 'Meistere das uralte Spiel';

  @override
  String get paywallFeatureUnlimitedPuzzles => 'Unbegrenzte tägliche Aufgaben';

  @override
  String get paywallFeatureAllBots => 'Alle Bots — Pup bis KataGo';

  @override
  String get paywallFeatureLessons => 'Volle Lektionsbibliothek + Spielanalyse';

  @override
  String get paywallFeatureSync => 'Cloud-Sync, Abzeichen & Profil-Flair';

  @override
  String get pricingTierMonthly => 'Monatlich';

  @override
  String get pricingTierAnnual => 'Jährlich';

  @override
  String get pricingTierLifetime => 'Lebenslang';

  @override
  String get pricingPopular => 'AM BELIEBTESTEN';

  @override
  String get pricingBestValue => 'Bestes Angebot';

  @override
  String pricingSave(int percent) {
    return 'Spare $percent%';
  }

  @override
  String pricingPerMonth(String price) {
    return '$price/Mon.';
  }

  @override
  String pricingPerYear(String price) {
    return '$price/Jahr';
  }

  @override
  String pricingOnce(String price) {
    return '$price einmalig';
  }

  @override
  String get startFreeTrial => '7 Tage kostenlos testen';

  @override
  String get cancelAnytime => 'Jederzeit kündbar';

  @override
  String renewsAtPrice(String price) {
    return 'Verlängert sich für $price';
  }

  @override
  String trustedByPlayers(String count) {
    return 'Vertraut von $count+ Spielern';
  }

  @override
  String get freeTrialDuration => '7 Tage gratis';

  @override
  String get paywallContinueFree => 'Vielleicht später';

  @override
  String get scoreStonesLabel => 'Steine';

  @override
  String get scoreTerritoryLabel => 'Gebiet';

  @override
  String get scoreCapturedLabel => 'Gefangen';

  @override
  String get gameEndedMarkDeadStones =>
      'Spiel beendet - Tote Steine markieren zum Bewerten';

  @override
  String get gameFinished => 'Spiel beendet';

  @override
  String get stoneRemovalAccepted => 'Steinentfernung akzeptiert';

  @override
  String get waitForPreviousMove => 'Bitte warten Sie auf den vorherigen Zug';

  @override
  String get positionAlreadyOccupied => 'Position bereits besetzt';

  @override
  String get invalidMoveSuicideOrKo =>
      'Ungültiger Zug (Selbstmord oder Ko-Regelverstoß)';

  @override
  String get moveTimedOut =>
      'Zug hat das Zeitlimit überschritten - versuchen Sie es erneut';

  @override
  String timeSecondsRemaining(int seconds) {
    return '$seconds Sekunden verbleibend!';
  }

  @override
  String periodTimeRemaining(int periods, int time) {
    return 'Periode $periods - ${time}s';
  }

  @override
  String get learningRankNovice => 'Anfänger';

  @override
  String get learningRankApprentice => 'Lehrling';

  @override
  String get learningRankScholar => 'Gelehrter';

  @override
  String get learningRankMaster => 'Meister';

  @override
  String get learningRankGrandmaster => 'Großmeister';

  @override
  String lessonsToNextRank(int count, String rank) {
    return '$count Lektionen bis $rank';
  }

  @override
  String get newBadge => 'NEU';

  @override
  String get nextUp => 'Als Nächstes';
}
