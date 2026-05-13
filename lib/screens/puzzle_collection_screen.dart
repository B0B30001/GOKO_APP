import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../models/puzzle_collection.dart';
import '../widgets/puzzle_list_card.dart';

/// Renders a single curated [PuzzleCollection] — title in the AppBar,
/// description card up top, then a ListView of the collection's puzzles
/// (resolved against [PuzzleData.allPuzzles]). Reuses [PuzzleListCard] so
/// every puzzle list in the app looks the same.
class PuzzleCollectionScreen extends StatefulWidget {
  final PuzzleCollection collection;

  const PuzzleCollectionScreen({required this.collection, super.key});

  @override
  State<PuzzleCollectionScreen> createState() => _PuzzleCollectionScreenState();
}

class _PuzzleCollectionScreenState extends State<PuzzleCollectionScreen> {
  final Set<String> _localSolved = <String>{};

  List<Puzzle> get _puzzles {
    final all = {for (final p in PuzzleData.allPuzzles) p.id: p};
    return widget.collection.puzzleIds
        .map((id) => all[id])
        .whereType<Puzzle>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final puzzles = _puzzles;
    return Scaffold(
      appBar: AppBar(title: Text(widget.collection.title), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          _Header(
            collection: widget.collection,
            solvedCount: _localSolved.length,
            totalCount: puzzles.length,
          ),
          const SizedBox(height: 12),
          ...puzzles.asMap().entries.map(
            (entry) => PuzzleListCard(
              puzzle: entry.value,
              solved: _localSolved.contains(entry.value.id),
              onSolved: (id) => setState(() => _localSolved.add(id)),
              sequence: puzzles,
              sequenceIndex: entry.key,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PuzzleCollection collection;
  final int solvedCount;
  final int totalCount;

  const _Header({
    required this.collection,
    required this.solvedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = totalCount == 0 ? 0.0 : solvedCount / totalCount;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              collection.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$solvedCount / $totalCount',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
