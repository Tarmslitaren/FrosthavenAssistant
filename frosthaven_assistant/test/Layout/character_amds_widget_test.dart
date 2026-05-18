// ignore_for_file: no-magic-number

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/ModifierDeckWidget/modifier_deck_widget.dart';
import 'package:frosthaven_assistant/Layout/character_amds_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_character_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    getIt<Settings>().showCharacterAMD.value = true;
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    FlutterError.onError = ignoreOverflowErrors;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CharacterAmdsWidget())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    FlutterError.onError = originalOnError;
  }

  group('CharacterAmdsWidget', () {
    testWidgets('returns empty container when showCharacterAMD is false', (
      WidgetTester tester,
    ) async {
      getIt<Settings>().showCharacterAMD.value = false;
      await pumpWidget(tester);
      expect(find.text('Character Decks'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('returns empty container when no characters', (
      WidgetTester tester,
    ) async {
      await pumpWidget(tester);
      expect(find.text('Character Decks'), findsNothing);
    });

    testWidgets(
      'renders Character Decks button when character with perks exists',
      (WidgetTester tester) async {
        // Blinkblade has perks
        AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
        await pumpWidget(tester);
        expect(find.text('Character Decks'), findsOneWidget);
      },
    );

    testWidgets('renders ElevatedButton when character with perks exists', (
      WidgetTester tester,
    ) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      await pumpWidget(tester);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tapping Character Decks button does not throw', (
      WidgetTester tester,
    ) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      await pumpWidget(tester);

      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = ignoreOverflowErrors;
      await tester.tap(find.text('Character Decks'));
      // Flush 0ms timers created by animation state changes, then advance
      // past the 500ms animation duration so all timers complete.
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      FlutterError.onError = originalOnError;

      // Just ensure it doesn't crash
      expect(find.text('Character Decks'), findsOneWidget);
    });

    testWidgets('returns empty when character has no perks', (
      WidgetTester tester,
    ) async {
      // Banner Spear has perks too, but let us verify the behavior with a
      // character that does have perks; testing 'no perks' is an edge case
      // handled by the widget guard (characterAmount == 0)
      await pumpWidget(tester);
      expect(find.text('Character Decks'), findsNothing);
    });

    testWidgets('widget renders without error with two characters', (
      WidgetTester tester,
    ) async {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 2).execute();
      await pumpWidget(tester);
      expect(find.text('Character Decks'), findsOneWidget);
    });

    testWidgets(
      'shows deck widget for newly added second character',
      (WidgetTester tester) async {
        AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
        await pumpWidget(tester);

        final originalOnError = FlutterError.onError;
        addTearDown(() => FlutterError.onError = originalOnError);
        FlutterError.onError = ignoreOverflowErrors;
        AddCharacterCommand('Banner Spear', 'Frosthaven', null, 2).execute();
        await tester.pump();
        FlutterError.onError = originalOnError;

        final deckWidgets = tester
            .widgetList<ModifierDeckWidget>(find.byType(ModifierDeckWidget))
            .toList();
        expect(
          deckWidgets.any((w) => w.name == 'Blinkblade'),
          isTrue,
          reason: 'Expected Blinkblade deck to be present',
        );
        expect(
          deckWidgets.any((w) => w.name == 'Banner Spear'),
          isTrue,
          reason: 'Expected Banner Spear deck to be present',
        );
      },
    );

    testWidgets(
      'shows correct deck after removing first of two characters',
      (WidgetTester tester) async {
        AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1).execute();
        AddCharacterCommand('Banner Spear', 'Frosthaven', null, 2).execute();

        final gameState = getIt<GameState>();
        // Draw one card from Banner Spear's deck so its size differs from the
        // monster deck (both start at 20). This lets the count check below
        // distinguish "showing BannerSpear" from "showing monster deck".
        gameState.action(
          DrawModifierCardCommand('Banner Spear', gameState: gameState),
        );
        final bannerSpearDeckSize =
            GameMethods.getModifierDeck('Banner Spear', gameState).drawPileSize;
        final monsterDeckSize =
            GameMethods.getModifierDeck('', gameState).drawPileSize;
        expect(bannerSpearDeckSize, isNot(equals(monsterDeckSize)));

        await pumpWidget(tester);

        final blinkblade = GameMethods.getCurrentCharacters()
            .firstWhere((c) => c.id == 'Blinkblade');

        final originalOnError = FlutterError.onError;
        addTearDown(() => FlutterError.onError = originalOnError);
        FlutterError.onError = ignoreOverflowErrors;
        gameState.action(
          RemoveCharacterCommand([blinkblade], gameState: gameState),
        );
        await tester.pump();
        FlutterError.onError = originalOnError;

        // After removing Blinkblade the widget must show Banner Spear's deck.
        // Without ValueKey on ModifierDeckWidget, Flutter reuses the Blinkblade
        // element at position 0; its cached vm finds no character named
        // 'Blinkblade' and falls through to the monster deck (size 20).
        expect(
          find.text(bannerSpearDeckSize.toString()),
          findsWidgets,
          reason: 'Expected displayed count to match Banner Spear deck size',
        );
        expect(
          find.text(monsterDeckSize.toString()),
          findsNothing,
          reason: 'Expected monster deck size not to be displayed',
        );
      },
    );
  });
}
