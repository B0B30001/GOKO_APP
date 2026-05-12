import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/models/optimized_board.dart';
import 'package:zaibal/services/match_history_service.dart';
import 'package:zaibal/services/ai/katago_analysis_service.dart';
import 'package:zaibal/widgets/fast_game_board.dart';

/// Post-game analysis screen with Chess.com-style evaluation.
///
/// Features:
/// - Move scrubber and prev/next/start/end controls
/// - Vertical eval bar showing Black win rate
/// - Score estimate and win-rate percentage labels
/// - "Best move" highlight overlay on the board (numbered circles)
/// - Per-move quality badges (best / good / inaccuracy / mistake / blunder)
/// - Eval toggle (requires a KataGo server configured in Settings)
class AnalysisScreen extends StatefulWidget {
  final String matchId;
  const AnalysisScreen({super.key, required this.matchId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  /// Number of moves applied (0 = empty board, max = end of game).
  int _ply = 0;

  /// Whether engine analysis is turned on.
  bool _analysisEnabled = false;

  /// Whether a KataGo query is in-flight.
  bool _analysing = false;

  /// Cached evaluations keyed by ply index so scrubbing doesn't re-query.
  final Map<int, PositionEval?> _evalCache = {};

  final _service = KataGoAnalysisService();

  // ── lifecycle ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    _evalCache.clear();
    super.dispose();
  }

  // ── analysis ──────────────────────────────────────────────────────────

  Future<void> _triggerAnalysis(
    MatchRecord record,
    List<List<int>> board,
  ) async {
    if (!_analysisEnabled) return;
    if (_evalCache.containsKey(_ply)) return;
    if (!mounted) return;
    setState(() => _analysing = true);

    // Black plays odd moves (ply 1, 3, …); White plays even (2, 4, …).
    final player = (_ply % 2 == 0) ? 1 : 2;
    final eval = await _service.analyse(
      board: board,
      boardSize: record.boardSize,
      player: player,
      maxVisits: 200,
    );

    if (!mounted) return;
    setState(() {
      _evalCache[_ply] = eval;
      _analysing = false;
    });
  }

  // ── helpers ───────────────────────────────────────────────────────────

  List<List<int>> _replayTo(MatchRecord record, int ply) {
    final board = Board(record.boardSize);
    final upTo = ply.clamp(0, record.moves.length);
    for (var i = 0; i < upTo; i++) {
      final m = record.moves[i];
      if (m.row < 0 || m.col < 0) continue;
      final ok = board.placeStone(m.row, m.col, m.color);
      if (!ok) board.setStone(m.row, m.col, m.color);
    }
    return List.generate(
      record.boardSize,
      (i) => List.generate(record.boardSize, (j) => board.getStone(i, j)),
    );
  }

  MoveQuality? _moveQuality(MatchRecord record, int ply) {
    if (ply == 0 || ply > record.moves.length) return null;
    final before = _evalCache[ply - 1];
    final after = _evalCache[ply];
    if (before == null || after == null) return null;
    final player = (ply % 2 == 1) ? 1 : 2;
    return PositionEval.classify(
      evalBefore: before,
      evalAfter: after,
      playedPlayer: player,
    );
  }

  void _setPlyClamped(int newPly, MatchRecord record, List<List<int>> board) {
    final clamped = newPly.clamp(0, record.moves.length);
    setState(() => _ply = clamped);
    _triggerAnalysis(record, board);
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final history = context.read<MatchHistoryService>();
    final record = history.findById(widget.matchId);

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.gameHistory)),
        body: const Center(child: Text('Match not found.')),
      );
    }

    final board = _replayTo(record, _ply);
    final maxPly = record.moves.length;
    final eval = _evalCache[_ply];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_analysisEnabled && !_evalCache.containsKey(_ply) && !_analysing) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _triggerAnalysis(record, board),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.analysisPanelTitle}: vs ${record.opponent}'),
        centerTitle: true,
        actions: [_buildAnalysisToggle(l)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (_analysisEnabled)
                      _EvalBar(eval: eval, isLoading: _analysing),
                    if (_analysisEnabled) const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _BoardWithOverlay(
                            key: ValueKey<int>(_ply),
                            board: board,
                            boardSize: record.boardSize,
                            eval: eval,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_analysisEnabled)
                _EvalInfoRow(
                  eval: eval,
                  quality: _moveQuality(record, _ply),
                  isLoading: _analysing,
                  l: l,
                ),
              if (_analysisEnabled &&
                  AppSettings.kataGoServerUrl.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l.noServerForAnalysis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 6),
              _buildScrubber(record, board, maxPly),
              const SizedBox(height: 4),
              _buildControls(record, board, maxPly),
              const SizedBox(height: 4),
              Text(
                '${l.moves}: $_ply / $maxPly  •  ${record.boardSize}×${record.boardSize}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisToggle(AppLocalizations l) {
    return IconButton(
      icon: Icon(_analysisEnabled ? Icons.analytics : Icons.analytics_outlined),
      tooltip: _analysisEnabled ? l.analysisOff : l.analysisOn,
      onPressed: () => setState(() => _analysisEnabled = !_analysisEnabled),
    );
  }

  Widget _buildScrubber(MatchRecord record, List<List<int>> board, int maxPly) {
    return Slider(
      value: _ply.toDouble(),
      min: 0,
      max: maxPly.toDouble(),
      divisions: maxPly == 0 ? null : maxPly,
      label: _ply.toString(),
      onChanged: maxPly == 0
          ? null
          : (v) => _setPlyClamped(v.round(), record, board),
    );
  }

  Widget _buildControls(MatchRecord record, List<List<int>> board, int maxPly) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _ply == 0 ? null : () => _setPlyClamped(0, record, board),
          tooltip: 'Start',
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: _ply == 0
              ? null
              : () => _setPlyClamped(_ply - 1, record, board),
          tooltip: 'Previous move',
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: _ply >= maxPly
              ? null
              : () => _setPlyClamped(_ply + 1, record, board),
          tooltip: 'Next move',
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _ply >= maxPly
              ? null
              : () => _setPlyClamped(maxPly, record, board),
          tooltip: 'End',
        ),
      ],
    );
  }
}

