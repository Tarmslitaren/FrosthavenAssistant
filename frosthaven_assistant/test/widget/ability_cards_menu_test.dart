import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_card_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;
  late MonsterAbilityState monsterAbilityState;

  // We use a separate setUp function to reset the game state before each test.
  // This ensures that our tests are independent and not affecting each other.
  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand("Zealot", 1, false).execute();
    DrawAbilityCardCommand("Zealot").execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    monsterAbilityState = getIt<GameState>().currentAbilityDecks.first;
  });

  // A helper function to pump the AbilityCardsMenu widget within a test.
  Future<void> pumpAbilityCardsMenu(WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AbilityCardsMenu(
                    monsterAbilityState: monsterAbilityState,
                    monsterData: monster,
                  ),
                );
              },
              child: const Text('Show Menu'),
            );
          },
        ),
      ),
    );

    // Open the dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }

  group('AbilityCardsMenu', () {
    testWidgets('should display piles and be dismissible',
        (WidgetTester tester) async {
      // Arrange & Act
      await pumpAbilityCardsMenu(tester);

      // Assert: Check for key widgets
      expect(find.byType(AbilityCardsMenu), findsOneWidget);
      expect(find.textRange.ofSubstring('Reveal'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Act: Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Assert: Dialog is gone
      expect(find.byType(AbilityCardsMenu), findsNothing);
    });

    testWidgets('should reveal a card when reveal button is tapped',
        (WidgetTester tester) async {
      // Arrange
      await pumpAbilityCardsMenu(tester);
      // Initially, all cards in the draw pile are hidden.
      // We expect to find the back of the card.
      // expect(find.byKey(const Key("rear")), findsWidgets);

      // Act
      await tester.tap(find.widgetWithText(TextButton, '1'));
      await tester.pumpAndSettle();

      // Assert
      // After tapping '1', at least one card should be revealed.
      // We find the specific card by its key and check if it is revealed.
      final item = tester.widget<Item>(find
          .byKey(Key(monsterAbilityState.discardPile.peek.nr.toString()))
          .last
          .first);
      expect(item.revealed, isTrue);
    });

    testWidgets('should draw an extra card', (WidgetTester tester) async {
      // Arrange
      await pumpAbilityCardsMenu(tester);
      final initialDiscardCount = monsterAbilityState.discardPile.size();

      // Act
      await tester.tap(find.text('Draw extra card'));
      await tester.pumpAndSettle();

      // Assert
      final newDiscardCount = monsterAbilityState.discardPile.size();
      expect(newDiscardCount, initialDiscardCount + 1);
    });

    testWidgets('should shuffle the deck', (WidgetTester tester) async {
      // Arrange
      await pumpAbilityCardsMenu(tester);
      expect(monsterAbilityState.discardPile.isNotEmpty, isTrue);

      // Act
      await tester.tap(find.text('Extra Shuffle'));
      await tester.pumpAndSettle();

      // Assert
      expect(monsterAbilityState.discardPile.isEmpty, isTrue);
    });

    testWidgets('should toggle monster active state',
        (WidgetTester tester) async {
      // Arrange
      await pumpAbilityCardsMenu(tester);
      final initialActiveState = monster.isActive;
      final buttonText =
          initialActiveState ? 'Inactivate\nMonster' : 'Activate\nMonster';

      // Act
      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      // Assert
      expect(monster.isActive, !initialActiveState);
    });

    testWidgets('tapping a card opens RemoveCardMenu',
        (WidgetTester tester) async {
      // Arrange
      await pumpAbilityCardsMenu(tester);
      // We need to find a card to tap. Let's tap the first one in the discard pile.
      final cardToTap = monsterAbilityState.discardPile.peek;

      // Act
      await tester.tap(find.byKey(Key(cardToTap.nr.toString())).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RemoveCardMenu), findsOneWidget);
    });
  });
}
