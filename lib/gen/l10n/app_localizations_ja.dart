// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'GOKO';

  @override
  String get play => '対局';

  @override
  String get learn => '学習';

  @override
  String get puzzles => '詰碁';

  @override
  String get profile => 'プロフィール';

  @override
  String get settings => '設定';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get practice => '練習';

  @override
  String get playVsBot => 'AIと対局';

  @override
  String get tutorial => 'チュートリアル';

  @override
  String get dailyChallenge => 'デイリーチャレンジ';

  @override
  String get recentGames => '最近の対局';

  @override
  String get heroPrimary => '打つ・学ぶ・上達する';

  @override
  String get heroSub => 'オフラインで全機能が使えます！';

  @override
  String get selectGameMode => 'ゲームモードを選択';

  @override
  String get vsComputer => 'コンピュータと対局';

  @override
  String get vsFriend => '友達と対局（同一端末）';

  @override
  String get vsOnline => 'オンライン対局';

  @override
  String get selectBoardSize => '盤面サイズを選択';

  @override
  String get selectDifficulty => '難易度を選択';

  @override
  String get learnGo => '囲碁を学ぶ';

  @override
  String get lessons => 'レッスン';

  @override
  String get practiceTab => '練習';

  @override
  String get statistics => '統計';

  @override
  String get games => '対局数';

  @override
  String get winRate => '勝率';

  @override
  String get puzzleRating => '詰碁レーティング';

  @override
  String get language => '言語';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get appearance => '外観';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get darkModeSubtitle => 'ライトとダークのテーマを切り替え';

  @override
  String get showCoordinates => '座標を表示';

  @override
  String get lightThemeInGame => '対局中はライトテーマを使用';

  @override
  String get lightThemeInGameSubtitle => '対局画面でライトテーマを強制';

  @override
  String get puzzleSolved => '詰碁を解きました！';

  @override
  String get notQuite => '惜しい';

  @override
  String get hint => 'ヒント';

  @override
  String get reset => 'リセット';

  @override
  String get tryAgain => 'もう一度';

  @override
  String get giveUp => 'あきらめる';

  @override
  String get stepBack => '一手戻す';

  @override
  String get continue_ => '続ける';

  @override
  String get nextPuzzle => '次の詰碁';

  @override
  String get theoryExplanation => '解説';

  @override
  String get solveToUnlock => '解くとロック解除';

  @override
  String get learnWhyThisWorks => 'なぜこうなるかを学ぶ';

  @override
  String get keyConceptPrefix => 'キーコンセプト：';

  @override
  String get gameHistory => '対局履歴';

  @override
  String get noRecentGames => '最近の対局はありません';

  @override
  String get home => 'ホーム';

  @override
  String get history => '履歴';

  @override
  String get playVsBotTitle => 'AIと対局';

  @override
  String get kataGoSection => 'AI / KataGo';

  @override
  String get kataGoServerUrl => 'KataGo サーバー URL';

  @override
  String get kataGoHint => '空のままにすると内蔵 MCTS エンジン（オフライン）を使用します。';

  @override
  String get leelaServerUrl => 'Leela Zero / GTP サーバー URL';

  @override
  String get leelaHint =>
      'GTP-over-WebSocket エンジン（Leela Zero、ELF OpenGo）を接続します。KataGo URL が設定されている場合は無視されます。';

  @override
  String get localEngineTitle => 'ローカル AI エンジン';

  @override
  String get localEngineSubtitle => '自動管理 KataGo（サーバー不要）';

  @override
  String get engineStatusReady => 'KataGo 準備完了';

  @override
  String get engineStatusStarting => '起動中…';

  @override
  String get engineStatusNotFound => '未インストール';

  @override
  String get engineStatusError => 'エラー';

  @override
  String get enginesFolderLabel => 'エンジンフォルダ';

  @override
  String get downloadKataGo => 'KataGo をダウンロード';

  @override
  String get engineRestartButton => 'エンジンを再起動';

  @override
  String get prev => '前へ';

  @override
  String get next => '次へ';

  @override
  String get done => '完了';

  @override
  String get playDemo => 'デモを再生';

  @override
  String get replayDemo => 'デモを再生';

  @override
  String get playingDemo => '再生中…';

  @override
  String get interactiveTapBoard => 'インタラクティブ — 盤面をタップ';

  @override
  String get sourcePrefix => '出典：';

  @override
  String stepXofY(int current, int total) {
    return 'ステップ $current / $total';
  }

  @override
  String get dailyPuzzles => '今日の詰碁';

  @override
  String get collections => 'コレクション';

  @override
  String get categories => 'カテゴリ';

  @override
  String get captures => '取り';

  @override
  String get liberties => 'ダメ';

  @override
  String get lifeDeath => '死活';

  @override
  String get koBasics => 'コウの基礎';

  @override
  String get tesuji => '手筋';

  @override
  String get swap => '交換';

  @override
  String swapsLeft(int count) {
    return '残り交換回数：$count';
  }

  @override
  String solvedCount(int solved, int total) {
    return '$solved/$total 解決';
  }

  @override
  String get learningPath => '学習パス';

  @override
  String get allTutorials => 'すべてのチュートリアル';

  @override
  String get byLevel => 'レベル別';

  @override
  String get beginner => '初級';

  @override
  String get intermediate => '中級';

  @override
  String get advanced => '上級';

  @override
  String get objective => '目的';

  @override
  String get difficulty => '難易度';

  @override
  String get yourTurn => 'あなたの番';

  @override
  String get moves => '手数';

  @override
  String get markAsLearned => '学習済みにする ✓';

  @override
  String get blackToPlay => '黒番';

  @override
  String get whiteToPlay => '白番';

  @override
  String get comingSoon => '近日';

  @override
  String get general => '一般';

  @override
  String get gameSettings => 'ゲーム設定';

  @override
  String get notifications => '通知';

  @override
  String get soundEffects => '効果音';

  @override
  String get soundEffectsSubtitle => '対局中に効果音を再生';

  @override
  String get vibration => 'バイブレーション';

  @override
  String get vibrationSubtitle => '着手時にバイブ';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get pushNotificationsSubtitle => '対局に関する通知を受け取る';

  @override
  String get account => 'アカウント';

  @override
  String get editProfile => 'プロフィール編集';

  @override
  String get changePassword => 'パスワード変更';

  @override
  String get about => '情報';

  @override
  String get version => 'バージョン';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get boardThemeLabel => '盤面テーマ';

  @override
  String get backgroundThemeLabel => '背景テーマ';

  @override
  String get themeDarkBlue => 'ダークブルー';

  @override
  String get themeOledBlack => 'OLED ブラック';

  @override
  String get themeClassicWood => 'クラシック木目';

  @override
  String get themeLightMode => 'ライト';

  @override
  String get themeHalloween => 'ハロウィン';

  @override
  String get themeWinter => '冬';

  @override
  String get themeForest => 'フォレスト';

  @override
  String get boardClassic => 'クラシック';

  @override
  String get boardWalnut => 'ウォルナット';

  @override
  String get boardSlate => 'スレート';

  @override
  String get boardNight => 'ナイト';

  @override
  String get bgStandard => '標準';

  @override
  String get bgMinimal => 'ミニマル';

  @override
  String get bgWarm => '暖色';

  @override
  String get bgCool => '寒色';

  @override
  String get conceptLibertiesCaptures => 'ダメと取り';

  @override
  String get conceptLibertyCounting => 'ダメの数え方';

  @override
  String get conceptLifeDeathTwoEyes => '死活 — 二眼';

  @override
  String get conceptKoRule => 'コウのルール';

  @override
  String get conceptLibertiesCapturesDesc =>
      '石はその全てのダメ（隣接する空点）が相手の石で塞がれると取られます。連結した石はダメを共有するひとつの群となります。';

  @override
  String get conceptLibertyCountingDesc =>
      '石または群に隣接する各空点がダメです。連結した石は一つの群となり、すべてのダメを共有します。残りダメが一つだけの状態を「アタリ」と呼びます。';

  @override
  String get conceptLifeDeathDesc =>
      '二つの独立した眼を持つ群は、相手が両方を同時に塞ぐことができないため取られません。これは群の生死を判断する基本概念です。';

  @override
  String get conceptKoRuleDesc =>
      'コウのルールは無限ループを防ぐため、同じ局面の即座の取り返しを禁止します。コウを取った後は別の場所に打ってから取り返す必要があります。';

  @override
  String get analysisPanelTitle => '検討';

  @override
  String get analysisOn => '検討を有効にする';

  @override
  String get analysisOff => '検討を無効にする';

  @override
  String get noServerForAnalysis => '検討機能を使うには、設定で KataGo サーバーを設定してください。';

  @override
  String get moveQualityBest => '最善手';

  @override
  String get moveQualityGood => '良手';

  @override
  String get moveQualityInaccuracy => '緩手';

  @override
  String get moveQualityMistake => '悪手';

  @override
  String get moveQualityBlunder => '大悪手';

  @override
  String get moveQualityExcellent => '好手';

  @override
  String get cancel => 'キャンセル';

  @override
  String get aiThinking => 'AIが考えています…';

  @override
  String get noLegalMoves => '合法な手がありません。パスを押してください。';

  @override
  String get useHintTitle => 'ヒントを使いますか？';

  @override
  String useHintContent(int remaining) {
    return '最善手を表示します。1★消費（残り$remaining個）。';
  }

  @override
  String get showHint => 'ヒントを表示';

  @override
  String get noHintAvailable => 'ヒントがありません。パスを試してください。';

  @override
  String get resignTitle => 'この対局を投了しますか？';

  @override
  String get resignConfirmBot => '対戦相手が不戦勝となります。';

  @override
  String resignConfirmLocal(String side) {
    return '$sideが投了します。相手の勝ちです。';
  }

  @override
  String get resign => '投了';

  @override
  String get gameReview => '棋譜解析';

  @override
  String get rematch => '再戦';

  @override
  String get close => '閉じる';

  @override
  String get noHintsRemaining => 'ヒントがありません';

  @override
  String get showBestMove => '最善手を表示（-1★）';

  @override
  String get noHintsUsed => 'ヒント未使用';

  @override
  String hintsUsed(int count) {
    return 'ヒント$count回使用';
  }

  @override
  String get resumeLesson => 'レッスンを再開しますか？';

  @override
  String resumeLessonContent(int step) {
    return 'ステップ$stepから再開しますか？';
  }

  @override
  String get startOver => '最初から';

  @override
  String get resume => '再開';

  @override
  String get notQuiteTapHint => '違います。別の交点を試してください。';

  @override
  String get hintShownTapHint => 'ヒント：マーカーに従ってください。';

  @override
  String get lessonComplete => 'レッスン完了！';

  @override
  String dayStreak(int count) {
    return '$count日連続';
  }

  @override
  String get master => 'マスター';

  @override
  String get quickDrills => 'クイックドリル';

  @override
  String get score => 'スコア';

  @override
  String get black => '黒';

  @override
  String get white => '白';

  @override
  String get you => 'あなた';

  @override
  String get computer => 'コンピューター';

  @override
  String get whiteWinsByResignation => '白の不戦勝';

  @override
  String get blackWinsByResignation => '黒の不戦勝';

  @override
  String blackWinsByPoints(int points) {
    return '黒が$points目勝ち！';
  }

  @override
  String whiteWinsByPoints(int points) {
    return '白が$points目勝ち！';
  }

  @override
  String get gameTied => '引き分け！';

  @override
  String get gameReviewComingSoon => '棋譜解析は近日公開';

  @override
  String get rating => 'レート';

  @override
  String get today => '今日';

  @override
  String get streak => '連続';

  @override
  String get xp => '経験値';

  @override
  String get seeAll => 'すべて表示';

  @override
  String get save => '保存';

  @override
  String get swapPuzzle => '問題を交換';

  @override
  String get replay => 'もう一度';

  @override
  String get continueLearning => '学習を続ける';

  @override
  String get noLessonsYet => 'レッスンはまだありません';

  @override
  String get finishPreviousLesson => '前のレッスンを完了してください。';

  @override
  String get noGamesYet => 'まだ対局がありません — 終了すると表示されます。';

  @override
  String get premium => 'プレミアム';

  @override
  String get unlockPremium => 'プレミアム解放';

  @override
  String get youArePremium => 'プレミアム会員です';

  @override
  String get unlockGokoPremium => 'GOKO プレミアムを解放';

  @override
  String get paywallTagline => '深く練習。強く対局。すべてを解放。';

  @override
  String get unlimitedPuzzles => '無制限の問題';

  @override
  String get freePuzzleLimit => '無料：1日3問まで';

  @override
  String get allBotsAndLessons => '全ボットとレッスン';

  @override
  String get allBotsAndLessonsDesc => '初心者ボットと最初の4レッスンは無料';

  @override
  String get postGameAnalysis => '対局解析';

  @override
  String get postGameAnalysisDesc => '終了した対局の詳細レビュー（近日公開）';

  @override
  String get profileFlair => 'プロフィール装飾';

  @override
  String get profileFlairDesc => 'プレミアムバッジとアバターボーダー';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get puzzleDailyQuotaReached =>
      '本日の無料問題3問を使い切りました。無制限にするにはアップグレードしてください。';

  @override
  String get advancedBotsLocked => '中級・上級・マスターボットはプレミアムが必要です。';

  @override
  String get premiumLessonsLocked => 'レッスン5以降はプレミアムが必要です。';

  @override
  String seeAllLessons(int count) {
    return '全$countレッスンを表示';
  }

  @override
  String get dayStreakLabel => '連続日数';

  @override
  String get snapback => 'シチョウ崩し';

  @override
  String get ladder => 'シチョウ';

  @override
  String get connect => '連絡';

  @override
  String get lockedPremium => 'プレミアム';

  @override
  String get stoneColors => '石の色';

  @override
  String get stoneColorClassic => 'クラシック';

  @override
  String get stoneColorJade => '翡翠';

  @override
  String get stoneColorAmber => '琥珀';

  @override
  String get stoneColorCobalt => 'コバルト';

  @override
  String get stoneColorCrimson => 'クリムゾン';

  @override
  String get stoneColorMono => 'モノ';

  @override
  String get freeTrialBadge => '7日間無料';

  @override
  String get freeTrialSubtitle => 'いつでも解約可能';

  @override
  String get ogsLogin => 'OGS ログイン';

  @override
  String get onlineGoServer => 'Online Go Server';

  @override
  String get signInWithOgsAccount => 'OGS アカウントでサインイン';

  @override
  String get signIn => 'サインイン';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get enterUsernamePassword => 'ユーザー名とパスワードを入力してください';

  @override
  String get loginFailed => 'ログインに失敗しました。資格情報を確認してください。';

  @override
  String get errorPrefix => 'エラー：';

  @override
  String get noAccountSignUp => 'アカウントがありませんか？ OGS でサインアップ';

  @override
  String get onlinePlay => 'オンライン対局';

  @override
  String get onlineStatusConnected => 'オンライン';

  @override
  String get onlineStatusOffline => 'オフライン';

  @override
  String get ogsPlayer => 'OGS プレイヤー';

  @override
  String get notLoggedIn => 'ログインしていません';

  @override
  String get pleaseLogInToPlayOnline => 'オンライン対局には OGS でログインしてください';

  @override
  String get goBack => '戻る';

  @override
  String get appTagline => '古代の囲碁をマスターしよう';

  @override
  String get featurePlayBots => 'KataGo とオンラインボットとの対局';

  @override
  String get featurePuzzlesLessons => '詰碁・レッスン・デイリードリル';

  @override
  String get featureLiveGames => 'Online Go Server でのライブ対局';

  @override
  String get signInWithOgs => 'OGS でサインイン';

  @override
  String get createOgsAccount => '無料 OGS アカウント作成';

  @override
  String get displayName => '表示名';

  @override
  String get attributionAvatars => 'ボットアバター: OpenMoji (CC BY-SA 4.0)';
}
