import 'board.dart';
import 'dart:io';

class Game {
  final int boardSize;
  late Board board;
  int currentPlayer = 1; // 1 = black, 2 = white

  // Счетчик пасов
  int consecutivePasses = 0;

  Game(this.boardSize) {
    board = Board(boardSize);
  }

  void playTurn(int i, int j) {
    if (board.placeStone(i, j, currentPlayer)) {
      // Здесь твоя логика для захвата камней, проверки Ко и т.д.
      // ...
      _switchPlayer(); // Переключить игрока, если ход был успешным
    } else {
      // Здесь ты можешь вывести сообщение об ошибке, если хочешь,
      // но в Flutter мы обычно отображаем это через UI.
    }
  }

  void start() {
    print('Игра Го началась! Размер доски: $boardSize x $boardSize');
    while (true) {
      board.printBoard();
      print('Ход игрока ${currentPlayer == 1 ? "Черные" : "Белые"}');
      print('Введите координаты (x,y) или "pass" для паса:');

      String? input = stdin.readLineSync()?.trim().toLowerCase();

      if (input == 'pass') {
        print('Игрок ${currentPlayer == 1 ? "Черные" : "Белые"} пасует.');
        consecutivePasses++;
        if (consecutivePasses >= 2) {
          print('Оба игрока спасовали. Игра окончена.');
          endGame();
          return;
        }
        _switchPlayer();
        continue;
      }

      var coords = input?.split(',').map(int.tryParse).toList();

      if (coords?.length != 2 || coords![0] == null || coords[1] == null) {
        print('Неверный ввод. Попробуйте еще раз.');
        continue;
      }

      int x = coords[0]! - 1;
      int y = coords[1]! - 1;

      if (board.placeStone(x, y, currentPlayer)) {
        consecutivePasses = 0;
        _switchPlayer();
      } else {
        print('Недопустимый ход! Попробуйте еще раз.');
      }
    }
  }

  void _switchPlayer() {
    currentPlayer = (currentPlayer == 1) ? 2 : 1;
  }

  void endGame() {
    // Подсчет очков и вывод победителя
    // (Логика подсчета очков здесь не реализована для краткости)
    print('Игра завершена. Победил тот, у кого больше территории и захваченных камней.');
  }
}