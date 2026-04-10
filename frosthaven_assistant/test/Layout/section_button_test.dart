import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/section_button.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
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

  Future<void> pumpWidget(WidgetTester tester, String data) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: SectionButton(data: data)),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('SectionButton', () {
    testWidgets('renders OutlinedButton', (WidgetTester tester) async {
      await pumpWidget(tester, '1a some section');
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders first word of section data as button text',
        (WidgetTester tester) async {
      await pumpWidget(tester, '1a some section');
      // data.split(' ')[0] -> '1a'
      expect(find.text('1a'), findsOneWidget);
    });

    testWidgets('button is enabled when section not yet added',
        (WidgetTester tester) async {
      await pumpWidget(tester, 'test-enabled-section');
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('button is disabled after section is added via command',
        (WidgetTester tester) async {
      const sectionName = 'test-disabled-section';
      // Add the section using SetScenarioCommand(name, true, gameState: getIt<GameState>()) — section=true path
      // does not crash for non-existent keys
      SetScenarioCommand(sectionName, true, gameState: getIt<GameState>()).execute();

      await pumpWidget(tester, sectionName);
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping enabled button adds section to scenarioSectionsAdded',
        (WidgetTester tester) async {
      const sectionName = 'test-tap-section';
      await pumpWidget(tester, sectionName);
      expect(
          getIt<GameState>().scenarioSectionsAdded.contains(sectionName), false);

      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      FlutterError.onError = originalOnError;

      expect(
          getIt<GameState>().scenarioSectionsAdded.contains(sectionName), true);
    });

    testWidgets('renders single-word section label correctly',
        (WidgetTester tester) async {
      await pumpWidget(tester, 'SectionX');
      expect(find.text('SectionX'), findsOneWidget);
    });

    testWidgets('button has non-null style', (WidgetTester tester) async {
      await pumpWidget(tester, '2b');
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.style, isNotNull);
    });

    testWidgets('renders RepaintBoundary wrapper',
        (WidgetTester tester) async {
      await pumpWidget(tester, '3c section');
      expect(find.byType(RepaintBoundary), findsAtLeast(1));
    });
  });
}
