import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
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

  Character _getBlinkblade() {
    return getIt<GameState>()
        .currentList
        .firstWhere((item) => item.id == 'Blinkblade') as Character;
  }

  Future<void> pumpCounterButton(WidgetTester tester,
      {bool showTotalValue = false}) async {
    final character = _getBlinkblade();
    final figureId = character.id;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CounterButton(
            notifier: character.characterState.health,
            command: ChangeHealthCommand(0, figureId, figureId, gameState: getIt<GameState>()),
            maxValue: character.characterState.maxHealth.value,
            image: 'assets/images/abilities/heal.png',
            showTotalValue: showTotalValue,
            color: Colors.red,
            figureId: figureId,
            ownerId: figureId,
            scale: 1.0,
          ),
        ),
      ),
    );
  }

  group('CounterButton', () {
    testWidgets('renders minus and plus buttons', (WidgetTester tester) async {
      await pumpCounterButton(tester);
      // Should have two IconButtons (sub and add)
      expect(find.byType(IconButton), findsNWidgets(2));
    });

    testWidgets('renders heal image', (WidgetTester tester) async {
      await pumpCounterButton(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/abilities/heal.png'),
        findsAtLeast(1),
      );
    });

    testWidgets('tapping + increments health', (WidgetTester tester) async {
      final character = _getBlinkblade();
      // Set health below max so we can increment
      final figureId = character.id;
      getIt<GameState>().action(ChangeHealthCommand(-1, figureId, figureId, gameState: getIt<GameState>()));
      final before = character.characterState.health.value;

      await pumpCounterButton(tester);
      // The add button is the second IconButton
      await tester.tap(find.byType(IconButton).last);
      await tester.pump();

      expect(character.characterState.health.value, before + 1);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    testWidgets('tapping - decrements health', (WidgetTester tester) async {
      final character = _getBlinkblade();
      final figureId = character.id;
      final before = character.characterState.health.value;
      expect(before, greaterThan(0));

      await pumpCounterButton(tester);
      // The sub button is the first IconButton
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(character.characterState.health.value, before - 1);
      getIt<GameState>().undo();
    });

    testWidgets('tapping + at max value does not increment',
        (WidgetTester tester) async {
      final character = _getBlinkblade();
      final maxHealth = character.characterState.maxHealth.value;
      final figureId = character.id;
      // Ensure health is at max
      while (character.characterState.health.value < maxHealth) {
        getIt<GameState>()
            .action(ChangeHealthCommand(1, figureId, figureId, gameState: getIt<GameState>()));
      }
      final before = character.characterState.health.value;

      await pumpCounterButton(tester);
      await tester.tap(find.byType(IconButton).last);
      await tester.pump();

      expect(character.characterState.health.value, before);
      // Restore to original
      while (character.characterState.health.value > before) {
        getIt<GameState>().undo();
      }
    });

    testWidgets('notifier value of 0 makes minus button no-op',
        (WidgetTester tester) async {
      // Use figureId='unknown' so Navigator.pop is NOT called on zero health
      final character = _getBlinkblade();
      final notifier = ValueNotifier<int>(0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterButton(
              notifier: notifier,
              command: ChangeHealthCommand(0, 'unknown', null, gameState: getIt<GameState>()),
              maxValue: 10,
              image: 'assets/images/abilities/heal.png',
              showTotalValue: true,
              color: Colors.red,
              figureId: 'unknown',
              ownerId: null,
              scale: 1.0,
            ),
          ),
        ),
      );
      // Value is 0, minus should be no-op
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();
      expect(notifier.value, 0);
    });

    testWidgets('showTotalValue=true shows notifier value as text',
        (WidgetTester tester) async {
      final character = _getBlinkblade();
      final health = character.characterState.health.value;

      await pumpCounterButton(tester, showTotalValue: true);
      expect(find.text(health.toString()), findsOneWidget);
    });

    testWidgets('renders extraImage when provided', (WidgetTester tester) async {
      final character = _getBlinkblade();
      final figureId = character.id;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterButton(
              notifier: character.characterState.health,
              command: ChangeHealthCommand(0, figureId, figureId, gameState: getIt<GameState>()),
              maxValue: character.characterState.maxHealth.value,
              image: 'assets/images/abilities/heal.png',
              showTotalValue: false,
              color: Colors.red,
              figureId: figureId,
              ownerId: figureId,
              scale: 1.0,
              extraImage: 'assets/images/abilities/bless.png',
            ),
          ),
        ),
      );
      // Extra image renders alongside main image
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/abilities/bless.png'),
        findsOneWidget,
      );
    });
  });
}
