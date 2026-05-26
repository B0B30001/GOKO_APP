import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/l10n/puzzle_translations.dart';
import '../models/puzzle.dart';
import '../models/optimized_game.dart';
import '../widgets/fast_game_board.dart';
import '../models/app_settings.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';

class PuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;
  final bool isDrillMode;

  /// Optional puzzle queue. When provided, the success modal shows a
  /// "Next puzzle" button that pushes the next entry in [sequence] without
  /// returning to the list, so users can chain puzzles like chess.com.
  final List<Puzzle>? sequence;
  final int? sequenceIndex;

  const PuzzleScreen({
    required this.puzzle,
    this.isDrillMode = false,
    this.sequence,
    this.sequenceIndex,
    super.key,
  });

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with SingleTickerProviderStateMixin {
  late Game _game;
  bool _solved = false;
  int _moveCount = 0;
  int _mistakeCount = 0;

  /// True while waiting for the opponent's auto-response to play.
  bool _awaitingOpponent = false;

  /// Coordinates of the last wrong move ("row,col") for targeted feedback.
  String? _lastWrongMoveKey;

  /// Current position in the branching solution tree. Null when the puzzle
  /// only has a linear [Puzzle.solution] list (legacy hand-curated puzzles).
  /// Initialised to `puzzle.solutionTree` so the virtual root's children are
  /// the first-move alternatives.
  SolutionNode? _treeCursor;

  // ignore: unused_field (kept for potential future use)

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnimation =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
    _game = Game(widget.puzzle.boardSize);
    _loadPuzzlePosition();
    _treeCursor = widget.puzzle.solutionTree;
    if (!widget.isDrillMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPuzzleQuota());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  /// Daily-quota gate is now a no-op — GOKO is fully free. Kept as a hook
  /// in case a soft daily-streak counter is reintroduced later.
  Future<void> _checkPuzzleQuota() async {}

  void _loadPuzzlePosition() {
    // Load the initial puzzle position
    for (int i = 0; i < widget.puzzle.boardSize; i++) {
      for (int j = 0; j < widget.puzzle.boardSize; j++) {
        final stone = widget.puzzle.initialBoard[i][j];
        if (stone != 0) {
          _game.board.setStone(i, j, stone);
        }
      }
    }
    setState(() {});
  }

  void _onTapBoard(int i, int j) {
    if (_solved || _awaitingOpponent) return;
    if (_game.board.getStone(i, j) != 0) return;

    final tree = _treeCursor;
    if (tree != null) {
      // Tree-walk evaluator: descend into any child that matches the tap.
      // Multiple correct first-move alternatives are honoured.
      final next = tree.matchChild(i, j, widget.puzzle.playerColor);
      if (next == null) {
        _handleWrongMove(i, j);
        return;
      }
      final capsBefore =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      final placed = _game.board.placeStone(i, j, widget.puzzle.playerColor);
      if (!placed) {
        _handleWrongMove(i, j, illegal: true);
        return;
      }
      SfxService.instance.play(SfxSound.stonePlace);
      final capsAfter =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      if (capsAfter > capsBefore) {
        SfxService.instance.play(SfxSound.capture);
      }
      setState(() {
        _moveCount++;
        _treeCursor = next;
      });
      _checkWinAndContinueTree();
      return;
    }

    // Legacy linear evaluator for hand-curated puzzles without a tree.
    if (widget.puzzle.solution.isEmpty) return; // view-only teaching puzzle
    if (_moveCount >= widget.puzzle.solution.length) return;
    final expectedMove = widget.puzzle.solution[_moveCount];
    if (expectedMove.color != widget.puzzle.playerColor) return;
    if (i != expectedMove.row || j != expectedMove.col) {
      _handleWrongMove(i, j);
      return;
    }
    final capsBefore =
        _game.board.capturedByBlack + _game.board.capturedByWhite;
    final placed = _game.board.placeStone(i, j, widget.puzzle.playerColor);
    if (!placed) {
      _handleWrongMove(i, j, illegal: true);
      return;
    }
    SfxService.instance.play(SfxSound.stonePlace);
    final capsAfter = _game.board.capturedByBlack + _game.board.capturedByWhite;
    if (capsAfter > capsBefore) {
      SfxService.instance.play(SfxSound.capture);
    }
    setState(() => _moveCount++);
    _checkWinAndContinue();
  }

  /// Tree-walk variant of [_checkWinAndContinue]. The puzzle solves when the
  /// player's move lands on a `correct: true` leaf. Otherwise auto-play the
  /// opponent's deterministic response (first opponent-coloured child of the
  /// current cursor).
  void _checkWinAndContinueTree() {
    final cursor = _treeCursor;
    if (cursor == null) return;
    if (cursor.correct && cursor.color == widget.puzzle.playerColor) {
      setState(() => _solved = true);
      SfxService.instance.play(SfxSound.complete);
      if (AppSettings.hapticsEnabled) HapticFeedback.mediumImpact();
      context.read<ProgressService>().markPuzzleSolved(widget.puzzle.id);
      if (widget.isDrillMode) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          Navigator.pop(context, {'solved': true, 'mistakes': _mistakeCount});
        });
      }
      return;
    }
    final opponentColor = widget.puzzle.playerColor == 1 ? 2 : 1;
    final opp = cursor.firstChildOfColor(opponentColor);
    if (opp != null) {
      _scheduleOpponentMoveTree(opp);
    }
  }

  /// Schedules the opponent's pre-determined response from the tree.
  void _scheduleOpponentMoveTree(SolutionNode oppNode) {
    setState(() => _awaitingOpponent = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final capsBefore =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      _game.board.placeStone(oppNode.row, oppNode.col, oppNode.color);
      SfxService.instance.play(SfxSound.stonePlace);
      final capsAfter =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      if (capsAfter > capsBefore) {
        SfxService.instance.play(SfxSound.capture);
      }
      setState(() {
        _moveCount++;
        _treeCursor = oppNode;
        _awaitingOpponent = false;
      });
      // After the opponent moves, the cursor may itself be a correct-leaf
      // (rare — usually the win is on the player's move) or branch further.
      _checkWinAndContinueTree();
    });
  }

  /// After a correct player move, check for win or schedule opponent response.
  void _checkWinAndContinue() {
    final sequenceComplete = _moveCount >= widget.puzzle.solution.length;
    final winSatisfied = widget.puzzle.winCondition.isSatisfied(
      _game.board.board,
    );

    if (sequenceComplete && winSatisfied) {
      setState(() => _solved = true);
      SfxService.instance.play(SfxSound.complete);
      if (AppSettings.hapticsEnabled) HapticFeedback.mediumImpact();
      // Persist the solve in ProgressService (fire-and-forget, non-blocking).
      context.read<ProgressService>().markPuzzleSolved(widget.puzzle.id);
      if (widget.isDrillMode) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          Navigator.pop(context, {'solved': true, 'mistakes': _mistakeCount});
        });
      }
      // In normal mode the inline solution panel reveals itself automatically.
      return;
    }

    // Auto-play the next move if it belongs to the opponent.
    if (_moveCount < widget.puzzle.solution.length) {
      final next = widget.puzzle.solution[_moveCount];
      if (next.color != widget.puzzle.playerColor) {
        _scheduleOpponentMove();
      }
    }
  }

  /// Plays the opponent's response automatically after a short delay,
  /// mimicking the chess.com puzzle experience.
  void _scheduleOpponentMove() {
    setState(() => _awaitingOpponent = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final move = widget.puzzle.solution[_moveCount];
      final capsBefore =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      _game.board.placeStone(move.row, move.col, move.color);
      SfxService.instance.play(SfxSound.stonePlace);
      final capsAfter =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      if (capsAfter > capsBefore) {
        SfxService.instance.play(SfxSound.capture);
      }
      setState(() {
        _moveCount++;
        _awaitingOpponent = false;
      });
      _checkWinAndContinue();
    });
  }

  void _handleWrongMove(int i, int j, {bool illegal = false}) {
    setState(() {
      _mistakeCount++;
      _lastWrongMoveKey = '$i,$j';
      // Briefly show the wrong stone so the shake is meaningful.
      if (!illegal) {
        _game.board.setStone(i, j, widget.puzzle.playerColor);
      }
    });

    // Shake the board, then remove the wrong stone and let the player retry
    // (chess.com style — no blocking dialog).
    SfxService.instance.play(SfxSound.wrong);
    _shakeController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        if (!illegal && _lastWrongMoveKey != null) {
          final parts = _lastWrongMoveKey!.split(',');
          _game.board.setStone(int.parse(parts[0]), int.parse(parts[1]), 0);
        }
        _lastWrongMoveKey = null;
      });
    });

    // Show a rich feedback banner with targeted explanation when available.
    final l = AppLocalizations.of(context);
    final targeted = widget.puzzle.failureReasons['$i,$j'];
    final feedbackMsg = illegal
        ? l.illegalMoveFeedback
        : targeted ?? l.wrongMoveFeedback;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.close, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feedbackMsg,
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFB71C1C),
          duration: Duration(milliseconds: targeted != null ? 2800 : 1400),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

    if (widget.isDrillMode) _resetPuzzle();
  }

  void _resetPuzzle() {
    setState(() {
      _game = Game(widget.puzzle.boardSize);
      _loadPuzzlePosition();
      _solved = false;
      _moveCount = 0;
      _lastWrongMoveKey = null;
      _treeCursor = widget.puzzle.solutionTree;
    });
  }

  void _showHint() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber),
            const SizedBox(width: 8),
            Text(l.hint),
          ],
        ),
        content: Text(widget.puzzle.localizedHint(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.continue_),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forceLight = AppSettings.forceLightThemeInGame;
    final isDark = forceLight
        ? false
        : Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF0EBE3),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF16213E)
            : const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        title: Text(
          widget.puzzle.localizedTitle(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
            onPressed: _showHint,
            tooltip: AppLocalizations.of(context).hint,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetPuzzle,
            tooltip: AppLocalizations.of(context).reset,
          ),
        ],
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return isWide
              ? _buildDesktopLayout(constraints, isDark, cs)
              : _buildMobileLayout(constraints, isDark, cs);
        },
      ),
    );
  }

  Widget _buildBoardWidget(double size, bool isDark) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 120 : 60),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: FastGameBoard(
            board: _game.board.board,
            onTap: _onTapBoard,
            isDarkTheme: isDark,
            showCoordinates: AppSettings.showCoordinates,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BoxConstraints constraints,
    bool isDark,
    ColorScheme cs,
  ) {
    final double boardSize = constraints.maxHeight * 0.8;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(child: _buildBoardWidget(boardSize, isDark)),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInstruction(isDark),
                const SizedBox(height: 20),
                _buildStatusPanel(isDark, cs),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BoxConstraints constraints,
    bool isDark,
    ColorScheme cs,
  ) {
    final double boardSize = constraints.maxWidth * 0.96;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInstruction(isDark),
          const SizedBox(height: 10),
          Center(child: _buildBoardWidget(boardSize, isDark)),
          const SizedBox(height: 16),
          _buildStatusPanel(isDark, cs),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Bold move-indicator bar: "● Ход чёрных" / "○ Ход белых".
  Widget _buildInstruction(bool isDark) {
    final l = AppLocalizations.of(context);
    final isBlack = widget.puzzle.playerColor == 1;
    final barBg = isDark ? const Color(0xFF0F3460) : const Color(0xFF2D2D2D);
    return Container(
      color: barBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBlack ? Colors.black : Colors.white,
              border: Border.all(
                color: isBlack ? Colors.grey.shade400 : Colors.grey.shade500,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isBlack ? l.blackToPlay : l.whiteToPlay,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          if (_awaitingOpponent) ...[
            const Spacer(),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Status panel below the board: description + actions, or solved banner.
  Widget _buildStatusPanel(bool isDark, ColorScheme cs) {
    final l = AppLocalizations.of(context);

    if (_solved) {
      final hasNext =
          widget.sequence != null &&
          widget.sequenceIndex != null &&
          widget.sequenceIndex! + 1 < widget.sequence!.length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.puzzleSolved,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '⭐' * widget.puzzle.difficulty,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            if (widget.puzzle.explanation.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(12)
                      : Colors.black.withAlpha(6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(12),
                  ),
                ),
                child: Text(
                  widget.puzzle.localizedExplanation(context),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: cs.onSurface.withAlpha(200),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (hasNext)
              FilledButton.icon(
                onPressed: () {
                  final nextIndex = widget.sequenceIndex! + 1;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PuzzleScreen(
                        puzzle: widget.sequence![nextIndex],
                        sequence: widget.sequence,
                        sequenceIndex: nextIndex,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.skip_next),
                label: Text(l.nextPuzzle),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.pop(context, {
                  'solved': true,
                  'puzzleId': widget.puzzle.id,
                  'mistakes': _mistakeCount,
                }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l.continue_),
              ),
          ],
        ),
      );
    }

    // Not yet solved — description + hint/reset
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(18)
                    : Colors.black.withAlpha(10),
              ),
            ),
            child: Text(
              // OGS puzzles (solutionTree != null) use a generic "Find the
              // best move" label — the OGS description is often in Japanese or
              // uses category terms that don't match the board position.
              widget.puzzle.solutionTree != null
                  ? l.puzzleBestMove
                  : widget.puzzle.localizedDescription(context),
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.puzzle.solution.isEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => _solved = true);
                  context.read<ProgressService>().markPuzzleSolved(
                    widget.puzzle.id,
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l.markAsLearned),
              ),
            )
          else
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _showHint,
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: Text(l.hint),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _resetPuzzle,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l.reset),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
