import 'dart:async';
import 'ai_engine.dart';
import 'go_ai_service.dart' show AIDifficulty;
import 'mcts_engine.dart';
import 'katago_process_service.dart';

/// [AIEngine] implementation backed by a locally-managed KataGo subprocess.
///
/// Delegates all process management to [KataGoProcessService]. If the process
/// is not ready (binary not found, still starting, or crashed) the request
/// transparently falls back to [MctsEngine] at hard difficulty so gameplay
/// is never interrupted.
class KataGoLocalEngine implements AIEngine {
  const KataGoLocalEngine();

  // GTP column letters — 'I' is skipped per Go convention.
  static const _kGtpCols = 'ABCDEFGHJKLMNOPQRST';

  @override
  String get name => 'katago-local';

  @override
  Future<List<int>?> getBestMove({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    required AIDifficulty difficulty,
  }) async {
    final service = KataGoProcessService.instance;

    // Auto-start the process the first time a move is requested.
    if (service.isAvailable && !service.isReady) {
      unawaited(service.start());
    }

    if (!service.isReady) {
      return const MctsEngine().getBestMove(
        board: board,
        boardSize: boardSize,
        player: player,
        difficulty: AIDifficulty.hard,
      );
    }

    // Build the initialStones list from the board.
    final initialStones = <List<String>>[];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        final stone = board[r][c];
        if (stone != 0) {
          initialStones.add([stone == 1 ? 'B' : 'W', _toGtp(r, c, boardSize)]);
        }
      }
    }

    final response = await service.query({
      'boardXSize': boardSize,
      'boardYSize': boardSize,
      'rules': 'japanese',
      'komi': 6.5,
      'initialStones': initialStones,
      'moves': <dynamic>[],
      'analyzeTurns': [initialStones.length],
      'maxVisits': difficulty.simulations,
    });

    if (response == null) {
      // Timed out or error — fall back to MCTS for this move.
      return const MctsEngine().getBestMove(
        board: board,
        boardSize: boardSize,
        player: player,
        difficulty: AIDifficulty.hard,
      );
    }

    final moveInfos = response['moveInfos'] as List?;
    if (moveInfos == null || moveInfos.isEmpty) return null;

    final best = (moveInfos.first as Map<String, dynamic>)['move'] as String?;
    if (best == null || best.toUpperCase() == 'PASS') return null;

    return _fromGtp(best, boardSize);
  }

  // ---------------------------------------------------------------------------
  // GTP coordinate helpers
  // ---------------------------------------------------------------------------

  String _toGtp(int row, int col, int boardSize) {
    return '${_kGtpCols[col]}${boardSize - row}';
  }

  List<int>? _fromGtp(String gtp, int boardSize) {
    final upper = gtp.toUpperCase();
    if (upper.length < 2) return null;
    final colIdx = _kGtpCols.indexOf(upper[0]);
    if (colIdx < 0) return null;
    final rowNum = int.tryParse(upper.substring(1));
    if (rowNum == null) return null;
    final row = boardSize - rowNum;
    if (row < 0 || row >= boardSize || colIdx >= boardSize) return null;
    return [row, colIdx];
  }
}
