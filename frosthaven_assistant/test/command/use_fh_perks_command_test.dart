import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_fh_perks_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1, gameState: getIt<GameState>()).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('UseFHPerksCommand', () {
    test('should toggle useFHPerks from false to true', () {
      expect(character.characterState.useFHPerks.value, isFalse);

      UseFHPerksCommand(character.id).execute();

      expect(character.characterState.useFHPerks.value, isTrue);
      checkSaveState();
    });

    test('should toggle useFHPerks from true to false', () {
      UseFHPerksCommand(character.id).execute();
      expect(character.characterState.useFHPerks.value, isTrue);

      UseFHPerksCommand(character.id).execute();

      expect(character.characterState.useFHPerks.value, isFalse);
    });

    test('describe should include character id', () {
      final command = UseFHPerksCommand(character.id);
      expect(command.describe(), contains(character.id));
    });
  });
}
