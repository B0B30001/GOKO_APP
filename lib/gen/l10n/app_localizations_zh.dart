// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'GOKO';

  @override
  String get play => '对弈';

  @override
  String get learn => '学习';

  @override
  String get puzzles => '题库';

  @override
  String get profile => '我的';

  @override
  String get settings => '设置';

  @override
  String get quickActions => '快捷操作';

  @override
  String get practice => '练习';

  @override
  String get playVsBot => '对战机器人';

  @override
  String get tutorial => '教程';

  @override
  String get dailyChallenge => '每日挑战';

  @override
  String get recentGames => '最近对局';

  @override
  String get heroPrimary => '下棋 · 学习 · 进步';

  @override
  String get heroSub => '完全离线可用，无需账号！';

  @override
  String get selectGameMode => '选择游戏模式';

  @override
  String get vsComputer => '对战电脑';

  @override
  String get vsFriend => '与朋友对弈（同一设备）';

  @override
  String get vsOnline => '在线对战';

  @override
  String get selectBoardSize => '选择棋盘大小';

  @override
  String get selectDifficulty => '选择难度';

  @override
  String get learnGo => '学习围棋';

  @override
  String get lessons => '课程';

  @override
  String get practiceTab => '练习';

  @override
  String get statistics => '统计';

  @override
  String get games => '对局数';

  @override
  String get winRate => '胜率';

  @override
  String get puzzleRating => '题目评分';

  @override
  String get language => '语言';

  @override
  String get appLanguage => '应用语言';

  @override
  String get appearance => '外观';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '在浅色和深色主题之间切换';

  @override
  String get showCoordinates => '显示坐标';

  @override
  String get lightThemeInGame => '游戏中使用浅色主题';

  @override
  String get lightThemeInGameSubtitle => '在对局画面强制使用浅色主题';

  @override
  String get puzzleSolved => '题目已解决！';

  @override
  String get notQuite => '还差一点';

  @override
  String get hint => '提示';

  @override
  String get reset => '重置';

  @override
  String get tryAgain => '再试一次';

  @override
  String get giveUp => '放弃';

  @override
  String get stepBack => '退一步';

  @override
  String get continue_ => '继续';

  @override
  String get nextPuzzle => '下一题';

  @override
  String get theoryExplanation => '理论与解析';

  @override
  String get solveToUnlock => '解题后解锁';

  @override
  String get learnWhyThisWorks => '了解原因';

  @override
  String get keyConceptPrefix => '核心概念：';

  @override
  String get gameHistory => '对局记录';

  @override
  String get noRecentGames => '暂无最近对局';

  @override
  String get home => '主页';

  @override
  String get history => '记录';

  @override
  String get playVsBotTitle => '对战机器人';

  @override
  String get kataGoSection => 'AI / KataGo';

  @override
  String get kataGoServerUrl => 'KataGo 服务器地址';

  @override
  String get kataGoHint => '留空则使用内置 MCTS 引擎（离线）。';

  @override
  String get leelaServerUrl => 'Leela Zero / GTP 服务器地址';

  @override
  String get leelaHint =>
      '连接任意 GTP-over-WebSocket 引擎（Leela Zero、ELF OpenGo）。设置了 KataGo 地址时忽略此项。';

  @override
  String get localEngineTitle => '本地 AI 引擎';

  @override
  String get localEngineSubtitle => '自动管理的 KataGo（无需服务器）';

  @override
  String get engineStatusReady => 'KataGo 就绪';

  @override
  String get engineStatusStarting => '启动中…';

  @override
  String get engineStatusNotFound => '未安装';

  @override
  String get engineStatusError => '错误';

  @override
  String get enginesFolderLabel => '引擎文件夹';

  @override
  String get downloadKataGo => '下载 KataGo';

  @override
  String get engineRestartButton => '重启引擎';

  @override
  String get prev => '上一步';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get playDemo => '播放演示';

  @override
  String get replayDemo => '重播演示';

  @override
  String get playingDemo => '演示中…';

  @override
  String get interactiveTapBoard => '互动 — 点击棋盘';

  @override
  String get sourcePrefix => '来源：';

  @override
  String stepXofY(int current, int total) {
    return '第 $current 步 / 共 $total 步';
  }

  @override
  String get dailyPuzzles => '每日题库';

  @override
  String get collections => '合集';

  @override
  String get categories => '分类';

  @override
  String get captures => '提子';

  @override
  String get liberties => '气';

  @override
  String get lifeDeath => '死活';

  @override
  String get koBasics => '劫的基础';

  @override
  String get tesuji => '手筋';

  @override
  String get swap => '更换';

  @override
  String swapsLeft(int count) {
    return '剩余更换：$count';
  }

  @override
  String solvedCount(int solved, int total) {
    return '已解 $solved/$total';
  }

  @override
  String get learningPath => '学习路径';

  @override
  String get allTutorials => '全部教程';

  @override
  String get byLevel => '按级别';

  @override
  String get beginner => '初级';

  @override
  String get intermediate => '中级';

  @override
  String get advanced => '高级';

  @override
  String get objective => '目标';

  @override
  String get difficulty => '难度';

  @override
  String get yourTurn => '你的回合';

  @override
  String get moves => '手数';

  @override
  String get markAsLearned => '标记为已学 ✓';

  @override
  String get blackToPlay => '黑棋落子';

  @override
  String get whiteToPlay => '白棋落子';

  @override
  String get comingSoon => '即将推出';

  @override
  String get general => '通用';

  @override
  String get gameSettings => '游戏设置';

  @override
  String get notifications => '通知';

  @override
  String get soundEffects => '音效';

  @override
  String get soundEffectsSubtitle => '对局时播放音效';

  @override
  String get vibration => '震动';

  @override
  String get vibrationSubtitle => '落子时震动';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get pushNotificationsSubtitle => '接收对局相关通知';

  @override
  String get account => '账号';

  @override
  String get editProfile => '编辑资料';

  @override
  String get changePassword => '修改密码';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get themeLabel => '主题';

  @override
  String get boardThemeLabel => '棋盘主题';

  @override
  String get backgroundThemeLabel => '背景主题';

  @override
  String get themeDarkBlue => '深蓝';

  @override
  String get themeOledBlack => 'OLED 黑';

  @override
  String get themeClassicWood => '经典木纹';

  @override
  String get themeLightMode => '浅色';

  @override
  String get themeHalloween => '万圣节';

  @override
  String get themeWinter => '冬季';

  @override
  String get themeForest => '森林';

  @override
  String get boardClassic => '经典';

  @override
  String get boardWalnut => '胡桃木';

  @override
  String get boardSlate => '石板';

  @override
  String get boardNight => '夜间';

  @override
  String get bgStandard => '标准';

  @override
  String get bgMinimal => '简约';

  @override
  String get bgWarm => '暖色';

  @override
  String get bgCool => '冷色';

  @override
  String get conceptLibertiesCaptures => '气与提子';

  @override
  String get conceptLibertyCounting => '数气';

  @override
  String get conceptLifeDeathTwoEyes => '死活 — 两眼';

  @override
  String get conceptKoRule => '劫规则';

  @override
  String get conceptLibertiesCapturesDesc =>
      '当棋子的所有气（相邻空点）都被对方占据时，该棋子被提子。连接的棋子作为一个整体共享气。';

  @override
  String get conceptLibertyCountingDesc =>
      '棋子或棋群相邻的每个空点都是一口气。连接的棋子形成一组并共享所有气。当一组只剩一口气时即为「打吃」。';

  @override
  String get conceptLifeDeathDesc =>
      '拥有两个独立眼位的棋群无法被提子，因为对方无法同时填入两个眼位。这是判断棋群死活的根本概念。';

  @override
  String get conceptKoRuleDesc =>
      '劫规则禁止在重复的局面下立即提回，避免无限循环。提劫之后必须先在别处下一手才能再次提回。';

  @override
  String get analysisPanelTitle => '分析';

  @override
  String get analysisOn => '开启分析';

  @override
  String get analysisOff => '关闭分析';

  @override
  String get noServerForAnalysis => '请在设置中配置 KataGo 服务器以启用分析功能。';

  @override
  String get moveQualityBest => '最佳';

  @override
  String get moveQualityGood => '良好';

  @override
  String get moveQualityInaccuracy => '不准确';

  @override
  String get moveQualityMistake => '失误';

  @override
  String get moveQualityBlunder => '大错';

  @override
  String get moveQualityExcellent => '优秀';

  @override
  String get cancel => '取消';

  @override
  String get aiThinking => 'AI思考中…';

  @override
  String get noLegalMoves => '没有合法落子点，请选择让一手。';

  @override
  String get useHintTitle => '使用提示？';

  @override
  String useHintContent(int remaining) {
    return '显示最佳落子。消耗1颗★（剩余$remaining颗）。';
  }

  @override
  String get showHint => '显示提示';

  @override
  String get noHintAvailable => '没有可用提示，请尝试让一手。';

  @override
  String get resignTitle => '认输本局？';

  @override
  String get resignConfirmBot => '对手将以认输方式获胜。';

  @override
  String resignConfirmLocal(String side) {
    return '$side认输，对手获胜。';
  }

  @override
  String get resign => '认输';

  @override
  String get gameReview => '复盘';

  @override
  String get rematch => '重来';

  @override
  String get close => '关闭';

  @override
  String get noHintsRemaining => '提示已用完';

  @override
  String get showBestMove => '显示最佳落子（-1★）';

  @override
  String get noHintsUsed => '未使用提示';

  @override
  String hintsUsed(int count) {
    return '已使用$count个提示';
  }

  @override
  String get resumeLesson => '继续课程？';

  @override
  String resumeLessonContent(int step) {
    return '从第$step步继续？';
  }

  @override
  String get startOver => '重新开始';

  @override
  String get resume => '继续';

  @override
  String get notQuiteTapHint => '不太对，请尝试其他位置。';

  @override
  String get hintShownTapHint => '提示：按标记落子。';

  @override
  String get lessonComplete => '课程完成！';

  @override
  String dayStreak(int count) {
    return '连续$count天';
  }

  @override
  String get master => '大师';

  @override
  String get quickDrills => '快速练习';

  @override
  String get score => '比分';

  @override
  String get black => '黑棋';

  @override
  String get white => '白棋';

  @override
  String get you => '你';

  @override
  String get computer => '电脑';

  @override
  String get whiteWinsByResignation => '白棋认输胜';

  @override
  String get blackWinsByResignation => '黑棋认输胜';

  @override
  String blackWinsByPoints(int points) {
    return '黑棋领先$points目胜！';
  }

  @override
  String whiteWinsByPoints(int points) {
    return '白棋领先$points目胜！';
  }

  @override
  String get gameTied => '平局！';

  @override
  String get gameReviewComingSoon => '复盘功能即将上线';

  @override
  String get rating => '等级分';

  @override
  String get today => '今日';

  @override
  String get streak => '连续';

  @override
  String get xp => '经验值';

  @override
  String get seeAll => '查看全部';

  @override
  String get save => '保存';

  @override
  String get swapPuzzle => '换题';

  @override
  String get replay => '重播';

  @override
  String get continueLearning => '继续学习';

  @override
  String get noLessonsYet => '暂无课程';

  @override
  String get finishPreviousLesson => '完成上一课程以解锁此课程。';

  @override
  String get noGamesYet => '暂无对局 — 完成一局后即可在此查看。';

  @override
  String get premium => '高级';

  @override
  String get unlockPremium => '解锁高级版';

  @override
  String get youArePremium => '您已是高级用户';

  @override
  String get unlockGokoPremium => '解锁 GOKO 高级版';

  @override
  String get paywallTagline => '深度训练。更强对局。解锁一切。';

  @override
  String get unlimitedPuzzles => '无限题目';

  @override
  String get freePuzzleLimit => '免费用户每天3题';

  @override
  String get allBotsAndLessons => '全部机器人和课程';

  @override
  String get allBotsAndLessonsDesc => '初级机器人和前4节课程免费';

  @override
  String get postGameAnalysis => '赛后分析';

  @override
  String get postGameAnalysisDesc => '深度回顾任何已完成对局（即将推出）';

  @override
  String get profileFlair => '个人资料装扮';

  @override
  String get profileFlairDesc => '高级徽章和头像边框';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get puzzleDailyQuotaReached => '您今天的3道免费题已用完。升级获取无限题目。';

  @override
  String get advancedBotsLocked => '中级、高级和大师机器人需要高级版。';

  @override
  String get premiumLessonsLocked => '第5节及之后的课程需要高级版。';

  @override
  String seeAllLessons(int count) {
    return '查看全部$count节课';
  }

  @override
  String get dayStreakLabel => '连续天数';

  @override
  String get snapback => '倒扑';

  @override
  String get ladder => '征子';

  @override
  String get connect => '连接';

  @override
  String get lockedPremium => '高级';
}
