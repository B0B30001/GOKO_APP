import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../gen/l10n/app_localizations.dart';
import '../services/ai/katago_process_service.dart';

/// Setup screen for the local KataGo process engine.
///
/// Shows the current engine status, the engines folder path (so the user
/// knows where to place files), platform-specific install instructions,
/// and a one-tap download button. Once the user has dropped the katago
/// binary and a model into the folder, [KataGoProcessService] discovers and
/// starts the engine automatically — no further configuration needed.
class AiEngineScreen extends StatelessWidget {
  const AiEngineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ChangeNotifierProvider.value(
      value: KataGoProcessService.instance,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.localEngineTitle),
          centerTitle: true,
        ),
        body: Consumer<KataGoProcessService>(
          builder: (context, service, _) =>
              _AiEngineBody(service: service),
        ),
      ),
    );
  }
}

class _AiEngineBody extends StatelessWidget {
  const _AiEngineBody({required this.service});

  final KataGoProcessService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Status card ──────────────────────────────────────────────────────
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatusDot(status: service.status),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KataGo',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel(l, service.status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _statusColor(context, service.status),
                            ),
                      ),
                      if (service.errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.errorMessage!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.error),
                        ),
                      ],
                    ],
                  ),
                ),
                if (service.status == EngineStatus.error ||
                    service.status == EngineStatus.notFound &&
                        service.isAvailable)
                  TextButton(
                    onPressed: service.restart,
                    child: Text(l.engineRestartButton),
                  ),
                if (service.status == EngineStatus.starting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Engines folder ───────────────────────────────────────────────────
        _SectionHeader(label: l.enginesFolderLabel),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.enginesDirectory ?? '(loading…)',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy path'),
                      onPressed: service.enginesDirectory == null
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(
                                  text: service.enginesDirectory!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Path copied'),
                                    duration: Duration(seconds: 2)),
                              );
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Place katago (or katago.exe) and one *.bin.gz model file in this folder.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (service.binaryPath != null)
                  _FileRow(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    label: 'Binary: ${service.binaryPath}',
                  ),
                if (service.binaryPath == null)
                  _FileRow(
                    icon: Icons.radio_button_unchecked,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    label: 'katago  (binary not found)',
                  ),
                if (service.modelPath != null)
                  _FileRow(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    label: 'Model: ${service.modelPath}',
                  ),
                if (service.modelPath == null)
                  _FileRow(
                    icon: Icons.radio_button_unchecked,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    label: '*.bin.gz  (model not found)',
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Install instructions ─────────────────────────────────────────────
        _SectionHeader(label: 'Installation guide'),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Step(
                  number: '1',
                  text:
                      'Download the KataGo binary for your platform (button below). '
                      'Choose the CPU build — no GPU required.',
                ),
                _Step(
                  number: '2',
                  text:
                      'Download a neural-network model from the same releases page. '
                      'The b18c384 network gives the strongest play; '
                      'b6c96 is smaller and faster for lower-end devices.',
                ),
                _Step(
                  number: '3',
                  text: 'Copy both files into the Engines Folder shown above. '
                      'Rename the binary to katago (or katago.exe on Windows) '
                      'if it has a different name.',
                ),
                _Step(
                  number: '4',
                  text:
                      'Restart the app. GOKO will detect the files automatically '
                      'and launch KataGo in the background — no further setup needed.',
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Android note: copy files to the engines folder via a file manager '
                  'app (the path is inside the app\'s private storage). '
                  'You can find the exact path using the Copy button above.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Download button ──────────────────────────────────────────────────
        FilledButton.icon(
          icon: const Icon(Icons.download),
          label: Text(l.downloadKataGo),
          onPressed: () => launchUrl(
            Uri.parse(
                'https://github.com/lightvector/KataGo/releases/latest'),
            mode: LaunchMode.externalApplication,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  String _statusLabel(AppLocalizations l, EngineStatus s) => switch (s) {
        EngineStatus.ready => l.engineStatusReady,
        EngineStatus.starting => l.engineStatusStarting,
        EngineStatus.notFound => l.engineStatusNotFound,
        EngineStatus.error => l.engineStatusError,
      };

  Color _statusColor(BuildContext context, EngineStatus s) {
    final cs = Theme.of(context).colorScheme;
    return switch (s) {
      EngineStatus.ready => Colors.green,
      EngineStatus.starting => cs.primary,
      EngineStatus.notFound => cs.onSurface.withValues(alpha: 0.5),
      EngineStatus.error => cs.error,
    };
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final EngineStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      EngineStatus.ready => Colors.green,
      EngineStatus.starting => Theme.of(context).colorScheme.primary,
      EngineStatus.notFound =>
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      EngineStatus.error => Theme.of(context).colorScheme.error,
    };
    if (status == EngineStatus.starting) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
