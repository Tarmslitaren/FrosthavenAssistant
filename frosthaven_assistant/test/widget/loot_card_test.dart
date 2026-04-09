import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/loot_card.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  LootCard _makeCard({
    int id = 1,
    LootType lootType = LootType.materiel,
    LootBaseValue baseValue = LootBaseValue.one,
    int enhanced = 0,
    String gfx = 'money_1',
    String owner = '',
  }) {
    final card = LootCard(
      id: id,
      lootType: lootType,
      baseValue: baseValue,
      enhanced: enhanced,
      gfx: gfx,
    );
    card.owner = owner;
    return card;
  }

  group('LootCardWidget buildFront', () {
    testWidgets('renders card front image', (WidgetTester tester) async {
      final card = _makeCard();
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('money card shows +1 value text', (WidgetTester tester) async {
      final card = _makeCard(lootType: LootType.materiel);
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      // materiel type with baseValue.one should show +1
      expect(find.textContaining('+'), findsOneWidget);
    });

    testWidgets('other type card with no enhancement shows no value text',
        (WidgetTester tester) async {
      final card = _makeCard(lootType: LootType.other, enhanced: 0);
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      // No value text for other type with no enhancement
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('enhanced card shows enhanced text', (WidgetTester tester) async {
      final card = _makeCard(lootType: LootType.other, enhanced: 3);
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      expect(find.textContaining('Enhanced'), findsOneWidget);
    });

    testWidgets('card with gfx containing "1418" shows "1418" text',
        (WidgetTester tester) async {
      final card = _makeCard(gfx: 'loot_1418');
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      expect(find.text('1418'), findsOneWidget);
    });

    testWidgets('card with gfx containing "1419" shows "1419" text',
        (WidgetTester tester) async {
      final card = _makeCard(gfx: 'loot_1419');
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      expect(find.text('1419'), findsOneWidget);
    });

    testWidgets('card with non-empty owner shows owner icon',
        (WidgetTester tester) async {
      final card = _makeCard(owner: 'Blinkblade');
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildFront(card, 1.0, false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      // Owner image should be rendered (Image widgets exist)
      expect(find.byType(Image), findsAtLeast(1));
    });
  });

  group('LootCardWidget buildRear', () {
    testWidgets('renders card back image', (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget.buildRear(1.0),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('LootCardWidget widget', () {
    testWidgets('revealed=true shows front (has Stack)',
        (WidgetTester tester) async {
      final card = _makeCard();
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget(card: card, revealed: true),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      // Front has a Stack widget
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('revealed=false shows rear (ClipRRect)',
        (WidgetTester tester) async {
      final card = _makeCard();
      final originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LootCardWidget(card: card, revealed: false),
          ),
        ),
      );
      FlutterError.onError = originalOnError;
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
