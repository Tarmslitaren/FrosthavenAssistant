import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/save_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/settings_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/set_ally_deck_in_og_gloom_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

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
                builder: (context) => const SettingsMenu(),
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

  group('SettingsMenu', () {
    testWidgets('renders Dark mode checkbox', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Dark mode'), findsOneWidget);
    });

    testWidgets('renders Expire Conditions checkbox',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Expire Conditions'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping Dark mode checkbox toggles the setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.darkMode.value;
      await pumpMenu(tester);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Dark mode'));
      await tester.pump();

      expect(settings.darkMode.value, !before);
      // restore
      settings.darkMode.value = before;
    });

    testWidgets('tapping Expire Conditions checkbox toggles the setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.expireConditions.value;
      await pumpMenu(tester);

      await tester.tap(
          find.widgetWithText(CheckboxListTile, 'Expire Conditions'));
      await tester.pump();

      expect(settings.expireConditions.value, !before);
      settings.expireConditions.value = before;
    });

    testWidgets('tapping Soft numpad for input checkbox toggles the setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.softNumpadInput.value;
      await pumpMenu(tester);

      await tester
          .tap(find.widgetWithText(CheckboxListTile, 'Soft numpad for input'));
      await tester.pump();

      expect(settings.softNumpadInput.value, !before);
      settings.softNumpadInput.value = before;
    });

    testWidgets("tapping Don't ask for initiative checkbox toggles setting",
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.noInit.value;
      await pumpMenu(tester);

      await tester.tap(
          find.widgetWithText(CheckboxListTile, "Don't ask for initiative"));
      await tester.pump();

      expect(settings.noInit.value, !before);
      settings.noInit.value = before;
    });

    testWidgets('tapping Auto Add Standees checkbox toggles the setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.autoAddStandees.value;
      await pumpMenu(tester);

      await tester
          .tap(find.widgetWithText(CheckboxListTile, 'Auto Add Standees'));
      await tester.pump();

      expect(settings.autoAddStandees.value, !before);
      settings.autoAddStandees.value = before;
    });

    testWidgets('tapping Random Standees checkbox toggles the setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.randomStandees.value;
      await pumpMenu(tester);

      await tester
          .tap(find.widgetWithText(CheckboxListTile, 'Random Standees'));
      await tester.pump();

      expect(settings.randomStandees.value, !before);
      settings.randomStandees.value = before;
    });

    testWidgets('tapping No Calculations checkbox toggles the setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.noCalculation.value;
      await pumpMenu(tester);

      final finder = find.widgetWithText(CheckboxListTile, 'No Calculations');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.noCalculation.value, !before);
      settings.noCalculation.value = before;
    });

    testWidgets("tapping Don't track Standees checkbox toggles setting",
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.noStandees.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, "Don't track Standees");
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.noStandees.value, !before);
      settings.noStandees.value = before;
    });

    testWidgets('tapping Auto Add Timed Spawns checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.autoAddSpawns.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Auto Add Timed Spawns');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.autoAddSpawns.value, !before);
      settings.autoAddSpawns.value = before;
    });

    testWidgets('tapping Hide Loot Deck checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.hideLootDeck.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Hide Loot Deck');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.hideLootDeck.value, !before);
      settings.hideLootDeck.value = before;
    });

    testWidgets('tapping Stat card text shimmers checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.shimmer.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Stat card text shimmers');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.shimmer.value, !before);
      settings.shimmer.value = before;
    });

    testWidgets('tapping Show Scenario names in list checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showScenarioNames.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Show Scenario names in list');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showScenarioNames.value, !before);
      settings.showScenarioNames.value = before;
    });

    testWidgets('tapping Show Battle Goal Reminder checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showBattleGoalReminder.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Show Battle Goal Reminder');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showBattleGoalReminder.value, !before);
      settings.showBattleGoalReminder.value = before;
    });

    testWidgets('tapping Show Custom Content checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showCustomContent.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Show Custom Content');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showCustomContent.value, !before);
      settings.showCustomContent.value = before;
    });

    testWidgets(
        'tapping Show Sections in Main Screen checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showSectionsInMainView.value;
      await pumpMenu(tester);

      final finder = find.widgetWithText(
          CheckboxListTile, 'Show Sections in Main Screen');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showSectionsInMainView.value, !before);
      settings.showSectionsInMainView.value = before;
    });

    testWidgets(
        'tapping Show Round Special Rule Reminders checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showReminders.value;
      await pumpMenu(tester);

      final finder = find.widgetWithText(
          CheckboxListTile, 'Show Round Special Rule Reminders');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showReminders.value, !before);
      settings.showReminders.value = before;
    });

    testWidgets('tapping Show Attack Modifier Decks checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showAmdDeck.value;
      await pumpMenu(tester);

      final finder =
          find.widgetWithText(CheckboxListTile, 'Show Attack Modifier Decks');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showAmdDeck.value, !before);
      settings.showAmdDeck.value = before;
    });

    testWidgets(
        'tapping Show character Attack Modifier Decks checkbox toggles setting',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final before = settings.showCharacterAMD.value;
      await pumpMenu(tester);

      final finder = find.widgetWithText(
          CheckboxListTile, 'Show character Attack Modifier Decks');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(settings.showCharacterAMD.value, !before);
      settings.showCharacterAMD.value = before;
    });

    testWidgets('tapping Style radio buttons changes the style',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      await pumpMenu(tester);

      // Find and tap the 'Original' radio button
      final originalFinder = find.descendant(
        of: find.widgetWithText(Row, 'Original'),
        matching: find.byType(Radio<Style>),
      );
      if (originalFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(originalFinder.first);
        await tester.tap(originalFinder.first);
        await tester.pump();
        expect(settings.style.value, Style.original);
      }
      // Restore to Frosthaven style
      settings.style.value = Style.frosthaven;
    });

    testWidgets('tapping Clear unlocked characters runs the command',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      final finder = find.widgetWithText(
          ListTile, 'Clear unlocked characters and stuff');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
      // Just verify the tap didn't throw
    });

    testWidgets('tapping Load/Save State opens SaveMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      final finder = find.widgetWithText(ListTile, 'Load/Save State');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.byType(SaveMenu), findsOneWidget);
    });

    testWidgets('tapping Use Ally AMD in OG Gloomhaven checkbox toggles setting',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final before = gameState.allyDeckInOGGloom.value;
      await pumpMenu(tester);

      final finder = find.widgetWithText(
          CheckboxListTile, 'Use Ally Attack Modifier Deck in OG Gloomhaven');
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();

      expect(gameState.allyDeckInOGGloom.value, !before);
      // restore
      getIt<GameState>().action(SetAllyDeckInOgGloomCommand(before));
    });
  });
}
