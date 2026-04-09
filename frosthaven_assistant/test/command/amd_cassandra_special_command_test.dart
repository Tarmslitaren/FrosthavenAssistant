import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_cassandra_special_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('AMDCassandraSpecialCommand', () {
    test('should set cassandraSpecial to true on main deck', () {
      AMDCassandraSpecialCommand('', true).execute();
      expect(getIt<GameState>().modifierDeck.cassandraSpecial.value, isTrue);
      checkSaveState();
    });

    test('should set cassandraSpecial to false on main deck', () {
      AMDCassandraSpecialCommand('', true).execute();
      AMDCassandraSpecialCommand('', false).execute();
      expect(getIt<GameState>().modifierDeck.cassandraSpecial.value, isFalse);
      checkSaveState();
    });

    test('describe when on returns leave-revealed string', () {
      final command = AMDCassandraSpecialCommand('Blinkblade', true);
      expect(command.describe(),
          'Leave revealed cards on top of Blinkblade deck');
    });

    test('describe when off returns turned-off string', () {
      final command = AMDCassandraSpecialCommand('Blinkblade', false);
      expect(command.describe(),
          'Cassandra Special turned off for Blinkblade deck');
    });
  });
}
