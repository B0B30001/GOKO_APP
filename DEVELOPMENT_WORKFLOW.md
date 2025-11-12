# Development Workflow & Testing Guidelines

## Pre-Change Checklist

Before making ANY code changes, follow this workflow:

### 1. **Understand the Request**
- [ ] Read and analyze the user's request thoroughly
- [ ] Identify all affected components
- [ ] List potential side effects

### 2. **Current State Analysis**
- [ ] Read current file contents (never assume)
- [ ] Check for recent changes by others
- [ ] Review related files that might be affected
- [ ] Search for similar patterns in codebase

### 3. **Impact Assessment**
- [ ] Identify all files that need changes
- [ ] List all functions/classes affected
- [ ] Consider cross-platform implications (Android/iOS/Web)
- [ ] Check for breaking changes

### 4. **Testing Plan**
- [ ] Identify what needs to be tested
- [ ] List test scenarios (happy path + edge cases)
- [ ] Check if existing tests exist
- [ ] Plan manual testing steps

### 5. **Implementation**
- [ ] Make minimal, focused changes
- [ ] Follow Flutter/Dart best practices
- [ ] Add comprehensive logging
- [ ] Include error handling

### 6. **Validation**
- [ ] Format code (`dart format`)
- [ ] Check for errors (`get_errors`)
- [ ] Run static analysis if available
- [ ] Review changes before commit

### 7. **Testing Execution**
- [ ] Run existing unit tests (if any)
- [ ] Test manually if needed
- [ ] Verify logs show expected behavior
- [ ] Test edge cases

### 8. **Documentation**
- [ ] Update relevant documentation
- [ ] Write clear commit messages
- [ ] Add inline comments for complex logic
- [ ] Update changelog if needed

---

## Testing Strategy for Online Go Game

### Unit Testing Priorities

#### 1. **Coordinate Conversion Tests**
```dart
// Test SGF encoding/decoding
test('encodeMove converts coordinates correctly', () {
  expect(encodeMove(0, 0), 'aa');
  expect(encodeMove(3, 3), 'dd');
  expect(encodeMove(18, 18), 'ss');
});

test('decodeSGF converts back correctly', () {
  expect(decodeSGF('aa'), [0, 0]);
  expect(decodeSGF('dd'), [3, 3]);
  expect(decodeSGF('ss'), [18, 18]);
});
```

#### 2. **Board State Tests**
```dart
test('board updates correctly on move', () {
  final board = createEmptyBoard(19);
  applyMove(board, 3, 3, 1);
  expect(board[3][3], 1);
});

test('board handles different formats', () {
  // Test flat array conversion
  // Test 2D array parsing
  // Test empty board initialization
});
```

#### 3. **Turn Logic Tests**
```dart
test('turn switches after move', () {
  var currentPlayer = 1;
  currentPlayer = switchTurn(currentPlayer);
  expect(currentPlayer, 2);
});

test('isMyTurn updates correctly', () {
  final myColor = 1;
  expect(isMyTurn(myColor, 1), true);
  expect(isMyTurn(myColor, 2), false);
});
```

#### 4. **Move Validation Tests**
```dart
test('validates move is on empty position', () {
  final board = createEmptyBoard(19);
  expect(canPlaceStone(board, 3, 3), true);
  
  board[3][3] = 1;
  expect(canPlaceStone(board, 3, 3), false);
});

test('validates turn ownership', () {
  expect(canMove(myColor: 1, currentPlayer: 1), true);
  expect(canMove(myColor: 1, currentPlayer: 2), false);
});
```

### Integration Testing

#### Online Game Flow
1. **Connection Test**
   - Connect to OGS
   - Authenticate
   - Join game
   - Verify game data received

2. **Move Submission Test**
   - Submit move
   - Verify server receives correct coordinates
   - Verify move appears on board
   - Verify turn switches

3. **Opponent Move Test**
   - Receive opponent move
   - Verify correct position
   - Verify correct color
   - Verify turn switches to player

4. **Synchronization Test**
   - Verify local board matches server
   - Test reconnection
   - Test state recovery

### Manual Testing Checklist

