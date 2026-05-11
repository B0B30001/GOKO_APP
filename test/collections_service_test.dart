import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/puzzle.dart';
import 'package:zaibal/services/content_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentService.loadCollections', () {
    test('loads at least one collection from the bundled JSON', () async {
      final collections = await ContentService.loadCollections();
      expect(collections.isNotEmpty, isTrue);
    });

    test('every collection has a title and at least one puzzleId', () async {
      final collections = await ContentService.loadCollections();
      for (final c in collections) {
        expect(c.title.isNotEmpty, isTrue, reason: 'collection ${c.id}');
        expect(c.puzzleIds.isNotEmpty, isTrue, reason: 'collection ${c.id}');
      }
    });

    test('every puzzleId resolves to a real puzzle in PuzzleData', () async {
      final collections = await ContentService.loadCollections();
      final allIds = PuzzleData.allPuzzles.map((p) => p.id).toSet();
      for (final c in collections) {
        for (final pid in c.puzzleIds) {
          expect(
            allIds.contains(pid),
            isTrue,
            reason: 'collection ${c.id} references missing puzzle id "$pid"',
          );
        }
      }
    });
  });
}
