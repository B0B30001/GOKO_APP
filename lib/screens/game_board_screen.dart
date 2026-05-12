// lib/screens/game_board_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zaibal/models/optimized_game.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/widgets/fast_game_board.dart';
import 'package:zaibal/widgets/player_panel.dart';
import 'package:zaibal/widgets/score_estimator_bar.dart';
import 'package:zaibal/widgets/move_history_panel.dart';
import 'package:zaibal/services/ai/go_ai_service.dart';
import 'package:zaibal/services/user_service.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/services/sfx_service.dart';

class GameBoardScreen extends StatefulWidget {
  final int boardSize;
  final bool isComputerMode;
  final AIDifficulty aiDifficulty;

  const GameBoardScreen({
    required this.boardSize,
    this.isComputerMode = false,
    this.aiDifficulty = AIDifficulty.medium,
    super.key,
  });

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late Game _game;
  bool _isAiThinking = false;
  bool _resultRecorded = false;
  final List<HistoryMove> _moves = [];

  // Player 1 = Black (human), Player 2 = White (AI) in computer mode.
  static const _aiPlayer = 2;

  @override
  void initState() {
    super.initState();
    _game = Game(widget.boardSize);
  }

  void _onTapBoard(int i, int j) {
    if (_game.isGameOver || _isAiThinking) return;

    if (widget.isComputerMode && !_game.isBlackTurn) return;

    final color = _game.isBlackTurn ? 1 : 2;
    final capturesBefore =
        _game.board.capturedByBlack + _game.board.capturedByWhite;
    final success = _game.playTurn(i, j);
    if (success) {
      final capturesAfter =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      if (capturesAfter > capturesBefore) {
        SfxService.instance.play(SfxSound.capture);
      } else {
        SfxService.instance.play(SfxSound.stonePlace);
      }
      _moves.add(HistoryMove(i, j, color));
      setState(() {});
      if (_game.isGameOver) return;

      if (widget.isComputerMode) {
        _triggerAiMove();
      } else if (!_game.hasValidMoves()) {
        Future.microtask(() {
          if (mounted) {
            _showSnack('No legal moves available. Press Pass to continue.');
          }
        });
      }
    }
  }

  Future<void> _triggerAiMove() async {
    setState(() => _isAiThinking = true);

    final move = await GoAIService.getBestMove(
      board: _game.board.board,
      boardSize: widget.boardSize,
      player: _aiPlayer,
      difficulty: widget.aiDifficulty,
    );

    if (!mounted) return;

    if (move != null) {
      final capturesBefore =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      _game.playTurn(move[0], move[1]);
      final capturesAfter =
          _game.board.capturedByBlack + _game.board.capturedByWhite;
      _moves.add(HistoryMove(move[0], move[1], _aiPlayer));
      if (capturesAfter > capturesBefore) {
        SfxService.instance.play(SfxSound.capture);
      } else {
        SfxService.instance.play(SfxSound.stonePlace);
      }
    } else {
      _game.pass();
      _moves.add(HistoryMove(-1, -1, _aiPlayer));
    }

    setState(() => _isAiThinking = false);

    if (_game.isGameOver) {
      Future.microtask(() {
        if (mounted) _showGameOverDialog();
      });
    }
  }

  void _resetGame() {
    setState(() {
      _game = Game(widget.boardSize);
      _isAiThinking = false;
      _resultRecorded = false;
      _moves.clear();
    });
  }

