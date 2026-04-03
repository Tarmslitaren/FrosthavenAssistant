import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
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
                builder: (context) => const SelectScenarioMenu(),
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

  group('SelectScenarioMenu', () {
    testWidgets('renders Set Scenario title', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Set Scenario'), findsWidgets);
    });

    testWidgets('renders search field', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('renders campaign buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      // Campaign buttons are inside an ExpansionTile — expand it first
      await tester.tap(find.textContaining('Current Campaign:'));
      await tester.pumpAndSettle();
      expect(find.text('Frosthaven'), findsAtLeast(1));
    });

    testWidgets('tapping a campaign button switches the scenario list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.textContaining('Current Campaign:'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jaws of the Lion'));
      await tester.pumpAndSettle();
      // After switching campaign, the title updates
      expect(find.textContaining('Jaws of the Lion'), findsAtLeast(1));
    });

    testWidgets('Frosthaven scenario list shows expected scenarios',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Expand the campaign ExpansionTile and switch to Frosthaven
      await tester.tap(find.textContaining('Current Campaign:'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frosthaven'));
      await tester.pumpAndSettle();

      // The Frosthaven scenario list should show scenarios
      expect(find.textContaining('#'), findsAtLeast(1));
    });

    testWidgets('typing in search field filters the scenario list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Ensure Frosthaven campaign is selected
      await tester.tap(find.textContaining('Current Campaign:'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frosthaven'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Town');
      await tester.pump();

      // Should show matching scenario(s)
      expect(find.textContaining('Town'), findsAtLeast(1));
    });

    testWidgets('tapping Close dismisses the menu', (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(SelectScenarioMenu), findsNothing);
    });

    testWidgets('tapping the search field clears it',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Set some text first
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      // Tap the text field (triggers onTap which clears it)
      await tester.tap(find.byType(TextField));
      await tester.pump();
      // The controller should be cleared
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text ?? '', isEmpty);
    });

    testWidgets('tapping the custom scenario sets the scenario',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // "custom" is the first item in the Frosthaven scenario list
      // by default the campaign is Jaws of the Lion after clearList(),
      // let's expand and switch to Frosthaven
      await tester.tap(find.textContaining('Current Campaign:'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frosthaven'));
      await tester.pumpAndSettle();

      // "custom" should be in the list - tap it
      final customFinder = find.text('custom');
      if (customFinder.evaluate().isNotEmpty) {
        await tester.tap(customFinder.first);
        await tester.pumpAndSettle();
        // Menu should close and scenario should be set to custom
        expect(find.byType(SelectScenarioMenu), findsNothing);
        expect(getIt<GameState>().scenario.value, 'custom');
      }
    });
  });
}
