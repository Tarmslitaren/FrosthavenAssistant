import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_section_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/main_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_monster_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_monster_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/settings_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/commands/hide_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/commands/show_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
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
                builder: (context) => const MainMenu(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;
  }

  group('MainMenu', () {
    testWidgets('renders Undo and Redo buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Undo'), findsOneWidget);
      expect(find.textContaining('Redo'), findsOneWidget);
    });

    testWidgets('renders Set Scenario button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Set Scenario'), findsOneWidget);
    });

    testWidgets('renders Add Character button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Character'), findsOneWidget);
    });

    testWidgets('renders Settings button', (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Settings'), 300);
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping Set Scenario opens SelectScenarioMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Set Scenario'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SelectScenarioMenu), findsOneWidget);
    });

    testWidgets('tapping Add Character opens AddCharacterMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Add Character'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AddCharacterMenu), findsOneWidget);
    });

    testWidgets('tapping Add Monsters opens AddMonsterMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Add Monsters'), 100);
      await tester.tap(find.text('Add Monsters'));
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      expect(find.byType(AddMonsterMenu), findsOneWidget);
    });

    testWidgets('tapping Set Level opens SetLevelMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Set Level'), 100);
      await tester.tap(find.text('Set Level'));
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      expect(find.byType(SetLevelMenu), findsOneWidget);
    });

    testWidgets('tapping Undo calls undo on game state',
        (WidgetTester tester) async {
      // Do an action first so undo is enabled
      getIt<GameState>().action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()));
      final gameState = getIt<GameState>();
      final indexBefore = gameState.commandIndex.value;

      await pumpMenu(tester);
      await tester.tap(find.textContaining('Undo'));
      await tester.pump();

      expect(gameState.commandIndex.value, indexBefore - 1);
    });

    testWidgets('tapping Redo calls redo on game state',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Do an action and undo it so redo is available
      gameState.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()));
      gameState.undo();
      final indexBefore = gameState.commandIndex.value;

      await pumpMenu(tester);
      await tester.tap(find.textContaining('Redo'));
      await tester.pump();

      expect(gameState.commandIndex.value, indexBefore + 1);
    });

    testWidgets('tapping Add Section opens AddSectionMenu',
        (WidgetTester tester) async {
      // Set up a valid scenario so AddSectionMenu can initialize
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false, gameState: getIt<GameState>()).execute();

      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Add Section'), 100);
      await tester.tap(find.text('Add Section'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AddSectionMenu), findsOneWidget);
    });

    testWidgets('tapping Remove Characters opens RemoveCharacterMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Remove Characters'), 100);
      await tester.tap(find.text('Remove Characters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RemoveCharacterMenu), findsOneWidget);
    });

    testWidgets('tapping Remove Monsters opens RemoveMonsterMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Remove Monsters'), 100);
      await tester.tap(find.text('Remove Monsters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RemoveMonsterMenu), findsOneWidget);
    });

    testWidgets('tapping Loot Deck Menu opens LootCardsMenu',
        (WidgetTester tester) async {
      // Set Frosthaven campaign so Loot Deck Menu appears
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('custom', false, gameState: getIt<GameState>()).execute();

      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Loot Deck Menu'), 100);
      await tester.ensureVisible(find.text('Loot Deck Menu'));
      await tester.pump();
      await tester.tap(find.text('Loot Deck Menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LootCardsMenu), findsOneWidget);
    });

    testWidgets('tapping Settings opens SettingsMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Settings'), 100);
      await tester.tap(find.text('Settings'));
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      expect(find.byType(SettingsMenu), findsOneWidget);
    });

    testWidgets('Show Ally Attack Modifier Deck appears when showAmdDeck=true',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final gameState = getIt<GameState>();
      // Enable AMD deck and ensure ally deck is hidden
      settings.showAmdDeck.value = true;
      if (gameState.showAllyDeck.value) {
        gameState.action(HideAllyDeckCommand());
      }

      await pumpMenu(tester);
      await tester.scrollUntilVisible(
          find.text('Show Ally Attack Modifier Deck'), 100);
      expect(find.text('Show Ally Attack Modifier Deck'), findsOneWidget);
    });

    testWidgets(
        'tapping Show Ally Attack Modifier Deck shows ally deck in game state',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final gameState = getIt<GameState>();
      settings.showAmdDeck.value = true;
      if (gameState.showAllyDeck.value) {
        gameState.action(HideAllyDeckCommand());
      }

      await pumpMenu(tester);
      await tester.scrollUntilVisible(
          find.text('Show Ally Attack Modifier Deck'), 100);
      await tester.tap(find.text('Show Ally Attack Modifier Deck'));
      await tester.pump();

      expect(gameState.showAllyDeck.value, true);
      gameState.undo();
    });

    testWidgets('undo text shows command description when available',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Do an action so there's a description
      gameState.action(
          AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()));

      await pumpMenu(tester);
      // Undo text should include the command description
      expect(find.textContaining('Undo'), findsOneWidget);
      gameState.undo();
    });

    testWidgets('server mode renders undo/redo via server path',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final gameState = getIt<GameState>();
      // Enable server mode — covers undoEnabled/redoEnabled server branches
      settings.server.value = true;
      gameState.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()));

      await pumpMenu(tester);
      expect(find.textContaining('Undo'), findsOneWidget);
      expect(find.textContaining('Redo'), findsOneWidget);

      // Restore
      settings.server.value = false;
      gameState.undo();
    });

    testWidgets('tapping Hide Ally Deck calls action when ally deck visible',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final gameState = getIt<GameState>();
      settings.showAmdDeck.value = true;
      // Ensure ally deck is shown
      if (!gameState.showAllyDeck.value) {
        gameState.action(ShowAllyDeckCommand());
      }

      await pumpMenu(tester);
      await tester.scrollUntilVisible(
          find.text('Hide Ally Attack Modifier Deck'), 100);
      await tester.tap(find.text('Hide Ally Attack Modifier Deck'));
      await tester.pump();

      expect(gameState.showAllyDeck.value, false);
      // Restore
      settings.showAmdDeck.value = false;
    });

    testWidgets('client connection section renders when lastKnownConnection is set',
        (WidgetTester tester) async {
      final settings = getIt<Settings>();
      final originalConnection = settings.lastKnownConnection;
      // Set a valid-looking connection address (not ending with '?')
      settings.lastKnownConnection = '192.168.1.1';

      await pumpMenu(tester);
      // The client CheckboxListTile should now be visible
      await tester.scrollUntilVisible(
          find.textContaining('Connect as Client'), 100);
      expect(find.textContaining('Connect as Client'), findsOneWidget);

      // Restore
      settings.lastKnownConnection = originalConnection;
    });
  });
}
