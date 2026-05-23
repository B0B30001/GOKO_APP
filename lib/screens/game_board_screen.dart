// lib/screens/game_board_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/optimized_game.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/widgets/fast_game_board.dart';
import 'package:zaibal/models/bot_profile.dart';
import 'package:zaibal/widgets/goko_logo.dart';
import 'package:zaibal/widgets/player_panel.dart';
import 'package:zaibal/widgets/score_estimator_bar.dart';
import 'package:zaibal/widgets/move_history_panel.dart';
import 'package:zaibal/services/ai/go_ai_service.dart';
import 'package:zaibal/services/user_service.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/services/sfx_service.dart';
import 'package:zaibal/screens/analysis_screen.dart';

class GameBoardScreen extends StatefulWidget {
  final int boardSize;
  final bool isComputerMode;
  final AIDifficulty aiDifficulty;

  /// Bot identity forwarded from the Bots screen. When null the opponent
  /// panel falls back to the generic "Computer" + difficulty-label display
  /// so non-bot entry points (legacy menu) still work.
  final String? opponentName;
  final String? opponentRank;
  final String? opponentAvatarPath;

  /// Full bot profile when launched from the Bots screen. Drives the
  /// post-game speech bubble and (later) per-bot engine tuning. Always
  /// consistent with opponentName/Rank/AvatarPath when both are set.
  final BotProfile? botProfile;

  /// When true: hints are free/unlimited, engine auto-suggests after every
  /// turn, and the result always shows 1 star (training mode).
  final bool practiceMode;

  const GameBoardScreen({
    required this.boardSize,
    this.isComputerMode = false,
    this.aiDifficulty = AIDifficulty.medium,
    this.opponentName,
    this.opponentRank,
    this.opponentAvatarPath,
    this.botProfile,
    this.practiceMode = false,
    super.key,
  });

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late Game _game;
  bool _isAiThinking = false;
  bool _resultRecorded = false;

  /// Id of the [MatchRecord] saved on game-end; used to launch analysis.
  String? _savedMatchId;
  final List<HistoryMove> _moves = [];

  // Player 1 = Black (human), Player 2 = White (AI) in computer mode.
  static const _aiPlayer = 2;

  // ── Chess.com-style hint mechanic ────────────────────────────────────────
  /// Hints used this game. Each consumes one star from a 3-star ceiling.
  int _hintsUsed = 0;
  static const _maxHints = 3;

  /// `[row, col]` of the active hint highlight, or null when not showing.
  List<int>? _hintCell;

  /// Becomes true while a hint MCTS search is in flight.
  bool _hintLoading = false;

