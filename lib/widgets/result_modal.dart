import 'package:flutter/material.dart';

/// Visual style of a [ResultModal]: success, failure, or neutral game-over.
enum ResultModalKind { success, failure, info }

/// A single shared modal for "Puzzle Solved", "Try Again", and "Game Over".
/// Material 3 rounded-card dialog with an icon header, body text, and 1–3
/// actions. Replaces hand-rolled `AlertDialog`s scattered across screens.
class ResultModal extends StatelessWidget {
  final ResultModalKind kind;
  final String title;
  final String body;
  final List<ResultModalAction> actions;

  const ResultModal({
    super.key,
    required this.kind,
    required this.title,
    required this.body,
    required this.actions,
  });

  /// Convenience: shows the modal as a non-dismissible dialog. Returns
  /// whatever the chosen action's `Navigator.pop(context, value)` returns.
  static Future<T?> show<T>(
    BuildContext context, {
    required ResultModalKind kind,
    required String title,
    required String body,
    required List<ResultModalAction> actions,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => ResultModal(
        kind: kind,
        title: title,
        body: body,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = switch (kind) {
      ResultModalKind.success => Colors.green.shade500,
      ResultModalKind.failure => Colors.red.shade400,
      ResultModalKind.info => cs.primary,
    };
    final iconData = switch (kind) {
      ResultModalKind.success => Icons.check_circle_rounded,
      ResultModalKind.failure => Icons.cancel_rounded,
      ResultModalKind.info => Icons.info_rounded,
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              _ActionRow(actions: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultModalAction {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ResultModalAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });
}

class _ActionRow extends StatelessWidget {
  final List<ResultModalAction> actions;
  const _ActionRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    // Use Wrap so 3 actions on a narrow dialog flow to multiple lines.
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: actions.map((a) {
        if (a.isPrimary) {
          return ElevatedButton.icon(
            icon: a.icon != null ? Icon(a.icon, size: 18) : const SizedBox.shrink(),
            label: Text(a.label),
            onPressed: a.onPressed,
          );
        }
        return TextButton.icon(
          icon: a.icon != null ? Icon(a.icon, size: 18) : const SizedBox.shrink(),
          label: Text(a.label),
          onPressed: a.onPressed,
        );
      }).toList(),
    );
  }
}
