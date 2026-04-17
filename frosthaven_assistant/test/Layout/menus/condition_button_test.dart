// ignore_for_file: avoid-late-keyword

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/condition_button.dart';
import 'package:frosthaven_assistant/Resource/commands/add_condition_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;
  late MonsterInstance standee;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand("Zealot", 1, false, gameState: getIt<GameState>())
        .execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    AddStandeeCommand(1, null, monster.id, MonsterType.normal, false,
            gameState: getIt<GameState>())
        .execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    standee = monster.monsterInstances.first;
  });

  Widget buildConditionButton({
    required Condition condition,
    required String figureId,
    required String? ownerId,
    List<String> immunities = const [],
  }) {
    return MaterialApp(
      home: Material(
        child: ConditionButton(
          condition: condition,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: 1.0,
        ),
      ),
    );
  }

  group('ConditionButton', () {
    testWidgets('renders a button when the figure exists',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final figureId = standee.getId();

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.stun,
        figureId: figureId,
        ownerId: monster.id,
      ));

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('returns empty SizedBox when figure does not exist',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.stun,
        figureId: 'nonexistent-figure-id',
        ownerId: monster.id,
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 0);
      expect(sizedBox.height, 0);
    });

    testWidgets('tapping an inactive condition adds it to the figure',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final figureId = standee.getId();
      expect(standee.conditions.value, isNot(contains(Condition.stun)));

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.stun,
        figureId: figureId,
        ownerId: monster.id,
      ));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(standee.conditions.value, contains(Condition.stun));
    });

    testWidgets('tapping an active condition removes it from the figure',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final figureId = standee.getId();

      // Add the condition first
      getIt<GameState>().action(AddConditionCommand(
          Condition.muddle, figureId, monster.id,
          gameState: getIt<GameState>()));
      expect(standee.conditions.value, contains(Condition.muddle));

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.muddle,
        figureId: figureId,
        ownerId: monster.id,
      ));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(standee.conditions.value, isNot(contains(Condition.muddle)));
    });

    testWidgets(
        'button is disabled and shows immunity overlay for immune condition',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final figureId = standee.getId();

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.stun,
        figureId: figureId,
        ownerId: monster.id,
        immunities: const ['(stun)'],
      ));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('infect is disabled when immune to poison',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final figureId = standee.getId();

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.infect,
        figureId: figureId,
        ownerId: monster.id,
        immunities: const ['(poison)'],
      ));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('rupture is disabled when immune to wound',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final figureId = standee.getId();

      await tester.pumpWidget(buildConditionButton(
        condition: Condition.rupture,
        figureId: figureId,
        ownerId: monster.id,
        immunities: const ['(wound)'],
      ));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });
  });
}
