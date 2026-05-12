import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/l10n/puzzle_translations.dart';
import '../models/puzzle.dart';
import '../models/optimized_game.dart';
import '../widgets/fast_game_board.dart';
import '../widgets/result_modal.dart';
import '../models/app_settings.dart';
import '../services/subscription_service.dart';
import 'paywall_screen.dart';

class PuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;
  final bool isDrillMode;

  const PuzzleScreen({
    required this.puzzle,
    this.isDrillMode = false,
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
    if (!widget.isDrillMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPuzzleQuota());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkPuzzleQuota() async {
    if (!mounted) return;
    final subscription = context.read<SubscriptionService>();
    if (!subscription.canSolveAnotherPuzzle()) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    await subscription.recordPuzzleAttempted();
  }

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
    // View-only teaching puzzles have no moves — tapping does nothing.
    if (widget.puzzle.solution.isEmpty) return;
    if (_game.board.getStone(i, j) != 0) return;
    if (_moveCount >= widget.puzzle.solution.length) return;

    final expectedMove = widget.puzzle.solution[_moveCount];

    // Skip if this solution step is the opponent's turn (shouldn't be reachable
    // since we auto-play opponent moves, but guard defensively).
    if (expectedMove.color != widget.puzzle.playerColor) return;

    final isExpectedCoord = i == expectedMove.row && j == expectedMove.col;

    if (!isExpectedCoord) {
      _handleWrongMove(i, j);
      return;
    }

    // Correct coordinate — try to place through the engine.
    final placed = _game.board.placeStone(i, j, widget.puzzle.playerColor);
    if (!placed) {
      _handleWrongMove(i, j, illegal: true);
      return;
    }

    setState(() => _moveCount++);
    _checkWinAndContinue();
  }

  /// After a correct player move, check for win or schedule opponent response.
  void _checkWinAndContinue() {
    final sequenceComplete = _moveCount >= widget.puzzle.solution.length;
    final winSatisfied = widget.puzzle.winCondition.isSatisfied(
      _game.board.board,
    );

    if (sequenceComplete && winSatisfied) {
      setState(() => _solved = true);
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
      _game.board.placeStone(move.row, move.col, move.color);
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

    // Brief snackbar feedback (drill mode or normal).
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            illegal
                ? 'Illegal move (Ko / suicide).'
                : 'Wrong move — try again!',
          ),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );

    if (widget.isDrillMode) _resetPuzzle();
  }

  void _showSuccessDialog() {
    final l = AppLocalizations.of(context);
    ResultModal.show<void>(
      context,
      kind: ResultModalKind.success,
      title: l.puzzleSolved,
      body:
          '"${widget.puzzle.localizedTitle(context)}"\n'
          '${l.difficulty}: ${'⭐' * widget.puzzle.difficulty}',
      actions: [
        ResultModalAction(
          label: l.continue_,
          icon: Icons.arrow_forward,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context, {
              'solved': true,
              'puzzleId': widget.puzzle.id,
              'mistakes': _mistakeCount,
            });
          },
        ),
        ResultModalAction(
          label: l.tryAgain,
          icon: Icons.refresh,
          isPrimary: true,
          onPressed: () {
            Navigator.pop(context);
            _resetPuzzle();
          },
        ),
      ],
    );
  }

  // ignore: unused_element
  void _showFailDialog() {
    final l = AppLocalizations.of(context);
    final targeted = _lastWrongMoveKey != null
        ? widget.puzzle.failureReasons[_lastWrongMoveKey!]
        : null;
    final localizedHint = widget.puzzle.localizedHint(context);
    final reason = targeted ?? localizedHint;
    final body = targeted != null
        ? '$reason\n\n${l.hint}: $localizedHint'
        : reason;
    ResultModal.show<void>(
      context,
      kind: ResultModalKind.failure,
      title: l.notQuite,
      body: body,
      actions: [
        ResultModalAction(
          label: l.stepBack,
          icon: Icons.undo,
          onPressed: () {
            Navigator.pop(context);
            _stepBack();
          },
        ),
        ResultModalAction(
          label: l.giveUp,
          icon: Icons.close,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        ResultModalAction(
          label: l.tryAgain,
          icon: Icons.refresh,
          isPrimary: true,
          onPressed: () {
            Navigator.pop(context);
            _resetPuzzle();
          },
        ),
      ],
    );
  }

  /// Reverts the most recent wrong move only, leaving previous correct moves
  /// in place so the user can keep working from where they were.
  void _stepBack() {
    setState(() {
      if (_lastWrongMoveKey != null) {
        final parts = _lastWrongMoveKey!.split(',');
        final r = int.parse(parts[0]);
        final c = int.parse(parts[1]);
        _game.board.setStone(r, c, 0);
        _lastWrongMoveKey = null;
      }
    });
  }

  void _resetPuzzle() {
    setState(() {
      _game = Game(widget.puzzle.boardSize);
      _loadPuzzlePosition();
      _solved = false;
      _moveCount = 0;
      _lastWrongMoveKey = null;
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
    final isDarkTheme = forceLight
        ? false
        : Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: forceLight ? Colors.white : null,
        title: Text(
          widget.puzzle.localizedTitle(context),
          style: forceLight ? const TextStyle(color: Colors.black87) : null,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: forceLight ? Colors.black87 : null,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.lightbulb_outline,
              color: forceLight ? Colors.black87 : null,
            ),
            onPressed: _showHint,
            tooltip: AppLocalizations.of(context).hint,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: forceLight ? Colors.black87 : null,
            ),
            onPressed: _resetPuzzle,
            tooltip: AppLocalizations.of(context).reset,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return isWide
              ? _buildDesktopLayout(constraints, isDarkTheme)
              : _buildMobileLayout(constraints, isDarkTheme);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints, bool isDarkTheme) {
    final double boardSize = constraints.maxHeight * 0.8;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: FastGameBoard(
                  board: _game.board.board,
                  onTap: _onTapBoard,
                  isDarkTheme: isDarkTheme,
                  showCoordinates: AppSettings.showCoordinates,
                ),
              ),
            ),
          ),
        ),
        Expanded(flex: 1, child: _buildPuzzleInfo()),
      ],
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints, bool isDarkTheme) {
    final double boardSize = constraints.maxWidth * 0.95;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Progress bar
            if (widget.puzzle.solution.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Move $_moveCount of ${widget.puzzle.solution.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_awaitingOpponent)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.puzzle.solution.isEmpty
                            ? 0
                            : _moveCount / widget.puzzle.solution.length,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            // Board with shake animation
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: FastGameBoard(
                  board: _game.board.board,
                  onTap: _onTapBoard,
                  isDarkTheme: isDarkTheme,
                  showCoordinates: AppSettings.showCoordinates,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPuzzleInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _solved ? Icons.check_circle : Icons.psychology,
                color: _solved ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _solved
                      ? AppLocalizations.of(context).puzzleSolved
                      : AppLocalizations.of(context).puzzles,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            AppLocalizations.of(context).objective,
            widget.puzzle.localizedDescription(context),
            Icons.flag,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            AppLocalizations.of(context).difficulty,
            '⭐' * widget.puzzle.difficulty,
            Icons.bar_chart,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            AppLocalizations.of(context).yourTurn,
            widget.puzzle.playerColor == 1
                ? AppLocalizations.of(context).blackToPlay
                : AppLocalizations.of(context).whiteToPlay,
            Icons.circle,
            iconColor: widget.puzzle.playerColor == 1
                ? Colors.black
                : Colors.white,
          ),
          const SizedBox(height: 12),
          if (widget.puzzle.solution.isNotEmpty)
            _buildInfoCard(
              AppLocalizations.of(context).moves,
              '$_moveCount / ${widget.puzzle.solution.length}',
              Icons.timeline,
            ),
          if (widget.puzzle.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTheorySection(),
          ],
          const SizedBox(height: 16),
          if (widget.puzzle.solution.isEmpty && !_solved)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _solved = true);
                  _showSuccessDialog();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(AppLocalizations.of(context).markAsLearned),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(AppLocalizations.of(context).hint),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTheorySection() {
    final l = AppLocalizations.of(context);
    return ExpansionTile(
      leading: const Icon(Icons.school, color: Colors.blue),
      title: Text(
        l.theoryExplanation,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _solved ? l.learnWhyThisWorks : l.solveToUnlock,
        style: TextStyle(
          fontSize: 12,
          color: _solved ? Colors.green : Colors.grey,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_solved) ...[
                Text(
                  widget.puzzle.explanation,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                _buildConceptCard(),
              ] else ...[
                const Icon(Icons.lock, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text(
                  'Complete the puzzle to unlock the explanation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConceptCard() {
    final l = AppLocalizations.of(context);
    final concept = _getConcept(widget.puzzle.category, l);
    if (concept == null) return const SizedBox.shrink();

    return Card(
      color: Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${l.keyConceptPrefix}${concept['title']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              concept['description']!,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String>? _getConcept(String category, AppLocalizations l) {
    switch (category) {
      case 'capture':
        return {
          'title': l.conceptLibertiesCaptures,
          'description': l.conceptLibertiesCapturesDesc,
        };
      case 'liberties':
        return {
          'title': l.conceptLibertyCounting,
          'description': l.conceptLibertyCountingDesc,
        };
      case 'life_death':
        return {
          'title': l.conceptLifeDeathTwoEyes,
          'description': l.conceptLifeDeathDesc,
        };
      case 'ko':
        return {'title': l.conceptKoRule, 'description': l.conceptKoRuleDesc};
      default:
        return null;
    }
  }
}
