import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/services/content_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentService.loadTutorials locale resolution', () {
    test(
      'English (default) returns the English title for a known tutorial',
      () async {
        final tutorials = await ContentService.loadTutorials(
          languageCode: 'en',
        );
        final ladders = tutorials.firstWhere((t) => t.id == 'ladders');
        expect(ladders.title, equals('Ladders (Shicho)'));
      },
    );

    test('Russian returns the Russian title for the same tutorial', () async {
      final tutorials = await ContentService.loadTutorials(languageCode: 'ru');
      final ladders = tutorials.firstWhere((t) => t.id == 'ladders');
      expect(ladders.title, isNot(equals('Ladders (Shicho)')));
      expect(ladders.title, contains('сичо'));
    });

    test('unknown locale falls back to English (no exception)', () async {
      final tutorials = await ContentService.loadTutorials(languageCode: 'xx');
      // Loader's catch path serves up the legacy tutorials.json (English).
      expect(tutorials, isNotEmpty);
      final ladders = tutorials.firstWhere((t) => t.id == 'ladders');
      expect(ladders.title, equals('Ladders (Shicho)'));
    });
  });
}
