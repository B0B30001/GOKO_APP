# Setting Up OAuth with GitHub Pages

## Quick Setup

### 1. Enable GitHub Pages for this repo

1. Go to your GitHub repo: https://github.com/B0B30001/zaibal_app
2. Click **Settings** → **Pages**
3. Under "Source", select **main** branch and **/docs** folder
4. Click **Save**
5. Wait a few minutes for deployment

Your callback URL will be:
```
https://b0b30001.github.io/zaibal_app/oauth2callback.html
```

### 2. Update OGS App Settings

1. Go to: https://online-go.com/oauth2/applications/registered/
2. Edit your app
3. Change **Redirect URI** to:
   ```
   https://b0b30001.github.io/zaibal_app/oauth2callback.html
   ```
4. Save changes

### 3. Commit and Push

```bash
git add docs/oauth2callback.html
git commit -m "Add OAuth callback page"
git push origin main
```

### 4. Test the Flow

1. Run app: `flutter run`
2. Tap "Sign in with OGS"
3. Login on OGS website
4. OGS redirects to GitHub Pages → which redirects back to your app!

---

## How It Works

```
User taps login 
  → Opens OGS login in browser
  → User logs in
  → OGS redirects to: https://b0b30001.github.io/zaibal_app/oauth2callback.html?code=ABC123
  → HTML page extracts code
  → Page redirects to: zaibalgo://oauth2callback?code=ABC123
  → App intercepts deep link
  → App exchanges code for token
  → Success!
```

---

## Alternative: Skip OAuth (Simpler)

If OAuth is too complex, you can:

1. **Use local games only** (vs Local / vs AI)
2. **Add OGS integration later** when you have users
3. **Focus on puzzles and learning** first

The app works great without OGS! All the puzzles and local gameplay are ready.

---

## Files Created

- `docs/oauth2callback.html` - Handles the OAuth redirect
- This file explains the setup

Push these to GitHub and enable Pages!
