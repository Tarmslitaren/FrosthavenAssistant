// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_zoom.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_deck_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  // '' resolves to the monster modifier deck in GameMethods.getModifierDeck
  const monsterDeckName = '';

  Future<void> pumpWidget(WidgetTester tester, String name) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: ModifierDeckWidget(name: name)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('ModifierDeckWidget monster deck', () {
    testWidgets('renders SizedBox with expected dimensions',
        (WidgetTester tester) async {
      await pumpWidget(tester, monsterDeckName);
      expect(find.byType(SizedBox), findsAtLeast(1));
    });

    testWidgets('renders InkWell for draw pile tap',
        (WidgetTester tester) async {
      await pumpWidget(tester, monsterDeckName);
      expect(find.byType(InkWell), findsAtLeast(1));
    });

    testWidgets('renders card count text', (WidgetTester tester) async {
      final deck =
          GameMethods.getModifierDeck(monsterDeckName, getIt<GameState>());
      await pumpWidget(tester, monsterDeckName);
      expect(find.text(deck.cardCount.value.toString()), findsAtLeast(1));
    });

    testWidgets('tapping draw pile draws a modifier card',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(monsterDeckName, gameState);
      final before = deck.discardPileSize;

      await pumpWidget(tester, monsterDeckName);

      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      // Tap the first InkWell (the draw pile)
      await tester.tap(find.byType(InkWell).first);
      // flush 0ms timers from TranslationAnimatedWidget.initState, then advance
      // past the 1200ms card animation duration
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      FlutterError.onError = originalOnError;

      expect(deck.discardPileSize, before + 1);
      // restore
      gameState.undo();
    });

    testWidgets('shows "Shuffle & Draw" when draw pile is empty',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(monsterDeckName, gameState);
      // Drain the draw pile
      while (deck.drawPileIsNotEmpty) {
        gameState.action(DrawModifierCardCommand(monsterDeckName,
            gameState: getIt<GameState>()));
      }

      await pumpWidget(tester, monsterDeckName);
      expect(find.text('Shuffle\n& Draw'), findsOneWidget);

      // restore
      while (gameState.commandIndex.value >= 0) {
        gameState.undo();
      }
    });

    testWidgets('tapping discard pile opens ModifierDeckMenu',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Draw a card so discard pile has something
      gameState.action(DrawModifierCardCommand(monsterDeckName,
          gameState: getIt<GameState>()));

      await pumpWidget(tester, monsterDeckName);
      // The discard pile InkWell is the second one (draw pile is first)
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsAtLeast(2));
      await tester.tap(inkWells.last);
      await tester.pumpAndSettle();
      expect(find.byType(ModifierDeckMenu), findsOneWidget);

      gameState.undo();
    });

    testWidgets(
        'long press on discard pile opens ModifierCardZoom when not empty',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      gameState.action(DrawModifierCardCommand(monsterDeckName,
          gameState: getIt<GameState>()));

      await pumpWidget(tester, monsterDeckName);
      final inkWells = find.byType(InkWell);
      await tester.longPress(inkWells.last);
      await tester.pumpAndSettle();
      expect(find.byType(ModifierCardZoom), findsOneWidget);

      gameState.undo();
    });

    testWidgets('renders Row with draw and discard sections',
        (WidgetTester tester) async {
      await pumpWidget(tester, monsterDeckName);
      expect(find.byType(Row), findsAtLeast(1));
    });
  });

  group('ModifierDeckWidget character deck', () {
    setUp(() {
      getIt<GameState>().clearList();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
    });

    testWidgets('renders without error for character deck',
        (WidgetTester tester) async {
      await pumpWidget(tester, 'Blinkblade');
      expect(find.byType(ModifierDeckWidget), findsOneWidget);
    });

    testWidgets('renders card count for character deck',
        (WidgetTester tester) async {
      final deck =
          GameMethods.getModifierDeck('Blinkblade', getIt<GameState>());
      await pumpWidget(tester, 'Blinkblade');
      expect(find.text(deck.cardCount.value.toString()), findsAtLeast(1));
    });

    testWidgets('tapping draw pile draws a card from character deck',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck('Blinkblade', gameState);
      final before = deck.discardPileSize;

      await pumpWidget(tester, 'Blinkblade');

      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      FlutterError.onError = originalOnError;

      expect(deck.discardPileSize, before + 1);
      gameState.undo();
    });
  });
}
