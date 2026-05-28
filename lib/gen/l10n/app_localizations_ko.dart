// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'GOKO';

  @override
  String get play => '대국';

  @override
  String get learn => '학습';

  @override
  String get puzzles => '퍼즐';

  @override
  String get profile => '프로필';

  @override
  String get settings => '설정';

  @override
  String get quickActions => '빠른 실행';

  @override
  String get practice => '연습';

  @override
  String get playVsBot => 'AI와 대국';

  @override
  String get tutorial => '튜토리얼';

  @override
  String get dailyChallenge => '오늘의 도전';

  @override
  String get recentGames => '최근 대국';

  @override
  String get heroPrimary => '두기 · 배우기 · 성장하기';

  @override
  String get heroSub => '오프라인에서도 모든 기능 사용 가능!';

  @override
  String get selectGameMode => '게임 모드 선택';

  @override
  String get vsComputer => '컴퓨터와 대국';

  @override
  String get vsFriend => '친구와 대국 (같은 기기)';

  @override
  String get vsOnline => '온라인 대국';

  @override
  String get selectBoardSize => '바둑판 크기 선택';

  @override
  String get selectDifficulty => '난이도 선택';

  @override
  String get learnGo => '바둑 배우기';

  @override
  String get lessons => '강의';

  @override
  String get practiceTab => '연습';

  @override
  String get statistics => '통계';

  @override
  String get games => '대국 수';

  @override
  String get winRate => '승률';

  @override
  String get puzzleRating => '퍼즐 레이팅';

  @override
  String get language => '언어';

  @override
  String get appLanguage => '앱 언어';

  @override
  String get appearance => '화면';

  @override
  String get darkMode => '다크 모드';

  @override
  String get darkModeSubtitle => '밝은 테마와 어두운 테마 전환';

  @override
  String get showCoordinates => '좌표 표시';

  @override
  String get lightThemeInGame => '게임 중 밝은 테마 사용';

  @override
  String get lightThemeInGameSubtitle => '게임 화면에서 밝은 테마 강제 적용';

  @override
  String get puzzleSolved => '퍼즐 해결!';

  @override
  String get notQuite => '아쉽네요';

  @override
  String get hint => '힌트';

  @override
  String get reset => '초기화';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get illegalMoveFeedback => '불법 착점 (코 / 자살) — 다른 점을 선택하세요.';

  @override
  String get wrongMoveFeedback => '잘못된 착점 — 다시 시도하세요!';

  @override
  String get giveUp => '포기';

  @override
  String get stepBack => '한 수 되돌리기';

  @override
  String get continue_ => '계속';

  @override
  String get nextPuzzle => '다음 퍼즐';

  @override
  String get theoryExplanation => '이론 및 해설';

  @override
  String get solveToUnlock => '풀면 잠금 해제';

  @override
  String get learnWhyThisWorks => '왜 이렇게 되는지 알아보기';

  @override
  String get keyConceptPrefix => '핵심 개념: ';

  @override
  String get gameHistory => '대국 기록';

  @override
  String get noRecentGames => '최근 대국이 없습니다';

  @override
  String get home => '홈';

  @override
  String get history => '기록';

  @override
  String get playVsBotTitle => 'AI와 대국';

  @override
  String get kataGoSection => 'AI / KataGo';

  @override
  String get kataGoServerUrl => 'KataGo 서버 URL';

  @override
  String get kataGoHint => '비워두면 내장 MCTS 엔진(오프라인)을 사용합니다.';

  @override
  String get leelaServerUrl => 'Leela Zero / GTP 서버 URL';

  @override
  String get leelaHint =>
      'GTP-over-WebSocket 엔진(Leela Zero, ELF OpenGo)을 연결하세요. KataGo URL이 설정된 경우 무시됩니다.';

  @override
  String get localEngineTitle => '로컈 AI 엔진';

  @override
  String get localEngineSubtitle => '자동 관리 KataGo (서버 불필요)';

  @override
  String get engineStatusReady => 'KataGo 준비완료';

  @override
  String get engineStatusStarting => '시작 중…';

  @override
  String get engineStatusNotFound => '설치되지 않음';

  @override
  String get engineStatusError => '오류';

  @override
  String get enginesFolderLabel => '엔진 폴더';

  @override
  String get downloadKataGo => 'KataGo 다운로드';

  @override
  String get engineRestartButton => '엔진 재시작';

  @override
  String get prev => '이전';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get playDemo => '데모 재생';

  @override
  String get replayDemo => '데모 다시 재생';

  @override
  String get playingDemo => '재생 중…';

  @override
  String get interactiveTapBoard => '상호작용 — 바둑판을 탭하세요';

  @override
  String get sourcePrefix => '출처: ';

  @override
  String stepXofY(int current, int total) {
    return '$current / $total 단계';
  }

  @override
  String get dailyPuzzles => '오늘의 퍼즐';

  @override
  String get collections => '컬렉션';

  @override
  String get categories => '카테고리';

  @override
  String get captures => '잡기';

  @override
  String get liberties => '활로';

  @override
  String get lifeDeath => '사활';

  @override
  String get koBasics => '패의 기초';

  @override
  String get tesuji => '묘수';

  @override
  String get swap => '교체';

  @override
  String swapsLeft(int count) {
    return '교체 가능: $count회';
  }

  @override
  String solvedCount(int solved, int total) {
    return '$solved/$total 해결';
  }

  @override
  String get learningPath => '학습 경로';

  @override
  String get allTutorials => '모든 튜토리얼';

  @override
  String get byLevel => '레벨별';

  @override
  String get beginner => '초급';

  @override
  String get intermediate => '중급';

  @override
  String get advanced => '고급';

  @override
  String get objective => '목표';

  @override
  String get difficulty => '난이도';

  @override
  String get yourTurn => '당신 차례';

  @override
  String get moves => '수';

  @override
  String get markAsLearned => '학습 완료 ✓';

  @override
  String get blackToPlay => '흑번';

  @override
  String get whiteToPlay => '백번';

  @override
  String get comingSoon => '출시 예정';

  @override
  String get general => '일반';

  @override
  String get gameSettings => '게임 설정';

  @override
  String get notifications => '알림';

  @override
  String get soundEffects => '효과음';

  @override
  String get soundEffectsSubtitle => '대국 중 효과음 재생';

  @override
  String get vibration => '진동';

  @override
  String get vibrationSubtitle => '착수 시 진동';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get pushNotificationsSubtitle => '대국 관련 알림 받기';

  @override
  String get account => '계정';

  @override
  String get editProfile => '프로필 편집';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get about => '정보';

  @override
  String get version => '버전';

  @override
  String get termsOfService => '이용 약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get themeLabel => '테마';

  @override
  String get boardThemeLabel => '바둑판 테마';

  @override
  String get backgroundThemeLabel => '배경 테마';

  @override
  String get themeDarkBlue => '다크 블루';

  @override
  String get themeOledBlack => 'OLED 블랙';

  @override
  String get themeClassicWood => '클래식 우드';

  @override
  String get themeLightMode => '라이트';

  @override
  String get themeHalloween => '할로윈';

  @override
  String get themeWinter => '겨울';

  @override
  String get themeForest => '포레스트';

  @override
  String get boardClassic => '클래식';

  @override
  String get boardWalnut => '월넛';

  @override
  String get boardSlate => '슬레이트';

  @override
  String get boardNight => '나이트';

  @override
  String get bgStandard => '표준';

  @override
  String get bgMinimal => '미니멀';

  @override
  String get bgWarm => '따뜻한';

  @override
  String get bgCool => '차가운';

  @override
  String get conceptLibertiesCaptures => '활로와 잡기';

  @override
  String get conceptLibertyCounting => '활로 세기';

  @override
  String get conceptLifeDeathTwoEyes => '사활 — 두 눈';

  @override
  String get conceptKoRule => '패 규칙';

  @override
  String get conceptLibertiesCapturesDesc =>
      '돌의 모든 활로(인접한 빈 점)가 상대 돌로 채워지면 돌은 잡힙니다. 연결된 돌은 활로를 공유하는 하나의 무리로 취급됩니다.';

  @override
  String get conceptLibertyCountingDesc =>
      '돌이나 무리에 인접한 각각의 빈 점이 활로입니다. 연결된 돌은 하나의 무리를 이루며 모든 활로를 공유합니다. 활로가 하나만 남은 상태를 「단수」라고 부릅니다.';

  @override
  String get conceptLifeDeathDesc =>
      '두 개의 독립된 눈을 가진 무리는 상대가 두 눈을 동시에 채울 수 없기 때문에 잡히지 않습니다. 이는 무리의 사활을 판단하는 기본 개념입니다.';

  @override
  String get conceptKoRuleDesc =>
      '패 규칙은 같은 모양의 즉시 다시 따냄을 금지하여 무한 반복을 방지합니다. 패를 따낸 후에는 다른 곳에 한 수를 두어야 다시 따낼 수 있습니다.';

  @override
  String get analysisPanelTitle => '분석';

  @override
  String get analysisOn => '분석 활성화';

  @override
  String get analysisOff => '분석 비활성화';

  @override
  String get noServerForAnalysis => '분석을 활성화하려면 설정에서 KataGo 서버를 구성하세요.';

  @override
  String get moveQualityBest => '최선';

  @override
  String get moveQualityGood => '좋음';

  @override
  String get moveQualityInaccuracy => '부정확';

  @override
  String get moveQualityMistake => '실수';

  @override
  String get moveQualityBlunder => '대실수';

  @override
  String get moveQualityExcellent => '우수';

  @override
  String get cancel => '취소';

  @override
  String get aiThinking => 'AI 생각 중…';

  @override
  String get noLegalMoves => '합법적인 수가 없습니다. 패스를 누르세요.';

  @override
  String get useHintTitle => '힌트를 사용하시겠습니까?';

  @override
  String useHintContent(int remaining) {
    return '최선의 수를 공개합니다. 1★ 소모 (남은 $remaining개).';
  }

  @override
  String get showHint => '힌트 표시';

  @override
  String get noHintAvailable => '힌트가 없습니다. 패스를 시도하세요.';

  @override
  String get resignTitle => '이 대국을 기권하시겠습니까?';

  @override
  String get resignConfirmBot => '상대방이 기권승을 거두게 됩니다.';

  @override
  String resignConfirmLocal(String side) {
    return '$side이(가) 기권합니다. 상대방이 이깁니다.';
  }

  @override
  String get resign => '기권';

  @override
  String get gameReview => '기보 분석';

  @override
  String get rematch => '재대결';

  @override
  String get close => '닫기';

  @override
  String get noHintsRemaining => '힌트가 남아있지 않습니다';

  @override
  String get showBestMove => '최선의 수 표시（-1★）';

  @override
  String get noHintsUsed => '힌트 미사용';

  @override
  String hintsUsed(int count) {
    return '힌트 $count회 사용';
  }

  @override
  String get resumeLesson => '레슨을 계속하시겠습니까?';

  @override
  String resumeLessonContent(int step) {
    return '$step단계부터 계속하시겠습니까?';
  }

  @override
  String get startOver => '처음부터';

  @override
  String get resume => '계속';

  @override
  String get notQuiteTapHint => '아닙니다. 다른 곳을 시도하세요.';

  @override
  String get hintShownTapHint => '힌트: 표시를 따라가세요.';

  @override
  String get lessonComplete => '레슨 완료!';

  @override
  String dayStreak(int count) {
    return '$count일 연속';
  }

  @override
  String get master => '마스터';

  @override
  String get quickDrills => '빠른 연습';

  @override
  String get score => '점수';

  @override
  String get black => '흑';

  @override
  String get white => '백';

  @override
  String get you => '당신';

  @override
  String get computer => '컴퓨터';

  @override
  String get whiteWinsByResignation => '백이 기권승';

  @override
  String get blackWinsByResignation => '흑이 기권승';

  @override
  String blackWinsByPoints(int points) {
    return '흑이 $points점 차 승리!';
  }

  @override
  String whiteWinsByPoints(int points) {
    return '백이 $points점 차 승리!';
  }

  @override
  String get gameTied => '무승부!';

  @override
  String get rating => '레이팅';

  @override
  String get today => '오늘';

  @override
  String get streak => '연속';

  @override
  String get xp => '경험치';

  @override
  String get seeAll => '모두 보기';

  @override
  String get save => '저장';

  @override
  String get swapPuzzle => '문제 교체';

  @override
  String get replay => '다시 보기';

  @override
  String get continueLearning => '계속 학습하기';

  @override
  String get noLessonsYet => '아직 수업이 없습니다';

  @override
  String get finishPreviousLesson => '이 수업을 열려면 이전 수업을 완료하세요.';

  @override
  String get noGamesYet => '아직 대국이 없습니다 — 완료 후 여기에 표시됩니다.';

  @override
  String get premium => '프리미엄';

  @override
  String get unlockPremium => '프리미엄 잠금 해제';

  @override
  String get youArePremium => '프리미엄 회원입니다';

  @override
  String get unlockGokoPremium => 'GOKO 프리미엄 잠금 해제';

  @override
  String get paywallTagline => '더 깊이 훈련하세요. 더 강하게 대국하세요. 모든 것을 해제하세요.';

  @override
  String get unlimitedPuzzles => '무제한 문제';

  @override
  String get freePuzzleLimit => '무료: 하루 3문제';

  @override
  String get allBotsAndLessons => '모든 봇과 수업';

  @override
  String get allBotsAndLessonsDesc => '초급 봇과 처음 4개 수업은 무료';

  @override
  String get postGameAnalysis => '대국 분석';

  @override
  String get postGameAnalysisDesc => '완료된 대국을 한 수씩 되감아 보세요.';

  @override
  String get profileFlair => '프로필 꾸미기';

  @override
  String get profileFlairDesc => '프리미엄 뱃지와 아바타 테두리';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get puzzleDailyQuotaReached =>
      '오늘의 무료 문제 3개를 모두 사용했습니다. 무제한을 위해 업그레이드하세요.';

  @override
  String get advancedBotsLocked => '중급, 고급, 마스터 봇은 프리미엄이 필요합니다.';

  @override
  String get premiumLessonsLocked => '5번째 수업 이후는 프리미엄이 필요합니다.';

  @override
  String seeAllLessons(int count) {
    return '전체 $count개 수업 보기';
  }

  @override
  String get dayStreakLabel => '연속 일수';

  @override
  String get snapback => '환격';

  @override
  String get ladder => '축';

  @override
  String get connect => '연결';

  @override
  String get lockedPremium => '프리미엄';

  @override
  String get stoneColors => '돌 색상';

  @override
  String get stoneColorClassic => '클래식';

  @override
  String get stoneColorJade => '비취';

  @override
  String get stoneColorAmber => '호박';

  @override
  String get stoneColorCobalt => '코발트';

  @override
  String get stoneColorCrimson => '크림슨';

  @override
  String get stoneColorMono => '모노';

  @override
  String get freeTrialBadge => '7일 무료';

  @override
  String get freeTrialSubtitle => '언제든 취소';

  @override
  String get ogsLogin => 'OGS 로그인';

  @override
  String get onlineGoServer => 'Online Go Server';

  @override
  String get signInWithOgsAccount => 'OGS 계정으로 로그인';

  @override
  String get signIn => '로그인';

  @override
  String get username => '사용자 이름';

  @override
  String get password => '비밀번호';

  @override
  String get enterUsernamePassword => '사용자 이름과 비밀번호를 입력하세요';

  @override
  String get loginFailed => '로그인 실패. 자격 증명을 확인하세요.';

  @override
  String get errorPrefix => '오류: ';

  @override
  String get noAccountSignUp => '계정이 없나요? OGS에서 가입';

  @override
  String get orContinueWith => '또는 다음으로 계속';

  @override
  String get continueWithOgs => 'OGS로 계속하기 (Google 등)';

  @override
  String get onlinePlay => '온라인 대국';

  @override
  String get onlineStatusConnected => '온라인';

  @override
  String get onlineStatusOffline => '오프라인';

  @override
  String get ogsPlayer => 'OGS 플레이어';

  @override
  String get notLoggedIn => '로그인되지 않음';

  @override
  String get pleaseLogInToPlayOnline => '온라인 대국을 위해 OGS로 로그인하세요';

  @override
  String get goBack => '뒤로';

  @override
  String get appTagline => '고대 바둑 게임을 마스터하세요';

  @override
  String get featurePlayBots => 'KataGo 및 온라인 봇과의 대국';

  @override
  String get featurePuzzlesLessons => '퍼즐, 레슨 및 일일 훈련';

  @override
  String get featureLiveGames => 'Online Go Server의 라이브 대국';

  @override
  String get signInWithOgs => 'OGS로 로그인';

  @override
  String get createOgsAccount => '무료 OGS 계정 만들기';

  @override
  String get displayName => '표시 이름';

  @override
  String get attributionAvatars => '봇 아바타: OpenMoji (CC BY-SA 4.0)';

  @override
  String get goodMorning => '좋은 아침이에요';

  @override
  String get goodAfternoon => '좋은 오후예요';

  @override
  String get goodEvening => '좋은 저녁이에요';

  @override
  String get unranked => '급수 없음';

  @override
  String get friendComputerOnline => '친구, 컴퓨터 또는 온라인';

  @override
  String get dailyPuzzle => '오늘의 문제';

  @override
  String get playBot => '봇과 대국';

  @override
  String get vsComputerSubtitle => '봇 선택 — 오프라인 AI';

  @override
  String get vsFriendSubtitle => '같은 기기에서 번갈아 두기';

  @override
  String get vsOnlineSubtitle => 'OGS 라이브 대국';

  @override
  String get playFirstGameHint => '첫 대국을 시작하세요 — 여기에 표시됩니다.';

  @override
  String get puzzleStreak => '연속 문제';

  @override
  String get puzzleStreakSubtitle => '틀릴 때까지 계속 풀기';

  @override
  String get currentStreak => '연속';

  @override
  String get bestLabel => '최고';

  @override
  String get streakEndedTitle => '연속 종료';

  @override
  String get newRecord => '새 기록!';

  @override
  String get puzzleModes => '문제 모드';

  @override
  String get leagueLabel => '리그';

  @override
  String get leagueRookie => '루키';

  @override
  String get leagueBronze => '브론즈';

  @override
  String get leagueSilver => '실버';

  @override
  String get leagueGold => '골드';

  @override
  String get leaguePlatinum => '플래티넘';

  @override
  String get leagueDiamond => '다이아몬드';

  @override
  String get puzzleMap => '지도';

  @override
  String get puzzleList => '목록';

  @override
  String get world1Beginner => '초보자의 정원';

  @override
  String get world2Intermediate => '중급자의 호수';

  @override
  String get world3Advanced => '고수의 화산';

  @override
  String get coachStreakIntro1 => '연속 도전을 시작할 준비됐나요?';

  @override
  String get coachStreakIntro2 => '오늘은 얼마나 이어갈 수 있나요?';

  @override
  String get coachStreakIntro3 => '최고 기록을 깨보세요!';

  @override
  String get coachStreakIntro4 => '한 번 실수하면 끝. 부담 갖지 마세요!';

  @override
  String get coachStreakIntro5 => '매일 연습이 두뇌를 예리하게 합니다.';

  @override
  String get coachSolve1 => '좋아요!';

  @override
  String get coachSolve2 => '훌륭해요!';

  @override
  String get coachSolve3 => '연속 기록 진행 중!';

  @override
  String get coachSolve4 => '꽤 어려웠어요!';

  @override
  String get coachSolve5 => '완벽한 수읽기.';

  @override
  String get coachSolve6 => '계속 가세요!';

  @override
  String get openLesson => '열기';

  @override
  String get puzzleGardenTitle => '초보자의 정원';

  @override
  String get coachLeagueRookieUnlocked => '환영합니다, 루키! 레이팅을 올려봅시다.';

  @override
  String get coachLeagueBronzeUnlocked => '브론즈 리그! 출발이 좋아요.';

  @override
  String get coachLeagueSilverUnlocked => '실버 리그! 판이 보이기 시작해요.';

  @override
  String get coachLeagueGoldUnlocked => '골드 리그! 진정한 전사.';

  @override
  String get coachLeaguePlatinumUnlocked => '플래티넘 리그! 여기까지 오는 사람은 드물어요.';

  @override
  String get coachLeagueDiamondUnlocked => '다이아몬드 리그! 마스터급.';

  @override
  String get coachKeepGoing => '다음 돌을 두세요 — 계속 올라가요!';

  @override
  String get coachTryAgain => '괜찮아요 — 다른 곳을 시도해 보세요.';

  @override
  String xpToNextLeague(int count, String league) {
    return '$league까지 $count XP';
  }

  @override
  String gateLockedUnlockAt(int xp) {
    return '$xp XP에서 잠금 해제';
  }

  @override
  String get solvePuzzles => '문제 풀기';

  @override
  String levelN(int n) {
    return '레벨 $n';
  }

  @override
  String get puzzleBestMove => '최선의 수를 찾으세요';

  @override
  String xpToUnlock(int xp) {
    return '+$xp XP';
  }

  @override
  String get worldStoneForest => '돌의 숲';

  @override
  String get worldCrystalCave => '수정 동굴';

  @override
  String get worldCopperPeaks => '구리 봉우리';

  @override
  String get worldDiamondTundra => '다이아몬드 툰드라';

  @override
  String get worldJadeHighlands => '옥 고원';

  @override
  String get quit => '종료';

  @override
  String get drillCompleteTitle => '드릴 완료';

  @override
  String get backToLearn => '학습으로 돌아가기';

  @override
  String get quitDrillTitle => '드릴 종료?';

  @override
  String get quitDrillBody => '지금 종료하면 진행 상황이 저장되지 않습니다.';

  @override
  String get resignGameTitle => '기권하시겠습니까?';

  @override
  String get resignGameBody => '정말 기권하시겠습니까?';

  @override
  String get undoRequestTitle => '무르기 요청';

  @override
  String get decline => '거절';

  @override
  String get accept => '수락';

  @override
  String get gameInfoTitle => '대국 정보';

  @override
  String get leaveGame => '대국 떠나기';

  @override
  String get connectionTestTitle => '연결 테스트';

  @override
  String get runConnectionTest => '테스트 실행';

  @override
  String get findOpponentSubtitle => '빠른 대국 상대를 즉시 찾기';

  @override
  String get startMatchHint => '빠른 대국으로 시작하세요!';

  @override
  String get shuffle => '셔플';

  @override
  String get tutorialsTitle => '튜토리얼';

  @override
  String get learnGardenTitle => '학습';

  @override
  String get categoryFundamentals => '기초';

  @override
  String get categoryRules => '규칙';

  @override
  String get categoryLifeDeath => '사활';

  @override
  String get categoryStrategy => '전략';

  @override
  String lessonsInCategoryCount(int count) {
    return '$count개 레슨';
  }

  @override
  String get continueLessonCta => '레슨 계속하기';

  @override
  String get startLessonCta => '첫 레슨 시작';

  @override
  String get lessonLocked => '프리미엄 레슨';

  @override
  String get coachLearnIntro1 => '다음은 어디로?';

  @override
  String get coachLearnIntro2 => '하루 한 레슨이면 머리가 맑아져요.';

  @override
  String get coachLearnIntro3 => '짧은 레슨을 시도해 보세요 — 5분도 안 걸려요.';

  @override
  String get coachLearnIntro4 => '카테고리를 골라 보세요 — 어느 길이든 재미있어요.';

  @override
  String get coachLearnIntro5 => '돌을 탭해 학습을 시작하세요!';

  @override
  String get coachCategoryDone => '한 카테고리를 모두 완료했어요 — 대단해요!';

  @override
  String get botDescPanda => '달콤하고 엉뚱합니다. 무작위 수를 좋아합니다.';

  @override
  String get botDescPup => '돌을 쫓는 신난 강아지. 쉽게 따돌릴 수 있습니다.';

  @override
  String get botDescBunny => '호기심 많고 예측 불가한 수로 판 위를 깡총거립니다.';

  @override
  String get botDescKoi => '부드럽고 안정적. 변과 작은 집을 좋아합니다.';

  @override
  String get botDescTanuki => '교활한 정령. 기본적인 잡기와 형태를 알고 있습니다.';

  @override
  String get botDescPebble => '조용하고 안정적. 천천히 견고한 형태를 쌓습니다.';

  @override
  String get botDescHeron => '참을성이 있음. 변의 허술한 형태를 부숩니다.';

  @override
  String get botDescOwl => '지혜롭고 인내심. 견고한 집의 틀을 쌓습니다.';

  @override
  String get botDescCrane => '우아하고 균형 잡힘. 가볍고 유연한 형태를 둡니다.';

  @override
  String get botDescMantis => '예리하고 빠름. 수읽기로 전술 수순을 계산합니다.';

  @override
  String get botDescBadger => '어떤 돌도 싸움 없이 보내지 않습니다.';

  @override
  String get botDescKitsune => '교활한 여우. 과수를 응징하고 좋은 형을 보상합니다.';

  @override
  String get botDescPhoenix => '압박 속에서 날카로운 역공으로 일어섭니다.';

  @override
  String get botDescHawk => '압박형 기사. 끊임없이 약한 돌을 노립니다.';

  @override
  String get botDescTiger => '사나운 전사. 약한 돌을 공격하는 걸 좋아합니다.';

  @override
  String get botDescOtter => '유연하고 장난기 많음. 공격과 수비를 오갑니다.';

  @override
  String get botDescDragon => '강한 수읽기와 깔끔한 끝내기. 정확함을 요구합니다.';

  @override
  String get botDescSamurai => '명예와 절제. 강한 싸움과 깨끗한 모양.';

  @override
  String get botDescTengu => '산의 정령. 강한 전투와 효율적인 형태.';

  @override
  String get botDescMonk => '차분하고 깊은 형세 판단. 전판을 봅니다.';

  @override
  String get botDescOracle => '수십 수 앞의 변화를 봅니다. 속이기 어려운 상대.';

  @override
  String get botDescSensei => '현명한 스승. 가장 교훈적인 프로 수를 둡니다.';

  @override
  String get botDescKataGo => '신경망으로 수십 수 앞을 계획. 초인적 전략 시야.';

  @override
  String get tauntDefaultGreet => '한 판 두시죠!';

  @override
  String get tauntDefaultWin => '좋은 대국이었습니다! 잘 두셨네요.';

  @override
  String get tauntDefaultLose => '멋진 대국이었습니다 — 다음 기회에!';

  @override
  String get tauntDefaultResign => '대국 감사합니다!';

  @override
  String get tauntPandaGreet => '안녕 친구! 같이 두자!';

  @override
  String get tauntPandaWin => '야호! 내가 이겼다!';

  @override
  String get tauntPandaLose => '정말 잘 두시네요!';

  @override
  String get undoMove => '수 무르기';

  @override
  String get passTurn => '패스';

  @override
  String get redoMove => '다시 두기';

  @override
  String get newGame => '새 대국';

  @override
  String get practiceBadge => '연습';

  @override
  String get notYourTurn => '당신 차례가 아닙니다!';

  @override
  String get menuTooltip => '메뉴';

  @override
  String get profileTooltip => '프로필';

  @override
  String get wins => '승';

  @override
  String get losses => '패';

  @override
  String get draws => '무';

  @override
  String get winLossLabel => '승 / 패';

  @override
  String get playGamesHint => '대국을 하면 여기에 통계가 표시됩니다.';

  @override
  String get filterAll => '전체';

  @override
  String get noPuzzlesForFilter => '이 필터에 해당하는 문제가 없습니다.';

  @override
  String tutorialsLoadError(String error) {
    return '튜토리얼을 불러올 수 없습니다: $error';
  }

  @override
  String get noTutorialsYet => '아직 튜토리얼이 없습니다.';

  @override
  String get practiceModeTitle => '연습 모드';

  @override
  String get practiceModeSubtitle => '수마다 최선의 수 표시 · 결과는 1 ★';

  @override
  String get chooseBoardSize => '판 크기 선택';

  @override
  String get undoRequestSent => '무르기 요청을 보냈습니다';

  @override
  String get undoRequestDeclined => '무르기 요청이 거절되었습니다';

  @override
  String get undoRequestAccepted => '무르기 요청이 수락되었습니다';

  @override
  String opponentRequestedUndo(int moveNumber) {
    return '상대가 #$moveNumber수에 대한 무르기를 요청했습니다.';
  }

  @override
  String suggestedRemovedStones(int count) {
    return '$count개의 죽은 돌을 제안했습니다';
  }

  @override
  String gameIdLabel(String id) {
    return '대국 ID: $id';
  }

  @override
  String moveLabel(int n) {
    return '수: $n';
  }

  @override
  String phaseLabel(String phase) {
    return '단계: $phase';
  }

  @override
  String boardLabel(String size) {
    return '판: $size';
  }

  @override
  String hintLookAt(int row, String col) {
    return '$row행, $col열을 보세요 — 여기에 강한 수가 있습니다.';
  }

  @override
  String get hintFallbackGeneric => '상대 돌을 압박하는 수를 찾으세요 — 단수, 약한 그룹, 눈 모양에 주목.';

  @override
  String get paywallHeroTitle => 'GOKO Premium 잠금 해제';

  @override
  String get paywallHeroTagline => '고대의 게임을 마스터하세요';

  @override
  String get paywallFeatureUnlimitedPuzzles => '무제한 일일 문제';

  @override
  String get paywallFeatureAllBots => '모든 봇 — Pup부터 KataGo까지';

  @override
  String get paywallFeatureLessons => '전체 레슨 + 복기 분석';

  @override
  String get paywallFeatureSync => '클라우드 동기화, 배지, 프로필 장식';

  @override
  String get pricingTierMonthly => '월간';

  @override
  String get pricingTierAnnual => '연간';

  @override
  String get pricingTierLifetime => '평생';

  @override
  String get pricingPopular => '가장 인기';

  @override
  String get pricingBestValue => '최고의 가치';

  @override
  String pricingSave(int percent) {
    return '$percent% 절약';
  }

  @override
  String pricingPerMonth(String price) {
    return '$price/월';
  }

  @override
  String pricingPerYear(String price) {
    return '$price/년';
  }

  @override
  String pricingOnce(String price) {
    return '$price 1회';
  }

  @override
  String get startFreeTrial => '7일 무료 체험 시작';

  @override
  String get cancelAnytime => '언제든 취소';

  @override
  String renewsAtPrice(String price) {
    return '$price로 갱신';
  }

  @override
  String trustedByPlayers(String count) {
    return '$count+ 플레이어가 신뢰';
  }

  @override
  String get freeTrialDuration => '7일 무료';

  @override
  String get paywallContinueFree => '나중에';

  @override
  String get scoreStonesLabel => '돌';

  @override
  String get scoreTerritoryLabel => '집';

  @override
  String get scoreCapturedLabel => '사석';

  @override
  String get gameEndedMarkDeadStones => '대국 끝 - 죽은 돌을 표시해 계산하기';

  @override
  String get gameFinished => '대국 완료';

  @override
  String get stoneRemovalAccepted => '돌 제거 승인됨';

  @override
  String get waitForPreviousMove => '이전 수를 기다려주세요';

  @override
  String get positionAlreadyOccupied => '이미 점유된 위치입니다';

  @override
  String get invalidMoveSuicideOrKo => '불법적 수 (자살 또는 코 규칙 위반)';

  @override
  String get moveTimedOut => '수의 시간이 초과됨 - 다시 시도해주세요';

  @override
  String timeSecondsRemaining(int seconds) {
    return '$seconds초 남음!';
  }

  @override
  String periodTimeRemaining(int periods, int time) {
    return '초읽기 $periods - ${time}s';
  }
}
