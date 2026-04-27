import 'dart:math';
import 'dart:typed_data';
import 'mcts_node.dart';

/// Runs MCTS for [simulations] iterations from the given board position and
/// returns the [row, col] of the best move for [player], or null for pass.
List<int>? runMCTS({
  required List<List<int>> board,
  required int boardSize,
  required int player,
  required int simulations,
}) {
  // Convert 2-D list to flat Uint8List for efficient copying.
  final flatBoard = Uint8List(boardSize * boardSize);
  for (int r = 0; r < boardSize; r++) {
    for (int c = 0; c < boardSize; c++) {
      flatBoard[r * boardSize + c] = board[r][c];
    }
  }

  final moves = MctsNode.validMoves(flatBoard, boardSize, player);
  if (moves.isEmpty) return null; // No valid moves — AI should pass.

  final rng = Random();
  final root = MctsNode(
    board: flatBoard,
    boardSize: boardSize,
    playerToMove: player,
    rng: rng,
  );

  for (int i = 0; i < simulations; i++) {
    // --- Selection ---
    var node = root;
    while (!node.isTerminal && node.isFullyExpanded) {
      node = node.selectBestChild();
    }

    // --- Expansion ---
    if (!node.isTerminal) {
      node = node.expand(rng);
    }

    // --- Simulation (rollout) ---
    final winner = _rollout(node.board, boardSize, node.playerToMove, rng);

    // --- Backpropagation ---
    // wins in a node are attributed to the parent's playerToMove (the player
    // who made the move to arrive at this node).
    var backNode = node;
    while (backNode.parent != null) {
      backNode.visits++;
      if (winner == backNode.parent!.playerToMove) backNode.wins += 1.0;
      backNode = backNode.parent!;
    }
    backNode.visits++; // root
  }

  if (root.children.isEmpty) {
    // No simulations reached children (e.g. simulations=0); pick random.
    final idx = moves[rng.nextInt(moves.length)];
    return [idx ~/ boardSize, idx % boardSize];
  }

  // Most-visited child is the most-explored and typically the best move.
  final best = root.children.reduce((a, b) => a.visits > b.visits ? a : b);
  return best.move;
}

// Fast random rollout: mutates a copy of the board until game end or depth
// limit, then scores by stone count with komi.
int _rollout(Uint8List board, int size, int startingPlayer, Random rng) {
  final b = Uint8List.fromList(board);
  var player = startingPlayer;
  var passes = 0;
  final limit = size * size * 2;

  for (int i = 0; i < limit && passes < 2; i++) {
    bool placed = false;
    // Try up to 25 random positions; skip if occupied or obviously suicide
    // (no empty adjacent cell).  Avoids the full liberty BFS during rollouts.
    for (int attempt = 0; attempt < 25; attempt++) {
      final r = rng.nextInt(size);
      final c = rng.nextInt(size);
      if (b[r * size + c] != 0) continue;
      if (_hasEmptyNeighbor(b, size, r, c)) {
        MctsNode.applyMoveInPlace(b, size, r, c, player);
        placed = true;
        passes = 0;
        break;
      }
    }
    if (!placed) passes++;
    player = 3 - player;
  }

  // Score: stone count + 6.5 komi for white.
  int black = 0, white = 0;
  for (final cell in b) {
    if (cell == 1) {
      black++;
    } else if (cell == 2) {
      white++;
    }
  }
  return black > white + 6.5 ? 1 : 2;
}

bool _hasEmptyNeighbor(Uint8List board, int size, int r, int c) {
  if (r > 0 && board[(r - 1) * size + c] == 0) return true;
  if (r < size - 1 && board[(r + 1) * size + c] == 0) return true;
  if (c > 0 && board[r * size + c - 1] == 0) return true;
  if (c < size - 1 && board[r * size + c + 1] == 0) return true;
  return false;
}
