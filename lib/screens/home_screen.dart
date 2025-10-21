// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:zaibal/screens/game_board_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра Го'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Выберите размер доски:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildBoardSizeButton(context, 9),
            _buildBoardSizeButton(context, 13),
            _buildBoardSizeButton(context, 19),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardSizeButton(BuildContext context, int size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Передаем выбранный размер на экран игры
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameBoardScreen(boardSize: size),
            ),
          );
        },
        child: Text('$size x $size'),
      ),
    );
  }
}