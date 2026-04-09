import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_card_enhancement_menu.dart';
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
                builder: (context) => const LootCardEnhancementMenu(),
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

  group('LootCardEnhancementMenu', () {
    testWidgets('renders Loot Card Enhancements title',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Loot Card Enhancements'), findsOneWidget);
    });

    testWidgets('renders hide section header', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('hide'), findsAtLeast(1));
    });

    testWidgets('renders lumber section header', (WidgetTester tester) async {
      await pumpMenu(tester);
      // SingleChildScrollView builds all children; multiple "lumber X" headers exist
      expect(find.textContaining('lumber'), findsAtLeast(1));
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      // SingleChildScrollView builds all children including Close at the bottom
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
