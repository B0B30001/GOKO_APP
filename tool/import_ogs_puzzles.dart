// Build-time tool: fetches OGS puzzle collections and writes a bundled JSON
// asset (`assets/content/ogs_puzzles.json`) consumed at runtime by
// `ContentService`. Run with:
//
//     dart run tool/import_ogs_puzzles.dart
//
// Re-runnable: overwrites the output file each invocation. No app dependency
// — uses only `dart:io` / `dart:convert` so it can be executed before
// `flutter pub get`.
//
// Collection IDs picked for the initial import (resolved from the OGS API
// during planning):
//   242  Exercises for Beginners            mark5000  107 puzzles
//   348  Stone Development for Beginners    mark5000  30  puzzles
//   3311 Ecole de Go de Rennes - Jôsékis 20k Ketler   22  puzzles

import 'dart:convert';
import 'dart:io';

const _collections = <_OgsCollection>[
  _OgsCollection(
    id: 242,
    slug: 'exercises-for-beginners',
    author: 'mark5000',
    name: 'Exercises for Beginners',
  ),
  _OgsCollection(
    id: 348,
    slug: 'stone-development-for-beginners',
    author: 'mark5000',
    name: 'Stone Development for Beginners',
  ),
  _OgsCollection(
    id: 3311,
    slug: 'ecole-de-go-de-rennes-josekis-20k',
    author: 'Ketler',
    name: 'Ecole de Go de Rennes - Jôsékis 20k',
  ),
];

Future<void> main(List<String> args) async {
  final client = HttpClient();
  client.userAgent = 'GOKO-PuzzleImporter/1.0';
  final out = <Map<String, Object?>>[];
  int totalOk = 0;
  int totalSkipped = 0;

  try {
    for (final collection in _collections) {
      stdout.writeln(
        '--- Fetching collection ${collection.id} '
        '(${collection.name}) ---',
      );
      final puzzles = await _fetchAllPuzzles(client, collection.id);
      stdout.writeln('  ${puzzles.length} raw puzzles received');
      for (final raw in puzzles) {
        try {
          final converted = _convertPuzzle(raw, collection);
          if (converted != null) {
            out.add(converted);
            totalOk++;
          } else {
            totalSkipped++;
          }
        } catch (e) {
          totalSkipped++;
          stderr.writeln('  ! skipped puzzle ${raw['id']}: $e');
        }
      }
    }
  } finally {
    client.close();
  }

  // Aggregate the diagnostic correct-leaf counts then drop them so they
  // don't bloat the bundled JSON.
  int totalCorrectLeaves = 0;
  int multiSolutionPuzzles = 0;
  for (final p in out) {
    final n = (p['_correctLeaves'] as int?) ?? 1;
    totalCorrectLeaves += n;
    if (n > 1) multiSolutionPuzzles++;
    p.remove('_correctLeaves');
  }

  final outFile = File('assets/content/ogs_puzzles.json');
  await outFile.create(recursive: true);
  await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(out));

  final avgLeaves = out.isEmpty
      ? 0
      : (totalCorrectLeaves / out.length).toStringAsFixed(2);
  stdout
    ..writeln('')
    ..writeln('Wrote ${out.length} puzzles to ${outFile.path}')
    ..writeln('  OK:                $totalOk')
    ..writeln('  skipped:           $totalSkipped')
    ..writeln('  correct leaves:    $totalCorrectLeaves total, avg $avgLeaves')
    ..writeln('  multi-solution:    $multiSolutionPuzzles puzzles');
}

// ── OGS API ──────────────────────────────────────────────────────────────────

Future<List<Map<String, Object?>>> _fetchAllPuzzles(
  HttpClient client,
  int collectionId,
) async {
  // The collection-puzzles endpoint returns a top-level JSON list.
  final url =
      'https://online-go.com/api/v1/puzzles/collections/$collectionId/puzzles/';
  final body = await _getJson(client, url);
  final all = <Map<String, Object?>>[];
  if (body is List) {
    for (final r in body) {
      if (r is Map<String, Object?>) all.add(r);
    }
  } else if (body is Map && body['results'] is List) {
    for (final r in (body['results'] as List)) {
      if (r is Map<String, Object?>) all.add(r);
    }
  }
  return all;
}

