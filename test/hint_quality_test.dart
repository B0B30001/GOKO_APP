import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Asserts every bundled OGS puzzle has a derivable hint, so the user never
/// opens the hint dialog and sees empty text.
///
/// We can't render the actual hint (that needs a BuildContext for localization),
/// but we can check the underlying data the runtime fallback chain relies on:
///
///   1. If the puzzle ships a non-empty `hint` field → great, dialog shows it.
///   2. Otherwise, if the puzzle has a `solutionTree` with at least one first-
///      move branch → runtime derives "Look at row N, column X".
///   3. Otherwise → the global "find atari / weak group" fallback fires.
///
/// The third case is only acceptable if the puzzle truly has no solution
/// tree (legacy hand-curated puzzle). For OGS puzzles, the tree should
/// always have first moves — the data-quality test enforces that separately.
void main() {
  final file = File('assets/content/ogs_puzzles.json');
  if (!file.existsSync()) {
    test('skipped — ogs_puzzles.json not built', () {});
    return;
  }
  final puzzles = (jsonDecode(file.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  group('Hint resolvability', () {
    test('every OGS puzzle has a hint source (text or solution tree)', () {
      final stranded = <String>[];
      for (final p in puzzles) {
        final hint = (p['hint'] as String?)?.trim() ?? '';
        if (hint.isNotEmpty) continue;
        final tree = p['solutionTree'];
        if (tree is! Map) {
          stranded.add(p['id'] as String);
          continue;
        }
        final children = tree['children'];
        if (children is! List || children.isEmpty) {
          stranded.add(p['id'] as String);
        }
      }
      expect(
        stranded,
        isEmpty,
        reason:
            'puzzles with no hint AND no derivable first move (the hint '
            'dialog would show only generic fallback text): $stranded',
      );
    });

    test('derived hint coordinates land on the board for every OGS puzzle', () {
      final outOfRange = <String>[];
      for (final p in puzzles) {
        final tree = p['solutionTree'];
        if (tree is! Map) continue;
        final children = tree['children'];
        if (children is! List || children.isEmpty) continue;
        final first = children.first as Map;
        final row = (first['row'] as num).toInt();
        final col = (first['col'] as num).toInt();
        final size = (p['boardSize'] as num).toInt();
        if (row < 0 || col < 0 || row >= size || col >= size) {
          outOfRange.add('${p['id']}: ($row,$col) outside ${size}x$size');
        }
      }
      expect(outOfRange, isEmpty, reason: outOfRange.join('\n'));
    });

    test('column → letter mapping covers every board column up to 19', () {
      // The runtime uses A-T (skipping I, 19 letters) for column display.
      // Confirm we have enough letters for the largest declared board.
      const letters = 'ABCDEFGHJKLMNOPQRST';
      final largestBoard = puzzles
          .map((p) => (p['boardSize'] as num).toInt())
          .fold<int>(0, (a, b) => a > b ? a : b);
      expect(letters.length, greaterThanOrEqualTo(largestBoard));
    });
  });
}
