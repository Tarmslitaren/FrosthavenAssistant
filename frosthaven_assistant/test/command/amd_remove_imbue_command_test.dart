// ignore_for_file: no-magic-number, no-empty-block

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue2_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_imbue_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {});

  group('AMDRemoveImbueCommand', () {
    test('should remove imbuement from the monster modifier deck', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AMDImbue1Command(gameState: getIt<GameState>()).execute();
      expect(monsterDeck.imbuement.value, 1);

      final command = AMDRemoveImbueCommand(gameState: getIt<GameState>());

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPileSize, 20);
      checkSaveState();
    });

    test('should remove imbuement from the monster modifier deck 2', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AMDImbue2Command(gameState: getIt<GameState>()).execute();
      expect(monsterDeck.imbuement.value, 2);

      final command = AMDRemoveImbueCommand(gameState: getIt<GameState>());

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPileSize, 20);
      checkSaveState();
    });

    test('should remove imbuement from the monster modifier deck both', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AMDImbue1Command(gameState: getIt<GameState>()).execute();
      AMDImbue2Command(gameState: getIt<GameState>()).execute();
      expect(monsterDeck.imbuement.value, 2);

      final command = AMDRemoveImbueCommand(gameState: getIt<GameState>());

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPileSize, 20);
      checkSaveState();
    });

    test('should not remove hail special', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AddCharacterCommand("Hail", "Mercenary Packs", "Hail", 1,
              gameState: getIt<GameState>())
          .execute();
      AddPerkCommand("Hail", 17).execute();
      AMDImbue2Command(gameState: getIt<GameState>()).execute();
      expect(monsterDeck.imbuement.value, 2);

      final command = AMDRemoveImbueCommand(gameState: getIt<GameState>());

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPileSize, 21);
      checkSaveState();
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AMDRemoveImbueCommand(gameState: getIt<GameState>());

      // Act & Assert
      expect(command.describe(), 'Remove Imbuement');
    });
  });
}
