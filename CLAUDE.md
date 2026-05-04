# CLAUDE.md — GOKO (Go Game App)

Persistent context for Claude. Read this before making any changes to the project.

---

## Project Overview

**GOKO** is an offline-first Go (Baduk/Weiqi) game app built with Flutter/Dart.

- **Platforms:** Android, iOS, Web (Vercel), Windows, Linux, macOS
- **Key features:** Local 2-player, AI opponent (MCTS), puzzle learning (12 puzzles / 4 categories), online multiplayer via OGS WebSocket
- **Go rules implemented:** Stone capture, Ko rule, territory scoring, undo/redo
- **AI difficulty levels:** Easy (200 sims), Medium (800 sims), Hard (2500 sims)
- **State management:** `Provider` for `OgsService` + `StatefulWidget` local state — no Riverpod or Bloc

---

## Commands

```bash
# Development
flutter pub get           # Install dependencies
flutter run               # Run on connected device (debug)
flutter run -d chrome     # Run on web
flutter run -d windows    # Run on Windows desktop

# Code quality
flutter analyze           # Run linter (must pass before committing)
dart format lib/          # Auto-format all Dart source files

# Testing
flutter test                                  # Run all tests
flutter test test/optimized_board_test.dart   # Single test file
flutter test --verbose                        # With full output
flutter test --coverage                       # With coverage report

# Build
flutter build apk         # Android APK
flutter build ios         # iOS app
flutter build web         # Web (static)
flutter build windows     # Windows executable

# Web deployment (Vercel)
bash scripts/vercel_build.sh
```

---

## Architecture

### `lib/` Structure

```
lib/
├── main.dart                        # Entry point — GokoApp (StatefulWidget)
├── models/                          # Business logic & data models
│   ├── optimized_board.dart         # ACTIVE board engine (2D array, captures, Ko, territories)
│   ├── optimized_game.dart          # ACTIVE game controller (turns, undo/redo, scoring)
│   ├── app_settings.dart            # Global static settings (coordinates, theme, verbose logs)
│   ├── drill.dart                   # Drill/practice mode model
│   ├── puzzle.dart                  # Puzzle definitions (12 puzzles, 4 categories)
│   └── user.dart                    # User profile model
├── screens/                         # Full-screen widgets (each maps to a route)
│   ├── home_screen.dart             # Main hub with navigation
│   ├── game_board_screen.dart       # Active gameplay
│   ├── learn_screen.dart            # Puzzle/learning hub
│   ├── puzzle_screen.dart           # Individual puzzle view
│   ├── drill_screen.dart            # Drill practice mode
│   ├── history_screen.dart          # Game history log
│   ├── profile_screen.dart          # User profile
│   ├── settings_screen.dart         # App settings (theme, coordinates)
│   ├── topic_detail_screen.dart     # Learning topic detail
│   └── online/                      # OGS multiplayer screens
│       ├── online_lobby_screen.dart
│       └── online_game_screen.dart
├── widgets/                         # Reusable UI components
│   ├── fast_game_board.dart         # ACTIVE board renderer (widget-grid with RepaintBoundary)
│   ├── bottom_nav_bar.dart          # App navigation bar
│   ├── game_title.dart              # Game header widget
│   └── login_dialog.dart            # OGS login dialog
├── services/                        # External APIs & engines
│   ├── ogs_service.dart             # OGS auth, REST API, game fetching (ChangeNotifier)
│   ├── board/
│   │   └── board_engine.dart        # Unified board engine layer
│   ├── ai/
│   │   ├── go_ai_service.dart       # Difficulty wrapper around MCTS
│   │   ├── mcts.dart                # Monte Carlo Tree Search algorithm
│   │   └── mcts_node.dart           # MCTS tree node
│   └── online/
│       ├── websocket_service.dart   # Socket.IO connection management
│       ├── game_connection.dart     # Per-game event streams
│       └── active_games_repository.dart  # Game state tracking
├── theme/
│   └── go_theme.dart                # Material Design 3 light + dark themes
└── utils/
    ├── turn.dart                    # nextPlayer() helper
    ├── error_messages.dart          # OGS error code mapping
    ├── sgf_coords.dart              # SGF coordinate string parsing
    ├── stone_shader_warmup.dart     # GPU shader pre-compilation on startup
    └── performance_config.dart      # Performance tuning constants
```

