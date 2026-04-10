import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/track_standees_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    getIt<Settings>().noStandees.value = false;
  });

  group('TrackStandeesCommand', () {
    test('should set noStandees to true when track is false', () {
      TrackStandeesCommand(false, gameState: getIt<GameState>(), settings: getIt<Settings>()).execute();
      expect(getIt<Settings>().noStandees.value, isTrue);
    });

    test('should set noStandees to false when track is true', () {
      TrackStandeesCommand(false, gameState: getIt<GameState>(), settings: getIt<Settings>()).execute();
      TrackStandeesCommand(true, gameState: getIt<GameState>(), settings: getIt<Settings>()).execute();
      expect(getIt<Settings>().noStandees.value, isFalse);
    });

    test('should clear monster instances when switching to no-track mode', () {
      AddMonsterCommand('Ancient Artillery (FH)', 1, false, gameState: getIt<GameState>()).execute();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false, gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      expect(monster.monsterInstances, isNotEmpty);

      TrackStandeesCommand(false, gameState: getIt<GameState>(), settings: getIt<Settings>()).execute();

      expect(monster.monsterInstances, isEmpty);
    });

    test('describe returns correct string when track is false', () {
      expect(TrackStandeesCommand(false, gameState: getIt<GameState>(), settings: getIt<Settings>()).describe(), "Don't track standees");
    });

    test('describe returns correct string when track is true', () {
      expect(TrackStandeesCommand(true, gameState: getIt<GameState>(), settings: getIt<Settings>()).describe(), 'Track Standees');
    });
  });
}
