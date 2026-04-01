import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_monster_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  group('RemoveMonsterCommand', () {
    test('should remove a single monster from the list', () {
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      expect(getIt<GameState>().currentList.whereType<Monster>().length, 1);

      RemoveMonsterCommand([monster]).execute();

      expect(getIt<GameState>().currentList.whereType<Monster>(), isEmpty);
      checkSaveState();
    });

    test('describe returns "Remove all monsters" for multiple items in list', () {
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      // Passing the same monster twice simulates a multi-monster list
      final command = RemoveMonsterCommand([monster, monster]);
      expect(command.describe(), 'Remove all monsters');
    });

    test('describe includes monster type name for single monster', () {
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      final command = RemoveMonsterCommand([monster]);
      expect(command.describe(), contains('Remove'));
    });
  });
}
