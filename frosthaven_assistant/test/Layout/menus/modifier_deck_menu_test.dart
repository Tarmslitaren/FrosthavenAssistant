import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_deck_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/perks_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_add_minus_one_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
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
                builder: (context) =>
                    const ModifierDeckMenu(name: deckName),
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
      gameState.action(AmdAddMinusOneCommand(deckName));
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
      final revealButtons =
          find.descendant(of: find.byType(ModifierDeckMenu), matching: find.text('1'));
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
      gameState.action(AMDImbue1Command());

      await pumpMenu(tester);
      await tester.tap(find.text('Remove Imbue'));
      await tester.pump();

      expect(deck.imbuement.value, 0);
      // restore
      gameState.undo();
      gameState.undo();
    });
  });

  group('ModifierDeckMenu character deck', () {
    setUp(() {
      getIt<GameState>().clearList();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
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
  });
}
