// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'ГОКО';

  @override
  String get play => 'Играть';

  @override
  String get learn => 'Учёба';

  @override
  String get puzzles => 'Задачи';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get practice => 'Практика';

  @override
  String get playVsBot => 'Игра с ботом';

  @override
  String get tutorial => 'Обучение';

  @override
  String get dailyChallenge => 'Ежедневный вызов';

  @override
  String get recentGames => 'Недавние игры';

  @override
  String get heroPrimary => 'Играй • Учись • Совершенствуйся';

  @override
  String get heroSub => 'Всё работает офлайн — аккаунт не нужен!';

  @override
  String get selectGameMode => 'Выберите режим игры';

  @override
  String get vsComputer => 'Против компьютера';

  @override
  String get vsFriend => 'С другом (на одном устройстве)';

  @override
  String get vsOnline => 'Онлайн';

  @override
  String get selectBoardSize => 'Выберите размер доски';

  @override
  String get selectDifficulty => 'Выберите сложность';

  @override
  String get learnGo => 'Учитесь играть в Го';

  @override
  String get lessons => 'Уроки';

  @override
  String get practiceTab => 'Практика';

  @override
  String get statistics => 'Статистика';

  @override
  String get games => 'Игры';

  @override
  String get winRate => 'Процент побед';

  @override
  String get puzzleRating => 'Рейтинг задач';

  @override
  String get language => 'Язык';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get darkModeSubtitle => 'Переключение между светлой и тёмной темой';

  @override
  String get showCoordinates => 'Показывать координаты';

  @override
  String get lightThemeInGame => 'Светлая тема в игре';

  @override
  String get lightThemeInGameSubtitle =>
      'Принудительно светлая тема в игровом экране';

  @override
  String get puzzleSolved => 'Задача решена!';

  @override
  String get notQuite => 'Не совсем';

  @override
  String get hint => 'Подсказка';

  @override
  String get reset => 'Сброс';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get illegalMoveFeedback =>
      'Недопустимый ход (ко/суицид) — попробуйте другую точку.';

  @override
  String get wrongMoveFeedback => 'Неверный ход — попробуйте ещё раз!';

  @override
  String get giveUp => 'Сдаться';

  @override
  String get stepBack => 'Шаг назад';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get nextPuzzle => 'Следующая задача';

  @override
  String get theoryExplanation => 'Теория и объяснение';

  @override
  String get solveToUnlock => 'Решите задачу, чтобы открыть';

  @override
  String get learnWhyThisWorks => 'Узнайте, почему это работает';

  @override
  String get keyConceptPrefix => 'Ключевая концепция: ';

  @override
  String get gameHistory => 'История игр';

  @override
  String get noRecentGames => 'Нет недавних игр';

  @override
  String get home => 'Главная';

  @override
  String get history => 'История';

  @override
  String get playVsBotTitle => 'Игра с ботом';

  @override
  String get kataGoSection => 'ИИ / KataGo';

  @override
  String get kataGoServerUrl => 'URL сервера KataGo';

  @override
  String get kataGoHint =>
      'Оставьте пустым, чтобы использовать встроенный движок MCTS.';

  @override
  String get leelaServerUrl => 'URL сервера Leela Zero / GTP';

  @override
  String get leelaHint =>
      'Подключите любой GTP-движок через WebSocket (Leela Zero, ELF OpenGo). Игнорируется, если задан URL KataGo.';

  @override
  String get localEngineTitle => 'Локальный движок ИИ';

  @override
  String get localEngineSubtitle => 'Авто-управляемый KataGo (без сервера)';

  @override
  String get engineStatusReady => 'KataGo готов';

  @override
  String get engineStatusStarting => 'Запуск…';

  @override
  String get engineStatusNotFound => 'Не установлен';

  @override
  String get engineStatusError => 'Ошибка';

  @override
  String get enginesFolderLabel => 'Папка движков';

  @override
  String get downloadKataGo => 'Скачать KataGo';

  @override
  String get engineRestartButton => 'Перезапустить движок';

  @override
  String get prev => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get done => 'Готово';

  @override
  String get playDemo => 'Запустить показ';

  @override
  String get replayDemo => 'Повторить показ';

  @override
  String get playingDemo => 'Показ идёт…';

  @override
  String get interactiveTapBoard => 'Интерактивно — нажмите на доску';

  @override
  String get sourcePrefix => 'Источник: ';

  @override
  String stepXofY(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get dailyPuzzles => 'Задачи дня';

  @override
  String get collections => 'Коллекции';

  @override
  String get categories => 'Категории';

  @override
  String get captures => 'Захваты';

  @override
  String get liberties => 'Дамэ';

  @override
  String get lifeDeath => 'Жизнь и смерть';

  @override
  String get koBasics => 'Основы ко';

  @override
  String get tesuji => 'Тэсудзи';

  @override
  String get swap => 'Заменить';

  @override
  String swapsLeft(int count) {
    return 'Осталось замен: $count';
  }

  @override
  String solvedCount(int solved, int total) {
    return '$solved/$total решено';
  }

  @override
  String get learningPath => 'Путь обучения';

  @override
  String get allTutorials => 'Все уроки';

  @override
  String get byLevel => 'По уровням';

  @override
  String get beginner => 'Начинающий';

  @override
  String get intermediate => 'Средний';

  @override
  String get advanced => 'Продвинутый';

  @override
  String get objective => 'Задача';

  @override
  String get difficulty => 'Сложность';

  @override
  String get yourTurn => 'Ваш ход';

  @override
  String get moves => 'Ходы';

  @override
  String get markAsLearned => 'Отметить как изученное ✓';

  @override
  String get blackToPlay => 'Ход чёрных';

  @override
  String get whiteToPlay => 'Ход белых';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get general => 'Общие';

  @override
  String get gameSettings => 'Настройки игры';

  @override
  String get notifications => 'Уведомления';

  @override
  String get soundEffects => 'Звуковые эффекты';

  @override
  String get soundEffectsSubtitle => 'Воспроизводить звуки во время игры';

  @override
  String get vibration => 'Вибрация';

  @override
  String get vibrationSubtitle => 'Вибрация при ходе';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get pushNotificationsSubtitle => 'Получать уведомления об играх';

  @override
  String get account => 'Аккаунт';

  @override
  String get editProfile => 'Изменить профиль';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get themeLabel => 'Тема';

  @override
  String get boardThemeLabel => 'Тема доски';

  @override
  String get backgroundThemeLabel => 'Тема фона';

  @override
  String get themeDarkBlue => 'Тёмно-синяя';

  @override
  String get themeOledBlack => 'OLED Чёрная';

  @override
  String get themeClassicWood => 'Классическое дерево';

  @override
  String get themeLightMode => 'Светлая';

  @override
  String get themeHalloween => 'Хэллоуин';

  @override
  String get themeWinter => 'Зима';

  @override
  String get themeForest => 'Лес';

  @override
  String get boardClassic => 'Классическая';

  @override
  String get boardWalnut => 'Орех';

  @override
  String get boardSlate => 'Шифер';

  @override
  String get boardNight => 'Ночная';

  @override
  String get bgStandard => 'Стандартный';

  @override
  String get bgMinimal => 'Минимальный';

  @override
  String get bgWarm => 'Тёплый';

  @override
  String get bgCool => 'Холодный';

  @override
  String get conceptLibertiesCaptures => 'Дамэ и захваты';

  @override
  String get conceptLibertyCounting => 'Подсчёт дамэ';

  @override
  String get conceptLifeDeathTwoEyes => 'Жизнь и смерть — два глаза';

  @override
  String get conceptKoRule => 'Правило ко';

  @override
  String get conceptLibertiesCapturesDesc =>
      'Камни захватываются, когда все их дамэ (соседние пустые точки) заняты камнями противника. Соединённые камни делят дамэ как одна группа.';

  @override
  String get conceptLibertyCountingDesc =>
      'Каждая пустая точка, соседняя с камнем или группой, — это дамэ. Соединённые камни образуют одну группу и делят все свои дамэ. Когда у группы остаётся только одно дамэ, она в «атари».';

  @override
  String get conceptLifeDeathDesc =>
      'Группа с двумя отдельными глазами не может быть захвачена, потому что противник не может одновременно заполнить оба глаза. Это основа понимания того, какие группы живы, а какие могут быть убиты.';

  @override
  String get conceptKoRuleDesc =>
      'Правило ко запрещает мгновенный повторный захват в повторяющейся позиции, чтобы избежать бесконечных циклов. После захвата в ко нужно сыграть в другом месте, прежде чем снова захватывать.';

  @override
  String get analysisPanelTitle => 'Анализ';

  @override
  String get analysisOn => 'Включить анализ';

  @override
  String get analysisOff => 'Выключить анализ';

  @override
  String get noServerForAnalysis =>
      'Настройте сервер KataGo в разделе «Настройки» для включения анализа.';

  @override
  String get moveQualityBest => 'Лучший ход';

  @override
  String get moveQualityGood => 'Хороший';

  @override
  String get moveQualityInaccuracy => 'Неточность';

  @override
  String get moveQualityMistake => 'Ошибка';

  @override
  String get moveQualityBlunder => 'Зевок';

  @override
  String get moveQualityExcellent => 'Отлично';

  @override
  String get cancel => 'Отмена';

  @override
  String get aiThinking => 'ИИ думает…';

  @override
  String get noLegalMoves => 'Нет доступных ходов. Нажмите «Пас».';

  @override
  String get useHintTitle => 'Использовать подсказку?';

  @override
  String useHintContent(int remaining) {
    return 'Показать лучший ход. Стоит 1 ★ (осталось $remaining).';
  }

  @override
  String get showHint => 'Показать подсказку';

  @override
  String get noHintAvailable => 'Подсказка недоступна — попробуйте пас.';

  @override
  String get resignTitle => 'Сдать эту партию?';

  @override
  String get resignConfirmBot => 'Ваш соперник победит по причине сдачи.';

  @override
  String resignConfirmLocal(String side) {
    return '$side сдаётся. Побеждает соперник.';
  }

  @override
  String get resign => 'Сдаться';

  @override
  String get gameReview => 'Разбор партии';

  @override
  String get rematch => 'Реванш';

  @override
  String get close => 'Закрыть';

  @override
  String get noHintsRemaining => 'Подсказки закончились';

  @override
  String get showBestMove => 'Лучший ход (-1 ★)';

  @override
  String get noHintsUsed => 'Подсказки не использовались';

  @override
  String hintsUsed(int count) {
    return 'Использовано подсказок: $count';
  }

  @override
  String get resumeLesson => 'Продолжить урок?';

  @override
  String resumeLessonContent(int step) {
    return 'Продолжить с шага $step?';
  }

  @override
  String get startOver => 'Начать заново';

  @override
  String get resume => 'Продолжить';

  @override
  String get notQuiteTapHint => 'Не совсем — попробуйте другую точку.';

  @override
  String get hintShownTapHint => 'Подсказка: следуйте маркеру.';

  @override
  String get lessonComplete => 'Урок завершён!';

  @override
  String dayStreak(int count) {
    return 'Серия: $count дн.';
  }

  @override
  String get master => 'Мастер';

  @override
  String get quickDrills => 'Быстрые упражнения';

  @override
  String get score => 'Счёт';

  @override
  String get black => 'Чёрные';

  @override
  String get white => 'Белые';

  @override
  String get you => 'Вы';

  @override
  String get computer => 'Компьютер';

  @override
  String get whiteWinsByResignation => 'Белые побеждают по причине сдачи';

  @override
  String get blackWinsByResignation => 'Чёрные побеждают по причине сдачи';

  @override
  String blackWinsByPoints(int points) {
    return 'Чёрные победили на $points очков!';
  }

  @override
  String whiteWinsByPoints(int points) {
    return 'Белые победили на $points очков!';
  }

  @override
  String get gameTied => 'Ничья!';

  @override
  String get rating => 'Рейтинг';

  @override
  String get today => 'Сегодня';

  @override
  String get streak => 'Серия';

  @override
  String get xp => 'Опыт';

  @override
  String get seeAll => 'Все';

  @override
  String get save => 'Сохранить';

  @override
  String get swapPuzzle => 'Заменить задачу';

  @override
  String get replay => 'Заново';

  @override
  String get continueLearning => 'Продолжить обучение';

  @override
  String get noLessonsYet => 'Уроков пока нет';

  @override
  String get finishPreviousLesson =>
      'Завершите предыдущий урок, чтобы разблокировать этот.';

  @override
  String get noGamesYet =>
      'Игр пока нет — завершите одну, чтобы увидеть её здесь.';

  @override
  String get premium => 'Премиум';

  @override
  String get unlockPremium => 'Получить Премиум';

  @override
  String get youArePremium => 'Вы — Премиум';

  @override
  String get unlockGokoPremium => 'Откройте GOKO Премиум';

  @override
  String get paywallTagline => 'Тренируйся глубже. Играй сильнее. Открой всё.';

  @override
  String get unlimitedPuzzles => 'Неограниченные задачи';

  @override
  String get freePuzzleLimit => 'Бесплатно: 3 задачи в день';

  @override
  String get allBotsAndLessons => 'Все боты и уроки';

  @override
  String get allBotsAndLessonsDesc => 'Боты-новички и первые 4 урока бесплатны';

  @override
  String get postGameAnalysis => 'Разбор партии';

  @override
  String get postGameAnalysisDesc =>
      'Перематывайте любую завершённую партию ход за ходом.';

  @override
  String get profileFlair => 'Оформление профиля';

  @override
  String get profileFlairDesc => 'Премиум-значки и рамки аватара';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get puzzleDailyQuotaReached =>
      'Вы решили 3 бесплатные задачи сегодня. Обновитесь для безлимита.';

  @override
  String get advancedBotsLocked =>
      'Средние, продвинутые и мастер-боты требуют Премиума.';

  @override
  String get premiumLessonsLocked => 'Уроки с 5-го требуют Премиума.';

  @override
  String seeAllLessons(int count) {
    return 'Все $count урока';
  }

  @override
  String get dayStreakLabel => 'Серия дней';

  @override
  String get snapback => 'Сикко';

  @override
  String get ladder => 'Лестница';

  @override
  String get connect => 'Соединение';

  @override
  String get lockedPremium => 'Премиум';

  @override
  String get stoneColors => 'Цвета камней';

  @override
  String get stoneColorClassic => 'Классические';

  @override
  String get stoneColorJade => 'Нефрит';

  @override
  String get stoneColorAmber => 'Янтарь';

  @override
  String get stoneColorCobalt => 'Кобальт';

  @override
  String get stoneColorCrimson => 'Багровый';

  @override
  String get stoneColorMono => 'Моно';

  @override
  String get freeTrialBadge => '7 дней бесплатно';

  @override
  String get freeTrialSubtitle => 'Отмена в любое время';

  @override
  String get ogsLogin => 'Вход OGS';

  @override
  String get onlineGoServer => 'Online Go Server';

  @override
  String get signInWithOgsAccount => 'Войдите в свой аккаунт OGS';

  @override
  String get signIn => 'Войти';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get enterUsernamePassword =>
      'Пожалуйста, введите имя пользователя и пароль';

  @override
  String get loginFailed => 'Ошибка входа. Проверьте данные.';

  @override
  String get errorPrefix => 'Ошибка: ';

  @override
  String get noAccountSignUp => 'Нет аккаунта? Зарегистрируйтесь на OGS';

  @override
  String get orContinueWith => 'или войти через';

  @override
  String get continueWithOgs => 'Войти через OGS (Google и др.)';

  @override
  String get onlinePlay => 'Игра онлайн';

  @override
  String get onlineStatusConnected => 'Онлайн';

  @override
  String get onlineStatusOffline => 'Не в сети';

  @override
  String get ogsPlayer => 'Игрок OGS';

  @override
  String get notLoggedIn => 'Не выполнен вход';

  @override
  String get pleaseLogInToPlayOnline =>
      'Войдите через OGS, чтобы играть онлайн';

  @override
  String get goBack => 'Назад';

  @override
  String get appTagline => 'Освойте древнюю игру Го';

  @override
  String get featurePlayBots => 'Игра против KataGo и онлайн-ботов';

  @override
  String get featurePuzzlesLessons => 'Задачи, уроки и ежедневные тренировки';

  @override
  String get featureLiveGames => 'Живые партии на Online Go Server';

  @override
  String get signInWithOgs => 'Войти через OGS';

  @override
  String get createOgsAccount => 'Создать бесплатный аккаунт OGS';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get attributionAvatars => 'Аватары ботов: OpenMoji (CC BY-SA 4.0)';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get unranked => 'Без ранга';

  @override
  String get friendComputerOnline => 'Друг, компьютер или онлайн';

  @override
  String get dailyPuzzle => 'Задача дня';

  @override
  String get playBot => 'Игра с ботом';

  @override
  String get vsComputerSubtitle => 'Выберите бота — без сети';

  @override
  String get vsFriendSubtitle => 'На одном устройстве';

  @override
  String get vsOnlineSubtitle => 'Живые партии на OGS';

  @override
  String get playFirstGameHint =>
      'Сыграйте первую партию — она появится здесь.';

  @override
  String get puzzleStreak => 'Цепочка задач';

  @override
  String get puzzleStreakSubtitle => 'Решайте до первой ошибки';

  @override
  String get currentStreak => 'Цепочка';

  @override
  String get bestLabel => 'Рекорд';

  @override
  String get streakEndedTitle => 'Цепочка прервана';

  @override
  String get newRecord => 'Новый рекорд!';

  @override
  String get puzzleModes => 'Режимы задач';

  @override
  String get leagueLabel => 'Лига';

  @override
  String get leagueRookie => 'Новичок';

  @override
  String get leagueBronze => 'Бронза';

  @override
  String get leagueSilver => 'Серебро';

  @override
  String get leagueGold => 'Золото';

  @override
  String get leaguePlatinum => 'Платина';

  @override
  String get leagueDiamond => 'Бриллиант';

  @override
  String get puzzleMap => 'Карта';

  @override
  String get puzzleList => 'Список';

  @override
  String get world1Beginner => 'Сад новичка';

  @override
  String get world2Intermediate => 'Озеро среднего уровня';

  @override
  String get world3Advanced => 'Вулкан мастера';

  @override
  String get coachStreakIntro1 => 'Готовы начать цепочку?';

  @override
  String get coachStreakIntro2 => 'Сколько решите подряд сегодня?';

  @override
  String get coachStreakIntro3 => 'Побейте свой рекорд!';

  @override
  String get coachStreakIntro4 => 'Одна ошибка — и конец. Без давления!';

  @override
  String get coachStreakIntro5 => 'Ежедневная практика — острый ум.';

  @override
  String get coachSolve1 => 'Отлично!';

  @override
  String get coachSolve2 => 'Блестяще!';

  @override
  String get coachSolve3 => 'Цепочка растёт!';

  @override
  String get coachSolve4 => 'Это было сложно!';

  @override
  String get coachSolve5 => 'Точный расчёт.';

  @override
  String get coachSolve6 => 'Так держать!';

  @override
  String get openLesson => 'Открыть';

  @override
  String get puzzleGardenTitle => 'Сад новичка';

  @override
  String get coachLeagueRookieUnlocked =>
      'Добро пожаловать, Новичок! Поднимем рейтинг.';

  @override
  String get coachLeagueBronzeUnlocked => 'Бронзовая лига! Ты в игре.';

  @override
  String get coachLeagueSilverUnlocked => 'Серебряная лига! Уже видишь доску.';

  @override
  String get coachLeagueGoldUnlocked => 'Золотая лига! Настоящий боец.';

  @override
  String get coachLeaguePlatinumUnlocked =>
      'Платиновая лига! Немногие доходят сюда.';

  @override
  String get coachLeagueDiamondUnlocked => 'Бриллиантовая лига! Мастер.';

  @override
  String get coachKeepGoing => 'Нажми следующий камень — продолжай!';

  @override
  String get coachTryAgain => 'Не страшно — попробуй другую точку.';

  @override
  String xpToNextLeague(int count, String league) {
    return '$count XP до $league';
  }

  @override
  String gateLockedUnlockAt(int xp) {
    return 'Открыто при $xp XP';
  }

  @override
  String get solvePuzzles => 'Решить задачи';

  @override
  String levelN(int n) {
    return 'Уровень $n';
  }

  @override
  String get puzzleBestMove => 'Найдите лучший ход';

  @override
  String xpToUnlock(int xp) {
    return '+$xp XP';
  }

  @override
  String get worldStoneForest => 'Каменный лес';

  @override
  String get worldCrystalCave => 'Хрустальная пещера';

  @override
  String get worldCopperPeaks => 'Медные вершины';

  @override
  String get worldDiamondTundra => 'Алмазная тундра';

  @override
  String get worldJadeHighlands => 'Нефритовые высоты';

  @override
  String get quit => 'Выйти';

  @override
  String get drillCompleteTitle => 'Тренировка завершена';

  @override
  String get backToLearn => 'Назад к обучению';

  @override
  String get quitDrillTitle => 'Выйти из тренировки?';

  @override
  String get quitDrillBody => 'Прогресс не будет сохранён, если выйти сейчас.';

  @override
  String get resignGameTitle => 'Сдаться?';

  @override
  String get resignGameBody => 'Вы уверены, что хотите сдаться?';

  @override
  String get undoRequestTitle => 'Запрос отмены хода';

  @override
  String get decline => 'Отклонить';

  @override
  String get accept => 'Принять';

  @override
  String get gameInfoTitle => 'Информация об игре';

  @override
  String get leaveGame => 'Покинуть игру';

  @override
  String get connectionTestTitle => 'Тест подключения';

  @override
  String get runConnectionTest => 'Запустить тест';

  @override
  String get findOpponentSubtitle => 'Быстрый поиск соперника для матча';

  @override
  String get startMatchHint => 'Начните быстрый матч!';

  @override
  String get shuffle => 'Перемешать';

  @override
  String get tutorialsTitle => 'Уроки';

  @override
  String get learnGardenTitle => 'Обучение';

  @override
  String get categoryFundamentals => 'Основы';

  @override
  String get categoryRules => 'Правила';

  @override
  String get categoryLifeDeath => 'Жизнь и смерть';

  @override
  String get categoryStrategy => 'Стратегия';

  @override
  String lessonsInCategoryCount(int count) {
    return '$count уроков';
  }

  @override
  String get continueLessonCta => 'Продолжить урок';

  @override
  String get startLessonCta => 'Начать первый урок';

  @override
  String get lessonLocked => 'Премиум-урок';

  @override
  String get coachLearnIntro1 => 'Куда дальше?';

  @override
  String get coachLearnIntro2 => 'Один урок в день держит ум в форме.';

  @override
  String get coachLearnIntro3 => 'Попробуй короткий урок — меньше 5 минут.';

  @override
  String get coachLearnIntro4 =>
      'Выбери категорию — каждый путь куда-то ведёт.';

  @override
  String get coachLearnIntro5 => 'Нажми на камень, чтобы начать учиться!';

  @override
  String get coachCategoryDone => 'Целая категория пройдена — невероятно!';

  @override
  String get botDescPanda => 'Милая и забавная. Любит играть случайные ходы.';

  @override
  String get botDescPup =>
      'Игривый щенок гоняется за каждым камнем. Легко перехитрить.';

  @override
  String get botDescBunny =>
      'Скачет по доске с любопытными, непредсказуемыми ходами.';

  @override
  String get botDescKoi =>
      'Мягкий и стабильный. Любит игру у края и небольшие огороды.';

  @override
  String get botDescTanuki => 'Хитрый дух. Знает основы захвата и форм.';

  @override
  String get botDescPebble =>
      'Тихий и спокойный. Медленно строит крепкие рамки.';

  @override
  String get botDescHeron => 'Терпеливый. Разбирает слабые формы у края.';

  @override
  String get botDescOwl =>
      'Мудрый и терпеливый. Строит крепкие рамки территории.';

  @override
  String get botDescCrane =>
      'Грациозный и сбалансированный. Играет лёгкие и гибкие формы.';

  @override
  String get botDescMantis =>
      'Острый и быстрый. Рассчитывает тактические последовательности.';

  @override
  String get botDescBadger => 'Не отпустит ни один камень без боя.';

  @override
  String get botDescKitsune =>
      'Хитрый лис. Наказывает за переигрывание и поощряет хорошую форму.';

  @override
  String get botDescPhoenix => 'Восстаёт из-под давления резкими контратаками.';

  @override
  String get botDescHawk => 'Давящий игрок. Постоянно ищет ваши слабые группы.';

  @override
  String get botDescTiger => 'Свирепый боец. Любит атаковать слабые группы.';

  @override
  String get botDescOtter => 'Гибкий и игривый. Переходит от атаки к защите.';

  @override
  String get botDescDragon =>
      'Сильное чтение и чистый эндшпиль. Требует точности.';

  @override
  String get botDescSamurai =>
      'Честь и дисциплина. Сильная борьба и чистая форма.';

  @override
  String get botDescTengu => 'Горный дух. Сильная борьба и эффективная форма.';

  @override
  String get botDescMonk =>
      'Спокойное, глубокое позиционное понимание. Видение всей доски.';

  @override
  String get botDescOracle =>
      'Видит варианты на дюжину ходов вперёд. Трудно обмануть.';

  @override
  String get botDescSensei =>
      'Мудрый учитель. Играет самые поучительные профессиональные ходы.';

  @override
  String get botDescKataGo =>
      'Планирует десятки ходов вперёд с нейросетевым анализом. Сверхчеловеческое видение.';

  @override
  String get tauntDefaultGreet => 'Поиграем!';

  @override
  String get tauntDefaultWin => 'Хорошая игра! Заслуженная победа.';

  @override
  String get tauntDefaultLose => 'Красиво сыграно — в следующий раз повезёт!';

  @override
  String get tauntDefaultResign => 'Спасибо за игру!';

  @override
  String get tauntPandaGreet => 'Привет, друг! Давай поиграем!';

  @override
  String get tauntPandaWin => 'Ура! Я выиграл!';

  @override
  String get tauntPandaLose => 'Ты очень хорош!';

  @override
  String get undoMove => 'Отменить ход';

  @override
  String get passTurn => 'Пас';

  @override
  String get redoMove => 'Повторить ход';

  @override
  String get newGame => 'Новая игра';

  @override
  String get practiceBadge => 'ТРЕНИРОВКА';

  @override
  String get notYourTurn => 'Не ваш ход!';

  @override
  String get menuTooltip => 'Меню';

  @override
  String get profileTooltip => 'Профиль';

  @override
  String get wins => 'Победы';

  @override
  String get losses => 'Поражения';

  @override
  String get draws => 'Ничьи';

  @override
  String get winLossLabel => 'Победы / Поражения';

  @override
  String get playGamesHint =>
      'Сыграйте партии, чтобы увидеть статистику здесь.';

  @override
  String get filterAll => 'Все';

  @override
  String get noPuzzlesForFilter => 'Нет задач для этого фильтра.';

  @override
  String tutorialsLoadError(String error) {
    return 'Не удалось загрузить уроки: $error';
  }

  @override
  String get noTutorialsYet => 'Уроков пока нет.';

  @override
  String get practiceModeTitle => 'Тренировочный режим';

  @override
  String get practiceModeSubtitle =>
      'Лучший ход показан после каждого хода · результат 1 ★';

  @override
  String get chooseBoardSize => 'Выберите размер доски';

  @override
  String get undoRequestSent => 'Запрос отмены отправлен';

  @override
  String get undoRequestDeclined => 'Запрос отмены отклонён';

  @override
  String get undoRequestAccepted => 'Запрос отмены принят';

  @override
  String opponentRequestedUndo(int moveNumber) {
    return 'Соперник запросил отмену хода #$moveNumber.';
  }

  @override
  String suggestedRemovedStones(int count) {
    return 'Предложено убрать камней: $count';
  }

  @override
  String gameIdLabel(String id) {
    return 'ID игры: $id';
  }

  @override
  String moveLabel(int n) {
    return 'Ход: $n';
  }

  @override
  String phaseLabel(String phase) {
    return 'Фаза: $phase';
  }

  @override
  String boardLabel(String size) {
    return 'Доска: $size';
  }

  @override
  String hintLookAt(int row, String col) {
    return 'Посмотрите на строку $row, столбец $col — здесь сильный ход.';
  }

  @override
  String get hintFallbackGeneric =>
      'Найдите ход, который давит на камни противника — ищите атари, слабые группы или формы глаз.';

  @override
  String get paywallHeroTitle => 'Откройте GOKO Premium';

  @override
  String get paywallHeroTagline => 'Освойте древнюю игру';

  @override
  String get paywallFeatureUnlimitedPuzzles => 'Безлимит ежедневных задач';

  @override
  String get paywallFeatureAllBots => 'Все боты — от Pup до KataGo';

  @override
  String get paywallFeatureLessons =>
      'Полная библиотека уроков + анализ партий';

  @override
  String get paywallFeatureSync =>
      'Облачная синхронизация, значки и оформление профиля';

  @override
  String get pricingTierMonthly => 'Месяц';

  @override
  String get pricingTierAnnual => 'Год';

  @override
  String get pricingTierLifetime => 'Навсегда';

  @override
  String get pricingPopular => 'ПОПУЛЯРНОЕ';

  @override
  String get pricingBestValue => 'Лучшая цена';

  @override
  String pricingSave(int percent) {
    return 'Экономия $percent%';
  }

  @override
  String pricingPerMonth(String price) {
    return '$price/мес';
  }

  @override
  String pricingPerYear(String price) {
    return '$price/год';
  }

  @override
  String pricingOnce(String price) {
    return '$price разово';
  }

  @override
  String get startFreeTrial => 'Начать 7-дневный пробный период';

  @override
  String get cancelAnytime => 'Отмена в любое время';

  @override
  String renewsAtPrice(String price) {
    return 'Возобновляется по $price';
  }

  @override
  String trustedByPlayers(String count) {
    return 'Нам доверяют $count+ игроков';
  }

  @override
  String get freeTrialDuration => '7 дней бесплатно';

  @override
  String get paywallContinueFree => 'Может быть позже';

  @override
  String get scoreStonesLabel => 'Камни';

  @override
  String get scoreTerritoryLabel => 'Территория';

  @override
  String get scoreCapturedLabel => 'Пленные';
}
