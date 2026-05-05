import 'optimized_board.dart';

class Game {
  final int boardSize;
  late Board board;
  bool _isBlackTurn = true;
  int _consecutivePasses = 0;
  Map<String, dynamic>? _cachedScore;
  bool _scoreIsDirty = true;

  final List<_GameState> _history = [];
  int _currentHistoryIndex = -1;

  Game(this.boardSize) {
    board = Board(boardSize);
    _saveState();
  }

  bool get isBlackTurn => _isBlackTurn;
  bool get isGameOver => _consecutivePasses >= 2;
  bool get canUndo => _currentHistoryIndex > 0;
  bool get canRedo => _currentHistoryIndex < _history.length - 1;

  void _saveState() {
    // Если мы делаем новый ход после undo, удаляем все последующие состояния
    if (_currentHistoryIndex < _history.length - 1) {
      _history.removeRange(_currentHistoryIndex + 1, _history.length);
    }
    _history.add(_GameState.fromGame(this));
    _currentHistoryIndex = _history.length - 1;
  }

  void _restoreState(_GameState state) {
    // Single-shot snapshot restore: rebuilds Zobrist hash and resets the ko
    // window. Doing this cell-by-cell with setStone leaves the ko cache full
    // of hashes from the discarded timeline, so post-undo Ko checks become
    // unreliable.
    board.resetToSnapshot(
      state.board,
      capturedByBlack: state.capturedByBlack,
      capturedByWhite: state.capturedByWhite,
    );
    _isBlackTurn = state.isBlackTurn;
    _consecutivePasses = state.consecutivePasses;
    _scoreIsDirty = true;
    _cachedScore = null;
  }

  void undo() {
    if (canUndo) {
      _currentHistoryIndex--;
      _restoreState(_history[_currentHistoryIndex]);
    }
  }

  void redo() {
    if (canRedo) {
      _currentHistoryIndex++;
      _restoreState(_history[_currentHistoryIndex]);
    }
  }

  bool hasValidMoves() {
    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        if (board.getStone(i, j) == 0 &&
            board.isValidMove(i, j, _isBlackTurn ? 1 : 2)) {
          return true;
        }
      }
    }
    return false;
  }

  bool playTurn(int i, int j) {
    if (board.placeStone(i, j, _isBlackTurn ? 1 : 2)) {
      _switchPlayer();
      _consecutivePasses = 0;
      _scoreIsDirty = true;
      _cachedScore = null;
      _saveState();
      return true;
    }
    return false;
  }

  void pass() {
    _consecutivePasses++;
    _switchPlayer();
    _scoreIsDirty = true;
    _cachedScore = null;
    _saveState();
  }

  void _switchPlayer() {
    _isBlackTurn = !_isBlackTurn;
  }

  Map<String, dynamic> getScore() {
    if (!_scoreIsDirty && _cachedScore != null) {
      return Map<String, dynamic>.from(_cachedScore!);
    }

    var territory = _calculateTerritory();
    var score = _calculateScore(territory);
    _cachedScore = score;
    _scoreIsDirty = false;

    return score;
  }

  Map<String, dynamic> _calculateScore(List<List<int>> territory) {
    var stats = {
      'black': {'stones': 0, 'territory': 0, 'captured': board.capturedByBlack},
      'white': {'stones': 0, 'territory': 0, 'captured': board.capturedByWhite},
    };

    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        final stone = board.getStone(i, j);
        if (stone == 1) {
          stats['black']!['stones'] = stats['black']!['stones']! + 1;
        } else if (stone == 2) {
          stats['white']!['stones'] = stats['white']!['stones']! + 1;
        }

        if (territory[i][j] == 1) {
          stats['black']!['territory'] = stats['black']!['territory']! + 1;
        } else if (territory[i][j] == 2) {
          stats['white']!['territory'] = stats['white']!['territory']! + 1;
        }
      }
    }

    stats['black']!['total'] =
        stats['black']!['stones']! +
        stats['black']!['territory']! +
        stats['black']!['captured']!;
    stats['white']!['total'] =
        stats['white']!['stones']! +
        stats['white']!['territory']! +
        stats['white']!['captured']!;

    return {
      'black': Map<String, dynamic>.from(stats['black']!),
      'white': Map<String, dynamic>.from(stats['white']!),
      'passCount': _consecutivePasses,
    };
  }

  List<List<int>> _calculateTerritory() {
    var territory = List.generate(
      boardSize,
      (_) => List.filled(boardSize, 0),
      growable: false,
    );
    var visited = List.generate(
      boardSize,
      (_) => List.filled(boardSize, false),
      growable: false,
    );

    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        if (board.getStone(i, j) == 0 && !visited[i][j]) {
          var area = <_Point>{};
          var borders = {'black': 0, 'white': 0};
          _floodFillTerritory(i, j, area, borders, visited);

          var owner = 0;
          if (borders['black']! > borders['white']!) {
            owner = 1;
          } else if (borders['white']! > borders['black']!) {
            owner = 2;
          }

          for (var point in area) {
            territory[point.i][point.j] = owner;
          }
        }
      }
    }

    return territory;
  }

  void _floodFillTerritory(
    int i,
    int j,
    Set<_Point> area,
    Map<String, int> borders,
    List<List<bool>> visited,
  ) {
    if (visited[i][j]) return;
    visited[i][j] = true;

    final stone = board.getStone(i, j);
    if (stone == 0) {
      area.add(_Point(i, j));
      for (var dir in const [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ]) {
        final ni = i + dir[0];
        final nj = j + dir[1];
        if (_isValidPosition(ni, nj)) {
          if (board.getStone(ni, nj) == 1) {
            borders['black'] = borders['black']! + 1;
          } else if (board.getStone(ni, nj) == 2) {
            borders['white'] = borders['white']! + 1;
          } else {
            _floodFillTerritory(ni, nj, area, borders, visited);
          }
        }
      }
    }
  }

  bool _isValidPosition(int i, int j) {
    return i >= 0 && i < boardSize && j >= 0 && j < boardSize;
  }
}

class _GameState {
  final List<List<int>> board;
  final bool isBlackTurn;
  final int consecutivePasses;
  final int capturedByBlack;
  final int capturedByWhite;

  _GameState({
    required this.board,
    required this.isBlackTurn,
    required this.consecutivePasses,
    required this.capturedByBlack,
    required this.capturedByWhite,
  });

  factory _GameState.fromGame(Game game) {
    return _GameState(
      board: List.generate(
        game.boardSize,
        (i) => List.generate(
          game.boardSize,
          (j) => game.board.getStone(i, j),
          growable: false,
        ),
        growable: false,
      ),
      isBlackTurn: game._isBlackTurn,
      consecutivePasses: game._consecutivePasses,
      capturedByBlack: game.board.capturedByBlack,
      capturedByWhite: game.board.capturedByWhite,
    );
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
