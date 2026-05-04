import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/models/optimized_board.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/widgets/fast_game_board.dart';

/// Premium-only post-game analysis screen. Steps forward and backward through
/// a saved match's move list and renders the resulting position.
///
/// Currently supports: scrubber, prev/next, jump-to-start/end. Variation
/// branching and engine evaluation will be added later.
class AnalysisScreen extends StatefulWidget {
  final String matchId;
  const AnalysisScreen({super.key, required this.matchId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  /// Number of moves currently applied (0 = empty board, [moves.length] = end).
  int _ply = 0;

  @override
  Widget build(BuildContext context) {
    final history = context.read<MatchHistoryService>();
    final record = history.findById(widget.matchId);

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis')),
        body: const Center(child: Text('Match not found.')),
      );
    }

    final boardSize = record.boardSize;
    final board = _replayTo(record, _ply);
    final maxPly = record.moves.length;

    return Scaffold(
      appBar: AppBar(title: Text('Review: vs ${record.opponent}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: FastGameBoard(
                      key: ValueKey<int>(_ply),
                      board: board,
                      onTap: (_, __) {},
                      isDarkTheme:
                          Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildScrubber(maxPly),
              const SizedBox(height: 8),
              _buildControls(maxPly),
              Text(
                'Move $_ply / $maxPly • $boardSize×$boardSize',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrubber(int maxPly) {
    return Slider(
      value: _ply.toDouble(),
      min: 0,
      max: maxPly.toDouble(),
      divisions: maxPly == 0 ? null : maxPly,
      label: _ply.toString(),
      onChanged: maxPly == 0 ? null : (v) => setState(() => _ply = v.round()),
    );
  }

  Widget _buildControls(int maxPly) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _ply == 0 ? null : () => setState(() => _ply = 0),
          tooltip: 'Start',
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: _ply == 0 ? null : () => setState(() => _ply -= 1),
          tooltip: 'Previous move',
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: _ply >= maxPly ? null : () => setState(() => _ply += 1),
          tooltip: 'Next move',
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _ply >= maxPly
              ? null
              : () => setState(() => _ply = maxPly),
          tooltip: 'End',
        ),
      ],
    );
  }

  /// Replays the first [ply] moves of [record] onto a fresh board and returns
  /// the 2D state. Captures are applied via [Board.placeStone] so the position
  /// matches what was on screen during play.
  List<List<int>> _replayTo(MatchRecord record, int ply) {
    final board = Board(record.boardSize);
    final upTo = ply.clamp(0, record.moves.length);
    for (var i = 0; i < upTo; i++) {
      final m = record.moves[i];
      // Pass moves are encoded as row=-1, col=-1 — skip on the board.
      if (m.row < 0 || m.col < 0) continue;
      // Use placeStone so captures resolve correctly. If the move is somehow
      // illegal (corrupt history), fall back to setStone so the replay
      // doesn't desync.
      final ok = board.placeStone(m.row, m.col, m.color);
      if (!ok) {
        board.setStone(m.row, m.col, m.color);
      }
    }
    return List.generate(
      record.boardSize,
      (i) => List.generate(record.boardSize, (j) => board.getStone(i, j)),
    );
  }
}
