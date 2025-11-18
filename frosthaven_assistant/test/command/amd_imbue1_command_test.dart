import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_imbue_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    AMDRemoveImbueCommand().execute();
  });

  group('AMDImbue1Command', () {
    test('should set imbue1 on the monster modifier deck', () {
      // Arrange
      final command = AMDImbue1Command();
      final monsterDeck = getIt<GameState>().modifierDeck;
      expect(monsterDeck.imbuement.value, 0);

      expect(monsterDeck.drawPile.size(), 20);

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.imbuement.value, 1);
      expect(monsterDeck.drawPile.size(), 22);
      //todo: check the cards in the deck
      checkSaveState();
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AMDImbue1Command();

      // Act & Assert
      expect(command.describe(), 'Imbue Monster Deck');
    });
  });
}
