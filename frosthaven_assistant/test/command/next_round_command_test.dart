import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1).execute();
    SetCampaignCommand('Jaws of the Lion').execute();
    SetScenarioCommand('#5 A Deeper Understanding', false).execute();
  });

  group('NextRoundCommand', () {
    test('should increment the round counter', () {
      final roundBefore = getIt<GameState>().round.value;

      NextRoundCommand().execute();

      expect(getIt<GameState>().round.value, roundBefore + 1);
      checkSaveState();
    });

    test('should step down full elements to half after next round', () {
      ImbueElementCommand(Elements.fire, false).execute();
      expect(getIt<GameState>().elementState[Elements.fire], ElementState.full);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.fire], ElementState.half);
    });

    test('should step down half elements to inert after next round', () {
      ImbueElementCommand(Elements.ice, true).execute();
      expect(getIt<GameState>().elementState[Elements.ice], ElementState.half);

      NextRoundCommand().execute();

      expect(getIt<GameState>().elementState[Elements.ice], ElementState.inert);
    });

    test('describe returns "Next Round"', () {
      expect(NextRoundCommand().describe(), 'Next Round');
    });
  });
}
