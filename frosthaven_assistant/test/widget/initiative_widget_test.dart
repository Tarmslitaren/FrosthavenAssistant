import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/initiative_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: getIt<GameState>()).execute();
  });

  Character _getBlinkblade() =>
      getIt<GameState>().currentList.firstWhere((e) => e.id == 'Blinkblade')
          as Character;

  Future<void> pumpWidget(WidgetTester tester, Character character) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: InitiativeWidget(
              scale: 1.0,
              scaledHeight: 100,
              shadow: const Shadow(),
              character: character,
              isCharacter: true,
              initTextFieldController: TextEditingController(),
              focusNode: FocusNode(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('InitiativeWidget', () {
    testWidgets('renders init image', (WidgetTester tester) async {
      final character = _getBlinkblade();
      await pumpWidget(tester, character);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'assets/images/init.png'),
        findsOneWidget,
      );
    });

    testWidgets('in chooseInitiative state shows TextField',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Default state after clearList + addCharacter is chooseInitiative
      expect(gameState.roundState.value, RoundState.chooseInitiative);
      final character = _getBlinkblade();
      await pumpWidget(tester, character);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('in playTurns state shows text instead of TextField',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // DrawCommand transitions to playTurns
      gameState.action(DrawCommand(gameState: getIt<GameState>()));
      expect(gameState.roundState.value, RoundState.playTurns);

      final character = _getBlinkblade();
      await pumpWidget(tester, character);
      // Drain the 600ms timer left by DrawCommand
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(TextField), findsNothing);
      gameState.undo();
    });

    testWidgets('shows no TextField in playTurns even with initiative > 0',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final character = _getBlinkblade();
      // Set initiative then advance to playTurns via DrawCommand
      SetInitCommand(character.id, 42, gameState: getIt<GameState>()).execute();
      gameState.action(DrawCommand(gameState: getIt<GameState>()));
      expect(gameState.roundState.value, RoundState.playTurns);

      await pumpWidget(tester, character);
      await tester.pump(const Duration(milliseconds: 700));
      // In playTurns, TextField should not be shown
      expect(find.byType(TextField), findsNothing);

      gameState.undo();
      gameState.undo();
    });

    testWidgets('shows empty text when initiative is 0 in playTurns',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final character = _getBlinkblade();
      gameState.action(DrawCommand(gameState: getIt<GameState>()));
      expect(gameState.roundState.value, RoundState.playTurns);

      await pumpWidget(tester, character);
      await tester.pump(const Duration(milliseconds: 700));
      // No initiative number text visible (initiative is 0)
      expect(find.text('0'), findsNothing);

      gameState.undo();
    });

    testWidgets('can type into TextField in chooseInitiative state',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      expect(gameState.roundState.value, RoundState.chooseInitiative);
      final character = _getBlinkblade();
      await pumpWidget(tester, character);

      await tester.enterText(find.byType(TextField), '15');
      await tester.pump();
      // Text was entered without error
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
