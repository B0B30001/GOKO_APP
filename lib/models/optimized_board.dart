import 'dart:collection';
import 'dart:typed_data';
import 'dart:math';

class Board {
  final int size;
  late Uint8List _board;
  final List<int> _history = [];
  int _capturedByBlack = 0;
  int _capturedByWhite = 0;
  final _boardStateCache = HashMap<String, bool>();
  late List<int> _zBlack; // Zobrist table entries for black stones
  late List<int> _zWhite; // Zobrist table entries for white stones
  int _zHash = 0; // Current Zobrist hash of the board

  // For potential superko extension (currently simple ko only)
  static const int _boardHashHistoryLimit = 8;

  Board(this.size) {
    _board = Uint8List(size * size);
    _initializeZobrist();
  }

  int get capturedByBlack => _capturedByBlack;
  int get capturedByWhite => _capturedByWhite;

  set capturedByBlack(int value) => _capturedByBlack = value;
  set capturedByWhite(int value) => _capturedByWhite = value;

  int getStone(int i, int j) => _board[i * size + j];
  
  /// Sets a stone directly (bypassing rule checks).
  /// Use placeStone for validated moves. This is for reconstructing board state from server data.
  void setStone(int i, int j, int value) => _setStoneHashed(i, j, value);

  bool isValidMove(int i, int j, int player) {
    if (i < 0 || i >= size || j < 0 || j >= size || getStone(i, j) != 0) {
      return false;
    }

    // Временно размещаем камень для проверки
    _setStone(i, j, player);

    // Проверяем, есть ли у группы свободы
    final hasLiberties = _findLiberties([_Point(i, j)]).isNotEmpty;

    // Если у группы нет свобод, проверяем, захватывает ли ход камни противника
    var capturesOpponent = false;
    if (!hasLiberties) {
      final opponent = (player == 1) ? 2 : 1;
      final neighborGroups = _getNeighborGroups(i, j, opponent);
      for (final group in neighborGroups) {
        if (_findLiberties(group).isEmpty) {
          capturesOpponent = true;
          break;
        }
      }
    }

    // Отменяем временное размещение камня (в isValidMove мы не учитываем Ко, т.к.
    // он корректно обрабатывается в placeStone при реальном ходе)
    _setStone(i, j, 0);

    // Достаточно проверить свободы/захват. Правило Ко будет применено при placeStone.
    return hasLiberties || capturesOpponent;
  }

  void _setStone(int i, int j, int value) => _board[i * size + j] = value;
  void _setStoneHashed(int i, int j, int value) {
    final idx = i * size + j;
    final oldVal = _board[idx];
    if (oldVal == value) return; // no change
    // Remove old value contribution
    if (oldVal == 1) {
      _zHash ^= _zBlack[idx];
    } else if (oldVal == 2) {
      _zHash ^= _zWhite[idx];
    }
    // Apply new value contribution
    if (value == 1) {
      _zHash ^= _zBlack[idx];
    } else if (value == 2) {
      _zHash ^= _zWhite[idx];
    }
    _board[idx] = value;
  }

  List<List<int>> get board {
    return List.generate(
      size,
      (i) => List.generate(size, (j) => getStone(i, j)),
    );
  }

  bool placeStone(int i, int j, int player) {
    if (i < 0 || i >= size || j < 0 || j >= size || getStone(i, j) != 0) {
      return false;
    }

    final opponent = (player == 1) ? 2 : 1;
    _setStoneHashed(i, j, player);

    // Проверяем захват и обновляем счетчики
    var capturedStones = <_Point>[];
    final neighborGroups = _getNeighborGroups(i, j, opponent);

    for (final group in neighborGroups) {
      if (_findLiberties(group).isEmpty) {
        capturedStones.addAll(group);
      }
    }

    if (capturedStones.isNotEmpty) {
      for (final stone in capturedStones) {
        _setStoneHashed(stone.i, stone.j, 0);
      }
      if (player == 1) {
        _capturedByBlack += capturedStones.length;
      } else {
        _capturedByWhite += capturedStones.length;
      }
    } else if (_findLiberties([_Point(i, j)]).isEmpty) {
      _setStoneHashed(i, j, 0);
      return false;
    }

    // Проверка правила Ко
    final boardHash = _getBoardHash();
    if (_boardStateCache.containsKey(boardHash)) {
      _setStoneHashed(i, j, 0);
      for (final stone in capturedStones) {
        _setStoneHashed(stone.i, stone.j, opponent);
      }
      return false;
    }

    _history.add(_getCompressedBoardState());
    _boardStateCache[boardHash] = true;

    if (_history.length > _boardHashHistoryLimit) {
      final oldState = _history.removeAt(0);
      _boardStateCache.remove(_getBoardHashFromState(oldState));
    }

    return true;
  }

