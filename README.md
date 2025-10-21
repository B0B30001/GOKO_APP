# Zaibal - GO Game

A modern implementation of the ancient board game GO, built with Flutter.

## Features

- Multiple board sizes (9x9, 13x13, 19x19)
- Dark/Light theme support
- Optimized rendering engine
- Responsive design for mobile and desktop
- Interactive stone placement with hover effects
- Territory calculation
- Game state management
- Coordinate display

## Technical Details

### Performance Optimizations
- Static board elements caching
- Efficient paint object reuse
- Optimized stone rendering
- Smart repaint boundary usage
- Memory-efficient data structures

### Board Features
- Dynamic board sizing
- Smooth stone placement
- Valid move highlighting
- Stone capture visualization
- Territory marking
- Hoshi points (star points)

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/zaibal_app.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/
│   ├── board.dart
│   ├── game.dart
│   └── user.dart
├── screens/
│   ├── game_board_screen.dart
│   ├── home_screen.dart
│   └── profile_screen.dart
├── widgets/
│   ├── game_board.dart
│   └── preview_board_painter.dart
└── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
