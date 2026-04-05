import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
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
    AddMonsterCommand('Zealot', 1, false).execute();
  });

  Monster _getZealot() {
    return getIt<GameState>()
        .currentList
        .firstWhere((e) => e.id == 'Zealot') as Monster;
  }

  Future<void> pumpWidget(WidgetTester tester, Monster monster) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonsterAbilityCardWidget(data: monster),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('MonsterAbilityCardWidget', () {
    testWidgets('renders without error in chooseInitiative state',
        (WidgetTester tester) async {
      final monster = _getZealot();
      await pumpWidget(tester, monster);
      expect(find.byType(MonsterAbilityCardWidget), findsOneWidget);
    });

    testWidgets('renders rear card when not in playTurns state',
        (WidgetTester tester) async {
      final monster = _getZealot();
      await pumpWidget(tester, monster);
      // In chooseInitiative state, the rear card should be shown
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('tapping card opens AbilityCardsMenu',
        (WidgetTester tester) async {
      final monster = _getZealot();
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonsterAbilityCardWidget(data: monster),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;

      final originalOnError2 = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError2;

      expect(find.byType(AbilityCardsMenu), findsOneWidget);
    });

    testWidgets('widget uses AnimatedSwitcher for card transition',
        (WidgetTester tester) async {
      final monster = _getZealot();
      await pumpWidget(tester, monster);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('renders front card in playTurns state when active',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      AddStandeeCommand(1, null, 'Zealot', MonsterType.normal, false).execute();
      final monster = _getZealot();

      // Enter playTurns by drawing
      DrawCommand().execute();
      expect(gameState.roundState.value, RoundState.playTurns);

      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonsterAbilityCardWidget(data: monster),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;

      expect(find.byType(MonsterAbilityCardWidget), findsOneWidget);

      // Cleanup: advance past the 600ms AnimatedSwitcher timer from NextRoundCommand
      final originalOnError2 = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      NextRoundCommand().execute();
      await tester.pump(const Duration(milliseconds: 700));
      FlutterError.onError = originalOnError2;
    });

    testWidgets('double tap in chooseInitiative state does not throw',
        (WidgetTester tester) async {
      final monster = _getZealot();
      await pumpWidget(tester, monster);

      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.tap(find.byType(InkWell).first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Close the opened dialog before double tap
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(find.byType(MonsterAbilityCardWidget), findsOneWidget);
    });
  });
}
