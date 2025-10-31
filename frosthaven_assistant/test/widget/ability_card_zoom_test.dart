import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/menus/ability_card_zoom.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('AbilityCardZoom', () {
    testWidgets('should display the ability card and be dismissible',
        (WidgetTester tester) async {
      // Arrange
      AddMonsterCommand("Zealot", 1, false).execute();
      //DrawAbilityCardCommand("Zealot").execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final card = getIt<GameState>().currentAbilityDecks.first.drawPile.peek;

      FlutterError.onError = ignoreOverflowErrors;
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AbilityCardZoom(
                      card: card,
                      monster: monster,
                      calculateAll: false,
                    ),
                  );
                },
                child: const Text('Show Zoom'),
              );
            },
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AbilityCardZoom), findsOneWidget);
      expect(find.text(card.title), findsOneWidget);

      // Act - dismiss dialog
      await tester.tap(find.byType(AbilityCardZoom));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AbilityCardZoom), findsNothing);
    });

    testWidgets('should display the ability card with calculateAll true',
        (WidgetTester tester) async {
      // Arrange
      AddMonsterCommand("Zealot", 1, false).execute();
      //DrawAbilityCardCommand("Zealot").execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final card = getIt<GameState>().currentAbilityDecks.first.drawPile.peek;

      FlutterError.onError = ignoreOverflowErrors;
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AbilityCardZoom(
                      card: card,
                      monster: monster,
                      calculateAll: true,
                    ),
                  );
                },
                child: const Text('Show Zoom'),
              );
            },
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AbilityCardZoom), findsOneWidget);
      expect(find.text(card.title), findsOneWidget);
    });
  });
}
