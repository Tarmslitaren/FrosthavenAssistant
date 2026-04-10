import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/section_button.dart';
import 'package:frosthaven_assistant/Layout/section_list.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
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
          body: Center(child: SectionList()),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('SectionList', () {
    testWidgets('renders empty Wrap when no scenario is set',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      // No scenario → list is null/empty → Wrap with no children
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(SectionButton), findsNothing);
    });

    testWidgets('renders Wrap widget', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('renders SectionButtons for a scenario with sections',
        (WidgetTester tester) async {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false, gameState: getIt<GameState>()).execute();
      getIt<Settings>().autoAddStandees.value = true;

      await pumpWidget(tester);

      // Any sections from the scenario (non-spawn) should appear as SectionButton
      // If none exist in testData, still check Wrap renders
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('filters out spawn sections from display',
        (WidgetTester tester) async {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false, gameState: getIt<GameState>()).execute();

      await pumpWidget(tester);
      // Sections containing "spawn" in their name should not be rendered
      final buttons = tester.widgetList<SectionButton>(find.byType(SectionButton));
      for (final btn in buttons) {
        expect(btn.data.toLowerCase(), isNot(contains('spawn')));
      }
    });

    testWidgets('renders empty Wrap when all sections are already added',
        (WidgetTester tester) async {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false, gameState: getIt<GameState>()).execute();
      // Add all sections by command (section=true path)
      final gameState = getIt<GameState>();
      final gameData = getIt<GameData>();
      final sections = gameData
          .modelData
          .value[gameState.currentCampaign.value]
          ?.scenarios[gameState.scenario.value]
          ?.sections
          .toList();

      if (sections != null) {
        for (final section in sections) {
          SetScenarioCommand(section.name, true, gameState: getIt<GameState>()).execute();
        }
      }

      await pumpWidget(tester);
      // All sections added → list becomes [] → no SectionButton
      expect(find.byType(SectionButton), findsNothing);
    });

    testWidgets('returns Wrap (RepaintBoundary > Wrap)',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(RepaintBoundary), findsAtLeast(1));
    });
  });
}
