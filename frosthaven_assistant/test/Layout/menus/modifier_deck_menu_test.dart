import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_deck_menu.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  // '' resolves to the monster modifier deck in GameMethods.getModifierDeck
  const deckName = '';

  setUp(() {
    getIt<GameState>().clearList();
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    const ModifierDeckMenu(name: deckName),
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

  group('ModifierDeckMenu', () {
    testWidgets('renders Add -1 card button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.textContaining('Add -1 card'), findsOneWidget);
    });

    testWidgets('renders Bless counter', (WidgetTester tester) async {
      await pumpMenu(tester);
      // CounterButton for bless uses assets/images/abilities/bless.png
      expect(
        find.byWidgetPredicate((widget) =>
            widget is CounterButton &&
            widget.image == 'assets/images/abilities/bless.png'),
        findsOneWidget,
      );
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
