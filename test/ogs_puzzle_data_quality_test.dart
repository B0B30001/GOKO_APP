import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Data-quality checks for the bundled OGS puzzle JSON.
///
/// These tests catch the most common "puzzle reported wrong even though
/// the player played a correct move" failure modes by verifying the
/// bundled JSON before it ever reaches the UI:
///
///   - Every puzzle has a non-empty solutionTree
///   - Every root has at least one child (first-move alternative)
///   - At least one branch leads to a correct leaf
///   - Initial board coordinates are inside the board
///   - playerColor matches the colour of the first solution move
///
/// If a puzzle slips through with any of these flaws, players see a
/// "find the right move" prompt with no path that actually solves it.
void main() {
  group('OGS puzzles bundle', () {
    final file = File('assets/content/ogs_puzzles.json');
    if (!file.existsSync()) {
      test('skipped — ogs_puzzles.json not built yet', () {});
      return;
    }

    final puzzles = (jsonDecode(file.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();

    test('bundle contains a non-trivial number of puzzles', () {
      expect(puzzles.length, greaterThan(50));
    });

    test('every puzzle has a solutionTree map', () {
      final broken = puzzles
          .where((p) => p['solutionTree'] is! Map)
          .map((p) => p['id'])
          .toList();
      expect(broken, isEmpty, reason: 'no solutionTree: $broken');
    });

    test('every solutionTree has at least one first-move branch', () {
      final empty = puzzles
          .where((p) {
            final tree = p['solutionTree'];
            if (tree is! Map) return true;
            final children = tree['children'];
            return children is! List || children.isEmpty;
          })
          .map((p) => p['id'])
          .toList();
      expect(empty, isEmpty, reason: 'empty solutionTree.children: $empty');
    });

    test('every puzzle has at least one correct leaf', () {
      bool hasCorrect(Map node) {
        if (node['correct'] == true) return true;
        final children = node['children'];
        if (children is! List) return false;
        for (final c in children) {
          if (c is Map && hasCorrect(c)) return true;
        }
        return false;
      }

      final dead = puzzles
          .where((p) {
            final tree = p['solutionTree'];
            return tree is! Map || !hasCorrect(tree);
          })
          .map((p) => p['id'])
          .toList();
      expect(dead, isEmpty, reason: 'no winning path: $dead');
    });

    test('first-move branches use the player colour', () {
      final mismatched = <String>[];
      for (final p in puzzles) {
        final playerColor = (p['playerColor'] as num).toInt();
        final tree = p['solutionTree'];
        if (tree is! Map) continue;
        final children = tree['children'];
        if (children is! List) continue;
        for (final m in children.cast<Map>()) {
          if ((m['color'] as num).toInt() != playerColor) {
            mismatched.add(
              '${p['id']}: first move colour=${m['color']} but '
              'playerColor=$playerColor',
            );
            break;
          }
        }
      }
      expect(mismatched, isEmpty, reason: mismatched.join('\n'));
    });

    test('every first-move coordinate is on the board', () {
      final oob = <String>[];
      for (final p in puzzles) {
        final size = (p['boardSize'] as num).toInt();
        final tree = p['solutionTree'];
        if (tree is! Map) continue;
        final children = tree['children'];
        if (children is! List) continue;
        for (final m in children.cast<Map>()) {
          final r = (m['row'] as num).toInt();
          final c = (m['col'] as num).toInt();
          if (r < 0 || c < 0 || r >= size || c >= size) {
            oob.add('${p['id']}: ($r,$c) on $size×$size');
          }
        }
      }
      expect(oob, isEmpty, reason: oob.join('\n'));
    });

    test('initialBoard matches declared boardSize', () {
      final wrongSize = <String>[];
      for (final p in puzzles) {
        final size = (p['boardSize'] as num).toInt();
        final board = p['initialBoard'] as List;
        if (board.length != size) {
          wrongSize.add('${p['id']}: rows=${board.length}, size=$size');
          continue;
        }
        for (final row in board.cast<List>()) {
          if (row.length != size) {
            wrongSize.add('${p['id']}: row length ≠ $size');
            break;
          }
        }
      }
      expect(wrongSize, isEmpty, reason: wrongSize.join('\n'));
    });
  });
}
