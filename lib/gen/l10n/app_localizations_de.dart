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
  String get comingSoon => 'Bald';

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
  String get gameReviewComingSoon => 'Partieanalyse kommt bald';

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
      'Tiefenanalyse jeder beendeten Partie (bald verfügbar)';

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
}
