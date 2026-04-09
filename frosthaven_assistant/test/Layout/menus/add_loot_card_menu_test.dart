import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_loot_card_menu.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
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
                builder: (context) => const AddLootCardMenu(),
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

  group('AddLootCardMenu', () {
    testWidgets('renders Add Extra Loot Card title', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Add Extra Loot Card'), findsOneWidget);
    });

    testWidgets('renders loot card entries', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('hide'), findsOneWidget);
      expect(find.text('lumber'), findsOneWidget);
      expect(find.text('metal'), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('tapping a loot card increments its added count',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      final countBefore = gameState.lootDeck.addedCards[0];
      await pumpMenu(tester);

      await tester.tap(find.text('hide'));
      await tester.pumpAndSettle();

      expect(gameState.lootDeck.addedCards[0], countBefore + 1);
    });
  });
}
