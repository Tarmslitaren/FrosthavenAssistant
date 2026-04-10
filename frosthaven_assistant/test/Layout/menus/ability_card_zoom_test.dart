import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/ability_card_zoom.dart';
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
    AddMonsterCommand('Zealot', 1, false, gameState: getIt<GameState>()).execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    abilityState = getIt<GameState>().currentAbilityDecks.first;
  });

  Future<void> pumpZoom(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    final card = abilityState.drawPileContents.toList().first;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Material(
                  child: AbilityCardZoom(
                    card: card,
                    monster: monster,
                    calculateAll: false,
                  ),
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

  group('AbilityCardZoom', () {
    testWidgets('renders the ability card zoom widget',
        (WidgetTester tester) async {
      await pumpZoom(tester);
      expect(find.byType(AbilityCardZoom), findsOneWidget);
    });

    testWidgets('tapping the card dismisses the dialog',
        (WidgetTester tester) async {
      await pumpZoom(tester);
      await tester.tap(find.byType(AbilityCardZoom));
      await tester.pumpAndSettle();
      expect(find.byType(AbilityCardZoom), findsNothing);
    });
  });
}
