// ignore_for_file: avoid-late-keyword

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/AbilityCardsMenu/ability_card_list_item.dart';
import 'package:frosthaven_assistant/Layout/menus/AbilityCardsMenu/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/MonsterAbilityCardWidget/monster_ability_card_front.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;
  late MonsterAbilityState abilityState;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand('Zealot', 1, false, gameState: getIt<GameState>())
        .execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    abilityState = getIt<GameState>().currentAbilityDecks.first;
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
                builder: (context) => AbilityCardsMenu(
                  monsterAbilityState: abilityState,
                  monsterData: monster,
                ),
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

  group('AbilityCardsMenu', () {
    testWidgets('renders Reveal cards label', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Reveal'), findsAtLeast(1));
    });

    testWidgets('renders Draw extra card button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Draw extra card'), findsOneWidget);
    });

    testWidgets('renders Extra Shuffle button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Extra Shuffle'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping Close dismisses the dialog',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AbilityCardsMenu), findsNothing);
    });
  });

  group('AbilityCardsMenu network sync', () {
    testWidgets(
        'menu reflects updated pile after loadFromData (network sync)',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();

      // Capture the initial state (no cards drawn yet)
      final cleanState = gameState.toString();

      await pumpMenu(tester);

      // Initially the discard pile is empty — no revealed (front-face) cards
      expect(
        tester
            .widgetList<AbilityCardListItem>(find.byType(AbilityCardListItem))
            .where((w) => w.revealed)
            .length,
        0,
        reason: 'Expected no revealed cards (empty discard pile) initially',
      );

      // Locally draw a card so the discard pile has 1 card
      gameState.action(DrawAbilityCardCommand(monster.id));
      await tester.pump();

      // The menu should now show 1 revealed (discard) card
      expect(
        tester
            .widgetList<AbilityCardListItem>(find.byType(AbilityCardListItem))
            .where((w) => w.revealed)
            .length,
        1,
        reason: 'Expected 1 revealed card after drawing',
      );

      // Simulate network sync: a remote device has "undone" the draw and sends
      // the clean state. loadFromData currently replaces _currentAbilityDecks
      // with new instances, leaving the widget's abilityState reference stale.
      gameState.loadFromData(cleanState);
      // Network sync also bumps commandIndex to trigger the VLB rebuild:
      gameState.commandIndex.value++;
      await tester.pump();

      // After fix: abilityState is updated in-place → discard pile = 0 → no revealed cards
      // Before fix (bug): abilityState stale → discard pile = 1 → still 1 revealed card
      expect(
        tester
            .widgetList<AbilityCardListItem>(find.byType(AbilityCardListItem))
            .where((w) => w.revealed)
            .length,
        0,
        reason:
            'Expected no revealed cards after network sync reset to clean state',
      );

      // The MonsterAbilityCardFront widgets come from revealed AbilityCardListItems
      expect(find.byType(MonsterAbilityCardFront), findsNothing,
          reason:
              'Expected no front-face cards after network sync reset to clean state');
    });
  });
}
