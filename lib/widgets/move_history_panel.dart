import 'package:flutter/material.dart';
import 'package:zaibal/services/match_history_service.dart';

/// Scrollable list of moves in standard Go column-letter notation, e.g.
/// `1. B Q16  W D4`. Designed to live in the right-hand sidebar on desktop
/// and to be hidden behind a tab on mobile.
class MoveHistoryPanel extends StatelessWidget {
  final List<HistoryMove> moves;
  final int boardSize;

  /// 0-based index of the currently active move (e.g. for highlighting). Pass
  /// `moves.length - 1` to highlight the latest. `null` highlights nothing.
  final int? activeIndex;

  const MoveHistoryPanel({
    super.key,
    required this.moves,
    required this.boardSize,
    this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Moves',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${moves.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: moves.isEmpty
              ? Center(
                  child: Text(
                    'No moves yet',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : _MoveList(
                  moves: moves,
                  boardSize: boardSize,
                  activeIndex: activeIndex,
                ),
        ),
      ],
    );
  }
}

class _MoveList extends StatelessWidget {
  final List<HistoryMove> moves;
  final int boardSize;
  final int? activeIndex;

  const _MoveList({
    required this.moves,
    required this.boardSize,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Pair moves into rows: (Black, White?). Each pair = one move number.
    final rowCount = (moves.length + 1) ~/ 2;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final blackIdx = rowIndex * 2;
        final whiteIdx = rowIndex * 2 + 1;
        final blackMove = moves[blackIdx];
        final whiteMove = whiteIdx < moves.length ? moves[whiteIdx] : null;
        return _MoveRow(
          number: rowIndex + 1,
          blackMove: blackMove,
          whiteMove: whiteMove,
          boardSize: boardSize,
          isBlackActive: activeIndex == blackIdx,
          isWhiteActive: whiteMove != null && activeIndex == whiteIdx,
        );
      },
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

  const _MoveRow({
    required this.number,
    required this.blackMove,
    required this.whiteMove,
    required this.boardSize,
    required this.isBlackActive,
    required this.isWhiteActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$number.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: _MoveCell(
              move: blackMove,
              boardSize: boardSize,
              active: isBlackActive,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: whiteMove == null
                ? const SizedBox.shrink()
                : _MoveCell(
                    move: whiteMove!,
                    boardSize: boardSize,
                    active: isWhiteActive,
                  ),
          ),
        ],
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

/// Convert a (row, col) pair to standard Go column-letter notation.
/// Row -1 (used for passes elsewhere in the codebase) maps to "pass".
/// Columns skip the letter "I" by convention.
String _toGoNotation(HistoryMove move, int boardSize) {
  if (move.row < 0 || move.col < 0) return 'pass';
  // Standard column letters: A B C D E F G H J K L M N O P Q R S T (skip I).
  const letters = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';
  if (move.col < 0 || move.col >= letters.length) return '?';
  final colLetter = letters[move.col];
  // Row 0 is the top of the array but rendered as the highest number on a Go
  // board (e.g. 19 on a 19x19). Mirror by subtracting from boardSize.
  final rowNumber = boardSize - move.row;
  return '$colLetter$rowNumber';
}
