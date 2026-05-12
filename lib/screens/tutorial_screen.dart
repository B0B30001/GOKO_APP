import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../models/tutorial.dart';
import '../models/app_settings.dart';
import '../widgets/fast_game_board.dart';
import '../services/sfx_service.dart';

/// Step-through viewer for a single [Tutorial]. Each step shows a board
/// snapshot + commentary; users navigate with Prev/Next, or tap the board
/// when the step is interactive.
class TutorialScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialScreen({required this.tutorial, super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  int _stepIndex = 0;

  /// 0 = none, 1 = green (correct), 2 = red (wrong). Drives a 300ms overlay.
  int _flashState = 0;

  /// Hint text shown below the board after a wrong tap on an interactive step.
  String? _wrongHint;

  /// Drives a horizontal shake on wrong taps. ±8 px translate, 3 cycles.
  late final AnimationController _shakeController;

  /// Mutable copy of the step's board, used during demo playback so each
  /// placed stone re-renders without mutating the underlying [TutorialStep].
  /// Null when the current step has no demoMoves (board renders from _step.board).
  List<List<int>>? _liveBoard;

  /// Demo playback state.
  bool _demoPlaying = false;
  bool _demoFinished = false;
  String? _demoCaption;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetDemoForStep();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  TutorialStep get _step => widget.tutorial.steps[_stepIndex];
  bool get _isLast => _stepIndex == widget.tutorial.steps.length - 1;
  bool get _isFirst => _stepIndex == 0;
  bool get _hasDemo => _step.demoMoves != null && _step.demoMoves!.isNotEmpty;

  /// The board to show right now — live board during/after a demo, otherwise
  /// the step's static board.
  List<List<int>> get _renderBoard => _liveBoard ?? _step.board;

  /// Reinitialize demo state when entering a step.
  void _resetDemoForStep() {
    _demoPlaying = false;
    _demoFinished = false;
    _demoCaption = null;
    if (_hasDemo) {
      _liveBoard = _step.board.map((row) => List<int>.from(row)).toList();
    } else {
      _liveBoard = null;
    }
  }

  /// Plays the current step's demoMoves one at a time, respecting per-move
  /// delays. Updates [_liveBoard] and [_demoCaption] via setState as it goes.
  Future<void> _playDemo() async {
    if (!_hasDemo || _demoPlaying) return;
    final moves = _step.demoMoves!;
    // Restart from the step's initial state so Replay always re-runs cleanly.
    setState(() {
      _liveBoard = _step.board.map((row) => List<int>.from(row)).toList();
      _demoPlaying = true;
      _demoFinished = false;
      _demoCaption = null;
    });
    for (final m in moves) {
      await Future.delayed(Duration(milliseconds: m.delayMs));
      if (!mounted) return;
      setState(() {
        _liveBoard![m.row][m.col] = m.color;
        _demoCaption = m.caption.isEmpty ? null : m.caption;
      });
    }
    if (!mounted) return;
    setState(() {
      _demoPlaying = false;
      _demoFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(child: LayoutBuilder(builder: _buildBody)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final total = widget.tutorial.steps.length;
    final value = (_stepIndex + 1) / total;
    final l = AppLocalizations.of(context);
    return AppBar(
      title: Text(widget.tutorial.title),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.stepXofY(_stepIndex + 1, total),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth >= 720;
    final boardArea = _buildBoard(isWide ? constraints.maxHeight - 160 : null);
    final commentary = _buildCommentary();
    final controls = _buildControls();
    if (isWide) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Center(child: boardArea)),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: SingleChildScrollView(child: commentary)),
                  const SizedBox(height: 12),
                  controls,
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: boardArea),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: commentary,
          ),
        ),
        Padding(padding: const EdgeInsets.all(12), child: controls),
      ],
    );
  }

  Widget _buildBoard(double? maxSide) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final core = AspectRatio(
      aspectRatio: 1,
      child: FastGameBoard(
        board: _renderBoard,
        onTap: _step.interactive && !_demoPlaying
            ? _handleInteractiveTap
            : (_, __) {},
        isDarkTheme: isDarkTheme,
        showCoordinates: AppSettings.showCoordinates,
      ),
    );
    final sized = maxSide != null
        ? SizedBox(width: maxSide, height: maxSide, child: core)
        : core;
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // 3 cycles of ±8 px, easing out toward zero.
        final t = _shakeController.value;
        final dx = 8 * (1 - t) * (t > 0 ? _shakeWave(t) : 0);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Stack(
        children: [sized, if (_flashState != 0) _buildFlashOverlay()],
      ),
    );
  }

  /// Three-half-cycle sine wave so the board snaps left-right-left-right…
  double _shakeWave(double t) {
    // sin(2π * 3 * t) gives 3 full cycles across t∈[0,1].
    return _sinWave(2 * 3.141592653589793 * 3 * t);
  }

  double _sinWave(double radians) {
    // Tiny sin without importing dart:math — Taylor series is overkill here,
    // but `radians` can be large, so reduce mod 2π first.
    const twoPi = 2 * 3.141592653589793;
    var r = radians % twoPi;
    if (r > 3.141592653589793) r -= twoPi;
    final r3 = r * r * r;
    final r5 = r3 * r * r;
    return r - r3 / 6 + r5 / 120;
  }

  Widget _buildFlashOverlay() {
    final color = _flashState == 1 ? Colors.green : Colors.red;
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentary() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // During demo playback we replace the static body with the active move's
    // caption so the reader can follow each placement.
    final body = _demoCaption ?? _step.body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _step.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        if (_hasDemo) _buildDemoButton(cs),
        if (_step.interactive)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).interactiveTapBoard,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (_wrongHint != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _wrongHint!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          '${AppLocalizations.of(context).sourcePrefix}${widget.tutorial.source}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    final disabled = _demoPlaying;
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: Text(l.prev),
            onPressed: (_isFirst || disabled) ? null : _goPrev,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(_isLast ? Icons.check : Icons.arrow_forward),
            label: Text(_isLast ? l.done : l.next),
            onPressed: disabled ? null : _goNext,
          ),
        ),
      ],
    );
  }

  /// Play / Replay button shown when the active step carries [demoMoves].
  Widget _buildDemoButton(ColorScheme cs) {
    final l = AppLocalizations.of(context);
    final IconData icon;
    final String label;
    if (_demoPlaying) {
      icon = Icons.hourglass_top;
      label = l.playingDemo;
    } else if (_demoFinished) {
      icon = Icons.replay;
      label = l.replayDemo;
    } else {
      icon = Icons.play_arrow;
      label = l.playDemo;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: _demoPlaying ? null : _playDemo,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
          ),
        ),
      ),
    );
  }

  void _goPrev() {
    setState(() {
      _stepIndex--;
      _wrongHint = null;
      _resetDemoForStep();
    });
  }

  void _goNext() {
    if (_isLast) {
      SfxService.instance.play(SfxSound.lessonComplete);
      Navigator.pop(context);
      return;
    }
    setState(() {
      _stepIndex++;
      _wrongHint = null;
      _resetDemoForStep();
    });
  }

  /// Called when the user taps the board on an interactive step. If the tap
  /// matches [TutorialStep.correctMove] flash green and auto-advance after
  /// 600 ms; otherwise flash red, shake, and surface a hint.
  void _handleInteractiveTap(int row, int col) {
    final correct = _step.correctMove;
    if (correct == null || correct.length < 2) return;
    final isRight = correct[0] == row && correct[1] == col;
    if (isRight) {
      setState(() {
        _flashState = 1;
        _wrongHint = null;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _flashState = 0);
        if (!_isLast) _goNext();
      });
    } else {
      setState(() {
        _flashState = 2;
        _wrongHint = 'Not quite — try the marked liberty.';
      });
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 320), () {
        if (!mounted) return;
        setState(() => _flashState = 0);
      });
    }
  }
}
