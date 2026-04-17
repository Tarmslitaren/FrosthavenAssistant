// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
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
    (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
        RoundState.chooseInitiative;
  });

  Future<void> pumpButton(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: DrawButton()),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('DrawButton', () {
    testWidgets('shows "Draw" in chooseInitiative state',
        (WidgetTester tester) async {
      await pumpButton(tester);
      expect(find.text('Draw'), findsOneWidget);
    });

    testWidgets('shows "Next Round" in playTurns state',
        (WidgetTester tester) async {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      await pumpButton(tester);
      expect(find.textContaining('Next Round'), findsOneWidget);
    });

    testWidgets('renders TextButton', (WidgetTester tester) async {
      await pumpButton(tester);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('displays round number', (WidgetTester tester) async {
      (getIt<GameState>().round as ValueNotifier<int>).value = 3;
      await pumpButton(tester);
      expect(find.textContaining('3'), findsAtLeast(1));
    });

    testWidgets('tapping with no characters in chooseInitiative does not crash',
        (WidgetTester tester) async {
      await pumpButton(tester);
      // No characters → showToast is called, but does not throw
      await tester.tap(find.byType(TextButton));
      await tester.pump(const Duration(milliseconds: 300));
      // No crash is the assertion
    });

    testWidgets('tapping in playTurns advances to next round',
        (WidgetTester tester) async {
      // NextRoundCommand calls currentList.last — needs at least one item
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      final roundBefore = getIt<GameState>().round.value;

      await pumpButton(tester);
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // NextRoundCommand increments round and resets state
      expect(getIt<GameState>().round.value, roundBefore + 1);
      // restore
      getIt<GameState>().undo();
    });

    testWidgets(
        'tapping Draw with character having initiative set executes DrawCommand',
        (WidgetTester tester) async {
      // Add a character and set their initiative
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gameState = getIt<GameState>();
      final character =
          gameState.currentList.firstWhere((e) => e is Character) as Character;
      (character.characterState.initiative as ValueNotifier<int>).value = 50;

      await pumpButton(tester);
      final before = gameState.roundState.value;
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // DrawCommand changes roundState from chooseInitiative to playTurns
      expect(gameState.roundState.value, isNot(equals(before)));
      // restore
      gameState.undo();
    });

    testWidgets('renders Stack wrapping TextButton',
        (WidgetTester tester) async {
      await pumpButton(tester);
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('renders RepaintBoundary', (WidgetTester tester) async {
      await pumpButton(tester);
      expect(find.byType(RepaintBoundary), findsAtLeast(1));
    });
  });
}
