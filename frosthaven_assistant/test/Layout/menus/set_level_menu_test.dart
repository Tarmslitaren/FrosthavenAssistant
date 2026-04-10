import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    // Reset level to known value so the tap test is deterministic
    SetLevelCommand(0, null).execute();
  });

  Future<void> pumpMenu(WidgetTester tester, {Monster? monster}) async {
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
                builder: (context) => SetLevelMenu(monster: monster),
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

  group('SetLevelMenu — scenario level mode', () {
    testWidgets('renders "Set Scenario Level" title',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Set Scenario Level'), findsOneWidget);
    });

    testWidgets('renders level buttons 0 through 7',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // Levels 1-7 appear once; level 0 also appears as the "0" difficulty button
      for (int i = 1; i <= 7; i++) {
        expect(find.text(i.toString()), findsOneWidget,
            reason: 'Level button $i should be visible');
      }
      expect(find.text('0'), findsAtLeast(1),
          reason: 'Level button 0 should be visible');
    });

    testWidgets('renders Solo checkbox', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Solo:'), findsOneWidget);
    });

    testWidgets('renders Automatic Scenario Level checkbox',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Automatic Scenario Level:'), findsOneWidget);
    });

    testWidgets('renders Difficulty label and buttons',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Difficulty:'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('renders legend entries (trap damage, XP, etc.)',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('trap damage'), findsOneWidget);
      expect(find.textContaining('experience added'), findsOneWidget);
      expect(find.textContaining('gold coin value'), findsOneWidget);
    });

    testWidgets('tapping a level button sets the scenario level',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      final gameState = getIt<GameState>();

      // Tap level 3: "3" only appears as a level button
      // (difficulty buttons render as "-1", "0", "+1", "+2", "+3")
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(gameState.level.value, 3);
    });
  });

  group('SetLevelMenu — monster level mode', () {
    testWidgets('renders the monster name in the title',
        (WidgetTester tester) async {
      AddMonsterCommand("Zealot", 1, false, gameState: getIt<GameState>()).execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;

      await pumpMenu(tester, monster: monster);
      expect(find.textContaining("Zealot"), findsOneWidget);
    });

    testWidgets('still renders legend entries in monster mode (figure==null)',
        (WidgetTester tester) async {
      AddMonsterCommand("Zealot", 1, false, gameState: getIt<GameState>()).execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;

      await pumpMenu(tester, monster: monster);
      // showLegend = widget.figure == null; passing monster but no figure
      // still shows the legend
      expect(find.textContaining('trap damage'), findsOneWidget);
    });
  });
}
