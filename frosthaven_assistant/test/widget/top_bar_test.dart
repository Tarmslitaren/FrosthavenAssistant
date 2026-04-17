import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/element_button.dart';
import 'package:frosthaven_assistant/Layout/top_bar.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

// ignore_for_file: no-magic-number

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  Future<void> pumpTopBar(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Builder(
              builder: (context) => const TopBar(),
            ),
          ),
          body: const SizedBox(),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;
  }

  group('TopBar', () {
    testWidgets('renders title text', (WidgetTester tester) async {
      await pumpTopBar(tester);
      expect(find.textContaining('X-haven'), findsOneWidget);
    });

    testWidgets('renders 6 ElementButtons', (WidgetTester tester) async {
      await pumpTopBar(tester);
      expect(find.byType(ElementButton), findsNWidgets(6));
    });

    testWidgets('renders menu icon', (WidgetTester tester) async {
      await pumpTopBar(tester);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('tapping fire element changes element state',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      // Ensure fire starts inert
      expect(gameState.elementState[Elements.fire], ElementState.inert);

      await pumpTopBar(tester);
      final fireButton = find.byWidgetPredicate(
          (w) => w is ElementButton && w.element == Elements.fire);
      await tester.tap(fireButton);
      await tester.pump();

      // After one tap, fire should be imbued (full or half)
      expect(
        gameState.elementState[Elements.fire],
        isNot(ElementState.inert),
      );
      gameState.undo();
    });

    testWidgets('long pressing fire element imbues it to half',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      await pumpTopBar(tester);
      final fireButton = find.byWidgetPredicate(
          (w) => w is ElementButton && w.element == Elements.fire);
      await tester.longPress(fireButton);
      await tester.pump();

      expect(gameState.elementState[Elements.fire], ElementState.half);
      gameState.undo();
    });

    testWidgets('tapping ice element changes element state',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      await pumpTopBar(tester);
      final iceButton = find.byWidgetPredicate(
          (w) => w is ElementButton && w.element == Elements.ice);
      await tester.tap(iceButton);
      await tester.pump();

      expect(
        gameState.elementState[Elements.ice],
        isNot(ElementState.inert),
      );
      gameState.undo();
    });

    testWidgets('tapping inert element imbues it (sets to full)',
        (WidgetTester tester) async {
      final gameState = getIt<GameState>();
      await pumpTopBar(tester);
      final earthButton = find.byWidgetPredicate(
          (w) => w is ElementButton && w.element == Elements.earth);
      // Tap inert → imbues to full (half=false)
      await tester.tap(earthButton);
      await tester.pump();
      expect(gameState.elementState[Elements.earth], ElementState.full);

      // Tap again (full → use → inert)
      await tester.tap(earthButton);
      await tester.pump();
      expect(gameState.elementState[Elements.earth], ElementState.inert);
      gameState.undo();
      gameState.undo();
    });
  });
}
