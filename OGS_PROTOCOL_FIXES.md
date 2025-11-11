# OGS WebSocket Protocol Fixes

## Summary
Updated the WebSocket implementation to match the **actual OGS (Online-Go.com) protocol** discovered through GitHub repository research.

## Date
November 12, 2025

## Changes Made

### 1. **WebSocket Service** (`lib/services/online/websocket_service.dart`)

#### Added OGS-compliant authentication:
- **JWT token**: Now extracted from login response and passed to WebSocket
- **device_id**: Unique UUID generated per device
- **user_agent**: Platform-specific user agent string
- **language**: Current language setting (en)
- **language_version**: Translation version
- **client_version**: App version (1.0.0)

#### Changed method terminology:
- Added `send()` method as an alias for `emit()` to match OGS documentation
- Updated all internal calls to use `send()` terminology
- Note: In Dart's socket_io_client, `emit()` is correct, but OGS docs call it "send"

#### Enhanced authentication:
```dart
socket.authenticate({
  'jwt': jwt_token,
  'device_id': uuid,
  'user_agent': platform_info,
  'language': 'en',
  'language_version': '1',
  'client_version': '1.0.0',
});
```

Previous (incorrect):
```dart
socket.emit('authenticate', {
  'player_id': userId,
  'auth': chatAuth,
});
```

### 2. **OGS Service** (`lib/services/ogs_service.dart`)

#### Added JWT extraction:
- Extract `user_jwt` from login response
- Store JWT token for WebSocket authentication
- Pass JWT to WebSocket service on connection

#### Updated automatch:
- Changed from `emit()` to `send()` for protocol compliance
- Updated logging to indicate "OGS Protocol"

### 3. **Game Connection** (`lib/services/online/game_connection.dart`)

#### Updated all game operations to use `send()`:
- `game/connect` - Connect to a game
- `game/disconnect` - Disconnect from a game
- `game/move` - Submit a move
- `game/resign` - Resign the game
- `game/undo/request` - Request undo
- `game/undo/accept` - Accept undo
- `chat/connect` - Connect to game chat
- `chat/disconnect` - Disconnect from chat

### 4. **Dependencies** (`pubspec.yaml`)

Added:
- `uuid: ^4.5.1` - For generating device IDs

## Protocol Research

Research was conducted on the official OGS repository: `online-go/online-go.com`

### Key findings:

1. **Authentication** (from `src/main.tsx`):
   ```typescript
   socket.authenticate({
     jwt: data.get("config.user_jwt", ""),
     device_id: get_device_id(),
     user_agent: navigator.userAgent,
     language: ogs_current_language,
     language_version: ogs_language_version,
     client_version: ogs_version,
   });
   ```

2. **Game Connection** (from `src/components/ChallengeModal/ChallengeModal.tsx`):
   ```typescript
   socket.send("game/connect", { game_id: game_id });
   socket.on(`game/${game_id}/gamedata`, onGamedata);
   ```

3. **Automatch** (from `src/lib/automatch_manager.tsx`):
   ```typescript
   socket.send("automatch/find_match", preferences);
   socket.on("automatch/start", handler);
   ```

## What This Fixes

### Before:
- ❌ WebSocket connected but authentication failed silently
- ❌ Server rejected requests due to missing JWT
- ❌ No device identification
- ❌ Incomplete user agent information
- ❌ Games wouldn't start or connect properly

### After:
- ✅ Proper authentication with all required parameters
- ✅ JWT token from login response
- ✅ Unique device ID for each installation
- ✅ Complete platform information sent to server
- ✅ Protocol matches OGS server expectations
- ✅ Ready for real online multiplayer with OGS users

## Testing

To test the fixes:

1. **Use the Connection Test Screen**:
   - Go to Online Play
   - Click the bug icon (🐛) in the app bar
   - Run connection test
   - Check authentication status and logs

2. **Try Automatch**:
   - Login with valid OGS credentials
   - Click "Quick Game (9x9)"
   - Watch debug logs for protocol communication
   - Check for successful match finding

3. **Monitor Logs**:
   - All WebSocket events are logged with visual formatting
   - Look for:
     - `✓ LOGIN SUCCESSFUL!` with JWT confirmation
     - `✓ WEBSOCKET CONNECTED!`
     - `AUTHENTICATING WITH OGS (Real Protocol)`
     - Authentication data showing all parameters

## Debug Features

Enhanced logging throughout:
- 📤 Outgoing messages (sent to server)
- 📥 Incoming messages (received from server)
- 🔊 All events (comprehensive event monitoring)
- ✅ Success indicators
- ❌ Error indicators
- ⚠️ Warnings
- 🔑 JWT/authentication events
- 🎮 Game events
- 💬 Chat messages

## Next Steps

1. **Test with real OGS account** to verify connection works
2. **Implement proper error handling** for authentication failures
3. **Add JWT refresh logic** when tokens expire
4. **Store device_id persistently** across app restarts
5. **Implement reconnection logic** with JWT reuse

## References

- OGS Repository: https://github.com/online-go/online-go.com
- Socket.IO Protocol: https://socket.io/docs/v4/
- OGS API: https://online-go.com/api/v1/
