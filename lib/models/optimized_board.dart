import 'dart:collection';
import 'dart:typed_data';

class Board {
  final int size;
  late Uint8List _board;
  final List<int> _history = [];
  int _capturedByBlack = 0;
  int _capturedByWhite = 0;
  final _boardStateCache = HashMap<String, bool>();
  
  Board(this.size) {
    _board = Uint8List(size * size);
  }

  int get capturedByBlack => _capturedByBlack;
  int get capturedByWhite => _capturedByWhite;

  int getStone(int i, int j) => _board[i * size + j];
  void _setStone(int i, int j, int value) => _board[i * size + j] = value;

  List<List<int>> get board {
    return List.generate(
      size,
      (i) => List.generate(
        size,
        (j) => getStone(i, j),
      ),
    );
  }

  bool placeStone(int i, int j, int player) {
    if (i < 0 || i >= size || j < 0 || j >= size || getStone(i, j) != 0) {
      return false;
    }

    final opponent = (player == 1) ? 2 : 1;
    _setStone(i, j, player);

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
        _setStone(stone.i, stone.j, 0);
      }
      if (player == 1) {
        _capturedByBlack += capturedStones.length;
      } else {
        _capturedByWhite += capturedStones.length;
      }
    } else if (_findLiberties([_Point(i, j)]).isEmpty) {
      _setStone(i, j, 0);
      return false;
    }

    // Проверка правила Ко
    final boardHash = _getBoardHash();
    if (_boardStateCache.containsKey(boardHash)) {
      _setStone(i, j, 0);
      for (final stone in capturedStones) {
        _setStone(stone.i, stone.j, opponent);
      }
      return false;
    }

    _history.add(_getCompressedBoardState());
    _boardStateCache[boardHash] = true;
    
    if (_history.length > 8) {
      final oldState = _history.removeAt(0);
      _boardStateCache.remove(_getBoardHashFromState(oldState));
    }

    return true;
  }

  Set<_Point> _findLiberties(List<_Point> group) {
    final liberties = <_Point>{};
    final player = getStone(group[0].i, group[0].j);
    final visited = <_Point>{};
    
    for (final stone in group) {
      visited.add(stone);
      final neighbors = _getAdjacentPoints(stone.i, stone.j);
      
      for (final neighbor in neighbors) {
        final neighborValue = getStone(neighbor.i, neighbor.j);
        if (neighborValue == 0) {
          liberties.add(neighbor);
        } else if (neighborValue == player && !visited.contains(neighbor)) {
          visited.add(neighbor);
          group.add(neighbor);
        }
      }
    }
    
    return liberties;
  }

  List<List<_Point>> _getNeighborGroups(int i, int j, int player) {
    final groups = <List<_Point>>[];
    final visited = <_Point>{};
    
    for (final neighbor in _getAdjacentPoints(i, j)) {
      if (getStone(neighbor.i, neighbor.j) == player && !visited.contains(neighbor)) {
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
      if (getStone(neighbor.i, neighbor.j) == player && !visited.contains(neighbor)) {
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

  String _getBoardHash() {
    final buffer = StringBuffer();
    for (var i = 0; i < size * size; i++) {
      buffer.write(_board[i]);
    }
    return buffer.toString();
  }

  String _getBoardHashFromState(int state) {
    final buffer = StringBuffer();
    var remaining = state;
    for (var i = 0; i < size * size; i++) {
      buffer.write(remaining % 3);
      remaining ~/= 3;
    }
    return buffer.toString();
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
