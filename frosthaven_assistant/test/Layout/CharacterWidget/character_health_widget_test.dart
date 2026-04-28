// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_health_widget.dart';
import 'package:frosthaven_assistant/Layout/health_wheel_controller.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart' show Character, GameState;
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
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
    testWidgets('shows CharacterHealthInnerWidget when health wheel disabled',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(HealthWheelController), findsNothing);
      expect(find.byType(CharacterHealthInnerWidget), findsOneWidget);
    });

    testWidgets('shows HealthWheelController when health wheel enabled',
        (WidgetTester tester) async {
      getIt<Settings>().enableHeathWheel.value = true;
      await pumpWidget(tester);
      expect(find.byType(HealthWheelController), findsOneWidget);
    });

    testWidgets('switches to HealthWheelController when setting changes after render',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(HealthWheelController), findsNothing);

      getIt<Settings>().enableHeathWheel.value = true;
      await tester.pump();

      expect(find.byType(HealthWheelController), findsOneWidget);
    });

    testWidgets('switches back to CharacterHealthInnerWidget when setting disabled after render',
        (WidgetTester tester) async {
      getIt<Settings>().enableHeathWheel.value = true;
      await pumpWidget(tester);
      expect(find.byType(HealthWheelController), findsOneWidget);

      getIt<Settings>().enableHeathWheel.value = false;
      await tester.pump();

      expect(find.byType(HealthWheelController), findsNothing);
      expect(find.byType(CharacterHealthInnerWidget), findsOneWidget);
    });
  });
}