  /// Records current board state to history for ko detection.
  /// Use this after reconstructing board from external data.
  void recordCurrentState() {
    final boardHash = _getBoardHash();
    _history.add(_getCompressedBoardState());
    _boardStateCache[boardHash] = true;

    if (_history.length > _boardHashHistoryLimit) {
      final oldState = _history.removeAt(0);
      _boardStateCache.remove(_getBoardHashFromState(oldState));
    }
  }

  /// Calculate which stones would be captured by placing a stone at (i, j).
  /// Returns a list of linear indices (r * size + c) of captured stones.
  /// Does not modify the board state.
  List<int> calculateCaptures(int i, int j, int player) {
    final opponent = (player == 1) ? 2 : 1;
    final capturedIndices = <int>[];

    // Temporarily place the stone
    _setStone(i, j, player);

    // Find all adjacent opponent groups
    final neighborGroups = _getNeighborGroups(i, j, opponent);

    // Check each group for liberties
    for (final group in neighborGroups) {
      if (_findLiberties(group).isEmpty) {
        // This group is captured
        for (final stone in group) {
          capturedIndices.add(stone.i * size + stone.j);
        }
      }
    }

    // Remove the temporary stone
    _setStone(i, j, 0);

    return capturedIndices;
  }

  Set<_Point> _findLiberties(List<_Point> group) {
    final liberties = <_Point>{};
    if (group.isEmpty) return liberties;
    final player = getStone(group[0].i, group[0].j);
    // BFS over the connected group without mutating the input list during iteration.
    final visited = <_Point>{};
    final queue = List<_Point>.from(group);

    while (queue.isNotEmpty) {
      final stone = queue.removeLast();
      if (visited.contains(stone)) continue;
      visited.add(stone);
      for (final neighbor in _getAdjacentPoints(stone.i, stone.j)) {
        final neighborValue = getStone(neighbor.i, neighbor.j);
        if (neighborValue == 0) {
          liberties.add(neighbor);
        } else if (neighborValue == player && !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    return liberties;
  }

  List<List<_Point>> _getNeighborGroups(int i, int j, int player) {
    final groups = <List<_Point>>[];
    final visited = <_Point>{};

    for (final neighbor in _getAdjacentPoints(i, j)) {
      if (getStone(neighbor.i, neighbor.j) == player &&
          !visited.contains(neighbor)) {
        final group = <_Point>[neighbor];
        visited.add(neighbor);
        groups.add(group);
        _floodFillGroup(neighbor.i, neighbor.j, player, visited, group);
      }
    }

    return groups;
  }

  void _floodFillGroup(
    int i,
    int j,
    int player,
    Set<_Point> visited,
    List<_Point> group,
  ) {
    for (final neighbor in _getAdjacentPoints(i, j)) {
      if (getStone(neighbor.i, neighbor.j) == player &&
          !visited.contains(neighbor)) {
        visited.add(neighbor);
        group.add(neighbor);
        _floodFillGroup(neighbor.i, neighbor.j, player, visited, group);
      }
    }
  }

  List<_Point> _getAdjacentPoints(int i, int j) {
    final points = <_Point>[];
    if (i > 0) points.add(_Point(i - 1, j));
    if (i < size - 1) points.add(_Point(i + 1, j));
    if (j > 0) points.add(_Point(i, j - 1));
    if (j < size - 1) points.add(_Point(i, j + 1));
    return points;
  }

  int _getCompressedBoardState() {
    var hash = 0;
    for (var i = 0; i < size * size; i++) {
      hash = hash * 3 + _board[i];
    }
    return hash;
  }

  String _getBoardHash() => _zHash.toRadixString(16);

  String _getBoardHashFromState(int state) {
    final buffer = StringBuffer();
    var remaining = state;
    for (var i = 0; i < size * size; i++) {
      buffer.write(remaining % 3);
      remaining ~/= 3;
    }
    return buffer.toString();
  }

  void _initializeZobrist() {
    final rand = Random(0xC0DEFEED); // deterministic seed for reproducibility
    _zBlack = List<int>.generate(size * size, (_) => rand.nextInt(1 << 32));
    _zWhite = List<int>.generate(size * size, (_) => rand.nextInt(1 << 32));
    _zHash = 0; // empty board hash
  }
}

class _Point {
  final int i;
  final int j;

  const _Point(this.i, this.j);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Point &&
          runtimeType == other.runtimeType &&
          i == other.i &&
          j == other.j;

  @override
  int get hashCode => i * 31 + j;
}
