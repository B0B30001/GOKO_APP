import 'package:flutter/material.dart';
import 'package:zaibal/l10n/puzzle_translations.dart';
import '../models/puzzle.dart';
import '../screens/puzzle_screen.dart';
import 'fast_game_board.dart';

/// Single-row puzzle card with a 60×60 board thumbnail, title, difficulty
/// stars, description, and a solved-or-chevron trailing badge. Shared by
/// `PuzzleCategoryScreen` and other puzzle list screens.
///
/// Tapping pushes [PuzzleScreen]; if the puzzle is solved, the pop value
/// `{'solved': true, 'puzzleId': id}` flows to the parent via [onSolved].
class PuzzleListCard extends StatelessWidget {
  final Puzzle puzzle;
  final bool solved;
  final ValueChanged<String>? onSolved;

  /// Optional sequence + index. When set, the success modal in PuzzleScreen
  /// will show a "Next puzzle" button that pushes the next entry without
  /// returning to the list (chess.com-style continuous flow).
  final List<Puzzle>? sequence;
  final int? sequenceIndex;

  const PuzzleListCard({
    required this.puzzle,
    this.solved = false,
    this.onSolved,
    this.sequence,
    this.sequenceIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _Thumbnail(puzzle: puzzle),
              const SizedBox(width: 12),
              Expanded(child: _Meta(puzzle: puzzle)),
              const SizedBox(width: 6),
              _SolvedBadge(solved: solved),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(
          puzzle: puzzle,
          sequence: sequence,
          sequenceIndex: sequenceIndex,
        ),
      ),
    );
    if (result != null && result['solved'] == true) {
      onSolved?.call(puzzle.id);
    }
  }
}

class _Thumbnail extends StatelessWidget {
  final Puzzle puzzle;
  const _Thumbnail({required this.puzzle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: FastGameBoard(
            board: puzzle.initialBoard,
            onTap: (_, __) {},
            isDarkTheme: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final Puzzle puzzle;
  const _Meta({required this.puzzle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          puzzle.localizedTitle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            3,
            (i) => Icon(
              i < puzzle.difficulty ? Icons.star : Icons.star_border,
              size: 14,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          puzzle.localizedDescription(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SolvedBadge extends StatelessWidget {
  final bool solved;
  const _SolvedBadge({required this.solved});

  @override
  Widget build(BuildContext context) {
    if (!solved) return const Icon(Icons.chevron_right, color: Colors.grey);
    return const Icon(Icons.check_circle, color: Colors.green);
  }
}
