// lib/screens/auth_gate_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/login_dialog.dart';

/// Full-screen sign-in gate shown at launch when the user is not authenticated.
/// There is no guest/skip option — an OGS account is required to use the app.
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: 0.85),
                  cs.surface,
                ],
                stops: const [0.0, 0.65],
              ),
            ),
          ),

          // ── Decorative Go board lines ────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _GoPatternPainter(cs)),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.10),

                  // Logo stone
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'GO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  Text(
                    'GOKO',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Master the ancient game of Go',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                  ),

                  const Spacer(),

                  // Feature bullets
                  _FeaturePill(Icons.smart_toy_outlined,
                      'Play vs KataGo & online bots'),
                  const SizedBox(height: 10),
                  _FeaturePill(
                      Icons.school_outlined, 'Puzzles, lessons & daily drills'),
                  const SizedBox(height: 10),
                  _FeaturePill(
                      Icons.people_outline, 'Live games on Online Go Server'),

                  const SizedBox(height: 40),

                  // ── Sign in button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Sign in with OGS',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => showLoginDialog(context),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Create account button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text(
                        'Create free OGS account',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _openRegister(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Online Go Server (OGS) is free to join.\n'
                    'Your account unlocks bots, puzzles and live play.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRegister() async {
    final url = Uri.parse('https://online-go.com/register');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Small feature pill widget ─────────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Background Go board pattern painter ──────────────────────────────────────

class _GoPatternPainter extends CustomPainter {
  final ColorScheme cs;
  _GoPatternPainter(this.cs);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cs.onSurface.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const lines = 9;
    final stepX = size.width / (lines + 1);
    final stepY = size.height / (lines + 1);

    for (int i = 1; i <= lines; i++) {
      canvas.drawLine(
          Offset(stepX * i, 0), Offset(stepX * i, size.height), paint);
      canvas.drawLine(
          Offset(0, stepY * i), Offset(size.width, stepY * i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoPatternPainter old) => false;
}
