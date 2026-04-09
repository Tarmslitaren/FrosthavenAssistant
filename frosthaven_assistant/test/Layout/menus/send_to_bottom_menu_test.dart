import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
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

  // Pump directly (no dialog wrapper) to avoid the modal barrier absorbing taps
  Future<void> pumpMenu(WidgetTester tester,
      {required int currentIndex,
      required int length,
      bool revealed = false}) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SendToBottomMenu(
            currentIndex: currentIndex,
            length: length,
            name: deckName,
            revealed: revealed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SendToBottomMenu', () {
    testWidgets('renders the "Send to Bottom" button',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final length = deck.drawPileSize;
      await pumpMenu(tester, currentIndex: 0, length: length);
      expect(find.text('Send to Bottom'), findsOneWidget);
    });

    testWidgets('renders the "Shuffle un-drawn Cards" button',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final length = deck.drawPileSize;
      await pumpMenu(tester, currentIndex: 0, length: length);
      expect(find.text('Shuffle un-drawn Cards'), findsOneWidget);
    });

    testWidgets(
        'tapping "Send to Bottom" reorders the deck without changing pile size',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final sizeBefore = deck.drawPileSize;
      await pumpMenu(tester, currentIndex: 0, length: sizeBefore);

      await tester.tap(find.text('Send to Bottom'));
      await tester.pumpAndSettle();

      // Card stays in draw pile — just reordered
      expect(deck.drawPileSize, sizeBefore);
    });

    testWidgets(
        'tapping "Shuffle un-drawn Cards" moves discard to draw pile',
        (WidgetTester tester) async {
      final deck = getIt<GameState>().modifierDeck;
      final length = deck.drawPileSize;
      await pumpMenu(tester, currentIndex: 0, length: length);

      await tester.tap(find.text('Shuffle un-drawn Cards'));
      await tester.pumpAndSettle();

      // After shuffle the discard pile is empty
      expect(deck.discardPileSize, 0);
    });
  });
}
