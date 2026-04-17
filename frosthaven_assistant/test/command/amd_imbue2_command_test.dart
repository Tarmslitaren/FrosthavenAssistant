// ignore_for_file: no-magic-number

import 'package:flutter_test/flutter_test.dart';
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

  setUp(() {
    AMDRemoveImbueCommand(gameState: getIt<GameState>()).execute();
  });

  group('AMDImbue2Command', () {
    test('should set imbue2 on the monster modifier deck', () {
      // Arrange
      final command = AMDImbue2Command(gameState: getIt<GameState>());
      final monsterDeck = getIt<GameState>().modifierDeck;
      expect(monsterDeck.imbuement.value, 0);

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 2);
      expect(monsterDeck.drawPileSize, 24);
      //todo: check actual cards
      checkSaveState();
    });

    test('should set imbue2 on the monster modifier deck after imbue 1 set',
        () {
      // Arrange
      AMDImbue1Command(gameState: getIt<GameState>()).execute();
      final command = AMDImbue2Command(gameState: getIt<GameState>());
      final monsterDeck = getIt<GameState>().modifierDeck;
      expect(monsterDeck.imbuement.value, 1);

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 2);
      expect(monsterDeck.drawPileSize, 24);
      //todo: check actual cards
      checkSaveState();
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AMDImbue2Command(gameState: getIt<GameState>());

      // Act & Assert
      expect(command.describe(), 'Advanced Imbue Monster Deck');
    });
  });
}
