import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../models/tutorial.dart';
import '../models/app_settings.dart';
import '../widgets/fast_game_board.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import 'practice_sequence_screen.dart';

/// Step-through viewer for a single [Tutorial], chess.com-style.
///
/// Mixes three kinds of steps:
/// - **demo** — passive read-and-watch with optional animated playback
/// - **tapTarget** — user must tap a specific intersection to advance
/// - **quiz** — multiple-choice question with correct/wrong feedback
///
/// Tracks hint usage and quiz retries to compute a 1–3 star rating shown
/// in the end-of-lesson celebration overlay. Resume bookmark is persisted
/// to [ProgressService] on every advance so an unexpected exit restores
/// the user to where they left off.
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

  String? _wrongHint;

  /// Driven by [_shakeController]. ±8 px translate, 3 cycles.
  late final AnimationController _shakeController;

  /// Drives the end-of-lesson celebration overlay (scale + fade in stars).
  late final AnimationController _celebrationController;

  /// Mutable copy of the step's board for demo animations.
  List<List<int>>? _liveBoard;

  bool _demoPlaying = false;
  bool _demoFinished = false;
  String? _demoCaption;

  // ── Quiz state for the current step ────────────────────────────────────────
  int? _quizSelected; // null until the user taps a choice
  bool _quizLocked = false; // becomes true after answering correctly

  // ── Tap-target state for the current step ──────────────────────────────────
  int _wrongTapsThisStep = 0;

  /// When the user has missed twice on the same tap-target step, surface a
  /// faint ghost stone on the correct intersection. Counts as "hint used".
  bool _showGhostHint = false;

  /// Persists across the lesson — drives the end-of-lesson star rating.
  int _totalHintsUsed = 0;
  int _totalRetries = 0;

  /// Becomes true while the celebration overlay is animating.
  bool _celebrating = false;
  int _earnedStars = 0;
  int _earnedXp = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _resetDemoForStep();
    // Defer bookmark read until after first frame so Provider lookup is safe.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferResume());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  // ── Convenience getters ────────────────────────────────────────────────────

  TutorialStep get _step => widget.tutorial.steps[_stepIndex];
  bool get _isLast => _stepIndex == widget.tutorial.steps.length - 1;
  bool get _isFirst => _stepIndex == 0;
  bool get _hasDemo => _step.demoMoves != null && _step.demoMoves!.isNotEmpty;
  bool get _isQuiz => _step.kind == TutorialStepKind.quiz;
  bool get _isTapTarget => _step.kind == TutorialStepKind.tapTarget;

  List<List<int>> get _renderBoard => _liveBoard ?? _step.board;

  // ── Step lifecycle ─────────────────────────────────────────────────────────

  void _resetDemoForStep() {
    _demoPlaying = false;
    _demoFinished = false;
    _demoCaption = null;
    _quizSelected = null;
    _quizLocked = false;
    _wrongTapsThisStep = 0;
    _showGhostHint = false;
    if (_hasDemo) {
      _liveBoard = _step.board.map((row) => List<int>.from(row)).toList();
    } else {
      _liveBoard = null;
    }
  }

  /// If the user has a saved bookmark for this lesson, ask whether to resume.
  Future<void> _maybeOfferResume() async {
    if (!mounted) return;
    final progress = context.read<ProgressService>();
    final saved = progress.getLessonBookmark(widget.tutorial.id);
    if (saved == null || saved <= 0) return;
    if (saved >= widget.tutorial.steps.length) return;
    final l = AppLocalizations.of(context);
    final choice = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.resumeLesson),
        content: Text(l.resumeLessonContent(saved + 1)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.startOver),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l.resume),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == true) {
      setState(() {
        _stepIndex = saved;
        _resetDemoForStep();
      });
    } else {
      await progress.clearLessonBookmark(widget.tutorial.id);
    }
  }

  Future<void> _playDemo() async {
    if (!_hasDemo || _demoPlaying) return;
    final moves = _step.demoMoves!;
    setState(() {
      _liveBoard = _step.board.map((row) => List<int>.from(row)).toList();
      _demoPlaying = true;
      _demoFinished = false;
      _demoCaption = null;
    });
    for (final m in moves) {
      await Future.delayed(Duration(milliseconds: m.delayMs));
      if (!mounted) return;
      SfxService.instance.play(SfxSound.stonePlace);
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

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goPrev() {
    setState(() {
      _stepIndex--;
      _wrongHint = null;
      _resetDemoForStep();
    });
    _saveBookmark();
  }

  void _goNext() {
    if (_isLast) {
      _finishLesson();
      return;
    }
    setState(() {
      _stepIndex++;
      _wrongHint = null;
      _resetDemoForStep();
    });
    _saveBookmark();
  }

  void _saveBookmark() {
    final progress = context.read<ProgressService>();
    progress.setLessonBookmark(widget.tutorial.id, _stepIndex);
  }

  // ── Finishing the lesson ──────────────────────────────────────────────────

  /// Computes 1–3 stars from accumulated hints + retries, runs the celebration
  /// overlay, awards XP, then routes to practice puzzles (if any) or pops.
  Future<void> _finishLesson() async {
    final stars = _computeStars();
    final xp = _xpForStars(stars);
    setState(() {
      _celebrating = true;
      _earnedStars = stars;
      _earnedXp = xp;
    });
    SfxService.instance.play(SfxSound.lessonComplete);
    if (AppSettings.hapticsEnabled) HapticFeedback.mediumImpact();
    _celebrationController.forward(from: 0);

    final progress = context.read<ProgressService>();
    // Award XP only on first completion. The service silently no-ops if the
    // lesson is already in completedLessons.
    await progress.markLessonCompleted(widget.tutorial.id, xpAward: xp);
    // Hold the overlay for a beat so the user enjoys it.
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final practiceIds = widget.tutorial.practicePuzzleIds;
    if (practiceIds.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeSequenceScreen(
            lessonId: widget.tutorial.id,
            lessonTitle: widget.tutorial.title,
            puzzleIds: practiceIds,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  int _computeStars() {
    // 3 stars: flawless. 2 stars: a little help. 1 star: needed a lot.
    final penalty = _totalHintsUsed + _totalRetries;
    if (penalty == 0) return 3;
    if (penalty <= 2) return 2;
    return 1;
  }

  int _xpForStars(int stars) {
    final base = widget.tutorial.xpReward;
    return switch (stars) {
      3 => base,
      2 => (base * 2 / 3).round(),
      _ => (base / 2).round(),
    };
  }

  // ── Interactive handlers ──────────────────────────────────────────────────

  /// Tap-target step: user must tap [TutorialStep.correctMove].
  void _handleInteractiveTap(int row, int col) {
    final correct = _step.correctMove;
    if (correct == null || correct.length < 2) return;
    final isRight = correct[0] == row && correct[1] == col;
    if (isRight) {
      SfxService.instance.play(SfxSound.stonePlace);
      SfxService.instance.play(SfxSound.correct);
      if (AppSettings.hapticsEnabled) HapticFeedback.lightImpact();
      setState(() {
        _flashState = 1;
        _wrongHint = null;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _flashState = 0);
        if (!_isLast) {
          _goNext();
        } else {
          _finishLesson();
        }
      });
    } else {
      SfxService.instance.play(SfxSound.wrong);
      if (AppSettings.hapticsEnabled) HapticFeedback.heavyImpact();
      _wrongTapsThisStep++;
      _totalRetries++;
      // After two wrong taps surface the ghost-stone hint.
      final shouldShowGhost = _wrongTapsThisStep >= 2 && !_showGhostHint;
      if (shouldShowGhost) {
        _totalHintsUsed++;
      }
      final l = AppLocalizations.of(context);
      setState(() {
        _flashState = 2;
        _wrongHint = _wrongTapsThisStep >= 2
            ? l.hintShownTapHint
            : l.notQuiteTapHint;
        if (shouldShowGhost) _showGhostHint = true;
      });
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 320), () {
        if (!mounted) return;
        setState(() => _flashState = 0);
      });
    }
  }

  /// Quiz step: user taps one of the choices.
  void _handleQuizAnswer(int index) {
    if (_quizLocked) return;
    final correct = _step.quizCorrectIndex;
    if (correct == null) return;
    setState(() => _quizSelected = index);
    if (index == correct) {
      SfxService.instance.play(SfxSound.correct);
      if (AppSettings.hapticsEnabled) HapticFeedback.lightImpact();
      setState(() {
        _quizLocked = true;
        _flashState = 1;
      });
      Future.delayed(const Duration(milliseconds: 320), () {
        if (!mounted) return;
        setState(() => _flashState = 0);
      });
    } else {
      SfxService.instance.play(SfxSound.wrong);
      if (AppSettings.hapticsEnabled) HapticFeedback.heavyImpact();
      _totalRetries++;
      setState(() => _flashState = 2);
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 320), () {
        if (!mounted) return;
        setState(() => _flashState = 0);
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SafeArea(child: LayoutBuilder(builder: _buildBody)),
          if (_celebrating) _buildCelebrationOverlay(),
        ],
      ),
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
    final boardArea = _isQuiz
        ? const SizedBox.shrink()
        : _buildBoard(isWide ? constraints.maxHeight - 160 : null);
    final commentary = _buildCommentary();
    final controls = _buildControls();
    if (isWide && !_isQuiz) {
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
        if (!_isQuiz)
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
        onTap: (_isTapTarget && !_demoPlaying)
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
        final t = _shakeController.value;
        final dx = 8 * (1 - t) * (t > 0 ? _shakeWave(t) : 0);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Stack(
        children: [
          sized,
          if (_showGhostHint && _step.correctMove != null)
            _buildGhostHintOverlay(),
          if (_flashState != 0) _buildFlashOverlay(),
        ],
      ),
    );
  }

  /// Faint translucent stone painted at [_step.correctMove] after two wrong
  /// taps. Uses the same coordinate math the board widget uses internally.
  Widget _buildGhostHintOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, c) {
            final size = c.maxWidth;
            const margin = 0.05;
            final n = widget.tutorial.boardSize;
            final boardArea = size * (1 - 2 * margin);
            final cell = boardArea / (n - 1);
            final ox = size * margin;
            final oy = size * margin;
            final row = _step.correctMove![0];
            final col = _step.correctMove![1];
            final cx = ox + col * cell;
            final cy = oy + row * cell;
            final stoneSize = cell * 0.85;
            return Stack(
              children: [
                Positioned(
                  left: cx - stoneSize / 2,
                  top: cy - stoneSize / 2,
                  width: stoneSize,
                  height: stoneSize,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: 0.45),
                      border: Border.all(
                        color: Colors.amber.shade700,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _shakeWave(double t) => _sinWave(2 * 3.141592653589793 * 3 * t);

  double _sinWave(double radians) {
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
        if (_hasDemo && !_isQuiz) _buildDemoButton(cs),
        if (_isTapTarget) _buildTapTargetHint(theme, cs),
        if (_isQuiz) _buildQuizPanel(theme, cs),
        if (_wrongHint != null && _isTapTarget)
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

  Widget _buildTapTargetHint(ThemeData theme, ColorScheme cs) {
    return Padding(
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
    );
  }

  /// Renders the quiz prompt + answer cards. After a correct answer, shows
  /// the explanation and unlocks "Continue".
  Widget _buildQuizPanel(ThemeData theme, ColorScheme cs) {
    final question = _step.quizQuestion ?? _step.title;
    final choices = _step.quizChoices ?? const <String>[];
    final correct = _step.quizCorrectIndex ?? -1;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final t = _shakeController.value;
          final dx = 6 * (1 - t) * (t > 0 ? _shakeWave(t) : 0);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < choices.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _QuizChoiceCard(
                  label: choices[i],
                  index: i,
                  selected: _quizSelected,
                  correctIndex: _quizLocked ? correct : null,
                  onTap: () => _handleQuizAnswer(i),
                ),
              ),
            if (_quizLocked && _step.quizExplanation != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, color: cs.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _step.quizExplanation!,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final disabled = _demoPlaying;
    final l = AppLocalizations.of(context);
    // For quiz steps, gate "Next" behind a correct answer.
    final nextEnabled = !disabled && (!_isQuiz || _quizLocked);
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
            onPressed: nextEnabled ? _goNext : null,
          ),
        ),
      ],
    );
  }

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

  /// Full-screen translucent overlay shown when the last step is reached:
  /// scale-in checkmark + stars + "+N XP" + streak chip.
  Widget _buildCelebrationOverlay() {
    final progress = context.read<ProgressService>();
    final streak = progress.streak;
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, _) {
          final t = Curves.easeOutBack.transform(
            _celebrationController.value.clamp(0.0, 1.0),
          );
          return Container(
            color: Colors.black.withValues(alpha: 0.55),
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 0.4 + 0.6 * t,
              child: Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).lessonComplete,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Icon(
                                i < _earnedStars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 36,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+$_earnedXp XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        if (streak > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.deepOrange,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context).dayStreak(streak),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Single tap card for one quiz choice. Renders with neutral / selected /
/// correct / wrong states based on the parent's locked answer.
class _QuizChoiceCard extends StatelessWidget {
  final String label;
  final int index;
  final int? selected;
  final int? correctIndex;
  final VoidCallback onTap;

  const _QuizChoiceCard({
    required this.label,
    required this.index,
    required this.selected,
    required this.correctIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selected == index;
    // Once the quiz is locked, mark the correct answer green and the user's
    // wrong selection (if any) red.
    final locked = correctIndex != null;
    final isCorrect = locked && index == correctIndex;
    final isWrong = locked && isSelected && index != correctIndex;

    Color borderColor;
    Color background;
    IconData? trailing;
    Color? trailingColor;
    if (isCorrect) {
      borderColor = Colors.green;
      background = Colors.green.withValues(alpha: 0.10);
      trailing = Icons.check_circle;
      trailingColor = Colors.green;
    } else if (isWrong) {
      borderColor = Colors.red;
      background = Colors.red.withValues(alpha: 0.10);
      trailing = Icons.cancel;
      trailingColor = Colors.red;
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      background = theme.colorScheme.primary.withValues(alpha: 0.08);
      trailing = null;
    } else {
      borderColor = theme.dividerColor;
      background = Colors.transparent;
      trailing = null;
    }
    return InkWell(
      onTap: locked ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withValues(alpha: 0.15),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: borderColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) Icon(trailing, color: trailingColor),
          ],
        ),
      ),
    );
  }
}