### App Entry Flow

```
main() → GokoApp (theme state)
  └── ChangeNotifierProvider(OgsService)
      └── MaterialApp
          ├── /home  → HomeScreen
          ├── /learn → LearnScreen
          ├── /history → HistoryScreen
          ├── /profile → ProfileScreen
          ├── /settings → SettingsScreen
          └── /topic → TopicDetailScreen
```

### Navigation Flow

1. App starts → `HomeScreen`
2. "Play" button → game mode selector (vs Friend / vs AI / Online)
3. Mode selected → board size selector → `GameBoardScreen`
4. "Learn" tab → `LearnScreen` (puzzle list) → `PuzzleScreen`
5. Settings icon → `SettingsScreen`

---

## Code Style Rules

### Naming
- **Files:** `snake_case` (`game_board_screen.dart`)
- **Classes:** `PascalCase` (`GameBoardScreen`, `OgsService`)
- **Methods & variables:** `camelCase` (`playTurn()`, `currentPlayer`)
- **Private members:** Leading `_` (`_history`, `_saveState()`)
- **Constants:** `camelCase` or `SCREAMING_SNAKE_CASE` depending on context

### Comments & Documentation
```dart
/// Triple-slash doc comments on all public classes, methods, and properties.
/// These appear in IDE hover tooltips.
/// Include @param / @return tags and example usage where helpful.

// Single-line comments for inline explanations and non-obvious logic.

// TODO: Mark future work items with TODO comments (include issue number if applicable).
```

- **Always add** `///` doc comments to all public APIs (classes, methods, fields)
- **Always add** `//` inline comments for non-obvious logic
- **Document complex algorithms** with step-by-step explanations (especially board logic, MCTS, WebSocket)
- **Document assumptions and limitations** in doc comments
- **Keep comments up-to-date** — update them when the code changes

### Widget Patterns
- Use `const` constructors everywhere possible — prevents unnecessary rebuilds
- Use named parameters for all widget constructors
- Extract complex build sections into `_buildXxx(BuildContext context)` private methods
- Wrap board-heavy widgets in `RepaintBoundary` to isolate repaints
- Use `ValueKey` on list items for efficient widget diffing
- Keep `build()` methods under ~50 lines; split into helpers otherwise
- Check `mounted` before calling `setState` in async callbacks
- Dispose all `AnimationController`s, `TextEditingController`s, and `StreamSubscription`s in `dispose()`

### Function Design
- Max ~25 lines per function; single responsibility principle
- Use early returns to reduce nesting (maximum 3 levels)
- Async operations that could block UI → run in `compute()` isolate (see `GoAIService`)
- Max file length: ~400 lines — split into focused files if larger

### Error Handling
- `try/catch` for all network calls (`OgsService`, `WebSocketService`)
- Always provide sensible defaults on error; do not swallow exceptions silently
- Show user-friendly error messages — never expose internal error details to users
- Validate all user input at system boundaries

### Performance Rules
- Use `const` widgets aggressively to prevent rebuilds
- Use `ListView.builder` for long/dynamic lists — never `Column` with many children
- Cache expensive computations; don't recompute in `build()`
- Minimize `setState` scope — call it on the smallest widget possible
- Use `ValueNotifier` for single-value reactive state (avoids full rebuilds)
- Avoid unnecessary object allocation in hot paths (stone rendering, move validation)
- Board rendering: `< 16ms`; move validation: `< 5ms`; territory calculation: `< 50ms`

### Security Rules
- Never hardcode secrets, API keys, or credentials in source code
- Use HTTPS for all network communication
- Validate and sanitize all data received from external sources (OGS API, WebSocket)
- Use least-privilege principle — request only permissions the feature actually needs
- Keep dependencies updated to patch known vulnerabilities

---

## Key Patterns

### AI in Isolate
```dart
// AI runs in a separate isolate to keep UI at 60fps
final move = await compute(_runMcts, params);
```
Never call `MCTS` directly on the main thread.

