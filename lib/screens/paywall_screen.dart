import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zaibal/services/subscription_service.dart';

/// Stub paywall. Real billing (Apple/Google IAP, Stripe) will replace
/// [SubscriptionService.unlockPremium] later. The UX here is what users will
/// see end-to-end once billing is wired up.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.workspace_premium,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock GOKO Premium',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Train deeper. Review every game. Stand out.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const _FeatureRow(
                icon: Icons.all_inclusive,
                title: 'Unlimited puzzles',
                subtitle: 'Free tier limits 3 puzzles per day',
              ),
              const _FeatureRow(
                icon: Icons.auto_graph,
                title: 'Post-game analysis',
                subtitle: 'Step through every move of any finished match',
              ),
              const _FeatureRow(
                icon: Icons.workspace_premium,
                title: 'Profile flair',
                subtitle: 'Premium badges and avatar borders',
              ),
              const Spacer(),
              if (subscription.isPremium)
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('You are Premium'),
                )
              else
                FilledButton(
                  onPressed: () async {
                    await subscription.unlockPremium();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Premium unlocked!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Unlock Premium'),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Restore Purchases will be enabled with billing.',
                      ),
                    ),
                  );
                },
                child: const Text('Restore purchases'),
              ),
              const SizedBox(height: 4),
              Text(
                'Stub build — billing not yet connected.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
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
