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
  String get giveUp => '포기';

  @override
  String get stepBack => '한 수 되돌리기';

  @override
  String get continue_ => '계속';

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
  String get comingSoon => '곧 출시';

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
}
