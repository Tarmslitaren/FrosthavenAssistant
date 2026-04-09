import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/return_amd_card_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_amd_card_command.dart';
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
    // Draw then remove a card to populate the removed pile
    DrawModifierCardCommand(deckName).execute();
    RemoveAMDCardCommand(0, deckName).execute();
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
                    const ReturnAMDCardMenu(index: 0, name: deckName),
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

  group('ReturnAMDCardMenu', () {
    testWidgets('renders the "Return card to discard pile" button',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Return card to discard pile'), findsOneWidget);
    });

    testWidgets(
        'tapping the button returns the card to the discard pile and closes the dialog',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final removedBefore = deck.removedPileSize;
      final discardBefore = deck.discardPileSize;
      await pumpMenu(tester);

      await tester.tap(find.text('Return card to discard pile'));
      await tester.pumpAndSettle();

      expect(find.byType(ReturnAMDCardMenu), findsNothing);
      expect(deck.removedPileSize, removedBefore - 1);
      expect(deck.discardPileSize, discardBefore + 1);
    });
  });
}
