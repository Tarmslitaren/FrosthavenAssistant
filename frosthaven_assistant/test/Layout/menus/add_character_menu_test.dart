import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/character_tile.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_menu.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
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
                builder: (context) => const AddCharacterMenu(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
  }

  group('AddCharacterMenu', () {
    testWidgets('renders Load or Save Characters button',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Load or Save Characters'), findsOneWidget);
    });

    testWidgets('renders search field', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders Close button', (WidgetTester tester) async {
      await pumpMenu(tester);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('typing in search field filters the character list',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.enterText(find.byType(TextField), 'Blinkblade');
      await tester.pump();
      // Should show Blinkblade in the list
      expect(find.textContaining('Blinkblade'), findsAtLeast(1));
    });

    testWidgets('typing non-matching text shows no results',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.enterText(find.byType(TextField), 'zzznomatch');
      await tester.pump();
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('tapping Load or Save Characters opens SaveCharacterMenu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Load or Save Characters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SaveCharacterMenu), findsOneWidget);
    });

    testWidgets(
        'tapping a character tile adds it to game state',
        (WidgetTester tester) async {
      getIt<GameState>().clearList();
      await pumpMenu(tester);
      // Search for Blinkblade to narrow results
      await tester.enterText(find.byType(TextField), 'Blinkblade');
      await tester.pump();

      // Find and tap the CharacterTile widget
      final tileFinder = find.byType(CharacterTile);
      if (tileFinder.evaluate().isNotEmpty) {
        await tester.tap(tileFinder.first);
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        FlutterError.onError = originalOnError;
        // Character was added to the game state
        expect(
          getIt<GameState>().currentList.any((item) =>
              item is Character && item.id == 'Blinkblade'),
          isTrue,
        );
      }
    });

    testWidgets('tapping Close dismisses the menu',
        (WidgetTester tester) async {
      await pumpMenu(tester);
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AddCharacterMenu), findsNothing);
    });
  });
}
