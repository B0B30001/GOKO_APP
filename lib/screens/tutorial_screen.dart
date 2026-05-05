import 'package:flutter/material.dart';
import '../models/tutorial.dart';
import '../models/app_settings.dart';
import '../widgets/fast_game_board.dart';

/// Step-through viewer for a single [Tutorial]. Each step shows a board
/// snapshot + commentary; users navigate with Prev/Next.
class TutorialScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialScreen({required this.tutorial, super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.tutorial.steps[_stepIndex];
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isLast = _stepIndex == widget.tutorial.steps.length - 1;
    final isFirst = _stepIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutorial.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final boardWidget = AspectRatio(
              aspectRatio: 1,
              child: FastGameBoard(
                board: step.board,
                onTap: (_, __) {},
                isDarkTheme: isDarkTheme,
                showCoordinates: AppSettings.showCoordinates,
              ),
            );
            final commentary = _buildCommentary(step);
            final controls = _buildControls(isFirst, isLast);

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Center(child: boardWidget)),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(child: commentary),
                          ),
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
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: boardWidget,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: commentary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: controls,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommentary(TutorialStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_stepIndex + 1} of ${widget.tutorial.steps.length}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          step.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          step.body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Source: ${widget.tutorial.source}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }

  Widget _buildControls(bool isFirst, bool isLast) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Prev'),
            onPressed: isFirst ? null : () => setState(() => _stepIndex--),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
            label: Text(isLast ? 'Done' : 'Next'),
            onPressed: () {
              if (isLast) {
                Navigator.pop(context);
              } else {
                setState(() => _stepIndex++);
              }
            },
          ),
        ),
      ],
    );
  }
}
