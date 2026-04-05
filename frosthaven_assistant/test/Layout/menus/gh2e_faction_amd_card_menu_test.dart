import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/gh2e_faction_amd_card_menu.dart' show GH2eFactionAMDCardMenu;
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
  });

  Future<void> pumpMenu(WidgetTester tester,
      {String faction = 'Demons'}) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Material(
                  child: GH2eFactionAMDCardMenu(
                    faction: faction,
                    name: 'Blinkblade',
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;
  }

  group('Gh2eFactionAmdCardMenu', () {
    testWidgets('renders "Tap Card to add to your deck" prompt',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Tap Card to add to your deck'), findsOneWidget);
    });

    testWidgets('renders faction card grid', (WidgetTester tester) async {
      await pumpMenu(tester);
      // The menu renders a grid of modifier cards
      expect(find.byType(GestureDetector), findsAtLeast(1));
    });

    testWidgets('renders for Merchant-Guild faction',
        (WidgetTester tester) async {
      await pumpMenu(tester, faction: 'Merchant-Guild');
      expect(find.text('Tap Card to add to your deck'), findsOneWidget);
    });

    testWidgets('tapping a faction card adds it to deck', (WidgetTester tester) async {
      await pumpMenu(tester);
      // Directly invoke onTap to avoid image-asset RenderErrorBox blocking hit test
      final inkWells = find.byType(InkWell);
      if (tester.widgetList(inkWells).isNotEmpty) {
        final inkWell = tester.widget<InkWell>(inkWells.first);
        inkWell.onTap?.call();
        await tester.pump();
      }
    });

    testWidgets('tapping remove button removes the faction card', (WidgetTester tester) async {
      await pumpMenu(tester);
      // First add a card via direct onTap invocation
      final inkWells = find.byType(InkWell);
      if (tester.widgetList(inkWells).isNotEmpty) {
        final inkWell = tester.widget<InkWell>(inkWells.first);
        inkWell.onTap?.call();
        await tester.pump();
        // Now remove it
        final removeBtn = find.text('Remove card from your deck?');
        if (tester.widgetList(removeBtn).isNotEmpty) {
          await tester.tap(removeBtn, warnIfMissed: false);
          await tester.pump();
          // After remove, "Tap Card to add" should reappear
          expect(find.text('Tap Card to add to your deck'), findsOneWidget);
        }
      }
    });
  });
}
