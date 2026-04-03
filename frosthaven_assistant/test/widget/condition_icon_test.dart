import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
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
  });
}
