import 'package:flutter/material.dart';
import '../models/tutorial.dart';
import '../models/app_settings.dart';
import '../widgets/fast_game_board.dart';

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

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  TutorialStep get _step => widget.tutorial.steps[_stepIndex];
  bool get _isLast => _stepIndex == widget.tutorial.steps.length - 1;
  bool get _isFirst => _stepIndex == 0;

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
                'Step ${_stepIndex + 1} of $total',
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
        board: _step.board,
        onTap: _step.interactive ? _handleInteractiveTap : (_, __) {},
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
        Text(
          _step.body,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        if (_step.interactive)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'Interactive — tap the board',
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
          'Source: ${widget.tutorial.source}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Prev'),
            onPressed: _isFirst ? null : _goPrev,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(_isLast ? Icons.check : Icons.arrow_forward),
            label: Text(_isLast ? 'Done' : 'Next'),
            onPressed: _goNext,
          ),
        ),
      ],
    );
  }

  void _goPrev() {
    setState(() {
      _stepIndex--;
      _wrongHint = null;
    });
  }

  void _goNext() {
    if (_isLast) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _stepIndex++;
      _wrongHint = null;
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
