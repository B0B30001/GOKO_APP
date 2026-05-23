# RevenueCat + Google Play Setup Guide (Kazakhstan-aware)

Step-by-step instructions to turn the existing GOKO paywall stub into a real
in-app subscription flow that accepts Kazakh card payments and pays out to a
Kazakhstan bank account.

The app code is already wired — only external setup is required to ship.

---

## TL;DR

1. **Google Play Console** ($25 one-time) → create app + subscription product
   (`goko_premium_monthly`, $4.99/mo, 7-day free trial).
2. **RevenueCat** (free until $2.5K MRR) → create project, paste your Google
   Play product ID, create `premium` entitlement, paste API key.
3. Replace `YOUR_REVENUECAT_ANDROID_API_KEY` in
   [lib/services/iap_service.dart](../lib/services/iap_service.dart) line 22.
4. Upload to internal test track and verify purchase flow on a real device.

**Will it work in Kazakhstan?** Yes — Google Play is fully supported in KZ,
RevenueCat is hosted in US/EU and validates Google receipts regardless of buyer
country, and Google Play has been making developer payouts to KZ bank accounts
since August 2023.

---

## A. Google Play Console (~1 hour)

### A.1 Developer account
1. Go to https://play.google.com/console and sign in with a Google account.
2. Pay **$25 one-time** developer registration fee.
   - **Card:** Kaspi Gold, Halyk Visa/MC, and most KZ-issued international cards work.
   - **Personal** account opens fastest (~24h). **Company** account needs DUNS
     verification and takes 1–4 weeks but lets you list "GOKO LLP" instead of
     your name.
3. Verify identity (passport or IIN-bound ID).

### A.2 Merchant (Payments) account
Required to receive money. **Skip if you only test internally.**

1. In Play Console → Setup → Payments profile → Create payments profile.
2. Select **Kazakhstan** as country (officially supported since Aug 2023).
3. Provide:
   - Business name (or "Sole proprietor — your name" for individual)
   - Address in Kazakhstan
   - Tax ID: **IIN** (12 digits) for individual; **BIN** for ИП/ТОО
   - Bank: **Kaspi**, **Halyk**, or **Forte** — they're the most-tested
     for receiving Google payouts in KZ
   - IBAN: KZ + 18 digits (your account's IBAN, ask your bank's app)
   - SWIFT/BIC: e.g. CASPKZKA (Kaspi), HSBKKZKX (Halyk)

### A.3 Create app + subscription product
1. **Create app** → fill metadata (name, description, screenshots — at least
   2 phone screenshots required).
2. **Monetization → Products → Subscriptions → Create**:
   - **Product ID:** `goko_premium_monthly` (cannot change later — type carefully)
   - **Name:** GOKO Premium (shown in Play Store)
   - **Description:** Unlimited puzzles, all bots, all lessons, premium flair
   - **Base plan ID:** `monthly`
   - **Billing period:** P1M (1 month)
   - **Price:** $4.99 USD → Google auto-converts to ≈ 2 290 ₸. You can override
     to a clean 1 990 ₸ for psychological pricing if you want.
   - **Free trial offer:** 7 days
   - **Grace period:** 7 days (when a renewal fails)
   - **Account hold:** 30 days
3. **Activate** the product. It takes ~2 hours to propagate.

### A.4 Internal testing
1. **Testing → Internal testing → Create new release**.
2. Upload the signed App Bundle from `flutter build appbundle`.
3. Add your own Gmail to the tester list.
4. Open the testing-track URL → install → tap "Unlock Premium" → real
   Play Store sheet appears (in test mode, no real charge).

---

## B. RevenueCat dashboard (~30 min)

### B.1 Account + project
1. Sign up free at https://app.revenuecat.com.
2. **Create Project** → "GOKO".
3. **Add app** → choose **Android Native** (Flutter uses the native Android binding under the hood).
4. Upload the **Service Account JSON** from Google Cloud Console — RevenueCat needs this to validate Google receipts server-side. Instructions are inline in the RC dashboard.

### B.2 API key
1. **Project Settings → API Keys**.
2. Copy the **Android (Google Play)** *public* key. Looks like `goog_…`.
   - **Do NOT use the secret server key** — public key is what the app uses.

### B.3 Product, entitlement, offering
1. **Products → New →** paste Google Play product ID `goko_premium_monthly`.
2. **Entitlements → New →** name it `premium` (must match the constant
   `_entitlementId = 'premium'` in [lib/services/iap_service.dart](../lib/services/iap_service.dart) line 8).