Future<dynamic> _getJson(HttpClient client, String url) async {
  final req = await client.getUrl(Uri.parse(url));
  req.headers.set(HttpHeaders.acceptHeader, 'application/json');
  final resp = await req.close();
  if (resp.statusCode != 200) {
    throw HttpException('GET $url -> ${resp.statusCode}');
  }
  final body = await resp.transform(utf8.decoder).join();
  return jsonDecode(body);
}

// ── Conversion ───────────────────────────────────────────────────────────────

const _sgfLetters = 'abcdefghijklmnopqrs';

/// Decodes a string of concatenated SGF coordinate pairs like "arbrcr" into
/// `[ [row,col], ... ]`. OGS uses column-first, row-second ordering matching
/// our existing `lib/utils/sgf_coords.dart`.
List<List<int>> _decodeStones(String s, int boardSize) {
  final out = <List<int>>[];
  for (int i = 0; i + 1 < s.length; i += 2) {
    final col = _sgfLetters.indexOf(s[i]);
    final row = _sgfLetters.indexOf(s[i + 1]);
    if (col < 0 || row < 0 || col >= boardSize || row >= boardSize) {
      continue;
    }
    out.add([row, col]);
  }
  return out;
}

/// Builds the full branching solution tree from an OGS `move_tree`.
///
/// OGS marks each node independently as `correct_answer` and/or
/// `wrong_answer`. Real tsumego routinely have multiple correct first-move
/// alternatives (e.g. kill at A *or* B), which OGS encodes as sibling
/// branches off the root. The v1 importer collapsed this to a single path,
/// which made the runtime mark legitimate moves wrong.
///
/// Algorithm:
///   1. Walk every branch where `wrong_answer != true`.
///   2. Recurse into children, preserving the tree structure.
///   3. Mark leaves as `correct: true` when the OGS node has
///      `correct_answer: true`.
///   4. Prune subtrees that contain zero correct leaves so we don't ship
///      dead variations the player can never win from.
///
/// Returns null when no correct path exists anywhere in the tree.
Map<String, Object?>? _buildSolutionTree(
  Map<String, Object?> rootTree,
  int firstPlayerColor,
) {
  final rootChildren = _convertBranches(rootTree, firstPlayerColor);
  if (rootChildren.isEmpty) return null;
  // Virtual root: holds the first-move alternatives. row=col=-1 marks it.
  return <String, Object?>{
    'row': -1,
    'col': -1,
    'color': firstPlayerColor,
    'children': rootChildren,
  };
}

/// Converts each branch under [node] into a SolutionNode-shaped Map.
/// Drops branches whose subtree leads to no `correct_answer: true` leaf.
List<Map<String, Object?>> _convertBranches(
  Map<String, Object?> node,
  int nextColor,
) {
  final branches =
      (node['branches'] as List?)?.cast<Map<String, Object?>>() ??
      const <Map<String, Object?>>[];
  final out = <Map<String, Object?>>[];
  for (final b in branches) {
    if (b['wrong_answer'] == true) continue;
    final x = (b['x'] as num?)?.toInt() ?? -1;
    final y = (b['y'] as num?)?.toInt() ?? -1;
    if (x < 0 || y < 0) continue;
    final correct = b['correct_answer'] == true;
    final children = _convertBranches(b, nextColor == 1 ? 2 : 1);
    // Prune: keep this node only if it is a correct leaf or has a correct
    // descendant. Otherwise it's a dead variation.
    if (!correct && children.isEmpty) continue;
    final entry = <String, Object?>{
      'row': y,
      'col': x,
      'color': nextColor,
      if (correct) 'correct': true,
      if (children.isNotEmpty) 'children': children,
    };
    out.add(entry);
  }
  return out;
}

/// Returns the first correct path through [tree] for the legacy `solution`
/// list. Mirrors the v1 first-leaf DFS so any consumer that still reads
/// `puzzle.solution` keeps working unchanged.
List<List<int>> _firstCorrectPath(Map<String, Object?> tree) {
  final path = <List<int>>[];
  if (_firstPathDfs(tree, path)) return path;
  return const [];
}

bool _firstPathDfs(Map<String, Object?> node, List<List<int>> path) {
  final children =
      (node['children'] as List?)?.cast<Map<String, Object?>>() ??
      const <Map<String, Object?>>[];
  for (final c in children) {
    final row = (c['row'] as num).toInt();
    final col = (c['col'] as num).toInt();
    final color = (c['color'] as num).toInt();
    path.add([row, col, color]);
    if (c['correct'] == true) return true;
    if (_firstPathDfs(c, path)) return true;
    path.removeLast();
  }
  return false;
}

