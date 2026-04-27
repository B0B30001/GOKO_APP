/// SGF-style coordinate encoding for OGS.
///
/// OGS uses a straight alphabet sequence without skipping 'i', so boards up
/// to 19x19 use 'abcdefghijklmnopqrs'. The encoded form is `<col><row>`,
/// e.g. (row 0, col 0) -> 'aa', (row 3, col 3) -> 'dd', (row 18, col 18) -> 'ss'.
/// A pass move is represented as '..'.
library;

const String sgfLetters = 'abcdefghijklmnopqrs';

/// Encodes a board coordinate to SGF string. Returns '..' for pass / out-of-range.
String encodeMove(int row, int col) {
  if (row < 0 || col < 0) return '..';
  if (col >= sgfLetters.length || row >= sgfLetters.length) return '..';
  return sgfLetters[col] + sgfLetters[row];
}

/// Decodes an SGF string to `[row, col]`. Returns `[-1, -1]` for pass / invalid.
List<int> decodeSGF(String code) {
  if (code == '..' || code.length < 2) return const [-1, -1];
  final col = sgfLetters.indexOf(code[0]);
  final row = sgfLetters.indexOf(code[1]);
  if (col < 0 || row < 0) return const [-1, -1];
  return [row, col];
}