  Future<void> _maybeRecordResult() async {
    if (!_game.isGameOver || _resultRecorded) return;
    _resultRecorded = true;
    final score = _game.getScore();
    final blackTotal = score['black']['total'] as int;
    final whiteTotal = score['white']['total'] as int;
    // Human always plays black in local and AI modes today.
    final humanWon = blackTotal > whiteTotal;
    final tied = blackTotal == whiteTotal;

    final user = context.read<UserService>();
    final history = context.read<MatchHistoryService>();
    if (!tied) {
      await user.recordGameResult(win: humanWon);
    }
    await history.add(
      MatchRecord(
        id: const Uuid().v4(),
        playedAt: DateTime.now(),
        opponent: widget.isComputerMode
            ? 'AI (${widget.aiDifficulty.label})'
            : 'Local opponent',
        boardSize: widget.boardSize,
        result: tied
            ? MatchResult.draw
            : humanWon
            ? MatchResult.win
            : MatchResult.loss,
        moves: List.unmodifiable(_moves),
        source: widget.isComputerMode ? MatchSource.ai : MatchSource.local,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forceLight = AppSettings.forceLightThemeInGame;
    final title = widget.isComputerMode
        ? 'vs Computer (${widget.aiDifficulty.label})'
        : 'GO Game ${widget.boardSize}x${widget.boardSize}';

    final scaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: forceLight ? Colors.white : null,
        title: Text(
          title,
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
              Icons.refresh,
              color: forceLight ? Colors.black87 : null,
            ),
            onPressed: _resetGame,
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1200) {
                  return _buildExtraWideLayout(constraints);
                } else if (constraints.maxWidth >= 720) {
                  return _buildWideLayout(constraints);
                } else {
                  return _buildMobileLayout(constraints);
                }
              },
            ),
            if (_isAiThinking) _buildAiThinkingChip(),
          ],
        ),
      ),
    );

    return forceLight
        ? Theme(data: ThemeData.light(), child: scaffold)
        : scaffold;
  }

  Widget _buildAiThinkingChip() {
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'AI thinking…',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    final isDarkTheme = _isEffectiveDark();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: FastGameBoard(
                  board: _game.board.board,
                  onTap: _onTapBoard,
                  isDarkTheme: isDarkTheme,
                  showCoordinates: AppSettings.showCoordinates,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 320, child: _buildSidePanel()),
        ],
      ),
    );
  }

  /// Two-sidebar layout for ≥1200px: board + game-info column + move history.
  Widget _buildExtraWideLayout(BoxConstraints constraints) {
    final isDarkTheme = _isEffectiveDark();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: FastGameBoard(
                  board: _game.board.board,
                  onTap: _onTapBoard,
                  isDarkTheme: isDarkTheme,
                  showCoordinates: AppSettings.showCoordinates,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 280, child: _buildSidePanel()),
          const SizedBox(width: 12),
          SizedBox(
            width: 320,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MoveHistoryPanel(
                moves: _moves,
                boardSize: widget.boardSize,
                activeIndex: _moves.isNotEmpty ? _moves.length - 1 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    final isDarkTheme = _isEffectiveDark();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildOpponentPanel(),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: FastGameBoard(
                  board: _game.board.board,
                  onTap: _onTapBoard,
                  isDarkTheme: isDarkTheme,
                  showCoordinates: AppSettings.showCoordinates,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildAdvantageBar(),
          const SizedBox(height: 8),
          _buildPlayerPanel(),
          const SizedBox(height: 4),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOpponentPanel(),
        const SizedBox(height: 12),
        _buildAdvantageBar(),
        const Spacer(),
        _buildScoreSummary(),
        const SizedBox(height: 12),
        _buildPlayerPanel(),
        const SizedBox(height: 8),
        _buildToolbar(),
      ],
    );
  }

  Widget _buildOpponentPanel() {
    final score = _game.getScore();
    final opponentName = widget.isComputerMode ? 'Computer' : 'White';
    return PlayerPanel(
      color: 2,
      name: opponentName,
      rank: widget.isComputerMode ? widget.aiDifficulty.label : null,
      captures: (score['white']['captured'] as int?) ?? 0,
      isActive: !_game.isBlackTurn && !_game.isGameOver,
      isDarkBackground: _isEffectiveDark(),
    );
  }

  Widget _buildPlayerPanel() {
    final score = _game.getScore();
    final user = context.watch<UserService>().currentUser;
    return PlayerPanel(
      color: 1,
      name: user?.displayName ?? 'You',
      rank: user?.rank,
      avatarPath: user?.avatarPath,
      captures: (score['black']['captured'] as int?) ?? 0,
      isActive: _game.isBlackTurn && !_game.isGameOver,
      isDarkBackground: _isEffectiveDark(),
    );
  }

  Widget _buildAdvantageBar() {
    final score = _game.getScore();
    return ScoreEstimatorBar(
      blackTotal: (score['black']['total'] as num?) ?? 0,
      whiteTotal: (score['white']['total'] as num?) ?? 0,
    );
  }

  Widget _buildScoreSummary() {
    final score = _game.getScore();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isEffectiveDark()
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          _buildScoreRow('Black', score['black']),
          const SizedBox(height: 4),
          _buildScoreRow('White', score['white']),
          if (_game.isGameOver) ...[
            const Divider(height: 16),
            Text(
              _getWinnerText(score),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: (!_isAiThinking && _game.canUndo)
              ? () {
                  _game.undo();
                  if (_moves.isNotEmpty) _moves.removeLast();
                  if (widget.isComputerMode && _game.canUndo) {
                    _game.undo();
                    if (_moves.isNotEmpty) _moves.removeLast();
                  }
                  setState(() {});
                }
              : null,
          tooltip: 'Undo move',
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (!_isAiThinking && !_game.isGameOver)
              ? () {
                  _game.pass();
                  _moves.add(HistoryMove(-1, -1, _game.isBlackTurn ? 2 : 1));
                  setState(() {});
                  if (_game.isGameOver) {
                    Future.microtask(() {
                      if (mounted) _showGameOverDialog();
                    });
                  } else if (widget.isComputerMode) {
                    _triggerAiMove();
                  } else if (!_game.hasValidMoves()) {
                    Future.microtask(() {
                      if (mounted) _showGameOverDialog();
                    });
                  }
                }
              : null,
          tooltip: 'Pass turn',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: (!_isAiThinking && _game.canRedo)
              ? () {
                  _game.redo();
                  setState(() {});
                }
              : null,
          tooltip: 'Redo move',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _resetGame,
          tooltip: 'New game',
        ),
      ],
    );
  }

  bool _isEffectiveDark() {
    final forceLight = AppSettings.forceLightThemeInGame;
    return forceLight ? false : Theme.of(context).brightness == Brightness.dark;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildScoreRow(String player, Map<String, dynamic> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(player),
        Row(
          children: [
            Tooltip(message: 'Stones', child: Text('⚫ ${stats['stones']}')),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Territory',
              child: Text('◻ ${stats['territory']}'),
            ),
            const SizedBox(width: 8),
            Tooltip(message: 'Captured', child: Text('✕ ${stats['captured']}')),
            const SizedBox(width: 12),
            Text(
              '= ${stats['total']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _getWinnerText(Map<String, dynamic> score) {
    final blackTotal = score['black']['total'];
    final whiteTotal = score['white']['total'];
    if (blackTotal > whiteTotal) {
      return 'Black wins by ${blackTotal - whiteTotal} points!';
    } else if (whiteTotal > blackTotal) {
      return 'White wins by ${whiteTotal - blackTotal} points!';
    } else {
      return 'Game is tied!';
    }
  }

  void _showGameOverDialog() {
    final score = _game.getScore();
    _maybeRecordResult();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getWinnerText(score)),
            const SizedBox(height: 16),
            _buildScoreRow('Black', score['black']),
            const Divider(),
            _buildScoreRow('White', score['white']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
