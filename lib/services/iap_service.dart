import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat entitlement identifier — must match the key in your RevenueCat
/// dashboard under Entitlements.
const String _entitlementId = 'premium';

// ─────────────────────────────────────────────────────────────────────────────
// SETUP CHECKLIST (do before first Play Store submission):
//
//  1. Go to https://app.revenuecat.com → your project → API Keys
//  2. Copy the "Android (Play Store)" public SDK key
//  3. Replace _androidApiKey below with that value
//  4. Create a subscription product in Google Play Console
//     (Subscriptions → Create → e.g. goko_premium_monthly $4.99/mo)
//  5. In RevenueCat: Products → + → paste the Play Store product ID
//  6. In RevenueCat: Offerings → Default → add the product as a package
//  7. In RevenueCat: Entitlements → "premium" → attach the package
// ─────────────────────────────────────────────────────────────────────────────
const String _androidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';

/// Thin wrapper around RevenueCat `purchases_flutter`.
///
/// Initialize once at startup via [IapService.init]. Then use [purchase],
/// [restorePurchases], and [checkIsPremium] anywhere in the app.
/// All methods are safe to call before init or on web — they just return false.
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  bool _configured = false;

  /// Whether RevenueCat has been successfully initialized with a real API key.
  bool get isConfigured => _configured;

  /// Call from [main()] before [runApp()]. Idempotent. No-op on web or when
  /// the API key placeholder has not been replaced yet.
  static Future<void> init() async {
    if (kIsWeb) return;
    if (instance._configured) return;
    final apiKey = Platform.isAndroid ? _androidApiKey : _androidApiKey;
    if (apiKey.startsWith('YOUR_')) return;
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      instance._configured = true;
    } catch (_) {
      // Don't crash the app if RevenueCat initialization fails.
    }
  }

  /// Returns true when the user has an active premium entitlement.
  Future<bool> checkIsPremium() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  /// Opens the Google Play purchase sheet for the first available package.
  /// Returns true on successful purchase. Throws [PurchasesErrorCode] on error
  /// (the caller should check for [PurchasesErrorCode.purchaseCancelledError]
  /// and treat that as a silent no-op).
  Future<bool> purchase() async {
    if (!_configured) return false;
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null || current.availablePackages.isEmpty) {
      throw Exception(
        'No RevenueCat offering found — verify dashboard configuration.',
      );
    }
    final info = await Purchases.purchasePackage(
      current.availablePackages.first,
    );
    return info.entitlements.active.containsKey(_entitlementId);
  }

  /// Restores previous purchases (required by Google Play policy).
  Future<bool> restorePurchases() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }
}
