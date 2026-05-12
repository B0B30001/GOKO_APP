import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;
import 'mcts_engine.dart';
import '../../models/app_settings.dart';

/// KataGo engine backed by a remote KataGo analysis WebSocket server.
///
/// Connects to the URL configured in [AppSettings.kataGoServerUrl] and sends
/// a KataGo analysis query. If the server is unreachable or times out within
/// 10 s, it falls back to [MctsEngine] at hard difficulty so the game is
/// never interrupted.
///
/// **Server URL format:** `ws://host:port` or `wss://host:port`
/// The server must speak the KataGo analysis engine WebSocket protocol
/// (the same as `katago analysis` mode with `--config`).
class KataGoEngine implements AIEngine {
  const KataGoEngine();

  // GTP column letters — 'I' is skipped per Go convention.
  static const _gtpCols = 'ABCDEFGHJKLMNOPQRST';

  @override
  String get name => 'katago';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) async {
    final serverUrl = AppSettings.kataGoServerUrl.trim();
    if (serverUrl.isEmpty) {
      // No server configured — silently fall back to strong MCTS.
      return const MctsEngine().getBestMove(
        board: board,
        boardSize: boardSize,
        player: player,
        difficulty: AIDifficulty.hard,
      );
    }

    try {
      final uri = Uri.parse(serverUrl);
      final channel = WebSocketChannel.connect(uri);

      // Build the initialStones list from the current board position.
      final initialStones = <List<String>>[];
      for (int r = 0; r < boardSize; r++) {
        for (int c = 0; c < boardSize; c++) {
          final stone = board[r][c];
          if (stone != 0) {
            initialStones.add([
              stone == 1 ? 'B' : 'W',
              _toGtp(r, c, boardSize),
            ]);
          }
        }
      }

      final query = json.encode({
        'id': 'goko_${DateTime.now().millisecondsSinceEpoch}',
        'maxVisits': difficulty.simulations,
        'boardXSize': boardSize,
        'boardYSize': boardSize,
        'rules': 'japanese',
        'komi': 6.5,
        'initialStones': initialStones,
        'moves': <dynamic>[],
        'analyzeTurns': [initialStones.length],
      });

      channel.sink.add(query);

      // Wait up to 10 s for a response; fall back on timeout.
      final raw = await channel.stream.first
          .timeout(const Duration(seconds: 10))
          .onError((_, __) => null);

      await channel.sink.close();

      if (raw == null) {
        return _fallback(board, boardSize, player, difficulty);
      }

      final data = json.decode(raw as String);
      final moveInfos = data['moveInfos'];
      if (moveInfos is List && moveInfos.isNotEmpty) {
        final best = moveInfos[0]['move'] as String?;
        if (best != null && best.toUpperCase() != 'PASS') {
          return _fromGtp(best, boardSize);
        }
      }
      return null; // pass
    } catch (_) {
      return _fallback(board, boardSize, player, difficulty);
    }
  }

  Future<List<int>?> _fallback(
    List<List<int>> board,
    int boardSize,
    int player,
    AIDifficulty difficulty,
  ) => const MctsEngine().getBestMove(
    board: board,
    boardSize: boardSize,
    player: player,
    difficulty: AIDifficulty.hard,
  );

  /// Converts board [row]/[col] to a GTP coordinate string (e.g. `'Q16'`).
  String _toGtp(int row, int col, int boardSize) {
    final letter = _gtpCols[col];
    final number = boardSize - row;
    return '$letter$number';
  }

  /// Parses a GTP coordinate string back to `[row, col]`.
  List<int>? _fromGtp(String gtp, int boardSize) {
    if (gtp.length < 2) return null;
    final col = _gtpCols.indexOf(gtp[0].toUpperCase());
    final row = boardSize - int.parse(gtp.substring(1));
    if (col < 0 || row < 0 || row >= boardSize || col >= boardSize) {
      return null;
    }
    return [row, col];
  }
}
