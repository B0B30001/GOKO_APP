import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;
import 'mcts_engine.dart';
import '../../models/app_settings.dart';

/// Go engine backed by a remote Leela Zero (or any GTP-over-WebSocket server).
///
/// Communicates via the **Go Text Protocol (GTP)**. All board-setup commands
/// plus a final `genmove` are sent as a single newline-delimited batch.
/// The server is expected to reply with one GTP response per command; the
/// implementation extracts the `genmove` coordinate from the last `= …` line.
///
/// Falls back to [MctsEngine] at hard difficulty when the server is
/// unreachable or when a 15-second timeout elapses.
///
/// **Server URL format:** `ws://host:port` or `wss://host:port`
///
/// **Compatible servers:**
/// - Any Python / Node WebSocket bridge that wraps `leelaz` or similar.
/// - Example minimal Python bridge:
///   ```python
///   import asyncio, subprocess, websockets
///   proc = subprocess.Popen(['leelaz', '--gtp'], stdin=subprocess.PIPE,
///                           stdout=subprocess.PIPE, text=True)
///   async def handler(ws):
///       async for msg in ws:
///           for cmd in msg.splitlines():
///               proc.stdin.write(cmd + '\n'); proc.stdin.flush()
///               out = proc.stdout.readline()
///               await ws.send(out)
///   asyncio.run(websockets.serve(handler, '0.0.0.0', 8081))
///   ```
///
/// **Note on AlphaGo / ELF OpenGo:**
/// DeepMind's AlphaGo is closed-source and cannot be integrated directly.
/// Facebook's ELF OpenGo uses the same GTP interface as Leela Zero and works
/// with this engine as a drop-in replacement — just point the URL at an ELF
/// WebSocket bridge.
class LeelaEngine implements AIEngine {
  const LeelaEngine();

  // GTP column letters — 'I' is intentionally skipped per the Go convention.
  static const _gtpCols = 'ABCDEFGHJKLMNOPQRST';

  @override
  String get name => 'leela';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) async {
    final serverUrl = AppSettings.leelaServerUrl.trim();
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

      // Build the complete GTP command sequence as a single batch message.
      // The board is set up from scratch on every request so no per-session
      // state is kept (stateless from the app's perspective).
      final batch = StringBuffer()
        ..writeln('boardsize $boardSize')
        ..writeln('komi 6.5')
        ..writeln('clear_board');

      for (int r = 0; r < boardSize; r++) {
        for (int c = 0; c < boardSize; c++) {
          final stone = board[r][c];
          if (stone != 0) {
            final color = stone == 1 ? 'B' : 'W';
            batch.writeln('play $color ${_toGtp(r, c, boardSize)}');
          }
        }
      }

      final colorStr = player == 1 ? 'B' : 'W';
      batch.write('genmove $colorStr'); // last command — no trailing newline

      channel.sink.add(batch.toString());

      // Accumulate all WebSocket messages until the stream is idle or we
      // detect the genmove response (starts with '= ' after stripping).
      final responseBuffer = StringBuffer();
      await channel.stream
          .timeout(const Duration(seconds: 15))
          .forEach((msg) {
            responseBuffer.write(msg as String);
          })
          .catchError((_) {}); // timeout or closed stream — use what we have

      await channel.sink.close();

      return _parseGenmoveResponse(responseBuffer.toString(), boardSize);
    } catch (_) {
      // Network error, invalid URL, or parse failure → fall back to MCTS.
      return const MctsEngine().getBestMove(
        board: board,
        boardSize: boardSize,
        player: player,
        difficulty: AIDifficulty.hard,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Coordinate helpers
  // ---------------------------------------------------------------------------

  /// Converts 0-indexed `(row, col)` to a GTP coordinate string like `"D5"`.
  String _toGtp(int row, int col, int boardSize) {
    return '${_gtpCols[col]}${boardSize - row}';
  }

  /// Parses the full multi-command GTP response and returns `[row, col]` for
  /// the `genmove` result, or `null` for pass / resign / error.
  List<int>? _parseGenmoveResponse(String raw, int boardSize) {
    // Scan lines in reverse — the genmove reply is the last '= …' line.
    final lines = raw.split('\n');
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      if (!line.startsWith('= ')) continue;

      final coord = line.substring(2).trim().toUpperCase();
      if (coord.isEmpty || coord == 'PASS' || coord == 'RESIGN') return null;
      if (coord.length < 2) continue;

      final colIdx = _gtpCols.indexOf(coord[0]);
      if (colIdx < 0) continue;

      final rowNum = int.tryParse(coord.substring(1));
      if (rowNum == null) continue;

      final row = boardSize - rowNum;
      if (row < 0 || row >= boardSize || colIdx >= boardSize) continue;

      return [row, colIdx];
    }
    return null;
  }
}
