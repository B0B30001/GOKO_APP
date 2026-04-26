import '../../models/optimized_board.dart';

/// Game modes supported by the unified board engine
enum GameMode { local, online, computer }

/// Factory/service providing optimized Board instances per mode.
/// In the future this can apply mode-specific rule toggles (e.g., superko online).
class BoardEngine {
  BoardEngine._();

  static Board create(int size, {GameMode mode = GameMode.local}) {
    // Mode-specific customization point
    switch (mode) {
      case GameMode.local:
      case GameMode.computer:
      case GameMode.online:
        return Board(size);
    }
  }
}
