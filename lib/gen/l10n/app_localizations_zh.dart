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
  String get illegalMoveFeedback => '非法落子（打劫/自杀）——请选择其他点。';

  @override
  String get wrongMoveFeedback => '落子有误——请再试一次！';

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
  String get postGameAnalysisDesc => '随时复盘任何已完成对局的每一手棋。';

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

  @override
  String get stoneColors => '棋子颜色';

  @override
  String get stoneColorClassic => '经典';

  @override
  String get stoneColorJade => '翡翠';

  @override
  String get stoneColorAmber => '琥珀';

  @override
  String get stoneColorCobalt => '钴蓝';

  @override
  String get stoneColorCrimson => '绯红';

  @override
  String get stoneColorMono => '单色';

  @override
  String get freeTrialBadge => '7 天免费试用';

  @override
  String get freeTrialSubtitle => '随时取消';

  @override
  String get ogsLogin => 'OGS 登录';

  @override
  String get onlineGoServer => 'Online Go Server';

  @override
  String get signInWithOgsAccount => '使用您的 OGS 账号登录';

  @override
  String get signIn => '登录';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get enterUsernamePassword => '请输入用户名和密码';

  @override
  String get loginFailed => '登录失败，请检查凭据。';

  @override
  String get errorPrefix => '错误：';

  @override
  String get noAccountSignUp => '还没有账号？在 OGS 上注册';

  @override
  String get orContinueWith => '或者通过以下方式继续';

  @override
  String get continueWithOgs => '通过 OGS 继续（Google 等）';

  @override
  String get onlinePlay => '在线对局';

  @override
  String get onlineStatusConnected => '在线';

  @override
  String get onlineStatusOffline => '离线';

  @override
  String get ogsPlayer => 'OGS 玩家';

  @override
  String get notLoggedIn => '未登录';

  @override
  String get pleaseLogInToPlayOnline => '请使用 OGS 登录以进行在线对局';

  @override
  String get goBack => '返回';

  @override
  String get appTagline => '掌握古老的围棋游戏';

  @override
  String get featurePlayBots => '与 KataGo 和在线机器人对弈';

  @override
  String get featurePuzzlesLessons => '题目、课程与每日练习';

  @override
  String get featureLiveGames => '在 Online Go Server 上直播对局';

  @override
  String get signInWithOgs => '使用 OGS 登录';

  @override
  String get createOgsAccount => '创建免费 OGS 账号';

  @override
  String get displayName => '显示名称';

  @override
  String get attributionAvatars => '机器人头像：OpenMoji (CC BY-SA 4.0)';

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get unranked => '未排级';

  @override
  String get friendComputerOnline => '朋友、电脑或在线';

  @override
  String get dailyPuzzle => '每日题目';

  @override
  String get playBot => '对战机器人';

  @override
  String get vsComputerSubtitle => '选择机器人 — 离线AI';

  @override
  String get vsFriendSubtitle => '同一设备传递对弈';

  @override
  String get vsOnlineSubtitle => 'OGS在线对弈';

  @override
  String get playFirstGameHint => '开始您的第一局对弈 — 将在此显示。';

  @override
  String get puzzleStreak => '连续题目';

  @override
  String get puzzleStreakSubtitle => '连续答对直到出错';

  @override
  String get currentStreak => '连续';

  @override
  String get bestLabel => '最佳';

  @override
  String get streakEndedTitle => '连续中断';

  @override
  String get newRecord => '新纪录！';

  @override
  String get puzzleModes => '题目模式';

  @override
  String get leagueLabel => '联赛';

  @override
  String get leagueRookie => '新手';

  @override
  String get leagueBronze => '青铜';

  @override
  String get leagueSilver => '白银';

  @override
  String get leagueGold => '黄金';

  @override
  String get leaguePlatinum => '白金';

  @override
  String get leagueDiamond => '钻石';

  @override
  String get puzzleMap => '地图';

  @override
  String get puzzleList => '列表';

  @override
  String get world1Beginner => '新手花园';

  @override
  String get world2Intermediate => '中级湖泊';

  @override
  String get world3Advanced => '高手火山';

  @override
  String get coachStreakIntro1 => '准备开始连胜了吗？';

  @override
  String get coachStreakIntro2 => '今天能连答多少题？';

  @override
  String get coachStreakIntro3 => '打破你的纪录吧！';

  @override
  String get coachStreakIntro4 => '一次失误就结束。轻松点！';

  @override
  String get coachStreakIntro5 => '每天练习让头脑保持敏锐。';

  @override
  String get coachSolve1 => '漂亮！';

  @override
  String get coachSolve2 => '精彩！';

  @override
  String get coachSolve3 => '连胜继续！';

  @override
  String get coachSolve4 => '这题真难！';

  @override
  String get coachSolve5 => '看得真准。';

  @override
  String get coachSolve6 => '继续加油！';

  @override
  String get openLesson => '打开';

  @override
  String get puzzleGardenTitle => '新手花园';

  @override
  String get coachLeagueRookieUnlocked => '欢迎，新手！一起提升等级吧。';

  @override
  String get coachLeagueBronzeUnlocked => '铜级联赛！你上榜了。';

  @override
  String get coachLeagueSilverUnlocked => '银级联赛！开始看懂棋盘。';

  @override
  String get coachLeagueGoldUnlocked => '金级联赛！真正的战士。';

  @override
  String get coachLeaguePlatinumUnlocked => '白金联赛！很少有人到达。';

  @override
  String get coachLeagueDiamondUnlocked => '钻石联赛！大师级别。';

  @override
  String get coachKeepGoing => '点下一颗棋子——继续攀登！';

  @override
  String get coachTryAgain => '没关系——试试别的点。';

  @override
  String xpToNextLeague(int count, String league) {
    return '距离$league还差 $count XP';
  }

  @override
  String gateLockedUnlockAt(int xp) {
    return '$xp XP 解锁';
  }

  @override
  String get solvePuzzles => '解决题目';

  @override
  String levelN(int n) {
    return '第 $n 关';
  }

  @override
  String get puzzleBestMove => '找出最佳着手';

  @override
  String xpToUnlock(int xp) {
    return '+$xp XP';
  }

  @override
  String get worldStoneForest => '石之森林';

  @override
  String get worldCrystalCave => '水晶洞穴';

  @override
  String get worldCopperPeaks => '铜峰';

  @override
  String get worldDiamondTundra => '钻石冻原';

  @override
  String get worldJadeHighlands => '翡翠高地';

  @override
  String get quit => '退出';

  @override
  String get drillCompleteTitle => '训练完成';

  @override
  String get backToLearn => '返回学习';

  @override
  String get quitDrillTitle => '退出训练？';

  @override
  String get quitDrillBody => '现在退出将不会保存进度。';

  @override
  String get resignGameTitle => '认输？';

  @override
  String get resignGameBody => '确定要认输吗？';

  @override
  String get undoRequestTitle => '悔棋请求';

  @override
  String get decline => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get gameInfoTitle => '对局信息';

  @override
  String get leaveGame => '离开对局';

  @override
  String get connectionTestTitle => '连接测试';

  @override
  String get runConnectionTest => '运行测试';

  @override
  String get findOpponentSubtitle => '立即匹配对手开始快速对局';

  @override
  String get startMatchHint => '开始快速对局！';

  @override
  String get shuffle => '随机';

  @override
  String get tutorialsTitle => '教程';

  @override
  String get learnGardenTitle => '学习';

  @override
  String get categoryFundamentals => '基础';

  @override
  String get categoryRules => '规则';

  @override
  String get categoryLifeDeath => '死活';

  @override
  String get categoryStrategy => '策略';

  @override
  String lessonsInCategoryCount(int count) {
    return '$count 节课';
  }

  @override
  String get continueLessonCta => '继续学习';

  @override
  String get startLessonCta => '开始第一课';

  @override
  String get lessonLocked => '高级课程';

  @override
  String get coachLearnIntro1 => '下一站去哪？';

  @override
  String get coachLearnIntro2 => '每天一节课，大脑常清醒。';

  @override
  String get coachLearnIntro3 => '试一节小课 — 不到 5 分钟。';

  @override
  String get coachLearnIntro4 => '选一个分类 — 每条路都有终点。';

  @override
  String get coachLearnIntro5 => '点一个棋子开始学习吧！';

  @override
  String get coachCategoryDone => '整个分类全部完成 — 太棒了！';

  @override
  String get botDescPanda => '甜美又有些傻气。喜欢下随意的着法。';

  @override
  String get botDescPup => '热情的小狗追着每颗棋子。容易智胜。';

  @override
  String get botDescBunny => '在棋盘上跳跃，下出好奇而难以预料的着法。';

  @override
  String get botDescKoi => '柔和而稳健。喜欢边角的小型围地。';

  @override
  String get botDescTanuki => '狡黠的小精灵。懂基本的吃子和形状。';

  @override
  String get botDescPebble => '安静而稳定。慢慢建立坚实的格局。';

  @override
  String get botDescHeron => '耐心。拆解边线松散的形状。';

  @override
  String get botDescOwl => '睿智而耐心。建立坚实的地盘格局。';

  @override
  String get botDescCrane => '优雅而均衡。下轻盈灵活的形状。';

  @override
  String get botDescMantis => '锐利而敏捷。计算战术次序。';

  @override
  String get botDescBadger => '绝不让一颗棋子不战而走。';

  @override
  String get botDescKitsune => '狡猾的狐狸。惩罚过强，奖励好形。';

  @override
  String get botDescPhoenix => '在压力中以犀利反击崛起。';

  @override
  String get botDescHawk => '压迫型棋手。不断试探你的弱棋。';

  @override
  String get botDescTiger => '凶猛的斗士。喜欢攻击弱棋。';

  @override
  String get botDescOtter => '灵活而俏皮。在攻守间灵活切换。';

  @override
  String get botDescDragon => '强大的读棋与干净的官子。要求精准。';

  @override
  String get botDescSamurai => '荣誉与纪律。强力战斗加干净形状。';

  @override
  String get botDescTengu => '山岳精灵。强力战斗与高效形状。';

  @override
  String get botDescMonk => '沉静、深邃的形势判断。全局视野。';

  @override
  String get botDescOracle => '看到十几手后的变化。难以欺骗。';

  @override
  String get botDescSensei => '睿智的导师。下最具教学意义的职业着法。';

  @override
  String get botDescKataGo => '用神经网络预读数十手。超人的战略视野。';

  @override
  String get tauntDefaultGreet => '我们开始吧！';

  @override
  String get tauntDefaultWin => '好棋！这局你赢得漂亮。';

  @override
  String get tauntDefaultLose => '下得漂亮——下次好运！';

  @override
  String get tauntDefaultResign => '感谢这局棋！';

  @override
  String get tauntPandaGreet => '嗨朋友！来下棋吧！';

  @override
  String get tauntPandaWin => '耶！我赢啦！';

  @override
  String get tauntPandaLose => '你真厉害！';

  @override
  String get undoMove => '悔棋';

  @override
  String get passTurn => '弃权';

  @override
  String get redoMove => '重做';

  @override
  String get newGame => '新游戏';

  @override
  String get practiceBadge => '练习';

  @override
  String get notYourTurn => '现在不是你的回合！';

  @override
  String get menuTooltip => '菜单';

  @override
  String get profileTooltip => '个人资料';

  @override
  String get wins => '胜';

  @override
  String get losses => '负';

  @override
  String get draws => '和';

  @override
  String get winLossLabel => '胜 / 负';

  @override
  String get playGamesHint => '对局后会在此显示战绩。';

  @override
  String get filterAll => '全部';

  @override
  String get noPuzzlesForFilter => '此筛选下无题目。';

  @override
  String tutorialsLoadError(String error) {
    return '无法加载教程：$error';
  }

  @override
  String get noTutorialsYet => '暂无教程。';

  @override
  String get practiceModeTitle => '练习模式';

  @override
  String get practiceModeSubtitle => '每手棋后显示最佳着法 · 结果为 1 ★';

  @override
  String get chooseBoardSize => '选择棋盘大小';

  @override
  String get undoRequestSent => '已发送悔棋请求';

  @override
  String get undoRequestDeclined => '悔棋请求已拒绝';

  @override
  String get undoRequestAccepted => '悔棋请求已接受';

  @override
  String opponentRequestedUndo(int moveNumber) {
    return '对手请求悔棋至第 #$moveNumber 手。';
  }

  @override
  String suggestedRemovedStones(int count) {
    return '建议移除 $count 颗棋子';
  }

  @override
  String gameIdLabel(String id) {
    return '对局 ID：$id';
  }

  @override
  String moveLabel(int n) {
    return '手数：$n';
  }

  @override
  String phaseLabel(String phase) {
    return '阶段：$phase';
  }

  @override
  String boardLabel(String size) {
    return '棋盘：$size';
  }

  @override
  String hintLookAt(int row, String col) {
    return '看第 $row 行，第 $col 列 — 这里有一手强着。';
  }

  @override
  String get hintFallbackGeneric => '找出能压迫对手棋子的着法 — 注意征子、弱棋或眼形。';

  @override
  String get paywallHeroTitle => '解锁 GOKO Premium';

  @override
  String get paywallHeroTagline => '掌握这门古老的棋艺';

  @override
  String get paywallFeatureUnlimitedPuzzles => '无限每日题目';

  @override
  String get paywallFeatureAllBots => '全部机器人 — 从 Pup 到 KataGo';

  @override
  String get paywallFeatureLessons => '完整课程库 + 复盘分析';

  @override
  String get paywallFeatureSync => '云同步、徽章与个人风格';

  @override
  String get pricingTierMonthly => '按月';

  @override
  String get pricingTierAnnual => '按年';

  @override
  String get pricingTierLifetime => '终身';

  @override
  String get pricingPopular => '最受欢迎';

  @override
  String get pricingBestValue => '最划算';

  @override
  String pricingSave(int percent) {
    return '节省 $percent%';
  }

  @override
  String pricingPerMonth(String price) {
    return '$price/月';
  }

  @override
  String pricingPerYear(String price) {
    return '$price/年';
  }

  @override
  String pricingOnce(String price) {
    return '$price 一次性';
  }

  @override
  String get startFreeTrial => '开始 7 天免费试用';

  @override
  String get cancelAnytime => '随时取消';

  @override
  String renewsAtPrice(String price) {
    return '续费 $price';
  }

  @override
  String trustedByPlayers(String count) {
    return '$count+ 玩家的信赖之选';
  }

  @override
  String get freeTrialDuration => '7 天免费';

  @override
  String get paywallContinueFree => '稍后再说';

  @override
  String get scoreStonesLabel => '棋子';

  @override
  String get scoreTerritoryLabel => '地';

  @override
  String get scoreCapturedLabel => '提子';
}
