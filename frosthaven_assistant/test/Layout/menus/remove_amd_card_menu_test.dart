import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_amd_card_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
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
    // Draw a card to populate the discard pile
    DrawModifierCardCommand(deckName).execute();
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
                builder: (context) =>
                    const RemoveAMDCardMenu(index: 0, name: deckName),
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

  group('RemoveAMDCardMenu', () {
    testWidgets('renders the "Remove card?" button',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Remove card?'), findsOneWidget);
    });

    testWidgets('renders the "Return top card" button',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Return top card'), findsOneWidget);
    });

    testWidgets('tapping "Remove card?" removes the card from the discard pile',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final discardBefore = deck.discardPileSize;
      final removedBefore = deck.removedPileSize;
      await pumpMenu(tester);

      await tester.tap(find.text('Remove card?'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveAMDCardMenu), findsNothing);
      expect(deck.discardPileSize, discardBefore - 1);
      expect(deck.removedPileSize, removedBefore + 1);
    });

    testWidgets(
        'tapping "Return top card" moves the card back to the draw pile',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final discardBefore = deck.discardPileSize;
      final drawBefore = deck.drawPileSize;
      await pumpMenu(tester);

      await tester.tap(find.text('Return top card'));
      await tester.pumpAndSettle();

      expect(deck.discardPileSize, discardBefore - 1);
      expect(deck.drawPileSize, drawBefore + 1);
    });
  });
}
