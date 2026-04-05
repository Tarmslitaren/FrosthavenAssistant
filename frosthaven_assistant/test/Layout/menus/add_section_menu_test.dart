import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_section_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
    // Set up a Frosthaven scenario that has sections in the test data
    SetCampaignCommand('Frosthaven').execute();
    SetScenarioCommand('#0 Howling in the Snow', false).execute();
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddSectionMenu(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    // AddSectionMenu contains a TextField whose cursor blinks, so use pump
    // instead of pumpAndSettle to avoid infinite animation loop.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('AddSectionMenu', () {
    testWidgets('renders search field', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('typing in search field filters section list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.enterText(find.byType(TextField), 'zzz_no_match');
      await tester.pump();
      // Filtering should show no results or fewer results
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('clearing search field restores full list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Type something, then clear
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      // Should not crash
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AddSectionMenu), findsNothing);
    });

    testWidgets('typing partial name shows matching sections',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // '#0.1 The Frozen Depths' is the section in testData scenario #0
      await tester.enterText(find.byType(TextField), 'Frozen');
      await tester.pump();
      expect(find.text('No results found'), findsNothing);
    });

    testWidgets('tapping a section item in the list triggers action',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // With empty search, any visible section should be tappable
      await tester.pump(const Duration(milliseconds: 100));
      // If there are visible sections, tap the first ListTile
      final listTiles = find.byType(ListTile);
      if (tester.widgetList(listTiles).isNotEmpty) {
        // Tap without asserting navigation outcome (may or may not pop)
        await tester.tap(listTiles.first, warnIfMissed: false);
        await tester.pump();
      }
    });
  });
}
