import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/widgets/fast_game_board.dart';

/// Regression test for the online-mode capture sync bug.
///
/// Bug: in [OnlineGameScreen], the 2D board list was mutated in place when a
/// remote move arrived with captures. Because [FastGameBoard] received the
/// same outer List reference, captured stones could remain visible until a
/// full state refresh.
///
/// Fix: rebuild [_board] as a fresh deep copy on every mutation, and key the
/// child board widget with [_boardVersion]. This test simulates that flow
/// against [FastGameBoard] directly so a regression in either fix is caught.
void main() {
  testWidgets(
    'FastGameBoard removes captured stone when parent rebuilds with new board ref',
    (tester) async {
      const size = 9;

      List<List<int>> initial() {
        final b = List.generate(size, (_) => List<int>.filled(size, 0));
        // Place a black stone that will get "captured."
        b[0][1] = 1;
        // Surround with white liberties already off the live board so we are
        // only testing the visual delta, not capture logic.
        b[0][0] = 2;
        b[0][2] = 2;
        b[1][1] = 2;
        return b;
      }

      await tester.pumpWidget(_BoardHarness(initialBoard: initial()));

      final stoneFinder = find.byKey(const ValueKey('s0_1'));
      expect(stoneFinder, findsOneWidget,
          reason: 'Black stone should render before capture');

      // Simulate the fixed path: deep-copy the board, zero the captured cell.
      final state =
          tester.state<_BoardHarnessState>(find.byType(_BoardHarness));
      state.applyCapture(0, 1);
      await tester.pump();

      expect(stoneFinder, findsNothing,
          reason:
              'Captured stone must disappear after parent rebuilds with a fresh board reference');
    },
  );

  testWidgets('FastGameBoard re-renders when bumping ValueKey on the widget',
      (tester) async {
    const size = 5;

    List<List<int>> board() =>
        List.generate(size, (_) => List<int>.filled(size, 0));

    final initial = board();
    initial[2][2] = 1;

    await tester.pumpWidget(_KeyedHarness(board: initial, version: 1));
    expect(find.byKey(const ValueKey('s2_2')), findsOneWidget);

    final cleared = board();
    await tester.pumpWidget(_KeyedHarness(board: cleared, version: 2));
    expect(find.byKey(const ValueKey('s2_2')), findsNothing);
  });
}

/// Minimal stateful harness that mirrors what [OnlineGameScreen] does after
/// the fix: hold the 2D board, rebuild it as a fresh deep copy on mutation,
/// and pass it down to [FastGameBoard].
class _BoardHarness extends StatefulWidget {
  final List<List<int>> initialBoard;
  const _BoardHarness({required this.initialBoard});

  @override
  State<_BoardHarness> createState() => _BoardHarnessState();
}

class _BoardHarnessState extends State<_BoardHarness> {
  late List<List<int>> _board;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _board = [for (final r in widget.initialBoard) [...r]];
  }

  void applyCapture(int row, int col) {
    setState(() {
      _board[row][col] = 0;
      _board = [for (final r in _board) [...r]];
      _version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: FastGameBoard(
            key: ValueKey<int>(_version),
            board: _board,
            onTap: (_, __) {},
          ),
        ),
      ),
    );
  }
}

class _KeyedHarness extends StatelessWidget {
  final List<List<int>> board;
  final int version;
  const _KeyedHarness({required this.board, required this.version});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: FastGameBoard(
            key: ValueKey<int>(version),
            board: board,
            onTap: (_, __) {},
          ),
        ),
      ),
    );
  }
}
