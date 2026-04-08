import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/global_hotkeys.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> resetGame() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    setupGetIt();
    getIt<GameState>().init();
    await getIt<GameData>().loadData('assets/testData/');
    await getIt<GameState>().load();
    getIt<GameState>().clearList();
    getIt<Settings>().noInit.value = false;
  }

  setUp(() async {
    await resetGame();
  });

  Future<void> pumpHotkeys(
    WidgetTester tester, {
    bool includeTextField = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlobalHotkeys(
            child: Focus(
              autofocus: true,
              child: Column(
                children: [
                  if (includeTextField)
                    const TextField(
                      autofocus: true,
                    ),
                  const SizedBox(height: 24, width: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> sendCtrlShortcut(
    WidgetTester tester,
    LogicalKeyboardKey key,
  ) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  group('GlobalHotkeys', () {
    testWidgets('ctrl z undoes and ctrl y redoes', (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      gameState.action(
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1),
      );

      await pumpHotkeys(tester);
      expect(gameState.currentList, isNotEmpty);

      await sendCtrlShortcut(tester, LogicalKeyboardKey.keyZ);
      expect(gameState.currentList, isEmpty);

      await sendCtrlShortcut(tester, LogicalKeyboardKey.keyY);
      expect(gameState.currentList, isNotEmpty);
    });

    testWidgets('tab advances activation and shift tab undoes it',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
          .execute();
      AddCharacterCommand('Banner Spear', 'Frosthaven', 'Banner Spear', 1)
          .execute();
      SetInitCommand('Blinkblade', 25).execute();
      SetInitCommand('Banner Spear', 30).execute();
      final gameState = getIt<GameState>();

      gameState.action(DrawCommand());
      await tester.pump(const Duration(milliseconds: 600));
      await pumpHotkeys(tester);

      expect(gameState.currentList.first.turnState.value, TurnsState.current);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(gameState.currentList.first.turnState.value, TurnsState.done);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(gameState.currentList.first.turnState.value, TurnsState.current);
    });

    testWidgets('space runs draw action', (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
          .execute();
      SetInitCommand('Blinkblade', 25).execute();
      final gameState = getIt<GameState>();

      await pumpHotkeys(tester);
      expect(gameState.roundState.value, RoundState.chooseInitiative);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(gameState.roundState.value, RoundState.playTurns);
    });

    testWidgets('number keys toggle elements', (WidgetTester tester) async {
      final gameState = getIt<GameState>();

      await pumpHotkeys(tester);
      expect(gameState.elementState[Elements.fire], ElementState.inert);

      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      expect(gameState.elementState[Elements.fire], ElementState.full);

      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      expect(gameState.elementState[Elements.fire], ElementState.inert);
    });

    testWidgets('shortcuts are ignored while text input is focused',
        (WidgetTester tester) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
          .execute();
      final gameState = getIt<GameState>();

      await pumpHotkeys(tester, includeTextField: true);
      expect(find.byType(TextField), findsOneWidget);

      await sendCtrlShortcut(tester, LogicalKeyboardKey.keyZ);

      expect(gameState.currentList, isNotEmpty);
    });
  });
}