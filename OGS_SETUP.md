# OGS Integration Setup Guide

This document explains how to complete the OGS (Online-Go.com) integration for online play.

## What's Been Implemented

✅ **Core Infrastructure:**
- OGS Service layer with OAuth2 authentication
- Login screen with OGS sign-in button
- Game list screen to browse open games
- Socket.IO real-time connection setup
- Provider state management for user session

✅ **UI Flow:**
- Home → Play → "vs Online" → Login Screen
- Login → Game List (shows open games from OGS)
- Game List → Join Game → Game Board (needs connection)

## Required Setup Steps

### 1. Register Your App on OGS

1. Go to https://online-go.com/oauth2/applications/registered/
2. Log in with your OGS account (create one if needed)
3. Click "New Application"
4. Fill in:
   - **Name:** Zaibal
   - **Client type:** Public
   - **Authorization grant type:** Authorization code
   - **Redirect URIs:** `com.zaibal.app://oauth2callback`
5. Save and copy your **Client ID** and **Client Secret**

### 2. Update Your Code

Open `lib/services/ogs_service.dart` and replace:

```dart
const String ogsClientId = 'YOUR_OGS_CLIENT_ID';
const String ogsClientSecret = 'YOUR_OGS_CLIENT_SECRET';
```

With your actual credentials from step 1.

### 3. Configure Platform-Specific Settings

#### Android (android/app/src/main/AndroidManifest.xml)

Add inside the `<activity>` tag:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="com.zaibal.app"
        android:host="oauth2callback" />
</intent-filter>
```

#### iOS (ios/Runner/Info.plist)

Add before the closing `</dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.zaibal.app</string>
        </array>
    </dict>
</array>
```

### 4. Test the Flow

```powershell
flutter run
```

1. Tap "Play" → "vs Online"
2. Tap "Sign in with OGS"
3. Log in with your OGS credentials
4. You should see the game list screen

## Next Steps: Connecting Game Board to OGS

Currently, the game board (`game_board_screen.dart`) works locally. To make it work with OGS:

1. **Modify GameBoardScreen** to accept an `isOnline` parameter
2. **Listen to socket events** for opponent moves
3. **Send moves** via `OgsService.makeMove()` instead of local state
4. **Sync game state** from OGS gamedata events

Example modification needed in `game_board_screen.dart`:

```dart
void _onTapBoard(int i, int j) {
  if (_game.isGameOver) return;
  
  setState(() {
    if (_game.playTurn(i, j)) {
      // If online, send to OGS
      if (widget.isOnline && widget.gameId != null) {
        final ogsService = Provider.of<OgsService>(context, listen: false);
        ogsService.makeMove(widget.gameId!, _convertToOgsMove(i, j));
      }
      
      if (!_game.hasValidMoves()) {
        _showSnack('No legal moves available. Press Pass to continue.');
      }
    }
  });
}
```

## Troubleshooting

**"Failed to log in"**
- Check that your Client ID and Secret are correct
- Verify redirect URI matches exactly: `com.zaibal.app://oauth2callback`

**"No open games"**
- This is normal if there are no active challenges on OGS
- You can create a game on online-go.com to test

**Socket not connecting**
- Check internet connection
- OGS may require additional authentication headers
- Review console logs for error messages

## API Documentation

- **OGS REST API:** https://ogs.docs.apiary.io/
- **OGS Real-time API:** Limited public docs; use browser dev tools to inspect
- **Community Forum:** https://forums.online-go.com/

## Current Limitations

- Game creation not yet implemented (users can only join existing games)
- Real-time move sync requires additional socket event handlers
- User profile data fetched but not displayed in UI
- No offline play persistence

## Security Notes

⚠️ **Never commit your Client Secret to public repositories**
- Consider using environment variables or a secrets manager
- For production, implement backend token exchange

---

Need help? Check the OGS developer forums or review their open-source web client at:
https://github.com/online-go/online-go.com