### Provider + ChangeNotifier
```dart
// OgsService is the only global ChangeNotifier
final ogsService = context.watch<OgsService>();
```
All other state lives in `StatefulWidget` local state.

### Board Rendering
- `FastGameBoard` renders stones as a grid of `_StoneWidget` widgets
- Static board layer (lines/dots) is cached as `ui.Image` — do not redraw on each frame
- `_paintCache` reuses `Paint` objects across frames
- GPU shaders are pre-warmed in `main()` via `StoneShaderWarmUp`

### WebSocket Reconnection
```dart
// Exponential backoff: 750ms → 1.5s → 3s → ... → 10s cap
```
Implemented in `WebSocketService`. Do not add separate reconnect logic.

---

## Testing

### Test Files
| File | What it tests |
|------|---------------|
| `test/turn_test.dart` | `nextPlayer()` utility |
| `test/optimized_board_test.dart` | Stone placement, captures, Ko rule |
| `test/sgf_coords_test.dart` | SGF coordinate parsing |
| `test/error_messages_test.dart` | OGS error code → message mapping |

### Rules
- Run `flutter test` before every commit — all 4 tests must pass
- Run `flutter analyze` before every commit — zero errors allowed
- Add tests for any new board logic or utility functions
- Test file convention: `test/<feature>_test.dart`
- Write unit tests for all new models
- Write widget tests for new UI components
- Test edge cases: captures, Ko rule, empty board, full board, game-end conditions

### Pre-Commit Checklist
```bash
flutter test              # All tests must pass
flutter analyze           # Zero errors (info warnings acceptable)
dart format lib/          # Code must be formatted
flutter run --profile     # Spot-check for performance regressions
```

- Verify responsive layout on mobile (portrait + landscape), tablet, desktop, and web
- Check dark and light themes both render correctly
- Verify proper disposal — no memory leaks in controllers/streams

---

## Dependencies (pubspec.yaml)

| Package | Purpose |
|---------|---------|
| `provider ^6.1.2` | State management (`OgsService`) |
| `socket_io_client ^2.0.3` | WebSocket for OGS multiplayer |
| `http ^1.2.1` | REST API calls to OGS |
| `app_links ^6.3.2` | Deep linking for OAuth callback |
| `url_launcher ^6.3.0` | Open external URLs |
| `uuid ^4.5.1` | Unique game/move IDs |
| `flutter_lints ^5.0.0` | (dev) Lint rules |

---

## Scope Boundaries

- **Board logic** lives in `optimized_board.dart` — do not duplicate it elsewhere
- **Game turn logic** lives in `optimized_game.dart` — `playTurn()` returns `bool` (success/fail)
- **AI moves** always go through `GoAIService`, never call `MCTS` directly from screens
- **Theme** is defined in `go_theme.dart` — do not hardcode colors in screens/widgets
- **Online multiplayer** code lives entirely under `services/online/` and `screens/online/`
- **Settings** are read from `AppSettings` (static) — do not store theme/coord state locally in widgets

---

## Platform Notes

- **Web:** Deployed to Vercel via `scripts/vercel_build.sh`; config in `vercel.json`
- **Android:** Gradle in `android/`; min SDK configured in `android/app/build.gradle.kts`
- **iOS:** Runner in `ios/Runner/`
- **OAuth callback:** Handled by `docs/oauth2callback.html` (GitHub Pages) and `app_links`

---

## Architecture Principles

- Follow SOLID principles — each class has one clear responsibility
- Separate business logic from UI — screens never contain raw game logic
- Keep widgets composable and reusable — extract into `lib/widgets/` when used in 2+ places
- Use Repository pattern for data layer (see `active_games_repository.dart`)
- Do not add features, refactor, or "improve" code beyond what is explicitly asked

---

## Game Logic Validation Checklist

When modifying board or game logic, verify:
- Move legality (occupied intersections, out-of-bounds)
- Ko rule — illegal repetition of board state
- Capture detection — all groups with zero liberties removed
- Territory calculation — dead stones excluded from scoring
- Game-ending conditions — double pass, resignation
- Undo/redo stack integrity after captures
- Score computation with both Japanese and Chinese rules
