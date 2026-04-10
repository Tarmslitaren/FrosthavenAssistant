import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false, gameState: getIt<GameState>()).execute();
  });

  group('DrawAbilityCardCommand', () {
    test('should move a card from draw pile to discard pile', () {
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      final deck = GameMethods.getDeck(monster.type.deck)!;
      final drawBefore = deck.drawPileSize;
      final discardBefore = deck.discardPileSize;

      DrawAbilityCardCommand(monster.id).execute();

      expect(deck.drawPileSize, drawBefore - 1);
      expect(deck.discardPileSize, discardBefore + 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      final command = DrawAbilityCardCommand(monster.id);
      expect(command.describe(), 'Draw extra ability card');
    });
  });
}
