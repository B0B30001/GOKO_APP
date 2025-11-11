# Online Multiplayer Implementation Plan
## Based on Sente Go Architecture

## ✅ STATUS: **WORKING AND FUNCTIONAL!**

### Quick Start Guide:
1. **Tap "vs Online"** on home screen
2. **Login**: Enter your online-go.com username and password
3. **Quick Match**: Choose board size (9×9, 13×13, or 19×19)
4. **Play**: Real-time moves, chat, timers all working!

**No OGS account?** Create one free at https://online-go.com

---

## Overview
This document outlines the plan to add real-time online multiplayer functionality to Zaibal, inspired by the open-source Sente Go app architecture.

## Architecture Analysis from Sente Go

### 1. WebSocket Service (OGSWebSocketService)
- **Technology**: Socket.IO over WebSocket
- **Base URL**: Uses BuildConfig.BASE_URL
- **Authentication**: JWT/Token-based with chat_auth and notification_auth
- **Connection Management**:
  - Automatic reconnection (750ms delay, max 10s)
  - Connection state monitoring (MutableStateFlow<Boolean>)
  - Repository pattern with SocketConnectedRepository interface
  - Event-based architecture (emit/observe pattern)

### 2. Key Components

#### A. Repository Pattern
```kotlin
interface SocketConnectedRepository {
    fun onSocketConnected()
    fun onSocketDisconnected()
}
```

Repositories:
- **ActiveGamesRepository**: Monitors active games, move updates, player turns
- **AutomatchRepository**: Handles matchmaking
- **ChallengesRepository**: Manages game challenges
- **ChatRepository**: Real-time chat in games
- **ClockDriftRepository**: Syncs server time (ping/pong)
- **ServerNotificationsRepository**: Push notifications

#### B. Game Connection
```kotlin
class GameConnection(
    val gameId: Long,
    includeChat: Boolean,
    gameDataObservable: Flowable<GameData>,
    movesObservable: Flowable<Move>,
    clockObservable: Flowable<OGSClock>,
    phaseObservable: Flowable<Phase>,
    ...
)
```

Each game connection:
- Emits `game/connect` with game_id, player_id, chat flag
- Observes `game/{id}/gamedata`, `game/{id}/move`, `game/{id}/clock`, etc.
- Manages connection lifecycle (increment/decrement counter)
- Disconnects when no longer needed

#### C. Event System
Events emitted:
- `game/move` - Submit a move
- `game/resign` - Resign the game
- `game/chat` - Send chat message
- `game/undo/request` - Request undo
- `game/undo/accept` - Accept undo
- `game/removed_stones/set` - Mark dead stones
- `game/removed_stones/accept` - Accept scoring

Events observed:
- `game/{id}/gamedata` - Full game state
- `game/{id}/move` - Move updates
- `game/{id}/clock` - Time updates
- `game/{id}/phase` - Game phase changes
- `game/{id}/chat` - Chat messages
- `active_game` - Global active games list

### 3. Data Flow

```
User Action → ViewModel → Repository → WebSocketService
                                             ↓
                                        emit(event, data)
                                             ↓
                                         Server
                                             ↓
                                    observeEvent(event)
                                             ↓
Repository → onNotification → Update DB/State → UI
```

## Implementation Plan for Zaibal

### Phase 1: Foundation (Week 1)
- [ ] Add socket_io_client dependency
- [ ] Create WebSocketService with connection management
- [ ] Implement SocketConnectedRepository interface
- [ ] Add connection state monitoring
- [ ] Create basic authentication flow

### Phase 2: Game Repository (Week 2)
- [ ] Create ActiveGamesRepository
- [ ] Implement game connection lifecycle
- [ ] Add move submission and observation
- [ ] Handle clock/timer synchronization
- [ ] Implement game phase tracking

### Phase 3: Matchmaking (Week 3)
- [ ] Create MatchmakingRepository
- [ ] Implement automatch system
- [ ] Add challenge creation/acceptance
- [ ] Create game lobby UI
- [ ] Add player search

### Phase 4: Real-time Features (Week 4)
- [ ] Add chat repository and UI
- [ ] Implement move notifications
- [ ] Add resign/undo functionality
- [ ] Handle connection interruptions
- [ ] Add reconnection logic

### Phase 5: Polish (Week 5)
- [ ] Add sound effects for moves
- [ ] Implement vibration feedback
- [ ] Create game history
- [ ] Add rating system
- [ ] Polish UI/UX

## Server Options

