// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_health_widget.dart';
import 'package:frosthaven_assistant/Layout/health_wheel_controller.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart' show Style;
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart'
    show Character, GameState;
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
    character =
        getIt<GameState>().currentList.firstWhere((e) => e is Character)
            as Character;
    getIt<Settings>().enableHeathWheel.value = false;
  });

  tearDown(() {
    getIt<Settings>().enableHeathWheel.value = false;
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterHealthWidget(
            character: character,
            scale: 1.0,
            shadow: const Shadow(),
            scaledHeight: 100.0,
            settings: getIt<Settings>(),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('CharacterHealthWidget', () {
    testWidgets('shows CharacterHealthInnerWidget when health wheel disabled', (
      WidgetTester tester,
    ) async {
      await pumpWidget(tester);
      expect(find.byType(HealthWheelController), findsNothing);
      expect(find.byType(CharacterHealthInnerWidget), findsOneWidget);
    });

    testWidgets('shows HealthWheelController when health wheel enabled', (
      WidgetTester tester,
    ) async {
      getIt<Settings>().enableHeathWheel.value = true;
      await pumpWidget(tester);
      expect(find.byType(HealthWheelController), findsOneWidget);
    });

    testWidgets(
      'switches to HealthWheelController when setting changes after render',
      (WidgetTester tester) async {
        await pumpWidget(tester);
        expect(find.byType(HealthWheelController), findsNothing);

        getIt<Settings>().enableHeathWheel.value = true;
        await tester.pump();

        expect(find.byType(HealthWheelController), findsOneWidget);
      },
    );

    testWidgets(
      'switches back to CharacterHealthInnerWidget when setting disabled after render',
      (WidgetTester tester) async {
        getIt<Settings>().enableHeathWheel.value = true;
        await pumpWidget(tester);
        expect(find.byType(HealthWheelController), findsOneWidget);

        getIt<Settings>().enableHeathWheel.value = false;
        await tester.pump();

        expect(find.byType(HealthWheelController), findsNothing);
        expect(find.byType(CharacterHealthInnerWidget), findsOneWidget);
      },
    );

    testWidgets(
      'health text updates immediately when health changes via command',
      (WidgetTester tester) async {
        await pumpWidget(tester);

        final initialHealth = character.characterState.health.value;
        final maxHealth = character.characterState.maxHealth.value;
        // Use Settings to determine the text format (no spaces in FH style).
        final isFH = getIt<Settings>().style.value == Style.frosthaven;
        final sep = isFH ? '/' : ' / ';
        final initialText = '$initialHealth$sep$maxHealth';
        final updatedText = '${initialHealth - 2}$sep$maxHealth';

        expect(find.text(initialText), findsOneWidget,
            reason: 'Initial health text should be rendered');

        getIt<GameState>().action(ChangeHealthCommand(
          -2,
          character.id,
          character.id,
          gameState: getIt<GameState>(),
        ));
        await tester.pump();

        expect(find.text(updatedText), findsOneWidget,
            reason: 'Health text must update immediately after ChangeHealthCommand');
        expect(find.text(initialText), findsNothing,
            reason: 'Stale health text must no longer appear');
      },
    );
  });
}
