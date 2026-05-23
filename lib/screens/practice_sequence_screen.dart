import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import 'puzzle_screen.dart';

/// Plays a list of practice puzzles sequentially after a lesson, then shows a
/// summary and marks the parent lesson complete.
///
/// Designed as the "Phase B" of the Learning Path: lesson → animated steps
/// (handled by [TutorialScreen]) → this screen runs the puzzles. The lesson
/// is only marked complete once the user has worked through (or skipped) the
/// whole sequence.
class PracticeSequenceScreen extends StatefulWidget {
  /// Stable identifier of the parent lesson, used to record completion.
  final String lessonId;

  /// Display title (usually the lesson title).
  final String lessonTitle;

  /// Ordered puzzle ids to attempt.
  final List<String> puzzleIds;

  const PracticeSequenceScreen({
    required this.lessonId,
    required this.lessonTitle,
    required this.puzzleIds,
    super.key,
  });

  @override
  State<PracticeSequenceScreen> createState() => _PracticeSequenceScreenState();
}

class _PracticeSequenceScreenState extends State<PracticeSequenceScreen> {
  late final List<Puzzle> _puzzles;
  int _index = 0;
  int _solved = 0;
  int _mistakes = 0;
  bool _running = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final allById = {for (final p in PuzzleData.allPuzzles) p.id: p};
    _puzzles = widget.puzzleIds
        .map((id) => allById[id])
        .whereType<Puzzle>()
        .toList();
    // Start the sequence on the next frame so the scaffold can lay out first.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  /// Pushes one [PuzzleScreen] per puzzle, awaiting its pop result before
  /// advancing. Skipping (back gesture / explicit skip) advances too — we
  /// still count the lesson as completed once the user has worked through
  /// the queue.
  Future<void> _runSequence() async {
    if (_running || _puzzles.isEmpty) {
      if (_puzzles.isEmpty) setState(() => _finished = true);
      return;
    }
    _running = true;
    // Grab the service up-front to avoid lints around BuildContext use after
    // async gaps inside the loop.
    final progress = context.read<ProgressService>();
    while (mounted && _index < _puzzles.length) {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => PuzzleScreen(puzzle: _puzzles[_index]),
        ),
      );
      if (!mounted) return;
      if (result != null && result['solved'] == true) {
        _solved++;
        final m = result['mistakes'];
        if (m is int) _mistakes += m;
        await progress.markPuzzleSolved(_puzzles[_index].id);
      }
      if (!mounted) return;
      setState(() => _index++);
    }
    if (!mounted) return;
    await progress.markLessonCompleted(widget.lessonId);
    if (!mounted) return;
    SfxService.instance.play(SfxSound.lessonComplete);
    if (AppSettings.hapticsEnabled) HapticFeedback.mediumImpact();
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.lessonTitle), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _finished ? _buildSummary(cs) : _buildBetweenPuzzles(cs),
        ),
      ),
    );
  }

  Widget _buildBetweenPuzzles(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _puzzles.isEmpty
                ? 'No practice puzzles for this lesson.'
                : 'Loading puzzle ${_index + 1} of ${_puzzles.length}…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(ColorScheme cs) {
    final total = _puzzles.length;
    final accuracy = total == 0 ? 0.0 : (_solved / total).clamp(0.0, 1.0);
    final stars = switch (accuracy) {
      >= 0.9 => 3,
      >= 0.6 => 2,
      > 0.0 => 1,
      _ => 0,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(Icons.check_circle, size: 72, color: cs.primary),
        const SizedBox(height: 16),
        Text(
          'Lesson Complete!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          widget.lessonTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Icon(
              i < stars ? Icons.star : Icons.star_border,
              size: 36,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryStat(label: 'Solved', value: '$_solved / $total'),
                _SummaryStat(label: 'Mistakes', value: '$_mistakes'),
                _SummaryStat(
                  label: 'Accuracy',
                  value: '${(accuracy * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
