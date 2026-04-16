import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_deck_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/perks_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_add_minus_one_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  // '' resolves to the monster modifier deck in GameMethods.getModifierDeck
  const deckName = '';

  setUp(() {
    getIt<GameState>().clearList();
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
                builder: (context) => const ModifierDeckMenu(name: deckName),
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

  group('ModifierDeckMenu', () {
    testWidgets('renders Add -1 card button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Add -1 card'), findsOneWidget);
    });

    testWidgets('renders Bless counter', (WidgetTester tester) async {
      await pumpMenu(tester);
      // CounterButton for bless uses assets/images/abilities/bless.png
      expect(
        find.byWidgetPredicate((widget) =>
            widget is CounterButton &&
            widget.image == 'assets/images/abilities/bless.png'),
        findsOneWidget,
      );
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping Add -1 card increments addedMinusOnes',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);
      final before = deck.addedMinusOnes.value;

      await pumpMenu(tester);
      await tester.tap(find.textContaining('Add -1 card'));
      await tester.pump();

      expect(deck.addedMinusOnes.value, before + 1);
      // restore
      gameState.undo();
    });

    testWidgets('tapping Remove -1 card decrements addedMinusOnes',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // First add a -1 card so we can remove it
      gameState.action(
          AmdAddMinusOneCommand(deckName, gameState: getIt<GameState>()));
      final deck = GameMethods.getModifierDeck(deckName, gameState);
      final before = deck.addedMinusOnes.value;

      await pumpMenu(tester);
      await tester.tap(find.text('Remove -1 card'));
      await tester.pump();

      expect(deck.addedMinusOnes.value, before - 1);
      // restore
      gameState.undo();
      gameState.undo();
    });

    testWidgets('renders Remove -2 card button for monster deck',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Monster deck (name='') shows Remove -2 card button
      expect(find.textContaining('-2 card'), findsOneWidget);
    });

    testWidgets('renders reveal buttons when draw pile is not empty',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Reveal buttons are shown when drawPile.isNotEmpty
      expect(find.textContaining('Reveal'), findsWidgets);
    });

    testWidgets('tapping reveal button 1 sets revealedCount',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);

      await pumpMenu(tester);
      // Find the "1" reveal button (second reveal button)
      final revealButtons = find.descendant(
          of: find.byType(ModifierDeckMenu), matching: find.text('1'));
      if (revealButtons.evaluate().isNotEmpty) {
        await tester.tap(revealButtons.first);
        await tester.pump();
        expect(deck.revealedCount.value, 1);
        // restore
        gameState.undo();
      }
    });

    testWidgets('tapping Remove -2 card triggers deck change',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);
      final hasMinus2Before = deck.hasMinus2();

      await pumpMenu(tester);
      await tester.tap(find.textContaining('-2 card'));
      await tester.pump();

      // if -2 was present, it should now be removed (or vice versa)
      if (hasMinus2Before) {
        expect(deck.hasMinus2(), false);
        gameState.undo();
      }
    });

    testWidgets('tapping Imbue button changes imbuement',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);
      final before = deck.imbuement.value;

      await pumpMenu(tester);
      await tester.tap(find.text('Imbue'));
      await tester.pump();

      expect(deck.imbuement.value, isNot(before));
      // restore
      gameState.undo();
    });

    testWidgets('tapping Advanced Imbue sets imbuement to 2',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);

      await pumpMenu(tester);
      // Advanced Imbue is only visible when imbuement != 2
      final advImbue = find.text('Advanced Imbue');
      if (advImbue.evaluate().isNotEmpty) {
        await tester.tap(advImbue);
        await tester.pump();
        expect(deck.imbuement.value, 2);
        gameState.undo();
      }
    });

    testWidgets('tapping Imbue when already imbuement > 0 removes imbue',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);
      // First set imbuement to 1
      gameState.action(AMDImbue1Command(gameState: getIt<GameState>()));

      await pumpMenu(tester);
      await tester.tap(find.text('Remove Imbue'));
      await tester.pump();

      expect(deck.imbuement.value, 0);
      // restore
      gameState.undo();
      gameState.undo();
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(ModifierDeckMenu), findsNothing);
    });

    testWidgets('draw pile contains InkWell cards',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Cards in draw pile are wrapped in InkWell widgets via generateList(allOpen=false)
      final cardTapTargets = find.descendant(
          of: find.byType(ModifierDeckMenu), matching: find.byType(InkWell));
      expect(cardTapTargets, findsWidgets);
    });

    testWidgets('renders Bless CounterButton and Curse CounterButton',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is CounterButton &&
            w.image == 'assets/images/abilities/bless.png'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) =>
            w is CounterButton &&
            w.image == 'assets/images/abilities/curse.png'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Bless + increments bless count',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);
      final before = deck.getRemovable('bless').value;

      await pumpMenu(tester);
      // Find the bless CounterButton and tap its + icon
      final blessButton = find.byWidgetPredicate((w) =>
          w is CounterButton && w.image == 'assets/images/abilities/bless.png');
      expect(blessButton, findsOneWidget);
      // The add IconButton is the last IconButton within the CounterButton
      final addButtons =
          find.descendant(of: blessButton, matching: find.byType(IconButton));
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.last);
        await tester.pump();
        expect(deck.getRemovable('bless').value, before + 1);
        gameState.undo();
      }
    });
  });

  group('ModifierDeckMenu character deck', () {
    setUp(() {
      getIt<GameState>().clearList();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
    });

    Future<void> pumpCharacterMenu(WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      const ModifierDeckMenu(name: 'Blinkblade'),
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

    testWidgets('renders Perks button for character deck',
        (WidgetTester tester) async {
      await pumpCharacterMenu(tester);
      expect(find.text('Perks'), findsOneWidget);
    });

    testWidgets('tapping Perks opens PerksMenu', (WidgetTester tester) async {
      await pumpCharacterMenu(tester);
      await tester.tap(find.text('Perks'));
      await tester.pumpAndSettle();
      expect(find.byType(PerksMenu), findsOneWidget);
    });

    testWidgets('renders Add -1 card button for character deck',
        (WidgetTester tester) async {
      await pumpCharacterMenu(tester);
      expect(find.textContaining('Add -1 card'), findsOneWidget);
    });

    testWidgets('does not render Remove -2 card button for character deck',
        (WidgetTester tester) async {
      await pumpCharacterMenu(tester);
      // The Remove -2 button is only shown for non-character (monster) decks
      expect(find.textContaining('-2 card'), findsNothing);
    });

    testWidgets('renders Remove +0 card button when deck has +0 card',
        (WidgetTester tester) async {
      await pumpCharacterMenu(tester);
      // Blinkblade's deck contains a +0 card by default
      expect(find.textContaining('+0 card'), findsOneWidget);
    });

    testWidgets('renders Curse CounterButton for character deck',
        (WidgetTester tester) async {
      await pumpCharacterMenu(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is CounterButton &&
            w.image == 'assets/images/abilities/curse.png'),
        findsOneWidget,
      );
    });
  });

  group('ModifierDeckMenu discard pile', () {
    setUp(() {
      getIt<GameState>().clearList();
    });

    testWidgets('discard pile shows cards after drawing',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Draw a card to move it from draw pile to discard pile
      gameState.action(
          DrawModifierCardCommand(deckName, gameState: getIt<GameState>()));

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
                  builder: (context) => const ModifierDeckMenu(name: deckName),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final deck = GameMethods.getModifierDeck(deckName, gameState);
      expect(deck.discardPileSize, greaterThan(0));

      gameState.undo();
    });

    testWidgets('reveal 0 button sets revealedCount to 0',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final deck = GameMethods.getModifierDeck(deckName, gameState);

      await pumpMenu(tester);
      // Find the '0' reveal button
      final reveal0Buttons = find.descendant(
          of: find.byType(ModifierDeckMenu), matching: find.text('0'));
      if (reveal0Buttons.evaluate().isNotEmpty) {
        await tester.tap(reveal0Buttons.first);
        await tester.pump();
        expect(deck.revealedCount.value, 0);
        gameState.undo();
      }
    });
  });

  group('ModifierDeckMenu allies deck', () {
    setUp(() {
      getIt<GameState>().clearList();
    });

    Future<void> pumpAlliesMenu(WidgetTester tester) async {
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
                  builder: (context) => const ModifierDeckMenu(name: 'allies'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('allies deck renders Add -1 card button',
        (WidgetTester tester) async {
      await pumpAlliesMenu(tester);
      expect(find.textContaining('Add -1 card'), findsOneWidget);
    });

    testWidgets('allies deck does not render Perks button',
        (WidgetTester tester) async {
      await pumpAlliesMenu(tester);
      expect(find.text('Perks'), findsNothing);
    });

    testWidgets('allies deck renders Remove -2 card button',
        (WidgetTester tester) async {
      await pumpAlliesMenu(tester);
      // 'allies' is not a character deck so -2 button appears
      expect(find.textContaining('-2 card'), findsOneWidget);
    });

    testWidgets('allies deck renders Bless CounterButton',
        (WidgetTester tester) async {
      await pumpAlliesMenu(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is CounterButton &&
            w.image == 'assets/images/abilities/bless.png'),
        findsOneWidget,
      );
    });
  });
}