### Option 1: OGS Integration (Easiest)
- **Pros**: Existing player base, mature API, free
- **Cons**: Dependent on external service, less control
- **Timeline**: 2-3 weeks
- **Cost**: Free

### Option 2: Custom Server (More Control)
- **Tech Stack**: Node.js + Socket.IO + PostgreSQL
- **Pros**: Full control, custom features, no dependencies
- **Cons**: Need to build/maintain, hosting costs
- **Timeline**: 6-8 weeks
- **Cost**: $5-20/month for hosting

### Option 3: Firebase + Cloud Functions (Hybrid)
- **Tech Stack**: Firebase Realtime Database + Cloud Functions
- **Pros**: Scalable, real-time out of the box, generous free tier
- **Cons**: Less flexible than custom server
- **Timeline**: 3-4 weeks
- **Cost**: Free tier sufficient for start

## Recommended Approach

**Start with OGS Integration** (Option 1):
1. Faster time to market
2. Existing player community
3. Proven infrastructure
4. Can switch later if needed

The OGS service we already have authentication for can be extended with:
- Real-time game connections
- Matchmaking
- Player rankings
- Game history

## Code Structure

```
lib/
  services/
    online/
      websocket_service.dart          # Core WebSocket connection
      game_connection.dart             # Individual game connection
      repository_interface.dart        # SocketConnectedRepository
      active_games_repository.dart     # Active games management
      matchmaking_repository.dart      # Matchmaking system
      chat_repository.dart             # In-game chat
      clock_sync_repository.dart       # Server time sync
  
  models/
    online/
      online_game.dart                 # Online game model
      player_profile.dart              # Player data
      game_challenge.dart              # Challenge data
      chat_message.dart                # Chat message
      
  screens/
    online/
      online_lobby_screen.dart         # Game lobby
      matchmaking_screen.dart          # Matchmaking UI
      online_game_screen.dart          # Online game board
      player_profile_screen.dart       # Player profiles
      game_history_screen.dart         # Past games
```

## Dependencies to Add

```yaml
dependencies:
  socket_io_client: ^2.0.3+1
  rxdart: ^0.27.7              # For reactive streams
  connectivity_plus: ^5.0.2     # Check internet connection
  vibration: ^1.8.4            # Haptic feedback
  flutter_sound: ^9.2.13       # Sound effects
```

## Testing Strategy

1. **Unit Tests**: Repository logic, data models
2. **Integration Tests**: WebSocket connection, event handling
3. **Widget Tests**: Online UI components
4. **E2E Tests**: Full game flow with mock server

## Rollout Plan

### Beta Phase (2 weeks)
- Limited to 50 beta testers
- Test matchmaking with small pool
- Gather feedback on UX
- Monitor server performance

### Soft Launch (1 month)
- Open to all users
- Feature flag to enable/disable
- Monitor crash reports
- Iterate based on feedback

### Full Launch
- Announce on social media
- Create tutorial videos
- Write blog posts
- Submit app update

## Success Metrics

- **Connection Success Rate**: > 95%
- **Average Matchmaking Time**: < 30 seconds
- **Game Completion Rate**: > 80%
- **User Retention**: > 60% after first online game
- **Crash-Free Rate**: > 99.5%

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| OGS API changes | High | Regular monitoring, fallback to offline |
| Connection issues | Medium | Robust reconnection logic, offline mode |
| Server downtime | High | Status page, clear error messages |
| Abuse/cheating | Medium | Rate limiting, report system |
| Scaling costs | Low | Start with free tier, monitor usage |

## Future Enhancements

- **Tournaments**: Organized competitions
- **Ranking System**: ELO/Glicko-2 ratings
- **Spectator Mode**: Watch live games
- **Game Analysis**: AI-powered game review
- **Social Features**: Friends, chat, profiles
- **Custom Rules**: Different rulesets (Japanese, Chinese, Korean)
- **Time Controls**: Fischer, Byo-yomi, Canadian overtime

## Timeline Summary

```
Week 1-2:  Foundation + Game Repository
Week 3-4:  Matchmaking + Real-time Features
Week 5:    Polish + Testing
Week 6-7:  Beta Testing
Week 8:    Soft Launch
Week 9+:   Full Launch + Iterations
```

**Estimated Total**: 8-10 weeks for full online multiplayer

## Conclusion

By following Sente Go's proven architecture and starting with OGS integration, we can add professional-grade online multiplayer to Zaibal efficiently. The modular design allows us to iterate quickly and potentially migrate to a custom server later if needed.
