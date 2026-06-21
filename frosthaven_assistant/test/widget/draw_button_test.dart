import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

// ignore_for_file: no-magic-number

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    final gs = getIt<GameState>();
    gs.clearList();
    // Reset roundState so each test starts from a known baseline.
    // RoundMethods.setRoundState requires a state-modifier token, so we
    // round-trip via undo() if a prior test left us in playTurns.
    // Guard on commandIndex >= 0: undo() is a no-op when commandIndex < 0,
    // so using gameSaveStates.isNotEmpty as the guard creates an infinite loop
    // if roundState was modified outside the command system (e.g. loadFromData).
    while (gs.roundState.value != RoundState.chooseInitiative &&
        gs.commandIndex.value >= 0) {
      gs.undo();
    }
  });

  Future<void> pumpDrawButton(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawButton(gameState: getIt<GameState>()),
        ),
      ),
    );
  }

  TextButton findTextButton(WidgetTester tester) {
    return tester.widget<TextButton>(find.byType(TextButton));
  }

  group('DrawButton sync lockout', () {
    testWidgets('initial onPressed is non-null in chooseInitiative state',
        (WidgetTester tester) async {
      await pumpDrawButton(tester);
      expect(getIt<GameState>().roundState.value, RoundState.chooseInitiative);
      expect(findTextButton(tester).onPressed, isNotNull);
    });

    testWidgets('roundState change disables button briefly, then re-enables',
        (WidgetTester tester) async {
      final gs = getIt<GameState>();

      // Set up a character with initiative so DrawCommand is allowed.
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      SetInitCommand('Blinkblade', 25, gameState: gs).execute();

      await pumpDrawButton(tester);
      expect(findTextButton(tester).onPressed, isNotNull,
          reason: 'button should start enabled');

      // Fire a roundState change: chooseInitiative -> playTurns.
      gs.action(DrawCommand(gameState: gs));
      await tester.pump();

      // Within the 300ms lockout the button must be disabled.
      await tester.pump(const Duration(milliseconds: 50));
      expect(findTextButton(tester).onPressed, isNull,
          reason: 'button should be disabled during the sync lockout');
      expect(gs.roundState.value, RoundState.playTurns,
          reason: 'roundState should have advanced');

      // After the lockout expires, the button re-enables.
      await tester.pump(const Duration(milliseconds: 400));
      expect(findTextButton(tester).onPressed, isNotNull,
          reason: 'button should re-enable after lockout expires');

      // Drain DrawCommand's deferred 600ms scroll Future before the test ends.
      await tester.pump(const Duration(milliseconds: 600));
      gs.undo();
    });

    testWidgets('roundState change via loadFromData (network broadcast) '
        'triggers the same lockout', (WidgetTester tester) async {
      final gs = getIt<GameState>();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      SetInitCommand('Blinkblade', 25, gameState: gs).execute();

      await pumpDrawButton(tester);
      expect(findTextButton(tester).onPressed, isNotNull,
          reason: 'button should start enabled in chooseInitiative');

      // Simulate a server broadcast: snapshot the current state, flip the
      // roundState field, and feed it back through the same loadFromData
      // entry point used by services/network/client.dart on a state update.
      // The DrawButton lockout subscribes to a ValueNotifier on roundState,
      // so it can't tell whether the change came from a local DrawCommand
      // or from a remote peer's broadcast — both end up calling
      // gameState._roundState.value = ... in GameSaveState.load.
      final originalJson = gs.toString();
      final snapshot = json.decode(originalJson) as Map<String, dynamic>;
      snapshot['roundState'] = RoundState.playTurns.index;
      gs.loadFromData(json.encode(snapshot));
      await tester.pump();

      // Lockout engages just as in the local-action test above.
      await tester.pump(const Duration(milliseconds: 50));
      expect(findTextButton(tester).onPressed, isNull,
          reason: 'button should be disabled after a network-driven '
              'roundState change');
      expect(gs.roundState.value, RoundState.playTurns,
          reason: 'loadFromData should have advanced roundState');

      // Lockout expires.
      await tester.pump(const Duration(milliseconds: 400));
      expect(findTextButton(tester).onPressed, isNotNull,
          reason: 'button should re-enable after lockout expires');

      // Restore original state (chooseInitiative) so the next test does not
      // inherit a playTurns roundState that loadFromData cannot undo.
      gs.loadFromData(originalJson);
      // Drain the 300ms lockout timer that the roundState change triggers.
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('lockout fades the button (AnimatedOpacity < 1.0)',
        (WidgetTester tester) async {
      final gs = getIt<GameState>();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      SetInitCommand('Blinkblade', 25, gameState: gs).execute();

      await pumpDrawButton(tester);
      gs.action(DrawCommand(gameState: gs));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, lessThan(1.0),
          reason: 'button should be visually dimmed during lockout');

      // Drain timers before the test ends.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));
      gs.undo();
    });

  });
}
