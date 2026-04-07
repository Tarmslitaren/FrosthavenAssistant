import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_stat_card_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand('Zealot', 1, false).execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonsterWidget(data: monster),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    FlutterError.onError = originalOnError;
  }

  group('MonsterWidget', () {
    testWidgets('renders monster type display name',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.textContaining(monster.type.display), findsAtLeast(1));
    });

    testWidgets('renders MonsterAbilityCardWidget',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(MonsterAbilityCardWidget), findsOneWidget);
    });

    testWidgets('renders MonsterStatCardWidget', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(MonsterStatCardWidget), findsOneWidget);
    });

    testWidgets('renders without error when monster has no standees',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      // No standees, but widget should still render without exception
      expect(find.byType(MonsterWidget), findsOneWidget);
    });

    testWidgets('renders Wrap for monster box grid', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Wrap), findsAtLeast(1));
    });

    testWidgets('renders Column as root layout', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Column), findsAtLeast(1));
    });

    testWidgets('tapping image in playTurns state wraps image in InkWell',
        (WidgetTester tester) async {
      // Add a standee so the monster has instances
      AddStandeeCommand(1, null, monster.id, MonsterType.normal, false)
          .execute();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;

      await pumpWidget(tester);

      // InkWell wrapping the image is present during playTurns when instances exist
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsAtLeast(1));

      // restore
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
          as Monster;
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.chooseInitiative;
    });

    testWidgets('monster image is shown via AssetImage',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders ColorFiltered widget for active state',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(ColorFiltered), findsAtLeast(1));
    });
  });
}
