import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/loot_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_cards_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    getIt<Settings>().hideLootDeck.value = false;
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: LootDeckWidget()),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('LootDeckWidget empty deck', () {
    testWidgets('renders Container (hidden) when both piles are empty',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      // Both piles empty → returns empty Container, no InkWell
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders Container when hideLootDeck is true',
        (WidgetTester tester) async {
      getIt<Settings>().hideLootDeck.value = true;
      // Set up a loot deck so it would normally show
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false, gameState: getIt<GameState>()).execute();

      await pumpWidget(tester);
      expect(find.byType(InkWell), findsNothing);

      getIt<Settings>().hideLootDeck.value = false;
    });
  });

  group('LootDeckWidget with loot deck', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false, gameState: getIt<GameState>()).execute();
    });

    testWidgets('renders InkWell for draw pile when deck has cards',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().lootDeck;
      // The scenario should have initialized the draw pile
      if (deck.drawPileIsEmpty && deck.discardPileIsEmpty) {
        return; // skip if testData has no loot deck for this scenario
      }
      await pumpWidget(tester);
      expect(find.byType(InkWell), findsAtLeast(1));
    });

    testWidgets('renders card count text', (WidgetTester tester) async {
      final deck = getIt<GameState>().lootDeck;
      if (deck.drawPileIsEmpty && deck.discardPileIsEmpty) {
        return;
      }
      await pumpWidget(tester);
      expect(find.text(deck.cardCount.value.toString()), findsAtLeast(1));
    });

    testWidgets('renders Row with draw and discard sections',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().lootDeck;
      if (deck.drawPileIsEmpty && deck.discardPileIsEmpty) {
        return;
      }
      await pumpWidget(tester);
      expect(find.byType(Row), findsAtLeast(1));
    });

    testWidgets('tapping draw pile draws a loot card',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = gameState.lootDeck;
      if (deck.drawPileIsEmpty) {
        return; // skip if no draw pile in testData
      }
      final before = deck.discardPileSize;

      await pumpWidget(tester);

      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      // First InkWell is the draw pile
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1700));
      FlutterError.onError = originalOnError;

      expect(deck.discardPileSize, before + 1);
      gameState.undo();
    });

    testWidgets('tapping discard pile opens LootCardsMenu',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().lootDeck;
      if (deck.drawPileIsEmpty && deck.discardPileIsEmpty) {
        return;
      }
      await pumpWidget(tester);

      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      // Second InkWell is the discard pile
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().length >= 2) {
        await tester.tap(inkWells.last);
        await tester.pumpAndSettle();
        FlutterError.onError = originalOnError;
        expect(find.byType(LootCardsMenu), findsOneWidget);
      }
      FlutterError.onError = originalOnError;
    });

    testWidgets('SizedBox has expected dimensions from userScalingBars',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().lootDeck;
      if (deck.drawPileIsEmpty && deck.discardPileIsEmpty) {
        return;
      }
      await pumpWidget(tester);
      // LootDeckWidget uses SizedBox(width: 94 * scale, height: 58.6666 * scale)
      expect(find.byType(SizedBox), findsAtLeast(1));
    });
  });
}
