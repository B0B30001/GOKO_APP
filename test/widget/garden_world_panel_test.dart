import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/widgets/garden/garden_scenery.dart';

/// Tests for [GardenWorldPanel] — the per-world scenery wrapper that scrolls
/// with the path and never stretches its art.
void main() {
  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GardenWorldPanel(
            themeIdx: 0,
            child: Text('band-content'),
          ),
        ),
      ),
    );
    expect(find.text('band-content'), findsOneWidget);
  });

  testWidgets('missing scenery asset falls back gracefully (no crash)', (
    tester,
  ) async {
    // No assets/backgrounds/*.png are bundled in the test harness, so the
    // Image.asset errorBuilder must kick in (→ transparent) without throwing.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GardenWorldPanel(
            themeIdx: 2,
            child: SizedBox(height: 200, width: 100),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(GardenWorldPanel), findsOneWidget);
  });

  testWidgets('clamps an out-of-range themeIdx without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GardenWorldPanel(themeIdx: 99, child: Text('x')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('x'), findsOneWidget);
  });
}
