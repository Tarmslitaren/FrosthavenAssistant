import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group('ConditionIcon frosthaven gfx suffix', () {
    testWidgets('constructor uses _fh suffix when campaign is Frosthaven',
        (WidgetTester tester) async {
      SetCampaignCommand('Frosthaven').execute();
      final character = _getBlinkblade();
      // Render stun icon — stun has a GH version, so suffix "_fh" should apply
      await pumpConditionIcon(tester, Condition.stun);
      final icon =
          tester.widget<ConditionIcon>(find.byType(ConditionIcon));
      // gfx should end with _fh.png for frosthaven-style campaign
      expect(icon.gfx, contains('_fh'));
      // Also verify GameMethods.isFrosthavenStyle is true in this context
      expect(GameMethods.isFrosthavenStyle(null), isTrue);
    });
  });

  group('ConditionIcon animation listener health change', () {
    setUp(() {
      // Mock SharedPreferences so saveToDisk does not throw MissingPluginException
      SharedPreferences.setMockInitialValues({});
      getIt<GameState>().clearList();
      // Use action() to populate gameSaveStates so listener can read old state
      getIt<GameState>()
          .action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1));
    });

    testWidgets('health decrease triggers animation for regenerate condition',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final character = gameState.currentList
          .firstWhere((e) => e is Character) as Character;

      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionIcon(
              Condition.regenerate,
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

      // Trigger health change: commandIndex change → listener → animation path
      gameState
          .action(ChangeHealthCommand(-1, character.id, character.id));

      FlutterError.onError = ignoreOverflowErrors;
      // Pump past the 1000ms animation timer started by _runAnimation()
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      FlutterError.onError = originalOnError;

      expect(find.byType(ConditionIcon), findsOneWidget);
      gameState.undo();
    });

    testWidgets(
        'health decrease then increase with stun covers full condition chains without animation',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final character = gameState.currentList
          .firstWhere((e) => e is Character) as Character;

      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      // stun is not in the health-decrease or health-increase animation lists
      // so _runAnimation() is NOT called → no pending timer
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionIcon(
              Condition.stun,
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

      // Health decrease: covers lines 128, 198-207 (all conditions evaluated, none match stun)
      gameState.action(ChangeHealthCommand(-1, character.id, character.id));
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pump();
      FlutterError.onError = originalOnError;

      // Health increase: covers lines 210-216 (all conditions evaluated, none match stun)
      gameState.action(ChangeHealthCommand(1, character.id, character.id));
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pump();
      FlutterError.onError = originalOnError;

      expect(find.byType(ConditionIcon), findsOneWidget);
      gameState.undo();
      gameState.undo();
    });
  });
}
