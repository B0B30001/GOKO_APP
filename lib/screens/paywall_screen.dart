import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/services/subscription_service.dart';

/// Why the user landed on the paywall. Drives a contextual banner at the top
/// so the upsell speaks to what they just tried to do.
enum PaywallReason {
  generic,
  gameReviewDailyQuota,
  puzzleDailyQuota,
  advancedBots,
  premiumLessons,
}

/// Stub paywall. Real billing (Apple/Google IAP) will replace
/// [SubscriptionService.unlockPremium] later.
class PaywallScreen extends StatelessWidget {
  final PaywallReason reason;

  const PaywallScreen({super.key, this.reason = PaywallReason.generic});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subscription = context.watch<SubscriptionService>();
    return Scaffold(
      appBar: AppBar(title: Text(l.premium)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (reason != PaywallReason.generic) _buildReasonBanner(context),
              const Icon(
                Icons.workspace_premium,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                l.unlockGokoPremium,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l.paywallTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _FeatureRow(
                icon: Icons.all_inclusive,
                title: l.unlimitedPuzzles,
                subtitle: l.freePuzzleLimit,
              ),
              _FeatureRow(
                icon: Icons.school,
                title: l.allBotsAndLessons,
                subtitle: l.allBotsAndLessonsDesc,
              ),
              _FeatureRow(
                icon: Icons.auto_graph,
                title: l.postGameAnalysis,
                subtitle: l.postGameAnalysisDesc,
              ),
              _FeatureRow(
                icon: Icons.workspace_premium,
                title: l.profileFlair,
                subtitle: l.profileFlairDesc,
              ),
              const Spacer(),
              if (subscription.isPremium)
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle),
                  label: Text(l.youArePremium),
                )
              else
                FilledButton(
                  onPressed: () async {
                    await subscription.unlockPremium();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.youArePremium)),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(l.unlockPremium),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.restorePurchases)),
                  );
                },
                child: Text(l.restorePurchases),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonBanner(BuildContext context) {
    final l = AppLocalizations.of(context);
    final String text = switch (reason) {
      PaywallReason.puzzleDailyQuota => l.puzzleDailyQuotaReached,
      PaywallReason.gameReviewDailyQuota =>
        '${l.postGameAnalysis} — ${l.postGameAnalysisDesc}',
      PaywallReason.advancedBots => l.advancedBotsLocked,
      PaywallReason.premiumLessons => l.premiumLessonsLocked,
      PaywallReason.generic => '',
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
