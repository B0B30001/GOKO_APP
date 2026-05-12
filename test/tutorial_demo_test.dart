import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/models/tutorial.dart';

void main() {
  group('TutorialStep.fromJson with demoMoves', () {
    test('parses demoMoves preserving coords/colors/captions/delays', () {
      final step = TutorialStep.fromJson({
        'title': 'demo step',
        'board': [
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 0],
        ],
        'body': 'play it out',
        'demoMoves': [
          {'row': 0, 'col': 1, 'color': 1, 'caption': 'first', 'delayMs': 500},
          {'row': 2, 'col': 2, 'color': 2, 'caption': 'second'},
        ],
      });
      expect(step.demoMoves, isNotNull);
      expect(step.demoMoves!.length, equals(2));
      expect(step.demoMoves![0].row, equals(0));
      expect(step.demoMoves![0].col, equals(1));
      expect(step.demoMoves![0].color, equals(1));
      expect(step.demoMoves![0].caption, equals('first'));
      expect(step.demoMoves![0].delayMs, equals(500));
      // Default delayMs when omitted.
      expect(step.demoMoves![1].delayMs, equals(700));
      expect(step.demoMoves![1].color, equals(2));
    });

    test('steps without demoMoves parse with demoMoves == null', () {
      final step = TutorialStep.fromJson({
        'title': 'plain step',
        'board': [
          [0, 0],
          [0, 0],
        ],
        'body': 'plain body',
      });
      expect(step.demoMoves, isNull);
    });

    test(
      'replaying demoMoves imperatively yields the expected final board',
      () {
        // Verifies the rendering loop's logic without mounting a widget: walk
        // through demoMoves and assert the resulting board matches.
        final step = TutorialStep.fromJson({
          'title': 'simple capture demo',
          'board': [
            [0, 1, 0],
            [1, 2, 0],
            [0, 1, 0],
          ],
          'body': 'capture the white stone',
          'demoMoves': [
            {'row': 1, 'col': 2, 'color': 1, 'caption': 'remove last liberty'},
            {'row': 1, 'col': 1, 'color': 0, 'caption': 'white removed'},
          ],
        });

        final live = step.board.map((r) => List<int>.from(r)).toList();
        for (final m in step.demoMoves!) {
          live[m.row][m.col] = m.color;
        }

        expect(live[1][2], equals(1)); // Black placement
        expect(live[1][1], equals(0)); // White removed
      },
    );
  });

  group('Tutorial JSON round trip with demoMoves', () {
    test('a tutorial with demoMoves on one step round-trips intact', () {
      final tutorial = Tutorial.fromJson({
        'id': 'demo-t',
        'title': 'demo tutorial',
        'summary': '',
        'category': 'fundamentals',
        'boardSize': 3,
        'source': '',
        'steps': [
          {
            'title': 'one',
            'board': [
              [0, 0, 0],
              [0, 0, 0],
              [0, 0, 0],
            ],
            'body': '',
          },
          {
            'title': 'two',
            'board': [
              [0, 0, 0],
              [0, 0, 0],
              [0, 0, 0],
            ],
            'body': '',
            'demoMoves': [
              {'row': 1, 'col': 1, 'color': 1},
            ],
          },
        ],
      });
      expect(tutorial.steps[0].demoMoves, isNull);
      expect(tutorial.steps[1].demoMoves, isNotNull);
      expect(tutorial.steps[1].demoMoves!.first.row, equals(1));
    });
  });
}
