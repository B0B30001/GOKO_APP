import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle.dart';
import '../models/tutorial.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../widgets/puzzle_list_card.dart';
import 'tutorial_screen.dart';

/// Three difficulty buckets the Learn tab surfaces.
enum LevelTier { beginner, intermediate, advanced }

/// All tutorials + puzzles filtered to a single [LevelTier]. Wired from the
/// new "By Level" section on the Lessons tab so each level card opens a
/// fully populated, tappable list rather than the dead links of the old UI.
class LevelTrackScreen extends StatefulWidget {
  final LevelTier tier;

  const LevelTrackScreen({required this.tier, super.key});

  @override
  State<LevelTrackScreen> createState() => _LevelTrackScreenState();
}

class _LevelTrackScreenState extends State<LevelTrackScreen> {

  String get _title => switch (widget.tier) {
    LevelTier.beginner => 'Beginner',
    LevelTier.intermediate => 'Intermediate',
    LevelTier.advanced => 'Advanced',
  };

  /// Puzzle.difficulty buckets. Advanced absorbs anything 3+.
  bool _matches(int d) => switch (widget.tier) {
    LevelTier.beginner => d <= 1,
    LevelTier.intermediate => d == 2,
    LevelTier.advanced => d >= 3,
  };

  List<Puzzle> get _puzzles =>
      PuzzleData.allPuzzles.where((p) => _matches(p.difficulty)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title), centerTitle: true),
      body: FutureBuilder<List<Tutorial>>(
        future: ContentService.loadTutorials(
          languageCode: Localizations.localeOf(context).languageCode,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final tutorials = (snapshot.data ?? const <Tutorial>[])
              .where((t) => _matches(t.difficulty))
              .toList();
          return _buildBody(tutorials, _puzzles);
        },
      ),
    );
  }

  Widget _buildBody(List<Tutorial> tutorials, List<Puzzle> puzzles) {
    final progress = context.watch<ProgressService>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      children: [
        _Header(
          tier: widget.tier,
          tutorialCount: tutorials.length,
          puzzleCount: puzzles.length,
          solvedCount: puzzles
              .where((p) => progress.isPuzzleSolved(p.id))
              .length,
        ),
        const SizedBox(height: 16),
        if (tutorials.isNotEmpty) ...[
          const _SectionLabel(label: 'Lessons'),
          const SizedBox(height: 8),
          ...tutorials.map(_buildTutorialTile),
          const SizedBox(height: 20),
        ],
        if (puzzles.isNotEmpty) ...[
          const _SectionLabel(label: 'Puzzles'),
          const SizedBox(height: 8),
          ...puzzles.map(
            (p) => PuzzleListCard(
              puzzle: p,
              solved: context.watch<ProgressService>().isPuzzleSolved(p.id),
              onSolved: (_) {
                // Progress is persisted by PuzzleScreen → ProgressService.
                // ProgressService is a ChangeNotifier so context.watch rebuilds.
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTutorialTile(Tutorial t) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.school),
        title: Text(t.title),
        subtitle: Text(t.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TutorialScreen(tutorial: t)),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final LevelTier tier;
  final int tutorialCount;
  final int puzzleCount;
  final int solvedCount;

  const _Header({
    required this.tier,
    required this.tutorialCount,
    required this.puzzleCount,
    required this.solvedCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = puzzleCount;
    final progress = total == 0 ? 0.0 : solvedCount / total;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(_iconFor(tier), size: 30, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tutorialCount lessons · $puzzleCount puzzles',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$solvedCount / $total solved',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(LevelTier t) => switch (t) {
    LevelTier.beginner => Icons.eco,
    LevelTier.intermediate => Icons.trending_up,
    LevelTier.advanced => Icons.emoji_events,
  };
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 3, height: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
