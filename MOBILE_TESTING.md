# Testing OGS Online Features

## ⚠️ Important: Web vs Mobile OAuth2

### Why OGS Login Doesn't Work on Web

The OGS login feature **does NOT work when running on Chrome/Web** because:
- `flutter_web_auth_2` plugin uses native platform features to intercept OAuth callbacks
- Web browsers don't support custom URL schemes like `http://localhost:8080/oauth2callback`
- The OAuth flow requires platform-specific deep linking that only works on **iOS and Android**

### ✅ How to Test OGS Login on Mobile

#### Option 1: Run on Android Emulator

1. **Start an Android emulator:**
   ```powershell
   flutter emulators --launch <emulator_id>
   ```

2. **Run the app:**
   ```powershell
   flutter run
   ```
   Then select the Android device when prompted

3. **Test login:**
   - Tap "Sign in with OGS"
   - Browser will open
   - Login with your OGS account
   - App should receive the token and navigate to game list

#### Option 2: Run on Physical Android Device

1. **Enable USB debugging** on your Android phone (Settings → Developer Options)

2. **Connect phone to computer via USB**

3. **Run:**
   ```powershell
   flutter run
   ```

4. **Select your physical device** from the list

#### Option 3: Build iOS App (Mac only)

1. **Open Xcode simulator or connect iPhone**

2. **Run:**
   ```bash
   flutter run
   ```

3. **Test on iOS device/simulator**

---

## 🔧 OGS Setup Requirements

Before testing, make sure you've registered your app on OGS:

1. **Visit:** https://online-go.com/oauth2/applications/registered/

2. **Create new application with these settings:**
   - **Name:** Zaibal (or any name)
   - **Client Type:** Confidential
   - **Authorization Grant Type:** Authorization code
   - **Redirect URIs:** `https://b0b30001.github.io/zaibal_app/oauth2callback.html`
   - **Algorithm:** (leave default or select HS256)

3. **Copy your credentials:**
   - Client ID
   - Client Secret

4. **Update `lib/services/ogs_service.dart`:**
   - Already done! ✅ (credentials are in the code)

---

## 📱 Expected Behavior on Mobile

### 1. **Login Flow:**
   - User taps "Sign in with OGS"
   - → Browser opens OGS login page
   - → User enters OGS credentials
   - → OGS redirects to `zaibalgo://oauth2callback?code=...`
   - → Flutter intercepts the URL and extracts the code
   - → App exchanges code for access token
   - → User profile is fetched
   - → Navigate to game list

### 2. **Game List:**
   - Shows open games from OGS
   - Can refresh the list
   - Can join games
   - Can logout

### 3. **Real-time Features:**
   - Socket.IO connection to OGS
   - Receive opponent moves in real-time
   - Send your moves to OGS servers

---

## 🐛 Common Issues & Solutions

### Issue: "redirect_uri_mismatch"
**Solution:** Make sure the redirect URI in your OGS app settings is EXACTLY:
```
zaibalgo://oauth2callback
```
No trailing slash, no extra spaces.

### Issue: "invalid_client"
**Solution:** Double-check your Client ID and Secret in `ogs_service.dart`

### Issue: Browser doesn't redirect back to app
**Solution:** This is normal on web. Must test on mobile device.

### Issue: "No authorization code received"
**Solution:** User may have cancelled the login. Try again.

---

## 🎮 Alternative: Test Without OGS

If you want to test the app without OGS integration:

1. **Use local games instead:**
   - From Home screen → "vs Local" or "vs AI"
   - These work offline on any platform

2. **Skip login:**
   - Tap "Continue as Guest" on the login screen
   - Goes directly to home screen

---

## 📊 Current Implementation Status

✅ **Working:**
- OAuth2 login flow (mobile only)
- Token exchange
- User profile fetching
- Socket.IO connection setup
- Game list API
- Join game API
- Move sending via socket

⏳ **Needs Testing:**
- Actual OAuth flow on real device
- Real-time move reception
- Game state synchronization
- Error handling

❌ **Not Working:**
- Web browser OAuth (by design - use mobile instead)

---

## 🚀 Next Steps

1. **Test on mobile device** (recommended)
2. **Create a game on OGS website** to test joining
3. **Play against opponent** to test real-time moves
4. **Report any errors** from mobile logs

---

## 📝 Notes

- The `zaibalgo://` custom scheme works with `app_links` package
- Deep linking is configured in Android Manifest
- No need to deploy to a real domain for testing
- OGS API documentation: https://ogs.docs.apiary.io/

---

## ✨ New Features Added

### Interactive Puzzles System
- **12 total puzzles** across 4 categories:
  - ✅ Captures (4 puzzles) - Learn capturing techniques
  - ✅ Liberties (3 puzzles) - Understanding liberties and groups  
  - ✅ Life & Death (3 puzzles) - Making two eyes and killing groups
  - ✅ Ko (2 puzzles) - Understanding the Ko rule

### Puzzle Features:
- **Progressive difficulty** (1-5 stars)
- **Hints system** - tap lightbulb icon
- **Explanations** - learn why solutions work
- **Interactive board** - try your moves
- **Instant feedback** - know if you're correct
- **Reset function** - try again anytime

### How to Access Puzzles:
1. Go to **Learn** screen from home
2. Select a topic (e.g., "Captures")
3. Choose a puzzle from the list
4. Solve it by placing stones on the board!

All puzzles are designed like professional Go teaching tools (similar to Sente/OGS style)!
