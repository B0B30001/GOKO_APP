import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _PuzzleScreenState extends State<PuzzleScreen> {
  late Game _game;
  bool _solved = false;
  bool _failed = false;
  int _moveCount = 0;
  int _mistakeCount = 0;

  /// Coordinates of the last wrong move ("row,col") so the fail dialog can
  /// show a targeted explanation when one exists.
  String? _lastWrongMoveKey;

  @override
  void initState() {
    super.initState();
    _game = Game(widget.puzzle.boardSize);
    _loadPuzzlePosition();
    if (!widget.isDrillMode) {
      // Defer until first frame so we have a valid context for navigation.
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPuzzleQuota());
    }
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
    if (_solved || _failed) return;
    // View-only teaching puzzles have no moves — tapping does nothing.
    if (widget.puzzle.solution.isEmpty) return;
    if (_game.board.getStone(i, j) != 0) return;
    if (_moveCount >= widget.puzzle.solution.length) return;

    final expectedMove = widget.puzzle.solution[_moveCount];
    final isExpectedCoord = i == expectedMove.row && j == expectedMove.col;

    if (!isExpectedCoord) {
      _handleWrongMove(i, j);
      return;
    }

    // Correct coordinate — try to place through the engine. If the engine
    // refuses (Ko, suicide), the move is illegal even though it matches the
    // recorded solution; treat it as a wrong move so we don't falsely solve.
    final placed = _game.board.placeStone(i, j, widget.puzzle.playerColor);
    if (!placed) {
      _handleWrongMove(i, j, illegal: true);
      return;
    }

    setState(() {
      _moveCount++;

      final sequenceComplete = _moveCount >= widget.puzzle.solution.length;
      final winSatisfied = widget.puzzle.winCondition.isSatisfied(
        _game.board.board,
      );

      if (sequenceComplete && winSatisfied) {
        _solved = true;
        if (widget.isDrillMode) {
          Navigator.pop(context, {'solved': true, 'mistakes': _mistakeCount});
        } else {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (!mounted) return;
            _showSuccessDialog();
          });
        }
      }
    });
  }

  void _handleWrongMove(int i, int j, {bool illegal = false}) {
    setState(() {
      _mistakeCount++;
      _lastWrongMoveKey = '$i,$j';
    });
    if (widget.isDrillMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            illegal ? 'Illegal move (Ko / suicide).' : 'Wrong move! Try again.',
          ),
          duration: const Duration(milliseconds: 900),
        ),
      );
      _resetPuzzle();
      return;
    }
    setState(() {
      // Only paint the wrong-move stone if it was a legal but wrong choice.
      // Illegal moves won't go on the board anyway.
      if (!illegal) {
        _game.board.setStone(i, j, widget.puzzle.playerColor);
      }
      _failed = true;
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _showFailDialog();
    });
  }

  void _showSuccessDialog() {
    ResultModal.show<void>(
      context,
      kind: ResultModalKind.success,
      title: 'Puzzle Solved!',
      body:
          'Congratulations! You solved "${widget.puzzle.title}".\n'
          'Difficulty: ${'⭐' * widget.puzzle.difficulty}',
      actions: [
        ResultModalAction(
          label: 'Continue',
          icon: Icons.arrow_forward,
          onPressed: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context); // back to list
          },
        ),
        ResultModalAction(
          label: 'Try Again',
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

  void _showFailDialog() {
    final targeted = _lastWrongMoveKey != null
        ? widget.puzzle.failureReasons[_lastWrongMoveKey!]
        : null;
    final reason = targeted ?? widget.puzzle.hint;
    final body = targeted != null
        ? '$reason\n\nGeneral hint: ${widget.puzzle.hint}'
        : reason;
    ResultModal.show<void>(
      context,
      kind: ResultModalKind.failure,
      title: 'Not quite',
      body: body,
      actions: [
        ResultModalAction(
          label: 'Step back',
          icon: Icons.undo,
          onPressed: () {
            Navigator.pop(context);
            _stepBack();
          },
        ),
        ResultModalAction(
          label: 'Give up',
          icon: Icons.close,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        ResultModalAction(
          label: 'Try again',
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
      _failed = false;
    });
  }

  void _resetPuzzle() {
    setState(() {
      _game = Game(widget.puzzle.boardSize);
      _loadPuzzlePosition();
      _solved = false;
      _failed = false;
      _moveCount = 0;
      _lastWrongMoveKey = null;
    });
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('Hint'),
          ],
        ),
        content: Text(widget.puzzle.hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
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
          widget.puzzle.title,
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
            tooltip: 'Show Hint',
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: forceLight ? Colors.black87 : null,
            ),
            onPressed: _resetPuzzle,
            tooltip: 'Reset',
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
            SizedBox(
              width: boardSize,
              height: boardSize,
              child: FastGameBoard(
                board: _game.board.board,
                onTap: _onTapBoard,
                isDarkTheme: isDarkTheme,
                showCoordinates: AppSettings.showCoordinates,
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
                  _solved ? 'Solved!' : 'Puzzle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Objective', widget.puzzle.description, Icons.flag),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Difficulty',
            '⭐' * widget.puzzle.difficulty,
            Icons.bar_chart,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Your Turn',
            widget.puzzle.playerColor == 1 ? 'Black to play' : 'White to play',
            Icons.circle,
            iconColor: widget.puzzle.playerColor == 1
                ? Colors.black
                : Colors.white,
          ),
          const SizedBox(height: 12),
          if (widget.puzzle.solution.isNotEmpty)
            _buildInfoCard(
              'Moves',
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
                label: const Text('Mark as Learned ✓'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Show Hint'),
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
    return ExpansionTile(
      leading: const Icon(Icons.school, color: Colors.blue),
      title: const Text(
        'Theory & Explanation',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _solved ? 'Learn why this works' : 'Solve to unlock',
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
    final concept = _getConcept(widget.puzzle.category);
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
                  'Key Concept: ${concept['title']}',
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

  Map<String, String>? _getConcept(String category) {
    switch (category) {
      case 'capture':
        return {
          'title': 'Liberties & Captures',
          'description':
              'Stones are captured when all their liberties (adjacent empty points) are occupied by enemy stones. Connected stones share liberties as a single group.',
        };
      case 'liberties':
        return {
          'title': 'Liberty Counting',
          'description':
              'Each empty point adjacent to a stone or group is a liberty. Connected stones form one group and share all their liberties. When a group has only one liberty left, it\'s in "atari" (check).',
        };
      case 'life_death':
        return {
          'title': 'Life & Death - Two Eyes',
          'description':
              'A group with two separate eyes cannot be captured because the opponent cannot fill both eyes simultaneously. This is fundamental to understanding which groups are alive and which can be killed.',
        };
      case 'ko':
        return {
          'title': 'Ko Rule',
          'description':
              'The Ko rule prevents infinite loops by prohibiting immediate recapture in a repeating position. After capturing in Ko, you must play elsewhere before you can recapture.',
        };
      default:
        return null;
    }
  }
}
