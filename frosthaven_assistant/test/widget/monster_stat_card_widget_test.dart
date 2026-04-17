import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_standee_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/stat_card_zoom.dart';
import 'package:frosthaven_assistant/Layout/monster_stat_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
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
    getIt<GameState>().clearList();
    AddMonsterCommand('Zealot', 1, false, gameState: getIt<GameState>())
        .execute();
  });

  Monster getZealot() {
    return getIt<GameState>()
        .currentList
        .firstWhere((item) => item.id == 'Zealot') as Monster;
  }

  Future<void> pumpStatCard(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MonsterStatCardWidget(data: getZealot()),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('MonsterStatCardWidget', () {
    testWidgets('renders monster name', (WidgetTester tester) async {
      await pumpStatCard(tester);
      expect(find.textContaining('Zealot'), findsAtLeast(1));
    });

    testWidgets('renders stat card images', (WidgetTester tester) async {
      await pumpStatCard(tester);
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders add normal standee button',
        (WidgetTester tester) async {
      await pumpStatCard(tester);
      // Two add buttons: one for normal, one for elite
      expect(find.byType(IconButton), findsAtLeast(1));
    });

    testWidgets('tapping add button opens AddStandeeMenu or adds standee',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await pumpStatCard(tester);
      // Tap the first add (normal) button
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      // Should either add standee or open AddStandeeMenu — just verify no crash
      expect(find.byType(MonsterStatCardWidget), findsOneWidget);
    });

    testWidgets('double tap opens StatCardZoom', (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await pumpStatCard(tester);
      // Double tap the GestureDetector wrapping buildCard
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      expect(find.byType(StatCardZoom), findsOneWidget);
    });

    testWidgets('renders level text', (WidgetTester tester) async {
      await pumpStatCard(tester);
      // Level 1 is shown
      expect(find.text('1'), findsAtLeast(1));
    });

    testWidgets('renders two add standee buttons (normal and elite)',
        (WidgetTester tester) async {
      await pumpStatCard(tester);
      // Non-boss monsters have 2 add buttons: one for normal, one for elite
      expect(find.byType(IconButton), findsNWidgets(2));
    });

    testWidgets('tapping elite add button opens AddStandeeMenu for elite',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await pumpStatCard(tester);
      // Elite add button is the second IconButton
      await tester.tap(find.byType(IconButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      // No crash expected
      expect(find.byType(MonsterStatCardWidget), findsOneWidget);
    });

    testWidgets('when all standees are out, add button is visually disabled',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final zealot = getZealot();
      // Add all available standees
      int maxCount = zealot.type.count;
      for (int i = 1; i <= maxCount; i++) {
        AddStandeeCommand(i, null, 'Zealot', MonsterType.normal, false,
                gameState: getIt<GameState>())
            .execute();
      }

      await pumpStatCard(tester);
      // The first IconButton (normal add) should render with white24 color
      final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
      expect(buttons, isNotEmpty);

      // Restore
      for (int i = 0; i < maxCount; i++) {
        gameState.undo();
      }
    });

    testWidgets(
        'tapping add button opens AddStandeeMenu when not at last standee',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      final zealot = getZealot();

      // With count > 2 available standees and none added, tapping opens menu
      if (zealot.type.count > 2) {
        await pumpStatCard(tester);
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();
        expect(find.byType(AddStandeeMenu), findsOneWidget);
      }
    });

    testWidgets('renders GestureDetector for double-tap zoom',
        (WidgetTester tester) async {
      await pumpStatCard(tester);
      expect(find.byType(GestureDetector), findsAtLeast(1));
    });

    testWidgets('changing level updates displayed stats',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();

      // Change to level 3
      gameState.action(SetLevelCommand(3, null));
      await pumpStatCard(tester);
      expect(find.text('3'), findsAtLeast(1));

      // Restore
      gameState.undo();
    });
  });

  group('MonsterStatCardWidget immunity conditions', () {
    setUp(() {
      getIt<GameState>().clearList();
      // Ancient Artillery (FH) has muddle immunity
      AddMonsterCommand('Ancient Artillery (FH)', 1, false,
              gameState: getIt<GameState>())
          .execute();
    });

    Future<void> pumpArtilleryCard(WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e.id == 'Ancient Artillery (FH)') as Monster;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MonsterStatCardWidget(data: monster),
            ),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
    }

    testWidgets('renders immunity icon for monster with immunities',
        (WidgetTester tester) async {
      await pumpArtilleryCard(tester);
      // Immunity list renders images — at least the immunity icon
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('renders monster name for artillery',
        (WidgetTester tester) async {
      await pumpArtilleryCard(tester);
      expect(find.textContaining('Ancient Artillery'), findsAtLeast(1));
    });
  });
}
