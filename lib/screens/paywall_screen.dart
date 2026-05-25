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

/// Premium paywall. Built around RevenueCat best-practices for mobile
/// subscription apps:
///
///   • Hard paywall — single primary CTA, no soft dismiss
///   • Three-tier pricing with the annual plan pre-selected and visually
///     anchored ("MOST POPULAR" gold border + strikethrough price)
///   • 7-day free trial badge on the annual plan
///   • Restore Purchases always visible (App Store policy)
///   • Cancel-anytime + renewal-price fine print under the CTA
///   • Soft social-proof footer
class PaywallScreen extends StatefulWidget {
  final PaywallReason reason;
  const PaywallScreen({super.key, this.reason = PaywallReason.generic});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  PremiumPlan _selected = PremiumPlan.annual;
  bool _purchasing = false;
  bool _restoring = false;

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    try {
      await context.read<SubscriptionService>().purchasePremium(_selected);
      if (!mounted) return;
      if (context.read<SubscriptionService>().isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).youArePremium)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      final restored = await context
          .read<SubscriptionService>()
          .restorePurchases();
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(restored ? l.youArePremium : l.restorePurchases),
        ),
      );
      if (restored) Navigator.pop(context);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subscription = context.watch<SubscriptionService>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Hero gradient background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFFE082),
                      const Color(0xFFFFB300).withValues(alpha: 0.18),
                      cs.surface,
                    ],
                    stops: const [0.0, 0.32, 0.55],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Close button row
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  // ── Hero ─────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x55FFB300),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 54,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.paywallHeroTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.paywallHeroTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  if (widget.reason != PaywallReason.generic) ...[
                    const SizedBox(height: 18),
                    _buildReasonBanner(context, l),
                  ],
                  const SizedBox(height: 22),
                  // ── Features ────────────────────────────────────────────
                  _FeatureRow(text: l.paywallFeatureUnlimitedPuzzles),
                  _FeatureRow(text: l.paywallFeatureAllBots),
                  _FeatureRow(text: l.paywallFeatureLessons),
                  _FeatureRow(text: l.paywallFeatureSync),
                  const SizedBox(height: 22),
                  // ── Tier cards ──────────────────────────────────────────
                  // IntrinsicHeight makes the three Expanded children match
                  // height (otherwise `crossAxisAlignment: stretch` inside a
                  // SingleChildScrollView would force infinite height).
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: _TierCard(
                            plan: PremiumPlan.monthly,
                            title: l.pricingTierMonthly,
                            priceLabel: l.pricingPerMonth(
                              PremiumPlan.monthly.fallbackPrice,
                            ),
                            selected: _selected == PremiumPlan.monthly,
                            onTap: () =>
                                setState(() => _selected = PremiumPlan.monthly),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TierCard(
                            plan: PremiumPlan.annual,
                            title: l.pricingTierAnnual,
                            priceLabel: l.pricingPerYear(
                              PremiumPlan.annual.fallbackPrice,
                            ),
                            selected: _selected == PremiumPlan.annual,
                            badge: l.pricingPopular,
                            subBadge: l.freeTrialDuration,
                            onTap: () =>
                                setState(() => _selected = PremiumPlan.annual),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TierCard(
                            plan: PremiumPlan.lifetime,
                            title: l.pricingTierLifetime,
                            priceLabel: l.pricingOnce(
                              PremiumPlan.lifetime.fallbackPrice,
                            ),
                            selected: _selected == PremiumPlan.lifetime,
                            subBadge: l.pricingBestValue,
                            onTap: () => setState(
                              () => _selected = PremiumPlan.lifetime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  // ── CTA ──────────────────────────────────────────────────
                  if (subscription.isPremium)
                    FilledButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle),
                      label: Text(l.youArePremium),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  else
                    FilledButton(
                      onPressed: _purchasing ? null : _purchase,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0x55FFB300),
                      ),
                      child: _purchasing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black87,
                              ),
                            )
                          : Text(
                              _selected == PremiumPlan.annual
                                  ? l.startFreeTrial
                                  : l.unlockPremium,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  const SizedBox(height: 10),
                  // Fine-print row: cancel-anytime + renewal price
                  Text(
                    '${l.cancelAnytime} · '
                    '${l.renewsAtPrice(_selected.fallbackPrice)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Restore + soft-dismiss
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: (_restoring || _purchasing)
                            ? null
                            : _restore,
                        child: _restoring
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l.restorePurchases),
                      ),
                      TextButton(
                        onPressed: _purchasing
                            ? null
                            : () => Navigator.maybePop(context),
                        child: Text(l.paywallContinueFree),
                      ),
                    ],
                  ),
                  // Social proof
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      l.trustedByPlayers('12,000'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonBanner(BuildContext context, AppLocalizations l) {
    final String text = switch (widget.reason) {
      PaywallReason.puzzleDailyQuota => l.puzzleDailyQuotaReached,
      PaywallReason.gameReviewDailyQuota =>
        '${l.postGameAnalysis} — ${l.postGameAnalysisDesc}',
      PaywallReason.advancedBots => l.advancedBotsLocked,
      PaywallReason.premiumLessons => l.premiumLessonsLocked,
      PaywallReason.generic => '',
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1.2),
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
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF66BB6A).withValues(alpha: 0.20),
            ),
            child: const Icon(Icons.check, color: Color(0xFF388E3C), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pricing tier card. The user taps to select one before tapping the main CTA.
class _TierCard extends StatelessWidget {
  final PremiumPlan plan;
  final String title;
  final String priceLabel;
  final bool selected;
  final String? badge;
  final String? subBadge;
  final VoidCallback onTap;

  const _TierCard({
    required this.plan,
    required this.title,
    required this.priceLabel,
    required this.selected,
    this.badge,
    this.subBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final borderColor = selected
        ? const Color(0xFFFFB300)
        : cs.outlineVariant.withValues(alpha: 0.5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF8E1)
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: selected ? 2.5 : 1.2),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0x33FFB300),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (badge != null) ...[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              title.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            // Anchor (strikethrough) price
            Text(
              plan.anchorPrice,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.45),
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Live discounted price
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                priceLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Save % pill
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF388E3C).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l.pricingSave(plan.savePercent),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            if (subBadge != null) ...[
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subBadge!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
