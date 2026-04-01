import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', '', 1).execute();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
  });

  group('ChangeEnfeebleCommand', () {
    test('should add enfeeble to character modifier deck', () {
      final character =
          getIt<GameState>().currentList.firstWhere((e) => e is Character)
              as Character;
      final initial =
          character.characterState.modifierDeck.getRemovable('enfeeble').value;

      ChangeEnfeebleCommand(1, 'enfeeble', character.id, character.id)
          .execute();

      expect(
          character.characterState.modifierDeck.getRemovable('enfeeble').value,
          initial + 1);
      checkSaveState();
    });

    test('should add enfeeble to monster modifier deck', () {
      final gameState = getIt<GameState>();
      final initial = gameState.modifierDeck.getRemovable('enfeeble').value;

      ChangeEnfeebleCommand(
              1, 'enfeeble', 'Ancient Artillery (FH)', 'Ancient Artillery (FH)')
          .execute();

      expect(gameState.modifierDeck.getRemovable('enfeeble').value,
          initial + 1);
    });

    test('describe should return "Add Enfeeble" when change is positive', () {
      final command =
          ChangeEnfeebleCommand(1, 'enfeeble', 'Blinkblade', 'Blinkblade');
      expect(command.describe(), 'Add Enfeeble');
    });

    test('describe should return "Remove Enfeeble" when change is negative',
        () {
      final command =
          ChangeEnfeebleCommand(-1, 'enfeeble', 'Blinkblade', 'Blinkblade');
      expect(command.describe(), 'Remove Enfeeble');
    });
  });
}
