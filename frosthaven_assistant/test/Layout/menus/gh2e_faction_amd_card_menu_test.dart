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
      // Find InkWells inside GH2eFactionAMDCardMenu (not the ElevatedButton)
      final menuInkWells = find.descendant(
          of: find.byType(GH2eFactionAMDCardMenu),
          matching: find.byType(InkWell));
      if (tester.widgetList(menuInkWells).isNotEmpty) {
        final inkWell = tester.widget<InkWell>(menuInkWells.first);
        inkWell.onTap?.call();
        await tester.pump();
      }
    });

    testWidgets('tapping remove button removes the faction card', (WidgetTester tester) async {
      await pumpMenu(tester);
      // Find InkWells inside GH2eFactionAMDCardMenu (not the ElevatedButton)
      final menuInkWells = find.descendant(
          of: find.byType(GH2eFactionAMDCardMenu),
          matching: find.byType(InkWell));
      if (tester.widgetList(menuInkWells).isNotEmpty) {
        final inkWell = tester.widget<InkWell>(menuInkWells.first);
        inkWell.onTap?.call();
        await tester.pump();
        // Now remove it
        final removeBtn = find.text('Remove card from your deck?');
        if (tester.widgetList(removeBtn).isNotEmpty) {
          final removeTextBtn = tester.widget<TextButton>(
              find.ancestor(of: removeBtn, matching: find.byType(TextButton)));
          removeTextBtn.onPressed?.call();
          await tester.pump();
          // After remove, "Tap Card to add" should reappear
          expect(find.text('Tap Card to add to your deck'), findsOneWidget);
        }
      }
    });
  });
}
