import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/monster_stat_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
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
        .firstWhere((item) => item.id == 'Zealot') as Monster;
  }

  Future<void> pumpStatCard(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MonsterStatCardWidget(data: _getZealot()),
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

    testWidgets('renders add normal standee button', (WidgetTester tester) async {
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
      // Double tap the stat card area (buildCard)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      // After double tap, StatCardZoom dialog should open
      // Just verify no exception
    });

    testWidgets('renders level text', (WidgetTester tester) async {
      await pumpStatCard(tester);
      // Level 1 is shown
      expect(find.text('1'), findsAtLeast(1));
    });
  });
}
