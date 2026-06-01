import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/widgets/garden/garden_scenery.dart';

/// Tests for [GardenWorldPanel] — the per-world layout wrapper that insets a
/// world band's content while the procedural background shows full-bleed
/// behind it. (Illustrated PNG backdrops were dropped, so it is now a thin
/// inset wrapper with no themeIdx/asset logic.)
void main() {
  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GardenWorldPanel(
            child: Text('band-content'),
          ),
        ),
      ),
    );
    expect(find.text('band-content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('applies the default horizontal inset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GardenWorldPanel(child: SizedBox(height: 200, width: 100)),
        ),
      ),
    );
    final padding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(GardenWorldPanel),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(padding.padding, const EdgeInsets.symmetric(horizontal: 16));
  });

  testWidgets('honours a custom horizontal inset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GardenWorldPanel(
            horizontalInset: 32,
            child: Text('x'),
          ),
        ),
      ),
    );
    final padding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(GardenWorldPanel),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(padding.padding, const EdgeInsets.symmetric(horizontal: 32));
    expect(find.text('x'), findsOneWidget);
  });
}
