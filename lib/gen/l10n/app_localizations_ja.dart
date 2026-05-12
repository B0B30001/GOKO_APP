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
}
