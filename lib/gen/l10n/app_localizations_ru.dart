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
  String get giveUp => 'Сдаться';

  @override
  String get stepBack => 'Шаг назад';

  @override
  String get continue_ => 'Продолжить';

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
}
