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

  // Opening book: prefer star points for the first few moves.
  final stoneCount = flatBoard.fold<int>(0, (s, v) => s + (v != 0 ? 1 : 0));
  if (stoneCount < 4) {
    final bookMove = _openingBook(flatBoard, boardSize, rng);
    if (bookMove != null) return bookMove;
  }

  final root = MctsNode(
    board: flatBoard,
    boardSize: boardSize,
    playerToMove: player,
    rng: rng,
  );

  for (int i = 0; i < simulations; i++) {
    // ── Selection ──────────────────────────────────────────────────────
    var node = root;
    while (!node.isTerminal && node.isFullyExpanded) {
      node = node.selectBestChild();
    }

    // ── Expansion ──────────────────────────────────────────────────────
    if (!node.isTerminal) {
      node = node.expand(rng);
    }

    // ── Simulation (heuristic rollout) ─────────────────────────────────
    final rollout = _rollout(node.board, boardSize, node.playerToMove, rng);
    final winner = rollout.winner;

    // Build RAVE move sets from rollout, then extend with tree-path moves.
    final simBlack = <int>{};
    final simWhite = <int>{};
    for (final (idx, p) in rollout.moves) {
      if (p == 1) {
        simBlack.add(idx);
      } else {
        simWhite.add(idx);
      }
    }
    var raveWalk = node;
    while (raveWalk.parent != null) {
      final mv = raveWalk.move;
      if (mv != null) {
        final fi = mv[0] * boardSize + mv[1];
        if (raveWalk.parent!.playerToMove == 1) {
          simBlack.add(fi);
        } else {
          simWhite.add(fi);
        }
      }
      raveWalk = raveWalk.parent!;
    }

    // ── Backpropagation + RAVE ─────────────────────────────────────────
    var backNode = node;
    while (backNode.parent != null) {
      backNode.visits++;
      if (winner == backNode.parent!.playerToMove) backNode.wins += 1.0;

      // Update RAVE stats for all siblings whose move appeared in simulation.
      final pPlayer = backNode.parent!.playerToMove;
      final pMoves = pPlayer == 1 ? simBlack : simWhite;
      for (final child in backNode.parent!.children) {
        final mv = child.move;
        if (mv == null) continue;
        final fi = mv[0] * boardSize + mv[1];
        if (pMoves.contains(fi)) {
          child.raveVisits++;
          if (winner == pPlayer) child.raveWins += 1.0;
        }
      }
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

/// Returns a star-point or tengen move for the opening phase, or null when
/// all star points are occupied or the board size has no book entry.
List<int>? _openingBook(Uint8List board, int size, Random rng) {
  final starPoints = switch (size) {
    9 => const [(2, 2), (2, 6), (6, 2), (6, 6), (4, 4)],
    13 => const [(3, 3), (3, 9), (9, 3), (9, 9), (6, 6)],
    19 => const [
      (3, 3),
      (3, 9),
      (3, 15),
      (9, 3),
      (9, 9),
      (9, 15),
      (15, 3),
      (15, 9),
      (15, 15),
    ],
    _ => const <(int, int)>[],
  };
  final empty = [
    for (final p in starPoints)
      if (board[p.$1 * size + p.$2] == 0) p,
  ];
  if (empty.isEmpty) return null;
  final pick = empty[rng.nextInt(empty.length)];
  return [pick.$1, pick.$2];
}

/// Heuristic rollout: uses atari responses and local moves instead of
/// pure random play, producing more informative simulations.
///
/// Returns the winner (1 = black, 2 = white) together with every move played
/// as (flatIndex, player) pairs for RAVE backpropagation.
({int winner, List<(int, int)> moves}) _rollout(
  Uint8List board,
  int size,
  int startingPlayer,
  Random rng,
) {
  final b = Uint8List.fromList(board);
  var player = startingPlayer;
  var passes = 0;
  final limit = size * size * 2;
  final recordedMoves = <(int, int)>[];
  int lastMove = -1;

  for (int i = 0; i < limit && passes < 2; i++) {
    final idx = _pickMove(b, size, player, lastMove, rng);
    if (idx == -1) {
      passes++;
    } else {
      recordedMoves.add((idx, player));
      MctsNode.applyMoveInPlace(b, size, idx ~/ size, idx % size, player);
      lastMove = idx;
      passes = 0;
    }
    player = 3 - player;
  }

  int black = 0, white = 0;
  for (final cell in b) {
    if (cell == 1) {
      black++;
    } else if (cell == 2) {
      white++;
    }
  }
  return (winner: black > white + 6.5 ? 1 : 2, moves: recordedMoves);
}

/// Four-priority heuristic move picker for rollouts.
///
/// 1. Save our group in atari (fill its last liberty).
/// 2. Capture opponent group in atari.
/// 3. 70 % chance: play within Chebyshev distance 2 of last move.
/// 4. Random empty cell with at least one empty neighbour.
///
/// Returns a flat board index, or -1 to signal a pass.
int _pickMove(Uint8List board, int size, int player, int lastMove, Random rng) {
  final opp = 3 - player;

  // Priorities 1 & 2: scan the 4-connected neighbours of the last move.
  if (lastMove != -1) {
    final lr = lastMove ~/ size;
    final lc = lastMove % size;
    const drs = [-1, 1, 0, 0];
    const dcs = [0, 0, -1, 1];
    for (int d = 0; d < 4; d++) {
      final nr = lr + drs[d];
      final nc = lc + dcs[d];
      if (nr < 0 || nr >= size || nc < 0 || nc >= size) continue;
      final cell = board[nr * size + nc];
      if (cell == 0) continue;

      if (cell == player && MctsNode.groupLiberties(board, size, nr, nc) == 1) {
        // Priority 1: our group is in atari — try to save it.
        final lib = _findLastLiberty(board, size, nr, nc);
        if (lib != -1 &&
            !MctsNode.isSuicideMove(
              board,
              size,
              lib ~/ size,
              lib % size,
              player,
            )) {
          return lib;
        }
      }

      if (cell == opp && MctsNode.groupLiberties(board, size, nr, nc) == 1) {
        // Priority 2: opponent group in atari — capture it (never suicide
        // after the captured stones free up liberties).
        final lib = _findLastLiberty(board, size, nr, nc);
        if (lib != -1) return lib;
      }
    }
  }

  // Priority 3: 70 % chance — play within Chebyshev distance 2 of last move.
  if (lastMove != -1 && rng.nextDouble() < 0.70) {
    final lr = lastMove ~/ size;
    final lc = lastMove % size;
    final nearby = <int>[];
    for (int dr = -2; dr <= 2; dr++) {
      for (int dc = -2; dc <= 2; dc++) {
        final nr = lr + dr;
        final nc = lc + dc;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) continue;
        final ni = nr * size + nc;
        if (board[ni] == 0 && _hasEmptyNeighbor(board, size, nr, nc)) {
          nearby.add(ni);
        }
      }
    }
    if (nearby.isNotEmpty) return nearby[rng.nextInt(nearby.length)];
  }

  // Priority 4: random move with at least one empty neighbour (fast suicide
  // guard avoids expensive BFS for the common case).
  for (int attempt = 0; attempt < 30; attempt++) {
    final idx = rng.nextInt(size * size);
    final r = idx ~/ size;
    final c = idx % size;
    if (board[idx] == 0 && _hasEmptyNeighbor(board, size, r, c)) return idx;
  }
  return -1; // pass
}

/// BFS that returns the flat index of the unique remaining liberty of the
/// group at (r, c).  Caller must have confirmed exactly 1 liberty via
/// [MctsNode.groupLiberties].  Returns -1 on unexpected failure.
int _findLastLiberty(Uint8List board, int size, int r, int c) {
  final color = board[r * size + c];
  if (color == 0) return -1;
  final visited = <int>{};
  final queue = <int>[r * size + c];
  while (queue.isNotEmpty) {
    final idx = queue.removeLast();
    if (!visited.add(idx)) continue;
    final ir = idx ~/ size;
    final ic = idx % size;
    if (ir > 0) {
      final ni = (ir - 1) * size + ic;
      final v = board[ni];
      if (v == 0) return ni;
      if (v == color) queue.add(ni);
    }
    if (ir < size - 1) {
      final ni = (ir + 1) * size + ic;
      final v = board[ni];
      if (v == 0) return ni;
      if (v == color) queue.add(ni);
    }
    if (ic > 0) {
      final ni = ir * size + (ic - 1);
      final v = board[ni];
      if (v == 0) return ni;
      if (v == color) queue.add(ni);
    }
    if (ic < size - 1) {
      final ni = ir * size + (ic + 1);
      final v = board[ni];
      if (v == 0) return ni;
      if (v == color) queue.add(ni);
    }
  }
  return -1;
}

bool _hasEmptyNeighbor(Uint8List board, int size, int r, int c) {
  if (r > 0 && board[(r - 1) * size + c] == 0) return true;
  if (r < size - 1 && board[(r + 1) * size + c] == 0) return true;
  if (c > 0 && board[r * size + c - 1] == 0) return true;
  if (c < size - 1 && board[r * size + c + 1] == 0) return true;
  return false;
}
