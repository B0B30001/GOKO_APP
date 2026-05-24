/// Minimal SGF (Smart Game Format) parser for OGS puzzle import.
///
/// Handles the subset needed to extract initial board state + the main-line
/// move sequence from an OGS puzzle SGF. Variations (branches) are skipped —
/// only the first path is treated as the canonical solution.
///
/// Properties recognized:
///  - `SZ[n]`            board size
///  - `AB[xy][xy]...`    setup black stones
///  - `AW[xy][xy]...`    setup white stones
///  - `PL[B|W]`          player to move
///  - `B[xy]` / `W[xy]`  move (one stone per node)
///  - `B[]`  / `W[]`     pass
library;

import 'sgf_coords.dart';

/// Result of parsing a single SGF puzzle.
class ParsedSgfPuzzle {
  /// Board side length (e.g. 9, 13, 19). Defaults to 19 if `SZ[]` missing.
  final int boardSize;

  /// Setup stones placed before play begins, as `[row, col]` pairs.
  final List<List<int>> initialBlack;
  final List<List<int>> initialWhite;

  /// 1 = black, 2 = white. Defaults to black when `PL[]` missing.
  final int playerToMove;

  /// Main-line solution. Each entry is `[row, col, color]` (color 1=B, 2=W).
  /// Passes are stored as `[-1, -1, color]`.
  final List<List<int>> solution;

  const ParsedSgfPuzzle({
    required this.boardSize,
    required this.initialBlack,
    required this.initialWhite,
    required this.playerToMove,
    required this.solution,
  });

  /// Builds a 2D `boardSize × boardSize` int array with `1` for black setup
  /// stones, `2` for white setup stones, `0` elsewhere. Suitable for the
  /// `Puzzle.initialBoard` field.
  List<List<int>> toInitialBoard() {
    final out = List.generate(boardSize, (_) => List<int>.filled(boardSize, 0));
    for (final s in initialBlack) {
      if (s[0] >= 0 && s[0] < boardSize && s[1] >= 0 && s[1] < boardSize) {
        out[s[0]][s[1]] = 1;
      }
    }
    for (final s in initialWhite) {
      if (s[0] >= 0 && s[0] < boardSize && s[1] >= 0 && s[1] < boardSize) {
        out[s[0]][s[1]] = 2;
      }
    }
    return out;
  }
}

/// Parses an SGF string. Throws [FormatException] when the document is not
/// well-formed enough to extract the basics.
ParsedSgfPuzzle parseSgf(String sgf) {
  final src = sgf.trim();
  if (src.isEmpty) {
    throw const FormatException('Empty SGF document.');
  }

  // Walk the SGF character-by-character. We only need the first branch, so on
  // an opening '(' inside an existing tree we record nothing, and on ')' we
  // pop. Property values use square brackets, escaped via backslash.
  int boardSize = 19;
  final initialBlack = <List<int>>[];
  final initialWhite = <List<int>>[];
  int playerToMove = 1;
  bool playerToMoveSet = false;
  final solution = <List<int>>[];

  int branchDepth = 0;
  int i = 0;

  while (i < src.length) {
    final ch = src[i];

    if (ch == '(') {
      branchDepth++;
      i++;
      continue;
    }
    if (ch == ')') {
      branchDepth--;
      if (branchDepth <= 0) break;
      i++;
      continue;
    }
    if (ch == ';') {
      i++;
      continue;
    }

    // We only consume properties from the first (main-line) branch.
    if (branchDepth > 1) {
      i++;
      continue;
    }

    // Identify a property key: contiguous uppercase letters.
    if (_isUpper(ch)) {
      final keyStart = i;
      while (i < src.length && _isUpper(src[i])) {
        i++;
      }
      final key = src.substring(keyStart, i);

      // Collect all `[value]` payloads attached to this property.
      final values = <String>[];
      while (i < src.length && src[i] == '[') {
        i++;
        final sb = StringBuffer();
        while (i < src.length && src[i] != ']') {
          if (src[i] == r'\' && i + 1 < src.length) {
            sb.write(src[i + 1]);
            i += 2;
          } else {
            sb.write(src[i]);
            i++;
          }
        }
        if (i < src.length) i++; // consume ']'
        values.add(sb.toString());
      }

      switch (key) {
        case 'SZ':
          final n = int.tryParse(values.first.trim());
          if (n != null && n > 0 && n <= 25) boardSize = n;
          break;
        case 'AB':
          for (final v in values) {
            final c = decodeSGF(v);
            if (c[0] >= 0) initialBlack.add(c);
          }
          break;
        case 'AW':
          for (final v in values) {
            final c = decodeSGF(v);
            if (c[0] >= 0) initialWhite.add(c);
          }
          break;
        case 'PL':
          final v = values.first.trim().toUpperCase();
          playerToMove = v == 'W' ? 2 : 1;
          playerToMoveSet = true;
          break;
        case 'B':
          final v = values.first;
          if (v.isEmpty) {
            solution.add(const [-1, -1, 1]);
          } else {
            final c = decodeSGF(v);
            solution.add([c[0], c[1], 1]);
          }
          break;
        case 'W':
          final v = values.first;
          if (v.isEmpty) {
            solution.add(const [-1, -1, 2]);
          } else {
            final c = decodeSGF(v);
            solution.add([c[0], c[1], 2]);
          }
          break;
        default:
          // Ignore comments, names, results, etc.
          break;
      }
      continue;
    }

    // Whitespace / unknown — skip.
    i++;
  }

  // If PL[] was not specified, infer from the first played move so the puzzle
  // starts on the right player. Fallback = black.
  if (!playerToMoveSet && solution.isNotEmpty) {
    playerToMove = solution.first[2];
  }

  return ParsedSgfPuzzle(
    boardSize: boardSize,
    initialBlack: initialBlack,
    initialWhite: initialWhite,
    playerToMove: playerToMove,
    solution: solution,
  );
}

bool _isUpper(String ch) {
  if (ch.isEmpty) return false;
  final code = ch.codeUnitAt(0);
  return code >= 0x41 && code <= 0x5A; // 'A'..'Z'
}
