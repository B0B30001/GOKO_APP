import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/models/optimized_game.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/widgets/fast_game_board.dart';

/// Chess.com-style game replay screen. Loads the saved [MatchRecord] by
/// [matchId], replays every move onto a fresh [Game], and lets the user
/// scrub forward / backward through the position history.
class AnalysisScreen extends StatefulWidget {
  final String matchId;

  const AnalysisScreen({super.key, required this.matchId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  MatchRecord? _record;

  /// _snapshots[0] = initial empty board; _snapshots[k] = board after k moves.
  final List<List<List<int>>> _snapshots = [];

  /// 0 = initial position, moves.length = final position.
  int _currentIndex = 0;
  bool _initialized = false;
  final ScrollController _scrollCtrl = ScrollController();

  static const double _rowHeight = 36.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _load();
    }
  }

  void _load() {
    final record = context.read<MatchHistoryService>().findById(widget.matchId);
    if (record == null) return;
    _record = record;
    _buildSnapshots(record);
    setState(() => _currentIndex = record.moves.length);
  }

  void _buildSnapshots(MatchRecord record) {
    final game = Game(record.boardSize);
    _snapshots.add(_copyBoard(game.board.board));
    for (final move in record.moves) {
      if (move.row < 0 || move.col < 0) {
        game.pass();
      } else {
        game.playTurn(move.row, move.col);
      }
      _snapshots.add(_copyBoard(game.board.board));
    }
  }

  static List<List<int>> _copyBoard(List<List<int>> src) =>
      src.map((row) => List<int>.from(row)).toList();

  void _goTo(int index) {
    final record = _record;
    if (record == null) return;
    final clamped = index.clamp(0, record.moves.length);
    setState(() => _currentIndex = clamped);
    // Scroll the move list so the active row is visible.
    final targetRow = (clamped - 1) ~/ 2;
    if (targetRow >= 0 && _scrollCtrl.hasClients) {
      final target = (targetRow * _rowHeight).clamp(
        0.0,
        _scrollCtrl.position.maxScrollExtent,
      );
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final record = _record;
    final cs = Theme.of(context).colorScheme;

    // Use surface (not the default scaffold black) so the screen blends with
    // the themed gradient used on Home/Settings rather than reading as a
    // separate stark-dark sheet.
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(l.gameReview),
        centerTitle: true,
        bottom: record == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(22),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${record.opponent} · ${record.boardSize}×${record.boardSize}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
      ),
      body: SafeArea(
        child: record == null || _snapshots.isEmpty
            ? Center(
                child: Text(
                  l.gameReview,
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              )
            : _buildBody(context, record),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MatchRecord record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final board = _snapshots[_currentIndex];
    final screenSize = MediaQuery.of(context).size;

    // Square board capped at 50 % of screen height and 100 % of screen width.
    final boardSide = min(screenSize.width, screenSize.height * 0.50);

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: boardSide,
            height: boardSide,
            child: FastGameBoard(
              board: board,
              onTap: (_, __) {},
              isDarkTheme: isDark,
              showCoordinates: AppSettings.showCoordinates,
            ),
          ),
        ),
        _buildPlayerRow(context, record),
        _buildNavBar(context, record),
        const Divider(height: 1),
        Expanded(child: _buildMoveList(context, record)),
      ],
    );
  }

  Widget _buildPlayerRow(BuildContext context, MatchRecord record) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final label = _currentIndex == 0
        ? 'Start'
        : 'Move $_currentIndex / ${record.moves.length}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _PlayerChip(stoneColor: Colors.black, name: l.black),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          _PlayerChip(stoneColor: Colors.white, name: record.opponent),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, MatchRecord record) {
    final total = record.moves.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'Start',
            onPressed: _currentIndex > 0 ? () => _goTo(0) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
            onPressed: _currentIndex > 0
                ? () => _goTo(_currentIndex - 1)
                : null,
          ),
          Expanded(
            child: Slider(
              value: _currentIndex.toDouble(),
              min: 0,
              max: total > 0 ? total.toDouble() : 1.0,
              divisions: total > 0 ? total : 1,
              onChanged: total > 0 ? (v) => _goTo(v.round()) : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next',
            onPressed: _currentIndex < total
                ? () => _goTo(_currentIndex + 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            tooltip: 'End',
            onPressed: _currentIndex < total ? () => _goTo(total) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList(BuildContext context, MatchRecord record) {
    final moves = record.moves;
    if (moves.isEmpty) {
      return Center(
        child: Text(
          'No moves recorded',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final rowCount = (moves.length + 1) ~/ 2;
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final bIdx = rowIndex * 2;
        final wIdx = bIdx + 1;
        final hasWhite = wIdx < moves.length;
        return _MoveRow(
          number: rowIndex + 1,
          blackMove: moves[bIdx],
          whiteMove: hasWhite ? moves[wIdx] : null,
          boardSize: record.boardSize,
          isBlackActive: _currentIndex == bIdx + 1,
          isWhiteActive: hasWhite && _currentIndex == wIdx + 1,
          onTapBlack: () => _goTo(bIdx + 1),
          onTapWhite: hasWhite ? () => _goTo(wIdx + 1) : null,
          rowHeight: _rowHeight,
        );
      },
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _PlayerChip extends StatelessWidget {
  final Color stoneColor;
  final String name;

  const _PlayerChip({required this.stoneColor, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: stoneColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade600, width: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MoveRow extends StatelessWidget {
  final int number;
  final HistoryMove blackMove;
  final HistoryMove? whiteMove;
  final int boardSize;
  final bool isBlackActive;
  final bool isWhiteActive;
  final VoidCallback onTapBlack;
  final VoidCallback? onTapWhite;
  final double rowHeight;

  const _MoveRow({
    required this.number,
    required this.blackMove,
    required this.whiteMove,
    required this.boardSize,
    required this.isBlackActive,
    required this.isWhiteActive,
    required this.onTapBlack,
    this.onTapWhite,
    required this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '$number.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onTapBlack,
                behavior: HitTestBehavior.opaque,
                child: _MoveCell(
                  move: blackMove,
                  boardSize: boardSize,
                  active: isBlackActive,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: whiteMove == null
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: onTapWhite,
                      behavior: HitTestBehavior.opaque,
                      child: _MoveCell(
                        move: whiteMove!,
                        boardSize: boardSize,
                        active: isWhiteActive,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveCell extends StatelessWidget {
  final HistoryMove move;
  final int boardSize;
  final bool active;

  const _MoveCell({
    required this.move,
    required this.boardSize,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notation = _toGoNotation(move, boardSize);
    final isBlack = move.color == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: active ? cs.primary.withValues(alpha: 0.18) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isBlack ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade600, width: 0.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            notation,
            style: const TextStyle(
              fontSize: 12,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Converts a [HistoryMove] to standard Go column-letter notation (e.g. "E5").
/// Passes are shown as "pass". Skips the letter "I" by convention.
String _toGoNotation(HistoryMove move, int boardSize) {
  if (move.row < 0 || move.col < 0) return 'pass';
  const letters = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';
  if (move.col >= letters.length) return '?';
  final col = letters[move.col];
  final row = boardSize - move.row;
  return '$col$row';
}
