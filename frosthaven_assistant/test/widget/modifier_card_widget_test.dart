import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  Future<void> pumpCard(WidgetTester tester, ModifierCardWidget widget) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: widget)),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('ModifierCardWidget', () {
    testWidgets('revealed=false renders rear card', (WidgetTester tester) async {
      final card = ModifierCard(CardType.add, 'minus1');
      await pumpCard(tester, ModifierCardWidget(card: card, revealed: false, name: ''));
      expect(find.byType(ModifierCardWidget), findsOneWidget);
    });

    testWidgets('revealed=true renders front card', (WidgetTester tester) async {
      final card = ModifierCard(CardType.add, 'plus1');
      await pumpCard(tester, ModifierCardWidget(card: card, revealed: true, name: ''));
      expect(find.byType(ModifierCardWidget), findsOneWidget);
    });

    testWidgets('buildFront with imbue card renders without error',
        (WidgetTester tester) async {
      final card = ModifierCard(CardType.add, 'imbue-plus1');
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModifierCardWidget.buildFront(card, '', 1.0, 1),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
    });

    testWidgets('buildFront with Military faction card renders without error',
        (WidgetTester tester) async {
      final card = ModifierCard(CardType.add, 'Military-perks/plus1shield1flip');
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModifierCardWidget.buildFront(card, '', 1.0, 1),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
    });

    testWidgets('buildFront with allies deck renders without error',
        (WidgetTester tester) async {
      final card = ModifierCard(CardType.add, 'plus1');
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModifierCardWidget.buildFront(card, 'allies', 1.0, 1),
          ),
        ),
      );
      await tester.pump();
      FlutterError.onError = originalOnError;
    });
  });
}
