import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/character_loot_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_loot_owner_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
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

  Future<void> pumpMenu(WidgetTester tester) async {
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
                builder: (context) => const CharacterLootMenu(),
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

  group('CharacterLootMenu', () {
    testWidgets("renders character loot section with character name",
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining("Blinkblade"), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping Close dismisses the dialog', (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterLootMenu), findsNothing);
    });

    testWidgets('renders loot with discard pile having owned cards',
        (WidgetTester tester) async {
      // Set up a Frosthaven scenario with loot deck
      getIt<GameState>().clearList();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false).execute();

      final gs = getIt<GameState>();
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;

      // Draw and assign loot cards if deck has any
      if (gs.lootDeck.drawPileIsNotEmpty) {
        DrawLootCardCommand().execute();
        // SetLootOwnerCommand assigns ownership of discard pile cards
        if (gs.lootDeck.discardPileIsNotEmpty) {
          SetLootOwnerCommand(character.id,
                  gs.lootDeck.discardPileContents.toList().first)
              .execute();
        }
      }

      await pumpMenu(tester);
      // Should render without error
      expect(find.byType(CharacterLootMenu), findsOneWidget);
    });
  });
}
