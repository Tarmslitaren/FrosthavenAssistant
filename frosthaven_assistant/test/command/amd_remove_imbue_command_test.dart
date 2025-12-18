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
      AMDImbue1Command().execute();
      expect(monsterDeck.imbuement.value, 1);

      final command = AMDRemoveImbueCommand();

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPile.size(), 20);
      checkSaveState();
    });

    test('should remove imbuement from the monster modifier deck 2', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AMDImbue2Command().execute();
      expect(monsterDeck.imbuement.value, 2);

      final command = AMDRemoveImbueCommand();

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPile.size(), 20);
      checkSaveState();
    });

    test('should remove imbuement from the monster modifier deck both', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AMDImbue1Command().execute();
      AMDImbue2Command().execute();
      expect(monsterDeck.imbuement.value, 2);

      final command = AMDRemoveImbueCommand();

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPile.size(), 20);
      checkSaveState();
    });

    test('should not remove hail special', () {
      // Arrange
      final monsterDeck = getIt<GameState>().modifierDeck;
      // Add imbuement first to ensure there is something to remove.
      AddCharacterCommand("Hail", "Mercenary Packs", "Hail", 1).execute();
      AddPerkCommand("Hail", 17).execute();
      AMDImbue2Command().execute();
      expect(monsterDeck.imbuement.value, 2);

      final command = AMDRemoveImbueCommand();

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 0);
      expect(monsterDeck.drawPile.size(), 21);
      checkSaveState();
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AMDRemoveImbueCommand();

      // Act & Assert
      expect(command.describe(), 'Remove Imbuement');
    });
  });
}
