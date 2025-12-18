import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_plus_0_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    // Setting a scenario resets the modifier decks to their default state.
    final command = SetScenarioCommand('#5 A Deeper Understanding', false);
    command.execute();
  });

  group('AmdRemovePlus0Command', () {
    test('should remove a plus zero card from the monster deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeck;
      final initialCount =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      final command = AmdRemovePlus0Command("", true);

      // Act
      command.execute();

      // Assert
      final finalCount =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      expect(finalCount, initialCount - 1);
    });

    test('should add back a removed plus zero card to the monster deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeck;
      final initialCount =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      final command = AmdRemovePlus0Command("", true);

      // Act
      command.execute(); // Remove one card

      // Assert
      final countAfterRemove =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      expect(countAfterRemove, initialCount - 1);

      // Act: Add the card back
      AmdRemovePlus0Command("", false).execute();

      // Assert
      final countAfterAdd =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      expect(countAfterAdd, initialCount);
    });

    test('should remove a plus zero card from the allies deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeckAllies;
      final initialCount =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      final command = AmdRemovePlus0Command("allies", true);

      // Act
      command.execute();

      // Assert
      final finalCount =
          modifierDeck.drawPile.getList().where((c) => c.gfx == 'plus0').length;
      expect(finalCount, initialCount - 1);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AmdRemovePlus0Command("", true);

      // Act & Assert
      expect(command.describe(), 'Remove plus zero');
    });
  });
}
