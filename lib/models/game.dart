import 'board.dart';

class Game {
  final int boardSize;
  late Board board;
  bool _isBlackTurn = true; // true = black, false = white
  int consecutivePasses = 0;

  Game(this.boardSize) {
    board = Board(boardSize);
  }

  bool get isBlackTurn => _isBlackTurn;

  void playTurn(int i, int j) {
    if (board.placeStone(i, j, _isBlackTurn ? 1 : 2)) {
      _switchPlayer();
      consecutivePasses = 0;
    }
  }

  void pass() {
    consecutivePasses++;
    _switchPlayer();
  }

  bool get isGameOver => consecutivePasses >= 2;

  void _switchPlayer() {
    _isBlackTurn = !_isBlackTurn;
  }

  // Подсчёт очков в стиле шахмат
  Map<String, dynamic> getScore() {
    int blackStones = 0;
    int whiteStones = 0;
    int blackTerritory = 0;
    int whiteTerritory = 0;
    int blackCaptured = board.capturedByBlack;
    int whiteCaptured = board.capturedByWhite;

    var territory = _calculateTerritory();

    // Подсчет камней и территории
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board.board[i][j] == 1) {
          blackStones++;
        } else if (board.board[i][j] == 2) {
          whiteStones++;
        }

        if (territory[i][j] == 1) {
          blackTerritory++;
        } else if (territory[i][j] == 2) {
          whiteTerritory++;
        }
      }
    }

    return {
      'black': {
        'stones': blackStones,
        'territory': blackTerritory,
        'captured': blackCaptured,
        'total': blackStones + blackTerritory + blackCaptured,
      },
      'white': {
        'stones': whiteStones,
        'territory': whiteTerritory,
        'captured': whiteCaptured,
        'total': whiteStones + whiteTerritory + whiteCaptured,
      },
      'passCount': consecutivePasses,
    };
  }

  // Определение территории
  List<List<int>> _calculateTerritory() {
    var territory = List.generate(boardSize, (_) => List.filled(boardSize, 0));

    // Находим пустые области
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board.board[i][j] == 0) {
          var area = _floodFill(i, j);
          var owner = _determineAreaOwner(area);

          // Маркируем территорию
          for (var point in area) {
            territory[point.i][point.j] = owner;
          }
        }
      }
    }

    return territory;
  }

  // Определение владельца территории
  int _determineAreaOwner(Set<Point> area) {
    var blackBorders = 0;
    var whiteBorders = 0;

    for (var point in area) {
      for (var dir in [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ]) {
        var ni = point.i + dir[0];
        var nj = point.j + dir[1];

        if (ni >= 0 && ni < boardSize && nj >= 0 && nj < boardSize) {
          if (board.board[ni][nj] == 1) blackBorders++;
          if (board.board[ni][nj] == 2) whiteBorders++;
        }
      }
    }

    if (blackBorders > whiteBorders) return 1;
    if (whiteBorders > blackBorders) return 2;
    return 0;
  }

  // Поиск связанных пустых пунктов
  Set<Point> _floodFill(int i, int j) {
    var points = <Point>{};
    var queue = <Point>[];
    queue.add(Point(i, j));

    while (queue.isNotEmpty) {
      var p = queue.removeAt(0);
      if (!points.contains(p) && board.board[p.i][p.j] == 0) {
        points.add(p);

        for (var dir in [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ]) {
          var ni = p.i + dir[0];
          var nj = p.j + dir[1];

          if (ni >= 0 && ni < boardSize && nj >= 0 && nj < boardSize) {
            queue.add(Point(ni, nj));
          }
        }
      }
    }

    return points;
  }
}

class Point {
  final int i;
  final int j;

  Point(this.i, this.j);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          i == other.i &&
          j == other.j;

  @override
  int get hashCode => i.hashCode ^ j.hashCode;
}
