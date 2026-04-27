import 'dart:math';
import 'dart:typed_data';

class MctsNode {
  final Uint8List board;
  final int boardSize;
  final int playerToMove;
  final MctsNode? parent;
  final List<int>? move; // [row, col] — null for root
  final List<MctsNode> children = [];
  int visits = 0;
  double wins = 0.0;
  // Untried moves as flat indices (r*size+c); shuffled for random expansion order.
  final List<int> _untriedMoves;

  MctsNode({
    required this.board,
    required this.boardSize,
    required this.playerToMove,
    this.parent,
    this.move,
    Random? rng,
  }) : _untriedMoves = validMoves(board, boardSize, playerToMove)
           ..shuffle(rng ?? Random());

  bool get isFullyExpanded => _untriedMoves.isEmpty;
  bool get isTerminal => children.isEmpty && _untriedMoves.isEmpty;

  double ucbScore(int parentVisits) {
    if (visits == 0) return double.infinity;
    return wins / visits + sqrt(2.0 * log(parentVisits) / visits);
  }

  MctsNode selectBestChild() =>
      children.reduce((a, b) => a.ucbScore(visits) > b.ucbScore(visits) ? a : b);

  MctsNode expand(Random rng) {
    final idx = _untriedMoves.removeLast();
    final row = idx ~/ boardSize;
    final col = idx % boardSize;
    final newBoard = applyMove(board, boardSize, row, col, playerToMove);
    final child = MctsNode(
      board: newBoard,
      boardSize: boardSize,
      playerToMove: 3 - playerToMove,
      parent: this,
      move: [row, col],
      rng: rng,
    );
    children.add(child);
    return child;
  }

  // Returns a list of valid move indices (r*size+c) for the given player.
  static List<int> validMoves(Uint8List board, int size, int player) {
    final moves = <int>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final idx = r * size + c;
        if (board[idx] == 0 && !_isSuicide(board, size, r, c, player)) {
          moves.add(idx);
        }
      }
    }
    return moves;
  }

  static bool _isSuicide(Uint8List board, int size, int r, int c, int player) {
    // Fast path: any empty adjacent cell means this cannot be suicide.
    if (r > 0 && board[(r - 1) * size + c] == 0) return false;
    if (r < size - 1 && board[(r + 1) * size + c] == 0) return false;
    if (c > 0 && board[r * size + c - 1] == 0) return false;
    if (c < size - 1 && board[r * size + c + 1] == 0) return false;

    // All adjacent cells occupied — full liberty check needed.
    final opp = 3 - player;
    for (final n in _adj(r, c, size)) {
      final nv = board[n[0] * size + n[1]];
      // Would capture an opponent group → not suicide.
      if (nv == opp && _liberties(board, size, n[0], n[1]) == 1) return false;
      // Merging with a friendly group that still has spare liberties → not suicide.
      if (nv == player && _liberties(board, size, n[0], n[1]) > 1) return false;
    }
    return true;
  }

  static int _liberties(Uint8List board, int size, int startR, int startC) {
    final color = board[startR * size + startC];
    if (color == 0) return 0;
    final visited = <int>{};
    final queue = <int>[startR * size + startC];
    final libs = <int>{};
    while (queue.isNotEmpty) {
      final idx = queue.removeLast();
      if (!visited.add(idx)) continue;
      final r = idx ~/ size;
      final c = idx % size;
      for (final n in _adj(r, c, size)) {
        final ni = n[0] * size + n[1];
        final nv = board[ni];
        if (nv == 0) {
          libs.add(ni);
        } else if (nv == color) {
          queue.add(ni);
        }
      }
    }
    return libs.length;
  }

  // Returns a new board with the stone placed and opponent captures applied.
  static Uint8List applyMove(Uint8List board, int size, int r, int c, int player) {
    final b = Uint8List.fromList(board);
    b[r * size + c] = player;
    final opp = 3 - player;
    for (final n in _adj(r, c, size)) {
      if (b[n[0] * size + n[1]] == opp && _liberties(b, size, n[0], n[1]) == 0) {
        _removeGroup(b, size, n[0], n[1]);
      }
    }
    return b;
  }

  // Mutates board in place — used in fast rollouts to avoid allocation.
  static void applyMoveInPlace(Uint8List board, int size, int r, int c, int player) {
    board[r * size + c] = player;
    final opp = 3 - player;
    for (final n in _adj(r, c, size)) {
      if (board[n[0] * size + n[1]] == opp &&
          _liberties(board, size, n[0], n[1]) == 0) {
        _removeGroup(board, size, n[0], n[1]);
      }
    }
  }

  static void _removeGroup(Uint8List board, int size, int startR, int startC) {
    final color = board[startR * size + startC];
    final queue = <int>[startR * size + startC];
    final visited = <int>{};
    while (queue.isNotEmpty) {
      final idx = queue.removeLast();
      if (!visited.add(idx)) continue;
      board[idx] = 0;
      final r = idx ~/ size;
      final c = idx % size;
      for (final n in _adj(r, c, size)) {
        if (board[n[0] * size + n[1]] == color) queue.add(n[0] * size + n[1]);
      }
    }
  }

  static List<List<int>> _adj(int r, int c, int size) {
    final result = <List<int>>[];
    if (r > 0) result.add([r - 1, c]);
    if (r < size - 1) result.add([r + 1, c]);
    if (c > 0) result.add([r, c - 1]);
    if (c < size - 1) result.add([r, c + 1]);
    return result;
  }
}
