# GOKO - Go Game (Flutter)

English | Русский

---

## English

### Overview
GOKO is a Flutter app for playing and learning Go (Baduk/Weiqi).
It supports offline local play, AI play, puzzle-based learning, and online multiplayer integration with OGS (online-go.com).

### Core Gameplay Features
- Board sizes: 9x9, 13x13, 19x19
- Local mode (two players on one device)
- Computer mode (human vs AI)
- Online mode via OGS
- Main Go mechanics: legal move validation, captures, ko handling, pass, game phases
- Undo/redo and game reset in local/computer mode

### AI and Algorithm
- AI engine uses Monte Carlo Tree Search (MCTS)
- Difficulty levels are simulation-budget based:
	- Easy: 200 simulations
	- Medium: 800 simulations
	- Hard: 2500 simulations
- AI computation runs in a separate isolate using `compute()` to keep UI responsive
- Rollouts use fast random playout logic and heuristic checks for speed

### Board Engine and Rules Layer
- Unified board engine supports multiple modes:
	- `local`
	- `computer`
	- `online`
- Board/rules logic is centralized and reused between game modes
- Online mode can evolve with mode-specific rule toggles in the same engine path

### Online Multiplayer (OGS) - How It Works
- Authentication:
	- Username/password login to OGS API (`/api/v0/login`)
	- Stores `chat_auth` and JWT for socket authentication
- Real-time transport:
	- Socket.IO WebSocket connection to `https://online-go.com`
	- Auto reconnect with backoff
- Match flow:
	- Start automatch with board size and speed
	- Listen for `automatch/start`
	- Open game connection by game id
- In-game real-time events:
	- Move updates
	- Clock/time control updates
	- Phase changes (play, stone removal, finished)
	- Chat
	- Undo requests
	- Stone removal/scoring events

### Learning Mode
- Interactive puzzle system (captures, liberties, life and death, ko)
- Hints and educational explanations
- Mobile-friendly puzzle UI and responsive layout

### Performance and UX
- Optimized board rendering and repaint isolation
- Paint object reuse and caching strategy
- Async/non-blocking updates to reduce UI jank
- Responsive layouts for phone/tablet/desktop
- Dark/light theme support and coordinate display toggle

### Tech Stack
- Flutter + Dart
- State management: Provider
- Network: `http`, `socket_io_client`
- Utility integrations: `url_launcher`, `uuid`

### Run Locally
```bash
git clone https://github.com/B0B30001/zaibal_app.git
cd zaibal_app
flutter pub get
flutter run
```

Useful commands:
```bash
flutter devices
flutter run -d chrome
flutter test
```

### High-Level Structure
```text
lib/
	models/                # Board/game models and optimized state
	services/
		ai/                  # MCTS AI service and tree logic
		board/               # Unified board engine
		online/              # WebSocket + online repositories/connections
		ogs_service.dart     # OGS auth/API and multiplayer entry points
	screens/
		online/              # Lobby, online game screen, connection testing
	widgets/               # Board and UI widgets
```

### Current Status
- Offline play: working
- AI mode: working (MCTS)
- Puzzle learning mode: working
- OGS online flow (login, lobby, automatch, live game events): implemented

---

## Русский

### Обзор
GOKO - это Flutter-приложение для игры и обучения Го (Baduk/Weiqi).
Поддерживает офлайн-игру на одном устройстве, игру против AI, обучение через задачи и онлайн-мультиплеер через OGS (online-go.com).

### Основные функции игры
- Размеры доски: 9x9, 13x13, 19x19
- Локальный режим (2 игрока на одном устройстве)
- Режим против компьютера (человек против AI)
- Онлайн-режим через OGS
- Базовая игровая логика Го: проверка хода, взятия, ko, пас, фазы партии
- Undo/Redo и новая партия в локальном/AI режиме

### AI и алгоритм
- AI построен на Monte Carlo Tree Search (MCTS)
- Сложность задается числом симуляций:
	- Easy: 200
	- Medium: 800
	- Hard: 2500
- Вычисление хода AI запускается в отдельном isolate через `compute()`, чтобы UI не зависал
- Для скорости используются быстрые случайные rollout-симуляции и эвристики

### Движок доски и слой правил
- Единый движок доски поддерживает режимы:
	- `local`
	- `computer`
	- `online`
- Логика доски и правил переиспользуется между режимами
- Онлайн-специфичные правила можно развивать в том же общем движке

### Онлайн-мультиплеер (OGS) - как работает
- Аутентификация:
	- Логин по username/password в OGS API (`/api/v0/login`)
	- Сохранение `chat_auth` и JWT для сокет-аутентификации
- Реальное время:
	- Socket.IO/WebSocket подключение к `https://online-go.com`
	- Авто-переподключение с backoff
- Подбор игры:
	- Запуск automatch с размером доски и скоростью
	- Ожидание события `automatch/start`
	- Подключение к партии по game id
- События в онлайн-партии:
	- Ходы
	- Обновления часов/контроля времени
	- Смена фаз партии (play, stone removal, finished)
	- Чат
	- Запросы undo
	- События снятия мертвых камней/подсчета

### Обучающий режим
- Интерактивные задачи (взятия, свободы, жизнь и смерть, ko)
- Подсказки и обучающие объяснения
- Адаптивный интерфейс задач для мобильных

### Производительность и UX
- Оптимизированный рендеринг доски и изоляция перерисовок
- Кеширование и переиспользование paint-объектов
- Неблокирующие обновления UI
- Адаптивные layout для телефона/планшета/десктопа
- Поддержка светлой/темной темы и переключатель координат

### Технологии
- Flutter + Dart
- Управление состоянием: Provider
- Сеть: `http`, `socket_io_client`
- Дополнительно: `url_launcher`, `uuid`

### Запуск локально
```bash
git clone https://github.com/B0B30001/zaibal_app.git
cd zaibal_app
flutter pub get
flutter run
```

Полезные команды:
```bash
flutter devices
flutter run -d chrome
flutter test
```

### Структура проекта (кратко)
```text
lib/
	models/                # Модели доски/игры и оптимизированное состояние
	services/
		ai/                  # MCTS AI и логика дерева
		board/               # Единый движок доски
		online/              # WebSocket, репозитории и game connection
		ogs_service.dart     # OGS авторизация/API и вход в онлайн-режим
	screens/
		online/              # Лобби, онлайн-игра, тест соединения
	widgets/               # Виджеты доски и UI
```

### Текущий статус
- Офлайн-режим: работает
- Режим против AI: работает (MCTS)
- Режим обучения (задачи): работает
- OGS онлайн-поток (логин, лобби, automatch, события партии): реализован

---

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License. See `LICENSE` for details.
