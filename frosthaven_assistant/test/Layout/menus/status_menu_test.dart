import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/condition_button.dart';
import 'package:frosthaven_assistant/Layout/menus/status_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
  });

  Character _getBlinkblade() {
    return getIt<GameState>()
        .currentList
        .firstWhere((item) => item.id == 'Blinkblade') as Character;
  }

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    final character = _getBlinkblade();
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatusMenu(
                  figureId: character.id,
                  characterId: character.id,
                  monsterId: null,
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

  group('StatusMenu', () {
    testWidgets('renders health counter image', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/abilities/heal.png'),
        findsWidgets,
      );
    });

    testWidgets('renders condition buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      // ConditionButton widgets are rendered for the standard set of conditions
      expect(find.byType(ConditionButton), findsWidgets);
    });

    testWidgets('tapping a condition button adds the condition to the character',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      final character = _getBlinkblade();
      final conditionsBefore =
          List<Condition>.from(character.characterState.conditions.value);

      // Find the stun ConditionButton and tap it
      final stunButtons = find.byWidgetPredicate((widget) =>
          widget is ConditionButton && widget.condition == Condition.stun);
      expect(stunButtons, findsOneWidget);
      await tester.tap(stunButtons);
      await tester.pumpAndSettle();

      expect(
        character.characterState.conditions.value,
        isNot(equals(conditionsBefore)),
      );
      expect(
        character.characterState.conditions.value,
        contains(Condition.stun),
      );
    });
  });
}
