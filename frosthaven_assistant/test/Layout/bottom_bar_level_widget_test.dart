// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/bottom_bar_level_widget.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: BottomBarLevelWidget()),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('BottomBarLevelWidget', () {
    testWidgets('renders scenario name', (WidgetTester tester) async {
      (getIt<GameState>().scenario as ValueNotifier<String>).value =
          'Test Scenario';
      await pumpWidget(tester);
      expect(find.textContaining('Test Scenario'), findsOneWidget);
    });

    testWidgets('renders level value', (WidgetTester tester) async {
      (getIt<GameState>().level as ValueNotifier<int>).value = 3;
      await pumpWidget(tester);
      expect(find.textContaining(': 3 '), findsOneWidget);
    });

    testWidgets('renders InkWell for tap interaction',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(InkWell), findsAtLeast(1));
    });

    testWidgets('tapping opens SetLevelMenu', (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: BottomBarLevelWidget()),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      FlutterError.onError = originalOnError;
      expect(find.byType(SetLevelMenu), findsOneWidget);
    });

    testWidgets('scenario text shows scenario from gameState',
        (WidgetTester tester) async {
      (getIt<GameState>().scenario as ValueNotifier<String>).value =
          '#1 Algox Encampment';
      await pumpWidget(tester);
      expect(find.textContaining('#1 Algox Encampment'), findsOneWidget);
    });

    testWidgets('formattedScenarioName strips prefix for Solo campaign',
        (WidgetTester tester) async {
      (getIt<GameState>().currentCampaign as ValueNotifier<String>).value =
          'Solo';
      (getIt<GameState>().scenario as ValueNotifier<String>).value =
          'prefix:MySoloScenario';
      await pumpWidget(tester);
      expect(find.textContaining('MySoloScenario'), findsOneWidget);
      expect(find.textContaining('prefix:'), findsNothing);
      // restore
      (getIt<GameState>().currentCampaign as ValueNotifier<String>).value =
          'Frosthaven';
    });

    testWidgets('renders Column with two rows of content',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Column), findsAtLeast(1));
    });

    testWidgets('renders Material widget for ink effects',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Material), findsAtLeast(1));
    });
  });
}
