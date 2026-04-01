import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('SetCampaignCommand', () {
    test('should set campaign to Frosthaven', () {
      final command = SetCampaignCommand('Frosthaven');
      command.execute();
      expect(getIt<GameState>().currentCampaign.value, 'Frosthaven');
      checkSaveState();
    });

    test('should set campaign to Jaws of the Lion', () {
      final command = SetCampaignCommand('Jaws of the Lion');
      command.execute();
      expect(getIt<GameState>().currentCampaign.value, 'Jaws of the Lion');
      checkSaveState();
    });

    test('describe should return correct string', () {
      final command = SetCampaignCommand('Frosthaven');
      expect(command.describe(), 'set Frosthaven campaign');
    });
  });
}