#### Before Release
- [ ] Test 9x9 board online
- [ ] Test 13x13 board online
- [ ] Test 19x19 board online
- [ ] Test as Black player
- [ ] Test as White player
- [ ] Test stone placement in all quadrants
- [ ] Test turn switching
- [ ] Test opponent move visibility
- [ ] Test reconnection
- [ ] Test pass move
- [ ] Test resign
- [ ] Test chat
- [ ] Test on Android
- [ ] Test on iOS
- [ ] Test on Web

#### Edge Cases
- [ ] Test rapid clicking (pending move protection)
- [ ] Test network interruption
- [ ] Test invalid moves
- [ ] Test placing on occupied position
- [ ] Test timeout scenarios
- [ ] Test game phase transitions

---

## Debugging Best Practices

### 1. **Comprehensive Logging**
```dart
debugPrint('🎯 [Component] Action: details');
debugPrint('   Context variable: $value');
debugPrint('   Before: $before -> After: $after');
debugPrint('✅ Success message');
debugPrint('⚠️ Warning message');
debugPrint('❌ Error message');
```

### 2. **Log Levels**
- 🎮 Game Events
- 🎯 Move Operations
- 📊 State Changes
- 🔍 Data Parsing
- 🔢 Coordinate Conversions
- ⏰ Clock/Timer Events
- 💬 Chat Messages
- 🔄 Turn Switches
- ✅ Success
- ⚠️ Warning
- ❌ Error

### 3. **Error Context**
Always include:
- What operation was being performed
- Input values
- Expected vs actual results
- Current state
- Stack trace if applicable

### 4. **Validation Logging**
```dart
debugPrint('🔍 Validating move at ($row, $col)');
debugPrint('   Board size: ${board.length}x${board[0].length}');
debugPrint('   Current value at position: ${board[row][col]}');
debugPrint('   Is my turn: $_isMyTurn');
debugPrint('   Current player: $_currentPlayer');
debugPrint('   My color: $_myColor');
```

---

## Git Workflow

### Commit Messages Format
```
<type>: <short description>

<detailed explanation>

<technical details>

<impact/result>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `test`: Adding tests
- `docs`: Documentation
- `perf`: Performance improvement
- `style`: Code style changes

### Before Committing
1. Review all changes
2. Run tests
3. Check for console errors
4. Verify formatting
5. Update documentation

---

## Performance Monitoring

### Key Metrics
- Frame rate (target: 60 FPS)
- Stone placement latency
- Network round-trip time
- Board render time
- Memory usage

### Optimization Checklist
- [ ] Use const constructors where possible
- [ ] Avoid rebuilding entire widget tree
- [ ] Use RepaintBoundary for heavy widgets
- [ ] Cache expensive computations
- [ ] Use ValueKey for widget diffing
- [ ] Profile before and after changes

---

## Code Review Checklist

Before finalizing changes:
- [ ] Code follows Dart style guide
- [ ] No hardcoded values (use constants)
- [ ] Error handling in place
- [ ] Null safety properly handled
- [ ] Logging added for debugging
- [ ] Comments explain complex logic
- [ ] No code duplication
- [ ] Performance considered
- [ ] Accessibility considered
- [ ] Cross-platform tested

---

## Emergency Rollback Plan

If changes cause critical issues:
1. Check git log for last working commit
2. Create emergency branch
3. Revert problematic commit
4. Test revert
5. Push emergency fix
6. Document what went wrong
7. Plan proper fix

---

## Continuous Improvement

After each release:
1. Review bugs reported
2. Analyze failure patterns
3. Update tests to cover gaps
4. Improve logging where needed
5. Update this document
6. Share learnings with team

---

## Quick Reference Commands

```bash
# Format code
dart format .

# Run tests
flutter test

# Check for errors
flutter analyze

# Run specific test
flutter test test/path_to_test.dart

# Run with verbose output
flutter test --reporter expanded

# Generate coverage
flutter test --coverage

# Run on device
flutter run

# Hot reload
r (in terminal)

# Hot restart
R (in terminal)

# Clear and rebuild
flutter clean && flutter pub get
```

---

## Notes

- Always assume files may have changed - read before editing
- Test on actual device, not just simulator
- Network issues are common - handle gracefully
- OGS protocol can change - stay updated
- User experience > technical perfection
- When in doubt, add more logging

---

Last Updated: 2025-11-13
