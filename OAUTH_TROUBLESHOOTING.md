# OAuth Login Troubleshooting Guide

## Current Status
You're seeing "Failed to log in. Please try again." This means the OAuth flow isn't completing properly.

## ✅ **What You MUST Do First**

### 1. **Enable GitHub Pages** (CRITICAL - THIS IS PROBABLY THE ISSUE!)

Your OAuth callback page is at `https://b0b30001.github.io/zaibal_app/oauth2callback.html` but GitHub Pages might not be enabled yet!

**Steps:**
1. Go to: https://github.com/B0B30001/zaibal_app/settings/pages
2. Under "Source", select: **Deploy from a branch**
3. Under "Branch", select: **main** branch and **/docs** folder
4. Click **Save**
5. Wait 2-5 minutes for deployment

**Test it works:**
- Visit: https://b0b30001.github.io/zaibal_app/oauth2callback.html
- You should see "Zaibal" page with spinning loader
- If you get 404, Pages isn't deployed yet - wait longer!

### 2. **Update OGS App Settings**

1. Go to: https://online-go.com/oauth2/applications/registered/
2. Click on your "Zaibal" application
3. Make sure **Redirect URI** is EXACTLY:
   ```
   https://b0b30001.github.io/zaibal_app/oauth2callback.html
   ```
4. Click **Save**

### 3. **Commit and Push the Files**

Make sure the callback page is in your GitHub repo:
```powershell
git add docs/oauth2callback.html
git add lib/services/ogs_service.dart
git commit -m "Add OAuth callback page"
git push origin main
```

Then wait 2-5 minutes for GitHub Pages to redeploy.

---

## 🔍 **Debugging Steps**

### Step 1: Test GitHub Pages
Open in browser: https://b0b30001.github.io/zaibal_app/oauth2callback.html

**Expected**: You see the Zaibal login page
**If 404**: GitHub Pages not set up yet - go back to "What You MUST Do First"

### Step 2: Test Deep Link Manually

Run this in PowerShell while your app is open:
```powershell
adb shell am start -W -a android.intent.action.VIEW -d "zaibalgo://oauth2callback?code=test123"
```

**Expected**: App should come to foreground
**If nothing happens**: Deep linking not working - see "Deep Link Issues" below

### Step 3: Check Console Output

When you tap "Sign in with OGS", you should see:
```
Opening OAuth URL: https://online-go.com/oauth2/authorize?...
Deep link received: zaibalgo://oauth2callback?code=...
Authorization code received: ...
Exchanging code for token...
Token response status: 200
Access token received!
Login successful!
```

**Run app with logs:**
```powershell
flutter run -d "Pixel 7" --verbose
```

Look for these specific messages in the console.

---

## 🐛 **Common Issues**

### Issue 1: GitHub Pages Returns 404
**Problem**: Callback page doesn't exist yet
**Solution**: 
- Make sure `docs/oauth2callback.html` is committed to GitHub
- Enable Pages in repo settings
- Wait 5 minutes after enabling

### Issue 2: Deep Link Not Working
**Problem**: App doesn't open from browser
**Solution**: 
```powershell
# Rebuild the app after changing AndroidManifest.xml
flutter clean
flutter pub get
flutter run -d "Pixel 7"
```

### Issue 3: "Invalid redirect_uri" Error
**Problem**: OGS settings don't match code
**Solution**: 
- OGS app redirect URI: `https://b0b30001.github.io/zaibal_app/oauth2callback.html`
- Code redirect URI (in ogs_service.dart): Same as above
- They MUST match exactly (including `.html`)

### Issue 4: Token Exchange Fails
**Problem**: Status code 400 or 401 when exchanging code
**Solution**: 
- Check client_id and client_secret are correct
- Check redirect_uri matches exactly what you registered on OGS
- Authorization codes expire in 10 minutes - don't wait too long

---

## 🧪 **Manual Testing**

### Test 1: Direct OAuth Flow
1. Open browser on your phone
2. Go to: 
   ```
   https://online-go.com/oauth2/authorize?client_id=cWdZPCV6jbYUzqeWdoAGYuklXDcgLGHNSisPzRp1&redirect_uri=https://b0b30001.github.io/zaibal_app/oauth2callback.html&response_type=code&scope=read+write
   ```
3. Log in to OGS
4. After login, you should be redirected to GitHub Pages
5. The page should automatically try to open your app
6. App should open and log you in

### Test 2: Check Deep Link Setup
```powershell
# Check if intent filter is registered
adb shell pm get-app-links com.zaibal.app

# Expected output should show zaibalgo domain
```

---

## 📝 **Quick Checklist**

Before testing login again:

- [ ] GitHub Pages enabled at `/docs` folder
- [ ] `oauth2callback.html` committed and pushed
- [ ] Waited 5 minutes after enabling Pages
- [ ] Visited callback URL and see Zaibal page (not 404)
- [ ] OGS redirect URI is `https://b0b30001.github.io/zaibal_app/oauth2callback.html`
- [ ] App rebuilt after manifest changes (`flutter clean && flutter run`)
- [ ] Deep link test works (adb command above)

---

## 🎯 **Expected Full Flow**

1. **User taps "Sign in with OGS"** in app
2. **Browser opens** OGS login page
3. **User logs in** on OGS website
4. **OGS redirects** to GitHub Pages: `https://b0b30001.github.io/zaibal_app/oauth2callback.html?code=ABC123`
5. **GitHub Pages loads**, extracts code from URL
6. **JavaScript redirects** to `zaibalgo://oauth2callback?code=ABC123`
7. **Android opens app** (deep link)
8. **App receives code**, exchanges for token
9. **Success!** User logged in

If ANY step fails, the whole flow fails.

---

## 🚨 **Still Not Working?**

### Alternative 1: Skip OAuth for Now
Comment out OAuth and use guest mode:
- Play local games (vs computer or friend)
- Test puzzles and learning features
- Come back to OAuth later

### Alternative 2: Use Localhost for Testing
Only works on web, not mobile:
1. Change redirect URI to `http://localhost:8080/oauth2callback`
2. Test with: `flutter run -d chrome`
3. Won't work on phone, but proves OAuth logic works

### Alternative 3: Add More Logging
Add `debugPrint` statements everywhere in `ogs_service.dart` to see exactly where it fails.

---

## 📞 **Need More Help?**

If still stuck, provide:
1. Console output when you tap login
2. Does https://b0b30001.github.io/zaibal_app/oauth2callback.html work? (yes/no)
3. Screenshot of OGS app settings (redirect URI section)
4. Output of: `adb shell pm get-app-links com.zaibal.app`
