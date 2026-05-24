# Why we use RevenueCat (and what it actually does)

When you asked "why do I need RevenueCat" — the short version is: it saves you from building, hosting, and maintaining a billing server. The long version follows.

## The problem RevenueCat solves

When a user taps "Subscribe" in your app, Google Play (or Apple) handles the actual money. They charge the card, deal with refunds, send tax forms, comply with local regulations. Good.

But Google doesn't tell your app whether the purchase was real, whether it's still active, whether the user got refunded yesterday, or whether they have the subscription on a different device. **You** have to figure all that out — and the way you figure it out is by talking to Google's servers from a server of your own.

So the question is never "do I need a billing server?" The question is: do you write one, or do you let RevenueCat be that server for you.

## Specifically, you need a server for these things

1. **Receipt validation (the security one)**
   The app receives a "purchase receipt" from Google after every transaction. A malicious user can forge a receipt locally and tell your app "I bought premium." The only safe check is to send that receipt to Google Play Developer API and ask "is this real?" That call must come from a trusted server — *not* the app itself, because anyone can MITM their own device. Without RevenueCat, you write this validation server, expose an endpoint, get every client to call it, and never let it go down.

2. **Cross-device entitlement sync**
   User subscribes on Android. Opens the web app. Premium features should light up immediately. The only way this works is if "premium" is stored against a user ID on a server your app trusts, and queried at startup. Without RevenueCat, that's your server. With RevenueCat, you call `Purchases.getCustomerInfo()` and it answers.

3. **Cancellation / refund detection**
   User cancels in Google Play, or asks for a refund. Google sends a webhook called a Real-Time Developer Notification (RTDN) to a URL you configured. You need a server to receive that webhook, update the user's entitlement, and serve the updated state to the app on next launch. RevenueCat receives those webhooks for you and surfaces the state change.

4. **Grace periods and billing retry**
   When a card declines, Google enters a 3-day "grace period." During that window the user should keep access, but you need to know the difference between "active" and "in grace." Encoded as a state machine in your server, or as a flag RevenueCat exposes — your choice.

5. **Multi-store unification**
   Day 1 you ship Android. Day 60 you add iOS. Day 200 you add web checkout via Stripe. Without RevenueCat each store has a different receipt format, a different validation endpoint, different webhook semantics, different refund timing. With RevenueCat all three look like one entitlement.

## Why not just trust the local receipt?

You can. People do. They get burned ~3 months in when the first crack tutorial hits Reddit and 8% of "premium users" are users who never paid. By the time you wire up server validation, the leaked entitlement is in the SharedPreferences of thousands of installs and you can't claw it back.

This is the single most common shipped-too-quickly billing mistake. The cost of doing it right at launch is a $0 RevenueCat account; the cost of doing it later is a public reputation hit + days of customer-support emails to angry legitimate users whose entitlements got reset.

## What RevenueCat costs

- **Free** below $2,500 MRR (about ~500 paying users at $5/mo).
- **1% of revenue** above that. So if you hit $10K MRR you pay $100/mo. If you hit $100K MRR you pay $1000/mo.
- At those revenue levels, you'd otherwise be paying a billing-ops engineer $10-20K/mo. Math is clear.

## How it's wired in this app today

- `lib/services/iap_service.dart` line 22 holds the API key. Currently `'YOUR_REVENUECAT_ANDROID_API_KEY'` — a placeholder.
- `lib/services/subscription_service.dart` checks `IapService.instance.isConfigured`. If the key is still the placeholder, it falls back to a **local stub** — a fake "purchase succeeded" path that flips a SharedPreferences flag. This lets you develop and test the UX without setting up RevenueCat at all.
- When you're ready for real billing, see [`REVENUECAT_SETUP.md`](REVENUECAT_SETUP.md) — that walks through the dashboard signup, Google Play store config, and replacing the placeholder.

So today the codepath is:

```
User taps Subscribe
  → SubscriptionService.purchasePremium()
    → IapService.isConfigured?
      → no  → _stubUnlockPremium() (dev: local flag)
      → yes → Purchases.purchasePackage() (prod: Google Play sheet → RevenueCat validates → entitlement set)
```

The app code never knows or cares which path ran. Same UI either way.

## "Can I just delete RevenueCat and roll my own?"

Yes. You'd need:

- A server (Cloud Function, Firebase, or VPS).
- An `/api/validate-receipt` endpoint that takes the receipt + user_id, calls Google Play Developer API, stores entitlements in your DB.
- A `/api/webhook/google` endpoint that receives RTDN events, parses them, updates entitlements.
- A `/api/is-premium?user_id=X` endpoint the app polls on launch.
- A retry queue for webhook failures.
- Auth so users can't query each others' entitlements.
- Monitoring + alerting for when Google rotates their API.

200-500 lines of server code. A database. Hosting. Backups. On-call rotation if something breaks at 3 AM. Tax-relevant audit logs for 7 years.

OR you paste a key into `iap_service.dart` and let RevenueCat handle the above. Your call — both are valid. This app picks RevenueCat because the breakeven for an indie game shipping in 2026 doesn't favour DIY billing infrastructure.
