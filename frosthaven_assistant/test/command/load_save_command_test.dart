import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/load_character_save_command.dart';
import 'package:frosthaven_assistant/Resource/commands/load_save_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('LoadSaveCommand', () {
    test('should restore game state from serialized data', () {
      getIt<GameState>().clearList();
      SetCampaignCommand('Jaws of the Lion').execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'SaveTest', 1).execute();
      final savedData = getIt<GameState>().toString();

      // Change state
      getIt<GameState>().clearList();

      // Restore
      LoadSaveCommand('test save', savedData).execute();

      expect(getIt<GameState>().currentList.whereType<Character>().length, 1);
      expect(
          getIt<GameState>()
              .currentList
              .whereType<Character>()
              .first
              .characterState
              .display
              .value,
          'SaveTest');
    });

    test('describe includes save name', () {
      final command = LoadSaveCommand('my save', '{}');
      expect(command.describe(), 'Load saved game: my save');
    });
  });

  group('LoadCharacterSaveCommand', () {
    test('should load a character from serialized character data', () {
      getIt<GameState>().clearList();
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('custom', false).execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'OrigName', 1).execute();
      final character = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character) as Character;
      final charData = character.toSave();

      // Remove the character
      getIt<GameState>().clearList();

      // Reload from save data
      LoadCharacterSaveCommand('Blinkblade', charData).execute();

      final loaded = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Character) as Character;
      expect(loaded.id, 'Blinkblade');
      expect(loaded.characterState.display.value, 'OrigName');
    });

    test('describe includes save name', () {
      final command = LoadCharacterSaveCommand('Blinkblade', '{}');
      expect(command.describe(), 'Load saved character: Blinkblade');
    });
  });
}
