// ignore_for_file: avoid-non-null-assertion

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_minus_2_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    final command = SetScenarioCommand('#5 A Deeper Understanding', false,
        gameState: getIt<GameState>()); //setting scenario resets the decks
    // Act
    command.execute();
  });

  group('AMDRemoveMinus2Command', () {
    test('should remove a minus two card from the monster deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeck;
      final command =
          AMDRemoveMinus2Command(false, gameState: getIt<GameState>());

      // Act
      command.execute();

      final card =
          modifierDeck.drawPileContents.toList().firstWhereOrNull((it) {
        return it.gfx == 'minus2';
      });
      // Assert
      expect(card, null);
    });

    test('should add back a removed minus two card from the monster deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeck;
      final command =
          AMDRemoveMinus2Command(false, gameState: getIt<GameState>());

      // Act
      command.execute();

      final card =
          modifierDeck.drawPileContents.toList().firstWhereOrNull((it) {
        return it.gfx == 'minus2';
      });
      // Assert
      expect(card, null);

      //add back
      AMDRemoveMinus2Command(false, gameState: getIt<GameState>()).execute();
      final card2 =
          modifierDeck.drawPileContents.toList().firstWhereOrNull((it) {
        return it.gfx == 'minus2';
      });
      // Assert
      expect(card2 == null, false);
      expect(card2!.gfx, 'minus2');
    });

    test('should remove a minus two card from the allies deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeckAllies;
      final command =
          AMDRemoveMinus2Command(true, gameState: getIt<GameState>());

      // Act
      command.execute();

      final card =
          modifierDeck.drawPileContents.toList().firstWhereOrNull((it) {
        return it.gfx == 'minus2';
      });

      // Assert
      expect(card, null);
    });

    test('describe should return correct string', () {
      // Arrange
      final command =
          AMDRemoveMinus2Command(false, gameState: getIt<GameState>());
      command.execute();

      // Act & Assert
      expect(command.describe(), 'Remove minus two');
    });
  });
}