// ── Eval bar ──────────────────────────────────────────────────────────────────

/// Vertical evaluation bar: dark top = Black win share, light bottom = White.
class _EvalBar extends StatelessWidget {
  final PositionEval? eval;
  final bool isLoading;

  const _EvalBar({required this.eval, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final blackFraction = eval?.blackWinRate ?? 0.5;
    return SizedBox(
      width: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: isLoading
            ? const LinearProgressIndicator()
            : Column(
                children: [
                  Expanded(
                    flex: (blackFraction * 100).round().clamp(1, 99),
                    child: Container(color: const Color(0xFF212121)),
                  ),
                  Expanded(
                    flex: ((1 - blackFraction) * 100).round().clamp(1, 99),
                    child: Container(color: const Color(0xFFF5F5F5)),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Eval info row ─────────────────────────────────────────────────────────────

/// Shows win-rate %, score estimate, and optional move-quality badge.
class _EvalInfoRow extends StatelessWidget {
  final PositionEval? eval;
  final MoveQuality? quality;
  final bool isLoading;
  final AppLocalizations l;

  const _EvalInfoRow({
    required this.eval,
    required this.quality,
    required this.isLoading,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: LinearProgressIndicator(),
      );
    }
    if (eval == null) return const SizedBox.shrink();

    final bWin = (eval!.blackWinRate * 100).toStringAsFixed(1);
    final wWin = ((1 - eval!.blackWinRate) * 100).toStringAsFixed(1);
    final scoreLabel = eval!.scoreLead >= 0
        ? 'B+${eval!.scoreLead.toStringAsFixed(1)}'
        : 'W+${(-eval!.scoreLead).toStringAsFixed(1)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          _WinChip(label: '● $bWin%', color: const Color(0xFF212121)),
          Text(scoreLabel, style: const TextStyle(fontSize: 12)),
          _WinChip(label: '○ $wWin%', color: const Color(0xFF9E9E9E)),
          if (quality != null) _QualityBadge(quality: quality!, l: l),
        ],
      ),
    );
  }
}

class _WinChip extends StatelessWidget {
  final String label;
  final Color color;
  const _WinChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final MoveQuality quality;
  final AppLocalizations l;
  const _QualityBadge({required this.quality, required this.l});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (quality) {
      MoveQuality.best => (l.moveQualityBest, const Color(0xFF4CAF50)),
      MoveQuality.good => (l.moveQualityGood, const Color(0xFF8BC34A)),
      MoveQuality.inaccuracy => (
        l.moveQualityInaccuracy,
        const Color(0xFFFFEB3B),
      ),
      MoveQuality.mistake => (l.moveQualityMistake, const Color(0xFFFF9800)),
      MoveQuality.blunder => (l.moveQualityBlunder, const Color(0xFFF44336)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Board with best-move overlay ──────────────────────────────────────────────

/// [FastGameBoard] overlaid with numbered circles at KataGo's top move candidates.
class _BoardWithOverlay extends StatelessWidget {
  final List<List<int>> board;
  final int boardSize;
  final PositionEval? eval;
  final bool isDark;

  const _BoardWithOverlay({
    required this.board,
    required this.boardSize,
    required this.eval,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FastGameBoard(
          board: board,
          onTap: (_, __) {},
          isDarkTheme: isDark,
          showCoordinates: AppSettings.showCoordinates,
        ),
        if (eval != null && eval!.topMoves.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BestMovePainter(
                  boardSize: boardSize,
                  topMoves: eval!.topMoves,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Paints translucent coloured circles at KataGo's top candidate moves.
class _BestMovePainter extends CustomPainter {
  final int boardSize;
  final List<List<int>> topMoves;

  static const _colors = [
    Color(0xCC4CAF50), // rank 1 — green
    Color(0xCCFFC107), // rank 2 — amber
    Color(0xCCFF9800), // rank 3 — orange
  ];

  const _BestMovePainter({required this.boardSize, required this.topMoves});

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 0.05;
    final boardArea = size.width * (1 - 2 * margin);
    final cellSize = boardArea / (boardSize - 1);
    final ox = size.width * margin;
    final oy = size.height * margin;

    for (var i = 0; i < topMoves.length && i < 3; i++) {
      final row = topMoves[i][0];
      final col = topMoves[i][1];
      final cx = ox + col * cellSize;
      final cy = oy + row * cellSize;

      canvas.drawCircle(
        Offset(cx, cy),
        cellSize * 0.35,
        Paint()
          ..color = _colors[i]
          ..style = PaintingStyle.fill,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_BestMovePainter old) =>
      old.boardSize != boardSize || old.topMoves != topMoves;
}
