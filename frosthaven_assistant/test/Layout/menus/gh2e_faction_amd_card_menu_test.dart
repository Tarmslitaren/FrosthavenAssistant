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
                builder: (context) => GH2eFactionAMDCardMenu(
                  faction: faction,
                  name: 'Blinkblade',
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
  });
}
