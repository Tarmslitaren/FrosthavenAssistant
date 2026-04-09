import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_zoom.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  final card = ModifierCard(CardType.add, 'minus1');

  Future<void> pumpModifierCardZoom(WidgetTester tester) async {
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
                builder: (context) => ModifierCardZoom(
                  name: 'TestDeck',
                  card: card,
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
  }

  group('ModifierCardZoom', () {
    testWidgets('renders the modifier card', (WidgetTester tester) async {
      await pumpModifierCardZoom(tester);

      expect(find.byType(ModifierCardZoom), findsOneWidget);
    });

    testWidgets('tapping dismisses the dialog', (WidgetTester tester) async {
      await pumpModifierCardZoom(tester);
      expect(find.byType(ModifierCardZoom), findsOneWidget);

      await tester.tap(find.byType(ModifierCardZoom));
      await tester.pumpAndSettle();

      expect(find.byType(ModifierCardZoom), findsNothing);
    });
  });
}