3. Attach the product to the entitlement.
4. **Offerings → Default → Add Package →** select `goko_premium_monthly`,
   set display name "Monthly Premium".

---

## C. Wire the app code

1. Open [lib/services/iap_service.dart](../lib/services/iap_service.dart) line 22:
   ```dart
   const String _androidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
   ```
   Replace with the key from step B.2 (e.g. `goog_XYZxyz…`).
2. Rebuild: `flutter build appbundle --release`.
3. Upload the new bundle to the internal-test track in Play Console.
4. Install on a real Android device with a tester Gmail signed in.
5. Open the app → Settings → Premium → tap "Unlock Premium":
   - You should see Google's official purchase sheet
   - "Free trial — 7 days then ₸2,290 / month" subtitle
   - Tap Subscribe → no charge (test track) but the entitlement flips to active
   - The app sees `subscription.isPremium == true` and shows the gold chip.

---

## D. Kazakhstan-specific FAQs

### Will Kazakh users be able to pay?
Yes. Google Play accepts:
- **Kaspi Gold** (Visa/MC) — most common
- **Halyk Bank** debit/credit Visa/MC
- **ForteBank**, **Eurasian Bank** cards
- Google Play balance (top up via Kaspi/Halyk)
- **Google Play gift cards** (sold in Kazpost branches)
- **Tenge (KZT)** is the default display currency

Apple Pay is irrelevant for Android-only launch.

### Will I be able to receive money?
Yes. Google Play Merchant has supported KZ developer payouts since **August 2023**.
- **Frequency:** monthly, if balance > $100 USD
- **Currency:** USD → your KZ bank converts at the interbank rate at receipt
- **Wire fee:** Halyk/Kaspi typically charge ~$15–30 SWIFT incoming fee
- **Best banks** for receiving Google payouts in KZ (based on developer reports):
  - **Halyk Bank** — smooth USD reception, decent FX
  - **Kaspi Bank** — easiest UI, slightly worse FX on conversion
  - **Forte Bank** — good for IP/ТОО entities

### What about taxes?
This is general advice — **consult a KZ accountant before launch**.
- **Individual selling on Play Store:** treated as foreign-service income.
  Tax = standard rate on declared income. File annually.
- **ИП (Sole Proprietor) on simplified regime:** 3% on revenue or 1% with
  reduced declarations. Most efficient at low scale.
- **ТОО (LLP):** 10% CIT + dividends — more overhead, makes sense above ~$50k/yr.
- **VAT (НДС):** Apps sold via Google Play are zero-rated (Google handles VAT
  collection in the buyer's country on your behalf).

### What does RevenueCat actually do?
- Server-side validation of every Google Play receipt (forgery protection).
- Cross-device entitlement sync (if user reinstalls, they don't lose Premium).
- Dashboard for MRR, churn, trial conversion — way better than raw Play Console.
- Free up to **$2,500 MRR**; then 1% of revenue above that.

### What about iOS later?
The same RevenueCat project lets you add an iOS app later. Apple has its own
$99/yr developer fee. Apple Developer accounts in KZ are supported. The
purchases_flutter package + IapService already abstract over both stores —
just create an iOS product in App Store Connect, paste it into RevenueCat,
add `Platform.isIOS` branch in iap_service.dart, ship.

---

## E. Production launch checklist

Once internal testing works end-to-end:

- [ ] Add **privacy policy** URL in Play Console (required for subscriptions —
      use a generic Flutter privacy-policy generator if you don't have one)
- [ ] Add **terms of service** URL
- [ ] Fill **content rating** questionnaire (GOKO = E for Everyone)
- [ ] Add **store listing assets**: hi-res icon (512×512), feature graphic
      (1024×500), 2+ phone screenshots, optional video
- [ ] Set **target audience** (Age 13+)
- [ ] Submit for review → **3–7 day** approval (first-time apps get extra scrutiny)
- [ ] After approval: promote internal track → **production** rollout
- [ ] Monitor first day in RevenueCat dashboard for purchase errors

---

## Quick references

- RevenueCat docs: https://www.revenuecat.com/docs/getting-started/installation/flutter
- Google Play subscriptions guide: https://support.google.com/googleplay/android-developer/answer/140504
- Country availability map: https://support.google.com/googleplay/android-developer/answer/9306917
- KZ payouts announcement (Aug 2023): https://support.google.com/googleplay/android-developer/answer/13577024
