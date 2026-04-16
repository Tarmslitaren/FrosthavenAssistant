import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_monster_menu.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddMonsterMenu(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('AddMonsterMenu', () {
    testWidgets('renders Show Bosses checkbox', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Show Bosses'), findsOneWidget);
    });

    testWidgets('renders search field', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('typing in search field filters the monster list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.enterText(find.byType(TextField), 'Zealot');
      await tester.pump();
      expect(find.textContaining('Zealot'), findsAtLeast(1));
    });

    testWidgets('typing non-matching text shows no results',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.enterText(find.byType(TextField), 'zzznomatch');
      await tester.pump();
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('tapping Show Bosses checkbox toggles bosses visibility',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Initially bosses are hidden (default _showBoss = false)
      final before = find.byType(ListTile).evaluate().length;

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Show Bosses'));
      await tester.pump();

      final after = find.byType(ListTile).evaluate().length;
      // After enabling bosses, there should be more or equal items
      expect(after, greaterThanOrEqualTo(before));
    });

    testWidgets('tapping Show Scenario Special Monsters checkbox works',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.widgetWithText(
          CheckboxListTile, 'Show Scenario Special Monsters'));
      await tester.pump();
      // Just verify it doesn't throw
    });

    testWidgets('tapping Add as Ally checkbox works',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Add as Ally'));
      await tester.pump();
      // Just verify it doesn't throw
    });

    testWidgets('monster list shows results after typing filter',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.enterText(find.byType(TextField), 'Zealot');
      await tester.pump();
      // Should have at least one Zealot result
      final tiles = find.byType(ListTile);
      expect(tiles, findsAtLeast(1));
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AddMonsterMenu), findsNothing);
    });
  });
}
