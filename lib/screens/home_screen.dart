// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:zaibal/screens/game_board_screen.dart';
import 'package:zaibal/widgets/preview_board_painter.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({required this.onThemeToggle, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaibal - GO Game'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose Board Size',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                _buildBoardSizeButton(context, 9),
                const SizedBox(height: 16),
                _buildBoardSizeButton(context, 13),
                const SizedBox(height: 16),
                _buildBoardSizeButton(context, 19),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Card(child: Center(child: _buildPreviewBoard())),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(child: SizedBox(height: 300, child: _buildPreviewBoard())),
            const SizedBox(height: 32),
            Text(
              'Choose Board Size',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            _buildBoardSizeButton(context, 9),
            const SizedBox(height: 16),
            _buildBoardSizeButton(context, 13),
            const SizedBox(height: 16),
            _buildBoardSizeButton(context, 19),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBoard() {
    return Builder(
      builder: (context) => AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: PreviewBoardPainter(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardSizeButton(BuildContext context, int size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 60),
          padding: const EdgeInsets.all(16),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameBoardScreen(boardSize: size),
            ),
          );
        },
        child: Text(
          '$size x $size',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}