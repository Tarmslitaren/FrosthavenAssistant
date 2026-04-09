import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/auto_add_standee_menu.dart';
import 'package:frosthaven_assistant/Model/room.dart';
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

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand('Zealot', 1, false).execute();
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    // One normal standee slot for Zealot
    final monsterData = [
      const RoomMonsterData('Zealot', [1, 0, 0], [0, 0, 0]),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    AutoAddStandeeMenu(monsterData: monsterData),
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

  group('AutoAddStandeeMenu', () {
    testWidgets('renders the monster name', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Zealot'), findsAtLeast(1));
    });

    testWidgets('renders numbered standee buttons', (WidgetTester tester) async {
      await pumpMenu(tester);
      // Standee buttons 1 through some number should be visible
      expect(find.text('1'), findsAtLeast(1));
    });

    testWidgets('renders Summoned label', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Summoned'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsAtLeast(1));
    });

    testWidgets('tapping standee button 1 adds a standee to the monster',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final monster = gameState.currentList
          .firstWhere((e) => e is Monster) as Monster;
      final instancesBefore = monster.monsterInstances.length;

      await pumpMenu(tester);
      // Tap the "1" standee number button
      final button1 = find.text('1');
      if (button1.evaluate().isNotEmpty) {
        await tester.tap(button1.first);
        // Verify standee was added before further pumping
        expect(monster.monsterInstances.length, greaterThan(instancesBefore));
        // Ignore errors from dialog closing animation
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;
        await tester.pump();
        FlutterError.onError = originalOnError;
      }
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AutoAddStandeeMenu), findsNothing);
    });

    testWidgets('renders Summoned checkbox unchecked by default',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('Summoned checkbox has onChanged callback',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      // Verify the checkbox is interactive (has an onChanged handler)
      expect(checkbox.onChanged, isNotNull);
    });

    testWidgets('already-added standee button still renders',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Add standee 1 so it's already out
      gameState.action(
          AddStandeeCommand(1, null, 'Zealot', MonsterType.normal, false));

      await pumpMenu(tester);
      // Button '1' should still render (greyed out, but visible)
      expect(find.text('1'), findsAtLeast(1));

      gameState.undo();
    });
  });

  group('AutoAddStandeeMenu summoned checkbox', () {
    testWidgets('invoking Summoned checkbox onChanged does not throw',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await pumpMenu(tester);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(
        () => checkbox.onChanged?.call(true),
        returnsNormally,
      );
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pump();
      FlutterError.onError = originalOnError;
    });
  });

  group('AutoAddStandeeMenu large standee count', () {
    setUp(() {
      getIt<GameState>().clearList();
      AddMonsterCommand('Rat Monstrosity', 1, false).execute();
    });

    Future<void> pumpLargeMenu(WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final monsterData = [
        const RoomMonsterData('Rat Monstrosity', [6, 0, 0], [0, 0, 0]),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AutoAddStandeeMenu(monsterData: monsterData),
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

    testWidgets('monster with 10 standees renders buttons through 10 and pluralizes name',
        (WidgetTester tester) async {
      await pumpLargeMenu(tester);
      // Rat Monstrosity ends with 'y' → _pluralize → 'Monstrosities'
      expect(find.textContaining('Monstrosit'), findsAtLeast(1));
      // Buttons 9 and 10 visible for monster with count=10
      expect(find.text('9'), findsAtLeast(1));
      expect(find.text('10'), findsAtLeast(1));
    });
  });

  group('AutoAddStandeeMenu two-monster progression', () {
    setUp(() {
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      AddMonsterCommand('Vermling Raider', 1, false).execute();
    });

    testWidgets('while-loop skips zero-standee monster to next',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      // First monster needs 0 standees — while loop advances to Vermling Raider
      final monsterData = [
        const RoomMonsterData('Zealot', [0, 0, 0], [0, 0, 0]),
        const RoomMonsterData('Vermling Raider', [1, 0, 0], [0, 0, 0]),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AutoAddStandeeMenu(monsterData: monsterData),
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
      // After skipping Zealot (0 needed), menu should show Vermling Raider
      expect(find.textContaining('Vermling'), findsAtLeast(1));
    });

    testWidgets('tapping standee for first monster advances to second monster',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final monsterData = [
        const RoomMonsterData('Zealot', [1, 0, 0], [0, 0, 0]),
        const RoomMonsterData('Vermling Raider', [1, 0, 0], [0, 0, 0]),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AutoAddStandeeMenu(monsterData: monsterData),
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

      // Tap standee 1 for Zealot to complete first monster
      final button1 = find.text('1');
      if (button1.evaluate().isNotEmpty) {
        FlutterError.onError = ignoreOverflowErrors;
        await tester.tap(button1.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        FlutterError.onError = originalOnError;
        // Menu should now show Vermling Raider
        expect(find.textContaining('Vermling'), findsAtLeast(1));
      }
    });
  });

  group('AutoAddStandeeMenu elite standees', () {
    Future<void> pumpEliteMenu(WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      // characterIndex=0: normal[0]=0, elite[0]=1
      final monsterData = [
        const RoomMonsterData('Zealot', [0, 0, 0], [1, 0, 0]),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AutoAddStandeeMenu(monsterData: monsterData),
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

    testWidgets('renders Elite title for elite-only monster data',
        (WidgetTester tester) async {
      await pumpEliteMenu(tester);
      expect(find.textContaining('Elite'), findsAtLeast(1));
    });

    testWidgets('tapping elite standee button 1 adds an elite standee',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final monster =
          gameState.currentList.firstWhere((e) => e is Monster) as Monster;
      final instancesBefore = monster.monsterInstances.length;

      await pumpEliteMenu(tester);
      final button1 = find.text('1');
      if (button1.evaluate().isNotEmpty) {
        await tester.tap(button1.first);
        expect(monster.monsterInstances.length, greaterThan(instancesBefore));
        if (monster.monsterInstances.isNotEmpty) {
          expect(monster.monsterInstances.last.type, MonsterType.elite);
        }
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;
        await tester.pump();
        FlutterError.onError = originalOnError;
      }
    });
  });
}
