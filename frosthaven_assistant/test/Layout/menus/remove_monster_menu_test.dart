import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_monster_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late String zealotDisplay;
  late String artilleryDisplay;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand("Zealot", 1, false).execute();
    AddMonsterCommand("Ancient Artillery (FH)", 1, false).execute();
    final monsters =
        getIt<GameState>().currentList.whereType<Monster>().toList();
    zealotDisplay = monsters.firstWhere((m) => m.id == 'Zealot').type.display;
    artilleryDisplay = monsters
        .firstWhere((m) => m.id == 'Ancient Artillery (FH)')
        .type
        .display;
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
                builder: (context) => const RemoveMonsterMenu(),
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

  group('RemoveMonsterMenu', () {
    testWidgets('renders the "Remove All" option', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Remove All'), findsOneWidget);
    });

    testWidgets('renders the "Close" button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('lists all currently added monsters',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text(zealotDisplay), findsOneWidget);
      expect(find.text(artilleryDisplay), findsOneWidget);
    });

    testWidgets('tapping "Remove All" removes all monsters and closes dialog',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      await tester.tap(find.text('Remove All'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveMonsterMenu), findsNothing);
      final monsters =
          getIt<GameState>().currentList.whereType<Monster>().toList();
      expect(monsters, isEmpty);
    });

    testWidgets('tapping a monster tile removes only that monster',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      await tester.tap(find.text(zealotDisplay));
      await tester.pumpAndSettle();

      final monsters =
          getIt<GameState>().currentList.whereType<Monster>().toList();
      expect(monsters.length, 1);
      expect(monsters.first.type.display, artilleryDisplay);
    });

    testWidgets('tapping "Close" dismisses the dialog without changes',
        (WidgetTester tester) async {
      await pumpMenu(tester);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveMonsterMenu), findsNothing);
      final monsters =
          getIt<GameState>().currentList.whereType<Monster>().toList();
      expect(monsters.length, 2);
    });
  });
}
