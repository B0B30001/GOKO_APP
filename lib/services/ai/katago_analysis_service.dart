import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/app_settings.dart';

/// Quality label for a single played move, computed by comparing the move's
/// win-rate delta against empirical thresholds (same scale as Chess.com).
enum MoveQuality {
  best, // best or within 0.5 % of best
  good, // within 2 %
  inaccuracy, // within 5 %
  mistake, // within 10 %
  blunder, // > 10 % loss
}

/// Win-rate and score evaluation for a single board position returned by the
/// KataGo analysis server.
class PositionEval {
  /// Black's win probability in [0, 1]. 0.5 = equal.
  final double blackWinRate;

  /// Score lead for Black in points (positive = Black ahead).
  final double scoreLead;

  /// Up to 3 best candidate moves, each as `[row, col]`.
  final List<List<int>> topMoves;

  /// Win rates corresponding to each [topMoves] entry.
  final List<double> topMoveWinRates;

  const PositionEval({
    required this.blackWinRate,
    required this.scoreLead,
    required this.topMoves,
    required this.topMoveWinRates,
  });

  /// Classifies how good [playedMove] was given this evaluation was computed
  /// *before* the move was played and [evalAfter] is the result after.
  ///
  /// Returns `null` if [playedMove] is a pass or the position is a mismatch.
  static MoveQuality? classify({
    required PositionEval evalBefore,
    required PositionEval evalAfter,
    required int playedPlayer, // 1=Black, 2=White
  }) {
    // Delta in win rate from the player's perspective.
    final before = playedPlayer == 1
        ? evalBefore.blackWinRate
        : 1.0 - evalBefore.blackWinRate;
    final after = playedPlayer == 1
        ? evalAfter.blackWinRate
        : 1.0 - evalAfter.blackWinRate;
    final delta = after - before; // positive = player improved

    if (delta >= -0.005) return MoveQuality.best;
    if (delta >= -0.02) return MoveQuality.good;
    if (delta >= -0.05) return MoveQuality.inaccuracy;
    if (delta >= -0.10) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }
}

/// Service that queries a remote KataGo analysis WebSocket server for position
/// evaluations. Used by [AnalysisScreen] to show an eval bar and move quality
/// classification (like Chess.com's analysis panel).
///
/// If [AppSettings.kataGoServerUrl] is empty, all calls immediately return
/// `null` so the screen degrades gracefully without a server.
///
/// **Thread safety:** all public methods are async and must be called from the
/// main isolate. The WebSocket response is awaited with a 15-second timeout.
class KataGoAnalysisService {
  // GTP column letters — 'I' is skipped per Go convention.
  static const _gtpCols = 'ABCDEFGHJKLMNOPQRST';

  /// Analyses [board] at the current position (all existing stones already
  /// placed) and returns the evaluation, or `null` on server error/timeout.
  ///
  /// [player] 1 = Black, 2 = White (next to play — used for komi orientation).
  Future<PositionEval?> analyse({
    required List<List<int>> board,
    required int boardSize,
    required int player,
    int maxVisits = 200,
  }) async {
    final serverUrl = AppSettings.kataGoServerUrl.trim();
    if (serverUrl.isEmpty) return null;

    try {
      final uri = Uri.parse(serverUrl);
      final channel = WebSocketChannel.connect(uri);

      final initialStones = _extractStones(board, boardSize);
      final query = json.encode({
        'id': 'analysis_${DateTime.now().millisecondsSinceEpoch}',
        'maxVisits': maxVisits,
        'boardXSize': boardSize,
        'boardYSize': boardSize,
        'rules': 'japanese',
        'komi': 6.5,
        'initialStones': initialStones,
        'moves': <dynamic>[],
        'analyzeTurns': [0],
        'includeOwnership': false,
        'includePolicy': false,
      });

      channel.sink.add(query);

      final raw = await channel.stream.first
          .timeout(const Duration(seconds: 15))
          .onError((_, __) => null);

      await channel.sink.close();
      if (raw == null) return null;

      return _parseResponse(raw as String, boardSize);
    } catch (_) {
      return null;
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  List<List<String>> _extractStones(List<List<int>> board, int boardSize) {
    final stones = <List<String>>[];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        final s = board[r][c];
        if (s != 0) {
          stones.add([s == 1 ? 'B' : 'W', _toGtp(r, c, boardSize)]);
        }
      }
    }
    return stones;
  }

  PositionEval? _parseResponse(String raw, int boardSize) {
    try {
      final data = json.decode(raw) as Map<String, dynamic>;
      final turnResults = data['turnResults'];
      if (turnResults is! List || turnResults.isEmpty) return null;

      final turn = turnResults[0] as Map<String, dynamic>;
      final winrate = (turn['winrate'] as num?)?.toDouble() ?? 0.5;
      final scoreLead = (turn['scoreLead'] as num?)?.toDouble() ?? 0.0;
      final moveInfos = turn['moveInfos'];

      final topMoves = <List<int>>[];
      final topWrs = <double>[];

      if (moveInfos is List) {
        for (final info in moveInfos.take(3)) {
          final move = info['move'] as String?;
          if (move == null || move.toUpperCase() == 'PASS') continue;
          final rc = _fromGtp(move, boardSize);
          if (rc != null) {
            topMoves.add(rc);
            topWrs.add((info['winrate'] as num?)?.toDouble() ?? winrate);
          }
        }
      }

      return PositionEval(
        blackWinRate: winrate,
        scoreLead: scoreLead,
        topMoves: topMoves,
        topMoveWinRates: topWrs,
      );
    } catch (_) {
      return null;
    }
  }

  String _toGtp(int row, int col, int boardSize) {
    return '${_gtpCols[col]}${boardSize - row}';
  }

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
