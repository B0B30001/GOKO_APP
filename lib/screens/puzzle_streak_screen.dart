import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';

import '../models/app_settings.dart';
import '../models/optimized_game.dart';
import '../models/puzzle.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../widgets/fast_game_board.dart';

enum _Phase { loading, playing, correct, gameOver }

/// Chess.com-style Puzzle Streak: solve back-to-back puzzles.
/// One wrong move ends the run. Streak counter animates between puzzles.
class PuzzleStreakScreen extends StatefulWidget {
  const PuzzleStreakScreen({super.key});

  @override
  State<PuzzleStreakScreen> createState() => _PuzzleStreakScreenState();
}

class _PuzzleStreakScreenState extends State<PuzzleStreakScreen>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  List<Puzzle> _pool = [];
  Puzzle? _current;
  Game? _game;
  int _moveCount = 0;
  bool _awaitingOpponent = false;

  _Phase _phase = _Phase.loading;
  int _streak = 0;
  int _bestStreak = 0;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _loadPool();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPool() async {
    final progress = context.read<ProgressService>();
    setState(() {
      _bestStreak = progress.bestPuzzleStreak;
    });
    final jsonPuzzles = await ContentService.loadPuzzles();
    final codePuzzles = <Puzzle>[];
    for (final topic in [
      'Captures', 'Liberties', 'Life & Death',
      'Ko Basics', 'Tesuji', 'Ladder', 'Snapback', 'Connect',
    ]) {
      codePuzzles.addAll(PuzzleData.getPuzzlesForTopic(topic));
    }
    final all = [
      ...jsonPuzzles,
      ...codePuzzles,
    ].where((p) => p.solution.isNotEmpty).toList();
    all.shuffle(_rng);
    if (!mounted) return;
    setState(() => _pool = all);
    _nextPuzzle();
  }

  void _nextPuzzle() {
    if (_pool.isEmpty) return;
    final puzzle = _pool.removeLast();
    if (_pool.length < 10) {
      // Refill pool quietly when running low.
      _loadPool();
    }
    final game = Game(puzzle.boardSize);
    for (var r = 0; r < puzzle.boardSize; r++) {
      for (var c = 0; c < puzzle.boardSize; c++) {
        final s = puzzle.initialBoard[r][c];
        if (s != 0) game.board.setStone(r, c, s);
      }
    }
    setState(() {
      _current = puzzle;
      _game = game;
      _moveCount = 0;
      _awaitingOpponent = false;
      _phase = _Phase.playing;
    });
  }

  void _onTap(int r, int c) {
    final puzzle = _current;
    final game = _game;
    if (_phase != _Phase.playing || _awaitingOpponent) return;
    if (puzzle == null || game == null) return;
    if (puzzle.solution.isEmpty) return;
    if (game.board.getStone(r, c) != 0) return;
    if (_moveCount >= puzzle.solution.length) return;

    final expected = puzzle.solution[_moveCount];
    if (expected.color != puzzle.playerColor) return;

    if (r != expected.row || c != expected.col) {
      _handleWrong(r, c, puzzle: puzzle, game: game);
      return;
    }
    final placed = game.board.placeStone(r, c, puzzle.playerColor);
    if (!placed) {
      _handleWrong(r, c, puzzle: puzzle, game: game);
      return;
    }
    SfxService.instance.play(SfxSound.stonePlace);
    setState(() => _moveCount++);
    _checkWin(puzzle: puzzle, game: game);
  }

  void _checkWin({required Puzzle puzzle, required Game game}) {
    final done = _moveCount >= puzzle.solution.length;
    final satisfied = puzzle.winCondition.isSatisfied(game.board.board);
    if (done && satisfied) {
      final newStreak = _streak + 1;
      final newBest = newStreak > _bestStreak ? newStreak : _bestStreak;
      setState(() {
        _streak = newStreak;
        _bestStreak = newBest;
        _phase = _Phase.correct;
      });
      SfxService.instance.play(SfxSound.complete);
      if (AppSettings.hapticsEnabled) HapticFeedback.mediumImpact();
      context.read<ProgressService>()
        ..markPuzzleSolved(puzzle.id)
        ..updateBestPuzzleStreak(newStreak);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _nextPuzzle();
      });
      return;
    }
    // Auto-play opponent response.
    if (_moveCount < puzzle.solution.length) {
      final next = puzzle.solution[_moveCount];
      if (next.color != puzzle.playerColor) {
        setState(() => _awaitingOpponent = true);
        Future.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          game.board.placeStone(next.row, next.col, next.color);
          SfxService.instance.play(SfxSound.stonePlace);
          setState(() {
            _moveCount++;
            _awaitingOpponent = false;
          });
          _checkWin(puzzle: puzzle, game: game);
        });
      }
    }
  }

  void _handleWrong(int r, int c, {required Puzzle puzzle, required Game game}) {
    game.board.setStone(r, c, puzzle.playerColor);
    SfxService.instance.play(SfxSound.wrong);
    if (AppSettings.hapticsEnabled) HapticFeedback.heavyImpact();
    _shakeCtrl.forward(from: 0.0).then((_) {
      if (!mounted) return;
      game.board.setStone(r, c, 0);
      setState(() {});
    });
    setState(() => _phase = _Phase.gameOver);
    context.read<ProgressService>().updateBestPuzzleStreak(_streak);
  }

  void _restart() {
    setState(() {
      _streak = 0;
      _phase = _Phase.loading;
    });
    _loadPool();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final puzzle = _current;
    final game = _game;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            const SizedBox(width: 6),
            Text(l.puzzleStreak),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── streak bar ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: cs.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StreakStat(
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                      value: '$_streak',
                      label: l.currentStreak,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: cs.onSurface.withValues(alpha: 0.15),
                    ),
                    _StreakStat(
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      value: '$_bestStreak',
                      label: l.bestLabel,
                    ),
                  ],
                ),
              ),
              // ── board ─────────────────────────────────────────────────
              Expanded(
                child: _phase == _Phase.loading || puzzle == null || game == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          const SizedBox(height: 12),
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              puzzle.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: AnimatedBuilder(
                                  animation: _shakeAnim,
                                  builder: (context, child) =>
                                      Transform.translate(
                                        offset: Offset(_shakeAnim.value, 0),
                                        child: child,
                                      ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: FastGameBoard(
                                          board: game.board.board,
                                          onTap: _onTap,
                                          isDarkTheme: isDark,
                                          showCoordinates: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Hint text
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            child: Text(
                              puzzle.hint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                  ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),

          // ── correct flash ───────────────────────────────────────────────
          if (_phase == _Phase.correct)
            IgnorePointer(
              child: Container(
                color: Colors.green.withValues(alpha: 0.15),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),

          // ── game over overlay ───────────────────────────────────────────
          if (_phase == _Phase.gameOver)
            _GameOverOverlay(
              streak: _streak,
              best: _bestStreak,
              onRestart: _restart,
              onExit: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StreakStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int streak;
  final int best;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _GameOverOverlay({
    required this.streak,
    required this.best,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isNewRecord = streak > 0 && streak >= best;

    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.streakEndedTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              if (isNewRecord)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.newRecord,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScorePill(
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    value: '$streak',
                    label: l.currentStreak,
                  ),
                  _ScorePill(
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                    value: '$best',
                    label: l.bestLabel,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh),
                  label: Text(l.tryAgain),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onExit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _ScorePill({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