/// Returns the number of `correct: true` leaves anywhere in the tree —
/// useful for the importer summary so we can confirm puzzles end up with
/// >1 valid solution after the v2 rewrite.
int _countCorrectLeaves(Map<String, Object?> node) {
  int n = (node['correct'] == true) ? 1 : 0;
  final children =
      (node['children'] as List?)?.cast<Map<String, Object?>>() ??
      const <Map<String, Object?>>[];
  for (final c in children) {
    n += _countCorrectLeaves(c);
  }
  return n;
}

/// Maps OGS puzzle `type` strings to the local category key used by
/// `ContentService` and the daily-tile color strip.
String _mapCategory(String? ogsType) {
  switch ((ogsType ?? '').toLowerCase()) {
    case 'life_and_death':
      return 'life_death';
    case 'joseki':
      return 'joseki';
    case 'fuseki':
      return 'fuseki';
    case 'tesuji':
      return 'tesuji';
    case 'best_move':
      return 'best_move';
    case 'endgame':
      return 'endgame';
    default:
      return 'tactic';
  }
}

/// Maps OGS internal rank (0..30+ kyu) to a 1..5 difficulty bucket.
int _mapDifficulty(num rank) {
  final r = rank.toDouble();
  if (r >= 20) return 5; // dan / very strong
  if (r >= 15) return 4;
  if (r >= 10) return 3;
  if (r >= 5) return 2;
  return 1;
}

Map<String, Object?>? _convertPuzzle(
  Map<String, Object?> raw,
  _OgsCollection collection,
) {
  final inner = raw['puzzle'] as Map<String, Object?>?;
  if (inner == null) return null;

  final width = (inner['width'] as num?)?.toInt() ?? 19;
  final height = (inner['height'] as num?)?.toInt() ?? 19;
  if (width != height) return null; // non-square boards unsupported
  final boardSize = width;

  final initial = inner['initial_state'] as Map<String, Object?>?;
  final blackStr = (initial?['black'] as String?) ?? '';
  final whiteStr = (initial?['white'] as String?) ?? '';
  final blackStones = _decodeStones(blackStr, boardSize);
  final whiteStones = _decodeStones(whiteStr, boardSize);

  // Build the 2D initial-board array (0 empty, 1 black, 2 white).
  final board = List.generate(boardSize, (_) => List<int>.filled(boardSize, 0));
  for (final s in blackStones) {
    board[s[0]][s[1]] = 1;
  }
  for (final s in whiteStones) {
    board[s[0]][s[1]] = 2;
  }

  final playerColor =
      (inner['initial_player'] as String?)?.toLowerCase() == 'white' ? 2 : 1;

  final moveTree = inner['move_tree'] as Map<String, Object?>?;
  if (moveTree == null) return null;
  final solutionTree = _buildSolutionTree(moveTree, playerColor);
  if (solutionTree == null) return null;
  final solution = _firstCorrectPath(solutionTree);
  if (solution.isEmpty) return null;

  final rank = (raw['rank'] as num?) ?? 0;
  final type = inner['puzzle_type'] as String?;
  final name = (raw['name'] as String?) ?? 'OGS Puzzle ${raw['id']}';
  final description = (inner['puzzle_description'] as String?)?.trim() ?? '';
  final hint = (moveTree['text'] as String?)?.trim() ?? '';
  final correctLeaves = _countCorrectLeaves(solutionTree);

  return {
    'id': 'ogs-${collection.id}-${raw['id']}',
    'title': name,
    'description': description,
    'category': _mapCategory(type),
    'difficulty': _mapDifficulty(rank),
    'boardSize': boardSize,
    'playerColor': playerColor,
    'initialBoard': board,
    'solution': [
      for (final m in solution) {'row': m[0], 'col': m[1], 'color': m[2]},
    ],
    'solutionTree': solutionTree,
    'hint': hint,
    'explanation': '',
    'winCondition': {'type': 'exactSequence'},
    'source': 'OGS · ${collection.name} by ${collection.author} (CC-BY)',
    '_correctLeaves': correctLeaves, // diagnostic only, dropped on write
  };
}

class _OgsCollection {
  final int id;
  final String slug;
  final String author;
  final String name;
  const _OgsCollection({
    required this.id,
    required this.slug,
    required this.author,
    required this.name,
  });
}
