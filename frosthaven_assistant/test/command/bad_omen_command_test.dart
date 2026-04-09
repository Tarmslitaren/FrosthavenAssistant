import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/bad_omen_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
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

  group('BadOmenCommand', () {
    test('should increase badOmen value for monster deck', () {
      // Arrange
      final command = BadOmenCommand(false);
      final monsterDeck = getIt<GameState>().modifierDeck;
      final initialBadOmenValue = monsterDeck.badOmen.value;

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 6);
      checkSaveState();
    });

    test('should increase badOmen value for allies deck', () {
      // Arrange
      final command = BadOmenCommand(true);
      final alliesDeck = getIt<GameState>().modifierDeckAllies;
      final initialBadOmenValue = alliesDeck.badOmen.value;

      // Act
      command.execute();

      // Assert
      expect(alliesDeck.badOmen.value, initialBadOmenValue + 6);
      checkSaveState();
    });

    test('should add curses on top', () {
      // Arrange
      final command = BadOmenCommand(false);
      final monsterDeck = getIt<GameState>().modifierDeck;
      final initialBadOmenValue = monsterDeck.badOmen.value;

      // Act
      command.execute();

      // Assert
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 6);

      ChangeCurseCommand(1, "Zealot", "Zealot").execute(); // Add a curse first
      expect(monsterDeck.drawPileContents.toList()[15].gfx, "curse");
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 5);

      ChangeCurseCommand(1, "Zealot", "Zealot").execute(); // Add a curse first
      expect(monsterDeck.drawPileContents.toList()[15].gfx, "curse");
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 4);

      ChangeCurseCommand(1, "Zealot", "Zealot").execute(); // Add a curse first
      expect(monsterDeck.drawPileContents.toList()[15].gfx, "curse");
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 3);

      ChangeCurseCommand(1, "Zealot", "Zealot").execute(); // Add a curse first
      expect(monsterDeck.drawPileContents.toList()[15].gfx, "curse");
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 2);

      ChangeCurseCommand(1, "Zealot", "Zealot").execute(); // Add a curse first
      expect(monsterDeck.drawPileContents.toList()[15].gfx, "curse");
      expect(monsterDeck.badOmen.value, initialBadOmenValue + 1);

      checkSaveState();
    });

    test('describe should return correct string', () {
      // Arrange
      final command = BadOmenCommand(false);

      // Act & Assert
      expect(command.describe(), 'Bad Omen');
    });
  });
}
