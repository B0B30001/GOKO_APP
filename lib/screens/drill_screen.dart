import 'package:flutter/material.dart';
import 'dart:async';
import '../models/drill.dart';
import '../models/puzzle.dart';
import 'puzzle_screen.dart';

class DrillScreen extends StatefulWidget {
  final Drill drill;

  const DrillScreen({required this.drill, super.key});

  @override
  State<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends State<DrillScreen> {
  late List<Puzzle> _puzzleQueue;
  int _currentPuzzleIndex = 0;
  int _solvedCount = 0;
  int _mistakeCount = 0;
  int _timeRemaining = 0;
  Timer? _timer;
  bool _drillStarted = false;
  bool _drillCompleted = false;
  int _finalScore = 0;
  int _finalStars = 0;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.drill.timeLimit;
    _puzzleQueue = List.from(
      widget.drill.puzzles.take(widget.drill.targetCount),
    );
    _puzzleQueue.shuffle(); // Randomize puzzle order
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDrill() {
    setState(() {
      _drillStarted = true;
    });
    _startTimer();
    _showCurrentPuzzle();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _completeDrill();
        }
      });
    });
  }

  void _showCurrentPuzzle() {
    if (_currentPuzzleIndex >= _puzzleQueue.length ||
        _timeRemaining <= 0 ||
        _solvedCount >= widget.drill.targetCount) {
      _completeDrill();
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              puzzle: _puzzleQueue[_currentPuzzleIndex],
              isDrillMode: true,
            ),
          ),
        )
        .then((result) {
          if (!mounted) return;

          // Result: {solved: bool, mistakes: int}
          if (result is Map<String, dynamic>) {
            final solved = result['solved'] as bool? ?? false;
            final mistakes = result['mistakes'] as int? ?? 0;

            setState(() {
              if (solved) {
                _solvedCount++;
              }
              _mistakeCount += mistakes;
              _currentPuzzleIndex++;
            });

            // Check if drill should continue
            if (_timeRemaining > 0 &&
                _solvedCount < widget.drill.targetCount &&
                _currentPuzzleIndex < _puzzleQueue.length) {
              // Small delay before next puzzle
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _showCurrentPuzzle();
              });
            } else {
              _completeDrill();
            }
          } else {
            // User backed out - end drill
            _completeDrill();
          }
        });
  }

  void _completeDrill() {
    _timer?.cancel();

    if (_drillCompleted) return;

    final timeUsed = widget.drill.timeLimit - _timeRemaining;
    final score = widget.drill.calculateScore(
      solved: _solvedCount,
      timeRemaining: _timeRemaining,
      mistakes: _mistakeCount,
    );
    final stars = widget.drill.getStarRating(score, widget.drill.targetCount);

    setState(() {
      _drillCompleted = true;
      _finalScore = score;
      _finalStars = stars;
    });

    // Save result (would integrate with persistence later)
    final result = DrillResult(
      drillId: widget.drill.id,
      completedAt: DateTime.now(),
      score: score,
      solved: _solvedCount,
      total: widget.drill.targetCount,
      timeUsed: timeUsed,
      mistakes: _mistakeCount,
      stars: stars,
    );

    debugPrint('Drill completed: ${result.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    if (!_drillStarted) {
      return _buildIntroScreen(context);
    }

    if (_drillCompleted) {
      return _buildResultsScreen(context);
    }

    return _buildDrillProgress(context);
  }

  Widget _buildIntroScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.drill.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getDrillIcon(widget.drill.type),
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              widget.drill.title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.drill.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              context,
              icon: Icons.timer,
              label: 'Time Limit',
              value: _formatTime(widget.drill.timeLimit),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.emoji_events,
              label: 'Target',
              value: '${widget.drill.targetCount} Puzzles',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.star,
              label: 'Difficulty',
              value:
                  '${'⭐' * widget.drill.minDifficulty}'
                  '${widget.drill.maxDifficulty > widget.drill.minDifficulty ? ' - ${'⭐' * widget.drill.maxDifficulty}' : ''}',
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startDrill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START DRILL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillProgress(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drill.title),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              _showQuitConfirmation(context);
            },
            child: const Text('Quit'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(_timeRemaining),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _timeRemaining <= 10 ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _solvedCount / widget.drill.targetCount,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_solvedCount / ${widget.drill.targetCount} Solved',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Loading next puzzle...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context) {
    final percentage = (_solvedCount / widget.drill.targetCount * 100).round();
    final passed = _finalStars > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Complete'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.pending,
              size: 100,
              color: passed ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Well Done!' : 'Keep Practicing!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  index < _finalStars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildResultCard(
              context,
              icon: Icons.check_circle,
              label: 'Solved',
              value: '$_solvedCount / ${widget.drill.targetCount}',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              context,
              icon: Icons.percent,
              label: 'Accuracy',
              value: '$percentage%',
              color: percentage >= 70 ? Colors.blue : Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              context,
              icon: Icons.error,
              label: 'Mistakes',
              value: '$_mistakeCount',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              context,
              icon: Icons.timer,
              label: 'Time Used',
              value: _formatTime(widget.drill.timeLimit - _timeRemaining),
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              context,
              icon: Icons.stars,
              label: 'Score',
              value: '$_finalScore',
              color: Colors.amber,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back to Learn'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Retry drill
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              DrillScreen(drill: widget.drill),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Drill?'),
        content: const Text('Your progress will not be saved if you quit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit drill screen
            },
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  IconData _getDrillIcon(DrillType type) {
    switch (type) {
      case DrillType.capture:
        return Icons.close;
      case DrillType.lifeAndDeath:
        return Icons.favorite;
      case DrillType.ko:
        return Icons.loop;
      case DrillType.tesuji:
        return Icons.auto_fix_high;
      case DrillType.mixed:
        return Icons.shuffle;
    }
  }
}
