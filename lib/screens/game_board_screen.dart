// lib/screens/game_board_screen.dart

import 'package:flutter/material.dart';
import 'package:zaibal/models/game.dart';
import 'package:zaibal/widgets/game_board.dart';

class GameBoardScreen extends StatefulWidget {
  final int boardSize;

  const GameBoardScreen({required this.boardSize, super.key});

  @override
  _GameBoardScreenState createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late Game _game;

  @override
  void initState() {
    super.initState();
    _game = Game(widget.boardSize);
  }

  void _onTapBoard(int i, int j) {
    setState(() {
      _game.playTurn(i, j);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Получаем ширину экрана
    final double screenWidth = MediaQuery.of(context).size.width;
    // Определяем максимальный размер для доски, оставляя отступы
    final double boardSize = screenWidth * 0.9; // 90% от ширины экрана

    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра Го'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ограничиваем размер доски
            SizedBox(
              width: boardSize,
              height: boardSize,
              child: GameBoard(
                board: _game.board.board,
                onTap: _onTapBoard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}