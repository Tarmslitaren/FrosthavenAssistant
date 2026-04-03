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
      getIt<GameState>().action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1));
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
      gameState.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1));
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
      SetScenarioCommand('#0 Howling in the Snow', false).execute();

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
      SetScenarioCommand('custom', false).execute();

      await pumpMenu(tester);
      await tester.scrollUntilVisible(find.text('Loot Deck Menu'), 100);
      await tester.ensureVisible(find.text('Loot Deck Menu'));
      await tester.pump();
      await tester.tap(find.text('Loot Deck Menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LootCardsMenu), findsOneWidget);
    });
  });
}
