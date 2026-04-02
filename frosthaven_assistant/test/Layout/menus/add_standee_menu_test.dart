import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_standee_menu.dart';
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

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand("Zealot", 1, false).execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
  });

  Future<void> pumpMenu(WidgetTester tester, {bool elite = false}) async {
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
                    AddStandeeMenu(monster: monster, elite: elite),
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

  group('AddStandeeMenu', () {
    testWidgets('renders the "Add Standee Nr" title',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Standee Nr'), findsOneWidget);
    });

    testWidgets('renders standee number buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders the "Summoned:" checkbox',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Summoned:'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('tapping a standee number adds a standee to the monster',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(monster.monsterInstances.length, 0);

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      final updated = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      expect(updated.monsterInstances.length, 1);
      expect(updated.monsterInstances.first.standeeNr, 1);
    });

    testWidgets('tapping an already occupied standee number does nothing',
        (WidgetTester tester) async {
      AddStandeeCommand(1, null, monster.id, MonsterType.normal, false)
          .execute();
      monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
          as Monster;
      await pumpMenu(tester);
      final countBefore = monster.monsterInstances.length;

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(monster.monsterInstances.length, countBefore);
    });

    testWidgets('Summoned checkbox is initially unchecked',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Check the Checkbox value via the widget state
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });
  });
}
