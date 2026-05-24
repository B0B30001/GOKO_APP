import 'package:flutter/material.dart';

/// Panda coach character with a speech bubble.
///
/// Used in two places per design:
///  - Above the Puzzle Streak card on the hub (intro tip rotation).
///  - On the puzzle-solve flash overlay (reactive praise).
///
/// Animates in via a scale + fade entry. Optionally auto-hides after
/// [autoHide]. Tapping anywhere on the bubble dismisses early.
class CoachSpeech extends StatefulWidget {
  /// Text shown inside the speech bubble.
  final String message;

  /// Callback when the bubble is dismissed (auto or by tap). Optional.
  final VoidCallback? onDismiss;

  /// Set to null to disable auto-hide. Defaults to 6 seconds.
  final Duration? autoHide;

  /// Compact variant — smaller avatar + bubble, used inside dialogs/overlays.
  final bool compact;

  const CoachSpeech({
    super.key,
    required this.message,
    this.onDismiss,
    this.autoHide = const Duration(seconds: 6),
    this.compact = false,
  });

  @override
  State<CoachSpeech> createState() => _CoachSpeechState();
}

class _CoachSpeechState extends State<CoachSpeech>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
    final hide = widget.autoHide;
    if (hide != null) {
      Future.delayed(hide, _dismiss);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    await _ctrl.reverse();
    if (!mounted) return;
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarSize = widget.compact ? 32.0 : 44.0;
    final bubblePadding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 10);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _dismiss,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Panda avatar — circular, white border so it pops on any bg.
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/avatars/panda.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            // Speech bubble with tail pointing at the panda.
            Flexible(
              child: CustomPaint(
                painter: _BubbleTailPainter(color: cs.surfaceContainerHighest),
                child: Container(
                  padding: bubblePadding,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: widget.compact ? 12.5 : 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the small triangular tail that connects the speech bubble to the
/// panda avatar.
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  const _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height / 2 - 6)
      ..lineTo(8, size.height / 2)
      ..lineTo(0, size.height / 2 + 6)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color;
}
