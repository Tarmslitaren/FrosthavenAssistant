import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/auto_add_standee_menu.dart';
import 'package:frosthaven_assistant/Model/room.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
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
  });
}
