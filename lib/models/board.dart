import 'dart:collection';

class Board {
  final int size;
  late List<List<int>> board;
  late List<String> history;
  int _capturedByBlack = 0;
  int _capturedByWhite = 0;

  Board(this.size) {
    board = List.generate(size, (_) => List.filled(size, 0));
    history = [];
  }

  int get capturedByBlack => _capturedByBlack;
  int get capturedByWhite => _capturedByWhite;

  bool placeStone(int i, int j, int player) {
    // 1. Проверка на выход за границы
    if (i < 0 || i >= size || j < 0 || j >= size) {
      return false;
    }
    // 2. Проверка, что ячейка пуста
    if (board[i][j] != 0) {
      return false;
    }

    // Временное размещение камня для проверки правил
    int opponent = (player == 1) ? 2 : 1;
    board[i][j] = player;

    // 3. Проверка на самоубийство и захват
    bool capturesExist = false;

    List<List<int>> capturedStones = [];
    if (i > 0 && board[i - 1][j] == opponent) capturedStones.addAll(findCapturedGroup(i - 1, j));
    if (i < size - 1 && board[i + 1][j] == opponent) capturedStones.addAll(findCapturedGroup(i + 1, j));
    if (j > 0 && board[i][j - 1] == opponent) capturedStones.addAll(findCapturedGroup(i, j - 1));
    if (j < size - 1 && board[i][j + 1] == opponent) capturedStones.addAll(findCapturedGroup(i, j + 1));

    if (capturedStones.isNotEmpty) {
      capturesExist = true;
      for (var stone in capturedStones) {
        board[stone[0]][stone[1]] = 0;
      }
      // Обновляем счетчик захваченных камней
      if (player == 1) {
        _capturedByBlack += capturedStones.length;
      } else {
        _capturedByWhite += capturedStones.length;
      }
    }

    // 4. Проверка на самоубийство
    if (!capturesExist && findLiberties(i, j).isEmpty) {
      board[i][j] = 0;
      return false;
    }

    // 5. Проверка на правило Ко
    String currentBoardState = board.toString();
    if (history.contains(currentBoardState)) {
      board[i][j] = 0;
      for (var stone in capturedStones) {
        board[stone[0]][stone[1]] = opponent;
      }
      return false;
    }

    history.add(currentBoardState);

    return true;
  }

  List<List<int>> findCapturedGroup(int i, int j) {
    if (findLiberties(i, j).isEmpty) {
      return findGroup(i, j);
    }
    return [];
  }

  List<List<int>> findGroup(int i, int j) {
    int player = board[i][j];
    if (player == 0) return [];

    List<List<int>> group = [];
    Queue<List<int>> queue = Queue.from([[i, j]]);
    Set<String> visited = { '$i,$j' };

    while(queue.isNotEmpty) {
      List<int> current = queue.removeFirst();
      int ci = current[0];
      int cj = current[1];

      group.add([ci, cj]);

      if (ci > 0 && board[ci-1][cj] == player && !visited.contains('${ci-1},$cj')) {
        queue.add([ci-1, cj]);
        visited.add('${ci-1},$cj');
      }
      if (ci < size - 1 && board[ci+1][cj] == player && !visited.contains('${ci+1},$cj')) {
        queue.add([ci+1, cj]);
        visited.add('${ci+1},$cj');
      }
      if (cj > 0 && board[ci][cj-1] == player && !visited.contains('$ci,${cj-1}')) {
        queue.add([ci, cj-1]);
        visited.add('$ci,${cj-1}');
      }
      if (cj < size - 1 && board[ci][cj+1] == player && !visited.contains('$ci,${cj+1}')) {
        queue.add([ci, cj+1]);
        visited.add('$ci,${cj+1}');
      }
    }
    return group;
  }

  Set<String> findLiberties(int i, int j) {
    int player = board[i][j];
    if (player == 0) return {};

    Set<String> liberties = {};
    Queue<List<int>> queue = Queue.from([[i, j]]);
    Set<String> visited = { '$i,$j' };

    while(queue.isNotEmpty) {
      List<int> current = queue.removeFirst();
      int ci = current[0];
      int cj = current[1];

      if (ci > 0) {
        if (board[ci-1][cj] == 0) liberties.add('${ci-1},$cj');
        if (board[ci-1][cj] == player && !visited.contains('${ci-1},$cj')) {
          queue.add([ci-1, cj]);
          visited.add('${ci-1},$cj');
        }
      }
      if (ci < size - 1) {
        if (board[ci+1][cj] == 0) liberties.add('${ci+1},$cj');
        if (board[ci+1][cj] == player && !visited.contains('${ci+1},$cj')) {
          queue.add([ci+1, cj]);
          visited.add('${ci+1},$cj');
        }
      }
      if (cj > 0) {
        if (board[ci][cj-1] == 0) liberties.add('$ci,${cj-1}');
        if (board[ci][cj-1] == player && !visited.contains('$ci,${cj-1}')) {
          queue.add([ci, cj-1]);
          visited.add('$ci,${cj-1}');
        }
      }
      if (cj < size - 1) {
        if (board[ci][cj+1] == 0) liberties.add('$ci,${cj+1}');
        if (board[ci][cj+1] == player && !visited.contains('$ci,${cj+1}')) {
          queue.add([ci, cj+1]);
          visited.add('$ci,${cj+1}');
        }
      }
    }
    return liberties;
  }

  void printBoard() {
    print('  ${List.generate(size, (j) => '${(j+1).toString().padLeft(2)}').join(' ')}');
    for (int i = 0; i < size; i++) {
      String row = '${(i+1).toString().padLeft(2)} ';
      for (int j = 0; j < size; j++) {
        String stone;
        if (board[i][j] == 1) {
          stone = '●';
        } else if (board[i][j] == 2) {
          stone = '○';
        } else {
          stone = '┼';
        }
        row += '$stone  ';
      }
      print(row);
    }
  }
}