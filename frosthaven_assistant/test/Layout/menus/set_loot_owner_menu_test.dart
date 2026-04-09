import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/set_loot_owner_menu.dart';
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

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    // Use a card from the hidePool (always initialized by LootDeck._initPools)
    final card = getIt<GameState>().lootDeck.hidePool.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SetLootOwnerMenu(card: card),
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

  group('SetLootOwnerMenu', () {
    testWidgets('renders Set Loot Owner header', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Set Loot Owner:'), findsOneWidget);
    });

    testWidgets('renders a button for the current character',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      // The button shows the character display name
      expect(find.textContaining('Blinkblade'), findsOneWidget);
    });

    testWidgets('tapping a character button assigns loot and closes dialog',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final card = gameState.lootDeck.hidePool.first;
      await pumpMenu(tester);

      await tester.tap(find.textContaining('Blinkblade'));
      await tester.pumpAndSettle();

      expect(find.byType(SetLootOwnerMenu), findsNothing);
      expect(card.owner, isNotEmpty);
    });
  });
}
