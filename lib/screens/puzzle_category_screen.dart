import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../widgets/fast_game_board.dart';
import 'puzzle_screen.dart';

/// Browse all puzzles in a single category, with a difficulty-filter chip
/// row above the list. Solved puzzles get a green check overlay.
class PuzzleCategoryScreen extends StatefulWidget {
  final String category;

  const PuzzleCategoryScreen({required this.category, super.key});

  @override
  State<PuzzleCategoryScreen> createState() => _PuzzleCategoryScreenState();
}

class _PuzzleCategoryScreenState extends State<PuzzleCategoryScreen> {
  /// `0` = "All". `1`/`2`/`3` = star count.
  int _filter = 0;
  late List<Puzzle> _puzzles;

  @override
  void initState() {
    super.initState();
    _puzzles = PuzzleData.getPuzzlesForTopic(widget.category);
  }

  List<Puzzle> get _visible => _filter == 0
      ? _puzzles
      : _puzzles.where((p) => p.difficulty == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category), centerTitle: true),
      body: Column(
        children: [
          _buildFilterRow(),
          const Divider(height: 1),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shuffle,
        icon: const Icon(Icons.shuffle),
        label: const Text('Shuffle'),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          _filterChip(label: 'All', value: 0),
          _filterChip(label: '★', value: 1),
          _filterChip(label: '★★', value: 2),
          _filterChip(label: '★★★', value: 3),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required int value}) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildList() {
    final list = _visible;
    if (list.isEmpty) {
      return const Center(child: Text('No puzzles for this filter.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
      itemCount: list.length,
      itemBuilder: (context, i) => _PuzzleCard(puzzle: list[i]),
    );
  }

  void _shuffle() {
    setState(() => _puzzles = List.of(_puzzles)..shuffle());
  }
}

class _PuzzleCard extends StatelessWidget {
  final Puzzle puzzle;

  const _PuzzleCard({required this.puzzle});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: puzzle)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: FastGameBoard(
                      board: puzzle.initialBoard,
                      onTap: (_, __) {},
                      isDarkTheme:
                          Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      puzzle.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Icon(
                          i < puzzle.difficulty
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      puzzle.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Solved-state badge slot. Persistent solved tracking is a
              // separate feature; surface a placeholder that the future
              // tracker can flip.
              const _SolvedBadge(solved: false),
            ],
          ),
        ),
      ),
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
