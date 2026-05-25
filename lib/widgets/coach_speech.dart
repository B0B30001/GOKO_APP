import 'dart:async';

import 'package:flutter/material.dart';

/// Panda coach character with a speech bubble.
///
/// Three flavours:
///  - Default — single message that animates in, auto-hides, tap to dismiss
///    early. Used on the hub intros and the puzzle-solve flash overlay.
///  - [CoachSpeech.sticky] — never dismisses, rotates through a message
///    list, and lets the user tap the bubble to skip to the next tip.
///    Used as the persistent header on PuzzleGardenScreen.
class CoachSpeech extends StatefulWidget {
  /// Text shown inside the speech bubble. Ignored when [messages] is set.
  final String message;

  /// Optional rotating list (sticky mode). When non-empty, [autoHide] is
  /// forced off and tapping cycles to the next message.
  final List<String> messages;

  /// Callback when the bubble is dismissed (auto or by tap). Optional.
  final VoidCallback? onDismiss;

  /// Set to null to disable auto-hide. Defaults to 6 seconds.
  final Duration? autoHide;

  /// Compact variant — smaller avatar + bubble, used inside dialogs/overlays.
  final bool compact;

  /// Interval between message rotations in sticky mode.
  final Duration rotateInterval;

  const CoachSpeech({
    super.key,
    required this.message,
    this.onDismiss,
    this.autoHide = const Duration(seconds: 6),
    this.compact = false,
  }) : messages = const [],
       rotateInterval = const Duration(seconds: 8);

  /// Persistent coach header. Cycles through [messages] every
  /// [rotateInterval]; tapping the bubble skips to the next message.
  /// Never auto-hides.
  const CoachSpeech.sticky({
    super.key,
    required this.messages,
    this.rotateInterval = const Duration(seconds: 8),
    this.compact = false,
  }) : message = '',
       autoHide = null,
       onDismiss = null;

  bool get _isSticky => messages.isNotEmpty;

  @override
  State<CoachSpeech> createState() => _CoachSpeechState();
}

class _CoachSpeechState extends State<CoachSpeech>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _dismissed = false;

  /// Index into widget.messages for sticky mode.
  int _stickyIdx = 0;
  Timer? _rotateTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
    if (widget._isSticky) {
      _rotateTimer = Timer.periodic(widget.rotateInterval, (_) => _advance());
    } else {
      final hide = widget.autoHide;
      if (hide != null) {
        Future.delayed(hide, _dismiss);
      }
    }
  }

  @override
  void dispose() {
    _rotateTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _advance() {
    if (!mounted || widget.messages.isEmpty) return;
    setState(() {
      _stickyIdx = (_stickyIdx + 1) % widget.messages.length;
    });
  }

  Future<void> _dismiss() async {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    await _ctrl.reverse();
    if (!mounted) return;
    widget.onDismiss?.call();
  }

  void _onBubbleTap() {
    if (widget._isSticky) {
      _advance();
    } else {
      _dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarSize = widget.compact ? 32.0 : 44.0;
    final bubblePadding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 10);

    final displayMessage = widget._isSticky
        ? widget.messages[_stickyIdx]
        : widget.message;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onBubbleTap,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      displayMessage,
                      key: ValueKey(displayMessage),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: widget.compact ? 12.5 : 13.5,
                        fontWeight: FontWeight.w600,
                      ),
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
