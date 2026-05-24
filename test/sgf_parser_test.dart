import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/utils/sgf_parser.dart';

void main() {
  group('parseSgf', () {
    test('extracts board size, setup stones, and main-line moves', () {
      const sgf =
          '(;GM[1]SZ[9]'
          'AB[bb][cc]'
          'AW[gg]'
          'PL[B]'
          ';B[ee];W[ff];B[dd])';
      final p = parseSgf(sgf);

      expect(p.boardSize, 9);
      expect(p.initialBlack, [
        [1, 1],
        [2, 2],
      ]);
      expect(p.initialWhite, [
        [6, 6],
      ]);
      expect(p.playerToMove, 1);
      expect(p.solution, [
        [4, 4, 1],
        [5, 5, 2],
        [3, 3, 1],
      ]);
    });

    test('skips branches, only keeps main line', () {
      // Two variations after the first move; only the first should be kept.
      const sgf =
          '(;SZ[9];B[ee]'
          '(;W[ff];B[gg])'
          '(;W[dd]))';
      final p = parseSgf(sgf);
      expect(p.solution, [
        [4, 4, 1],
      ]);
    });

    test('defaults board size to 19 and player to black', () {
      const sgf = '(;GM[1];B[pd];W[dp])';
      final p = parseSgf(sgf);
      expect(p.boardSize, 19);
      expect(p.playerToMove, 1);
      expect(p.solution.first, [3, 15, 1]);
    });

    test('toInitialBoard produces a correctly-marked grid', () {
      const sgf = '(;SZ[5]AB[aa][bb]AW[ee])';
      final board = parseSgf(sgf).toInitialBoard();
      expect(board.length, 5);
      expect(board[0][0], 1);
      expect(board[1][1], 1);
      expect(board[4][4], 2);
      expect(board[2][2], 0);
    });

    test('handles passes as [-1,-1]', () {
      const sgf = '(;SZ[9];B[];W[ee])';
      final p = parseSgf(sgf);
      expect(p.solution.first, [-1, -1, 1]);
      expect(p.solution.last, [4, 4, 2]);
    });

    test('throws on empty input', () {
      expect(() => parseSgf('   '), throwsFormatException);
    });
  });
}
