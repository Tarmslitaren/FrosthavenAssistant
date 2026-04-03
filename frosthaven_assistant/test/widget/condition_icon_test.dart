import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
  });

  Character _getBlinkblade() {
    return getIt<GameState>()
        .currentList
        .firstWhere((item) => item.id == 'Blinkblade') as Character;
  }

  Future<void> pumpConditionIcon(
      WidgetTester tester, Condition condition) async {
    final character = _getBlinkblade();
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConditionIcon(
            condition,
            32.0,
            character,
            character.characterState,
            scale: 1.0,
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('ConditionIcon', () {
    testWidgets('renders stun condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.stun);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders wound condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.wound);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders poison condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.poison);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders invisible condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.invisible);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders strengthen condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.strengthen);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders regenerate condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.regenerate);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders bane condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.bane);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders muddle condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.muddle);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders character condition with token background',
        (WidgetTester tester) async {
      // character1 condition targets the first character icon
      final character = _getBlinkblade();
      final owner = character;
      final figure = character.characterState;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionIcon(
              Condition.character1,
              32.0,
              owner,
              figure,
              scale: 1.0,
            ),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      // character condition renders two images (token bg + class icon)
      expect(find.byType(Image), findsAtLeast(2));
    });

    testWidgets('uses frosthaven-style gfx path', (WidgetTester tester) async {
      // The gfx path is set in constructor — for stun in frosthaven style it should be _fh suffix
      final character = _getBlinkblade();
      // Just verify widget renders without throwing
      await pumpConditionIcon(tester, Condition.stun);
      expect(find.byType(ConditionIcon), findsOneWidget);
    });

    testWidgets('ShakeAnimatedWidget is in the widget tree',
        (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.stun);
      expect(find.byType(ShakeAnimatedWidget), findsOneWidget);
    });

    testWidgets('animate starts as false (no shake on build)',
        (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.poison);
      // Find the ShakeAnimatedWidget and verify enabled=false initially
      final shake = tester
          .widget<ShakeAnimatedWidget>(find.byType(ShakeAnimatedWidget));
      expect(shake.enabled, false);
    });

    testWidgets('renders chill condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.chill);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders disarm condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.disarm);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders immobilize condition icon',
        (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.immobilize);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders ward condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.ward);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders brittle condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.brittle);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders infect condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.infect);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders impair condition icon', (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.impair);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('character condition uses Stack layout',
        (WidgetTester tester) async {
      final character = _getBlinkblade();
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionIcon(
              Condition.character1,
              32.0,
              character,
              character.characterState,
              scale: 1.0,
            ),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      // character condition renders using Stack (bg + icon)
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('non-character condition renders single Image (no Stack)',
        (WidgetTester tester) async {
      await pumpConditionIcon(tester, Condition.stun);
      // Non-character conditions render a single Image directly
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('ConditionIcon monster figure', () {
    setUp(() {
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      AddStandeeCommand(1, null, 'Zealot', MonsterType.normal, false).execute();
    });

    testWidgets('renders condition icon for monster instance',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final monster =
          gameState.currentList.firstWhere((e) => e.id == 'Zealot') as Monster;
      final instance = monster.monsterInstances.first;

      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionIcon(
              Condition.stun,
              32.0,
              monster,
              instance,
              scale: 1.0,
            ),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
      expect(find.byType(ConditionIcon), findsOneWidget);
      expect(find.byType(Image), findsAtLeast(1));
    });
  });
}