  /// Drives the chess.com-style end-of-game overlay.
  bool _showingGameOver = false;

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
      } else {
        if (widget.practiceMode) _autoShowHint();
        if (!_game.hasValidMoves()) {
          Future.microtask(() {
            if (mounted) {
              _showSnack(AppLocalizations.of(context).noLegalMoves);
            }
          });
        }
      }
    }
  }

  Future<void> _triggerAiMove() async {
    setState(() => _isAiThinking = true);

    // Pace the move: weak engines return in tens of ms which feels robotic.
    // Subtract whatever the search actually took so strong engines stay snappy.
    final stopwatch = Stopwatch()..start();
    final move = await GoAIService.getBestMove(
      board: _game.board.board,
      boardSize: widget.boardSize,
      player: _aiPlayer,
      difficulty: widget.aiDifficulty,
    );
    final desiredMs = switch (widget.aiDifficulty) {
      AIDifficulty.easy => 600,
      AIDifficulty.medium => 1000,
      AIDifficulty.hard => 1500,
    };
    final remainingMs = desiredMs - stopwatch.elapsedMilliseconds;
    if (remainingMs > 0) {
      await Future.delayed(Duration(milliseconds: remainingMs));
    }

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

    // In practice mode auto-hint the best human response after the AI moves.
    if (widget.practiceMode && !_game.isGameOver) _autoShowHint();

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
      _savedMatchId = null;
      _moves.clear();
      _hintsUsed = 0;
      _hintCell = null;
      _hintLoading = false;
      _showingGameOver = false;
    });
  }

  Future<void> _maybeRecordResult() async {
    if (!_game.isGameOver || _resultRecorded) return;
    _resultRecorded = true;
    final score = _game.getScore();
    final blackTotal = score['black']['total'] as int;
    final whiteTotal = score['white']['total'] as int;
    // Resignation overrides the on-board score: whoever resigned loses.
    // Human always plays black in local and AI modes today.
    final resigned = _game.resignedColor;
    final humanWon = resigned == 2
        ? true
        : resigned == 1
        ? false
        : blackTotal > whiteTotal;
    final tied = resigned == 0 && blackTotal == whiteTotal;

    final user = context.read<UserService>();
    final history = context.read<MatchHistoryService>();
    if (!tied) {
      await user.recordGameResult(win: humanWon);
    }
    final id = const Uuid().v4();
    _savedMatchId = id;
    await history.add(
      MatchRecord(
        id: id,
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

  /// Asks the AI engine for the human's best move and highlights it on the
  /// board for ~3 seconds. Each call deducts one star (capped at 3 hints).
  /// Disabled when the human isn't on move or the engine is busy.
  Future<void> _useHint() async {
    if (_game.isGameOver || _isAiThinking || _hintLoading) return;
    if (_hintsUsed >= _maxHints) return;
    // Only meaningful for the human side.
    if (widget.isComputerMode && !_game.isBlackTurn) return;
    final remaining = _maxHints - _hintsUsed - 1;
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.useHintTitle),
        content: Text(l.useHintContent(remaining < 0 ? 0 : remaining)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogCtx, true),
            icon: const Icon(Icons.lightbulb, size: 16),
            label: Text(l.showHint),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _hintLoading = true;
      _hintsUsed++;
    });
    final humanColor = widget.isComputerMode ? 1 : (_game.isBlackTurn ? 1 : 2);
    final move = await GoAIService.getBestMove(
      board: _game.board.board,
      boardSize: widget.boardSize,
      player: humanColor,
      difficulty: widget.aiDifficulty,
    );
    if (!mounted) return;
    if (move == null || move.length < 2) {
      setState(() => _hintLoading = false);
      if (mounted) _showSnack(AppLocalizations.of(context).noHintAvailable);
      return;
    }
    setState(() {
      _hintCell = move;
      _hintLoading = false;
    });
    // Auto-clear after a few seconds so the highlight doesn't linger.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_hintCell != null &&
          _hintCell![0] == move[0] &&
          _hintCell![1] == move[1]) {
        setState(() => _hintCell = null);
      }
    });
  }

  /// In Practice Mode: automatically shows the engine's best move for the
  /// current player. Runs after every move without costing a star.
  Future<void> _autoShowHint() async {
    if (_game.isGameOver || !mounted) return;
    // In computer mode only hint when it's the human's (black's) turn.
    if (widget.isComputerMode && !_game.isBlackTurn) return;
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted || _game.isGameOver) return;
    if (widget.isComputerMode && !_game.isBlackTurn) return;
    final forColor = _game.isBlackTurn ? 1 : 2;
    final move = await GoAIService.getBestMove(
      board: _game.board.board,
      boardSize: widget.boardSize,
      player: forColor,
      difficulty: widget.aiDifficulty,
    );
    if (!mounted) return;
    if (move == null || move.length < 2) return;
    setState(() => _hintCell = move);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      if (_hintCell?[0] == move[0] && _hintCell?[1] == move[1]) {
        setState(() => _hintCell = null);
      }
    });
  }

  /// Stars earned: fixed at 1 in Practice Mode, otherwise 3 minus hints used.
  int get _starsEarned => widget.practiceMode
      ? 1
      : (_maxHints - _hintsUsed).clamp(0, _maxHints).toInt();

  /// Shows a confirm dialog then resigns the active player's game.
  /// Works in both vs-AI and local two-player modes.
  Future<void> _confirmResign() async {
    if (_game.isGameOver || _isAiThinking) return;
    final resigningColor = _game.isBlackTurn ? 1 : 2;
    final l = AppLocalizations.of(context);
    final content = widget.isComputerMode
        ? l.resignConfirmBot
        : l.resignConfirmLocal(resigningColor == 1 ? l.black : l.white);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.resignTitle),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.resign),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _game.resignAs(resigningColor));
    Future.microtask(() {
      if (mounted) _showGameOverDialog();
    });
  }

  /// Open [AnalysisScreen] for the just-saved match. Cloud analysis is not
  /// yet enabled; the screen shows a "coming soon" placeholder.
  void _openAnalysis() {
    if (_savedMatchId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(matchId: _savedMatchId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final forceLight = AppSettings.forceLightThemeInGame;
    final title = widget.isComputerMode
        ? '${l.vsComputer} (${widget.aiDifficulty.label})'
        : 'GO ${widget.boardSize}×${widget.boardSize}';

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
          if (widget.practiceMode)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PRACTICE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
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
            if (_showingGameOver) _buildGameOverOverlay(),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).aiThinking,
                style: const TextStyle(color: Colors.white, fontSize: 13),
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
                  hintCell: _hintCell,
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
                  hintCell: _hintCell,
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
                  hintCell: _hintCell,
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
    final l = AppLocalizations.of(context);
    final score = _game.getScore();
    final defaultName = widget.isComputerMode ? l.computer : l.white;
    final defaultRank = widget.isComputerMode
        ? widget.aiDifficulty.label
        : null;
    return PlayerPanel(
      color: 2,
      name: widget.opponentName ?? defaultName,
      rank: widget.opponentRank ?? defaultRank,
      avatarPath: widget.opponentAvatarPath,
      captures: (score['white']['captured'] as int?) ?? 0,
      isActive: !_game.isBlackTurn && !_game.isGameOver,
      isDarkBackground: _isEffectiveDark(),
      isThinking: widget.isComputerMode && _isAiThinking,
    );
  }

  Widget _buildPlayerPanel() {
    final score = _game.getScore();
    final user = context.watch<UserService>().currentUser;
    final rawName = user?.displayName;
    final playerName = (rawName == null || rawName == 'Player')
        ? AppLocalizations.of(context).you
        : rawName;
    return PlayerPanel(
      color: 1,
      name: playerName,
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
          Text(AppLocalizations.of(context).score, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          _buildScoreRow(AppLocalizations.of(context).black, score['black']),
          const SizedBox(height: 4),
          _buildScoreRow(AppLocalizations.of(context).white, score['white']),
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
    final isMyTurn = !widget.isComputerMode || _game.isBlackTurn;
    final canHint =
        !_game.isGameOver &&
        !_isAiThinking &&
        !_hintLoading &&
        isMyTurn &&
        (widget.practiceMode || _hintsUsed < _maxHints);
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
        // Hint button — shows the engine's best move, costs 1 ★ per use.
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: canHint ? Colors.amber.shade700 : null,
              ),
              if (_hintsUsed > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_maxHints - _hintsUsed}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: canHint ? _useHint : null,
          tooltip: _hintsUsed >= _maxHints
              ? AppLocalizations.of(context).noHintsRemaining
              : AppLocalizations.of(context).showBestMove,
        ),
        // Resign button — available in every mode, gives the other side the win.
        IconButton(
          icon: const Icon(Icons.flag),
          color: (!_isAiThinking && !_game.isGameOver) ? Colors.red : null,
          onPressed: (!_isAiThinking && !_game.isGameOver)
              ? _confirmResign
              : null,
          tooltip: AppLocalizations.of(context).resign,
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
    final l = AppLocalizations.of(context);
    final resigned = _game.resignedColor;
    if (resigned == 1) return l.whiteWinsByResignation;
    if (resigned == 2) return l.blackWinsByResignation;
    final blackTotal = score['black']['total'] as int;
    final whiteTotal = score['white']['total'] as int;
    if (blackTotal > whiteTotal) {
      return l.blackWinsByPoints(blackTotal - whiteTotal);
    } else if (whiteTotal > blackTotal) {
      return l.whiteWinsByPoints(whiteTotal - blackTotal);
    } else {
      return l.gameTied;
    }
  }

  /// Records the result and shows the chess.com-style overlay. Called from
  /// every game-end path: two-pass, no-legal-moves, and resign.
  void _showGameOverDialog() {
    _maybeRecordResult();
    // Outcome sounds + haptics, mirroring chess.com's win/lose chimes.
    final humanWon = _didHumanWin();
    SfxService.instance.play(
      humanWon == true ? SfxSound.lessonComplete : SfxSound.wrong,
    );
    setState(() => _showingGameOver = true);
  }

  /// True if the human (always black) won, false if they lost, null on a tie.
  bool? _didHumanWin() {
    final resigned = _game.resignedColor;
    if (resigned == 1) return false;
    if (resigned == 2) return true;
    final score = _game.getScore();
    final b = score['black']['total'] as int;
    final w = score['white']['total'] as int;
    if (b == w) return null;
    return b > w;
  }

  Widget _buildGameOverOverlay() {
    final score = _game.getScore();
    final outcome = _getWinnerText(score);
    final humanWon = _didHumanWin();
    final stars = _starsEarned;
    final isBot = widget.isComputerMode;

    // Canned opponent line keyed off the result. Pulls from the bot's own
    // taunts when we have a BotProfile (Phase C); falls back to generic copy
    // for legacy entry points (Play menu → Computer with no profile).
    final BotEvent event;
    if (_game.resignedColor == 1) {
      // Human (black) resigned.
      event = BotEvent.resign;
    } else if (humanWon == true) {
      // Bot lost on the board.
      event = BotEvent.lose;
    } else if (humanWon == false) {
      event = BotEvent.win;
    } else {
      event = BotEvent.greet;
    }
    final botLine =
        widget.botProfile?.taunt(event) ??
        (humanWon == true
            ? 'Good game! You earned that one.'
            : humanWon == false
            ? (_game.resignedColor == 1
                  ? 'Thanks for the game!'
                  : 'Nicely played — better luck next time!')
            : 'A close one!');

    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, t, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.55 * t.clamp(0.0, 1.0)),
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 0.5 + 0.5 * t.clamp(0.0, 1.0),
              child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
            ),
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hero outcome line — green/red/amber by result.
                      Text(
                        outcome,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: humanWon == true
                              ? Colors.green.shade600
                              : humanWon == false
                                  ? Colors.red.shade600
                                  : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bot avatar row with speech bubble.
                      if (isBot) _buildBotResultRow(botLine),
                      if (isBot) const SizedBox(height: 18),
                      // 3-star rating (chess.com casual feel).
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 38,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      if (widget.practiceMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school,
                                size: 13,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Practice Mode',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          _hintsUsed == 0
                              ? AppLocalizations.of(context).noHintsUsed
                              : AppLocalizations.of(context).hintsUsed(
                                  _hintsUsed,
                                ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Score breakdown.
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isEffectiveDark()
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _buildScoreRow(AppLocalizations.of(context).black, score['black']),
                            const Divider(height: 14),
                            _buildScoreRow(AppLocalizations.of(context).white, score['white']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Primary CTA — Game Review.
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openAnalysis,
                          icon: const Icon(Icons.analytics),
                          label: Text(AppLocalizations.of(context).gameReview),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetGame,
                              icon: const Icon(Icons.refresh),
                              label: Text(AppLocalizations.of(context).rematch),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() => _showingGameOver = false);
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(AppLocalizations.of(context).close),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Brand mark in the footer corner.
                      Align(
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: 0.55,
                          child: GokoLogo(size: 18, showWordmark: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotResultRow(String line) {
    final avatarPath = widget.opponentAvatarPath;
    final name = widget.opponentName ?? AppLocalizations.of(context).computer;
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.15),
          backgroundImage: avatarPath != null ? AssetImage(avatarPath) : null,
          child: avatarPath == null
              ? const Icon(Icons.smart_toy, size: 28)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(line, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
