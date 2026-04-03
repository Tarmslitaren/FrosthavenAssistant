import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/removed_modifier_card_menu.dart';
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
    // Draw a card to populate the discard pile, then remove it to the removed pile
    DrawModifierCardCommand(deckName).execute();
    RemoveAMDCardCommand(0, deckName).execute();
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
                    const RemovedModifierCardMenu(name: deckName),
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

  group('RemovedModifierCardMenu', () {
    testWidgets('renders Removed cards header', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Removed cards'), findsOneWidget);
    });

    testWidgets('renders removed cards in the list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      final deck = getIt<GameState>().modifierDeck;
      final removedCount = deck.removedPile.size();
      expect(removedCount, greaterThan(0));
      // The Item widgets are rendered inside the list for each removed card
      expect(find.byType(Item), findsWidgets);
    });
  });
}
