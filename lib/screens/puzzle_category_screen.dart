import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../widgets/puzzle_list_card.dart';

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
    // Exclude theory/observer puzzles (solution:[]) — those belong in tutorials.
    _puzzles = PuzzleData.getPuzzlesForTopic(
      widget.category,
    ).where((p) => p.solution.isNotEmpty).toList();
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
      itemBuilder: (context, i) => PuzzleListCard(puzzle: list[i]),
    );
  }

  void _shuffle() {
    setState(() => _puzzles = List.of(_puzzles)..shuffle());
  }
}
