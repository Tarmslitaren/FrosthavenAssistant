import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_card_menu.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late MonsterAbilityState abilityState;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand("Zealot", 1, false, gameState: getIt<GameState>()).execute();
    DrawAbilityCardCommand("Zealot").execute();
    abilityState = getIt<GameState>().currentAbilityDecks.first;
  });

  Future<void> pumpMenu(
      WidgetTester tester, MonsterAbilityCardModel card) async {
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
                builder: (context) => RemoveCardMenu(card: card),
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

  group('RemoveCardMenu', () {
    testWidgets('shows remove button with card title for a discard pile card',
        (WidgetTester tester) async {
      final card = abilityState.discardPileTop;
      await pumpMenu(tester, card);

      expect(
          find.textContaining('Remove ${card.title}'), findsOneWidget);
    });

    testWidgets(
        'does not show "Send to Bottom" for a card not in the draw pile',
        (WidgetTester tester) async {
      final card = abilityState.discardPileTop;
      await pumpMenu(tester, card);

      expect(find.text('Send to Bottom'), findsNothing);
      expect(find.text('Shuffle un-drawn Cards'), findsNothing);
    });

    testWidgets('shows "Send to Bottom" for a card still in the draw pile',
        (WidgetTester tester) async {
      final drawCard = abilityState.drawPileTop;
      await pumpMenu(tester, drawCard);

      expect(find.text('Send to Bottom'), findsOneWidget);
      expect(find.text('Shuffle un-drawn Cards'), findsOneWidget);
    });

    testWidgets('tapping remove button removes the card and closes the dialog',
        (WidgetTester tester) async {
      final card = abilityState.discardPileTop;
      await pumpMenu(tester, card);

      await tester.tap(find.textContaining('Remove ${card.title}'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveCardMenu), findsNothing);
      // RemoveCardCommand also shuffles + redraws — verify the card is gone
      final allCards = [
        ...abilityState.drawPileContents.toList(),
        ...abilityState.discardPileContents.toList(),
      ];
      expect(allCards.any((c) => c.nr == card.nr), isFalse);
    });

    testWidgets(
        'tapping "Send to Bottom" reorders draw pile and closes the dialog',
        (WidgetTester tester) async {
      final drawCard = abilityState.drawPileTop;
      final drawSizeBefore = abilityState.drawPileSize;
      await pumpMenu(tester, drawCard);

      await tester.tap(find.text('Send to Bottom'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveCardMenu), findsNothing);
      expect(abilityState.drawPileSize, drawSizeBefore);
    });

    testWidgets(
        'tapping "Shuffle un-drawn Cards" shuffles draw pile and closes the dialog',
        (WidgetTester tester) async {
      final drawCard = abilityState.drawPileTop;
      await pumpMenu(tester, drawCard);

      await tester.tap(find.text('Shuffle un-drawn Cards'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveCardMenu), findsNothing);
    });
  });
}
