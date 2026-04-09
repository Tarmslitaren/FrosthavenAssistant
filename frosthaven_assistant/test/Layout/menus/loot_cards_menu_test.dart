import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/character_loot_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_card_enhancement_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_special_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove__special_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    // Set Frosthaven campaign with 'custom' scenario to populate loot deck
    // without triggering monster creation (which fails in test data)
    SetCampaignCommand('Frosthaven').execute();
    SetScenarioCommand('custom', false).execute();
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
                builder: (context) => const LootCardsMenu(),
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

  group('LootCardsMenu', () {
    testWidgets('renders Character loot button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Character loot'), findsOneWidget);
    });

    testWidgets('renders Enhance cards button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Enhance cards'), findsOneWidget);
    });

    testWidgets('renders Add Card button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Card'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping Character loot opens CharacterLootMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Character loot'));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterLootMenu), findsOneWidget);
    });

    testWidgets('tapping Enhance cards opens LootCardEnhancementMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Enhance cards'));
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;
      expect(find.byType(LootCardEnhancementMenu), findsOneWidget);
    });

    testWidgets('tapping Add card 1418 toggles its presence',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final hadBefore = gameState.lootDeck.hasCard1418;
      await pumpMenu(tester);

      final buttonText = hadBefore ? 'Remove card 1418' : 'Add card 1418';
      await tester.tap(find.text(buttonText));
      await tester.pump();

      expect(gameState.lootDeck.hasCard1418, !hadBefore);
      // restore
      gameState.action(hadBefore
          ? AddSpecialLootCardCommand(1418)
          : RemoveSpecialLootCardCommand(1418));
    });

    testWidgets('Return to Top button appears when discard pile has cards',
        (WidgetTester tester) async {
      // Draw a loot card to populate the discard pile
      getIt<GameState>().action(DrawLootCardCommand());
      await pumpMenu(tester);
      expect(find.text('Return to Top'), findsOneWidget);
    });

    testWidgets('tapping Return to Top moves card from discard to draw pile',
        (WidgetTester tester) async {
      getIt<GameState>().action(DrawLootCardCommand());
      final gameState = getIt<GameState>();
      final discardBefore = gameState.lootDeck.discardPileSize;
      final drawBefore = gameState.lootDeck.drawPileSize;

      await pumpMenu(tester);
      await tester.tap(find.text('Return to Top'));
      await tester.pump();

      expect(gameState.lootDeck.discardPileSize, discardBefore - 1);
      expect(gameState.lootDeck.drawPileSize, drawBefore + 1);
    });
  });
}
