// ignore_for_file: avoid-late-keyword

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
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
}
