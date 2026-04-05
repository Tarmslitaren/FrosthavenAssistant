import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_list_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_ability_list_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1).execute();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
  });

  group('ReorderListCommand', () {
    test('should swap two items in the main list', () {
      final list = getIt<GameState>().currentList;
      final firstId = list[0].id;
      final secondId = list[1].id;

      ReorderListCommand(0, 1).execute();

      expect(getIt<GameState>().currentList[0].id, secondId);
      expect(getIt<GameState>().currentList[1].id, firstId);
    });

    test('describe returns correct string', () {
      expect(ReorderListCommand(0, 1).describe(), 'Reorder List');
    });

    test('undo does not throw', () {
      final gs = getIt<GameState>();
      gs.action(ReorderListCommand(0, 1));
      expect(() => gs.undo(), returnsNormally);
    });
  });

  group('ReorderAbilityListCommand', () {
    test('should reorder cards in a monster ability deck', () {
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;
      final deck = GameMethods.getDeck(monster.type.deck)!;
      // Need at least 2 cards
      if (deck.drawPile.size() >= 2) {
        final firstCardNr = deck.drawPile.getList()[0].nr;
        final secondCardNr = deck.drawPile.getList()[1].nr;

        ReorderAbilityListCommand(monster.type.deck, 0, 1).execute();

        expect(deck.drawPile.getList()[0].nr, secondCardNr);
        expect(deck.drawPile.getList()[1].nr, firstCardNr);
      }
    });

    test('describe returns correct string', () {
      expect(ReorderAbilityListCommand('deck', 0, 1).describe(),
          'Reorder Ability Cards');
    });
  });

  group('ReorderModifierListCommand', () {
    test('should reorder cards in a modifier deck draw pile', () {
      final deck = getIt<GameState>().modifierDeck;
      if (deck.drawPile.size() >= 2) {
        final firstGfx = deck.drawPile.getList()[0].gfx;
        final secondGfx = deck.drawPile.getList()[1].gfx;

        ReorderModifierListCommand(0, 1, '').execute();

        expect(deck.drawPile.getList()[0].gfx, secondGfx);
        expect(deck.drawPile.getList()[1].gfx, firstGfx);
      }
    });

    test('describe returns correct string', () {
      expect(ReorderModifierListCommand(0, 1, '').describe(),
          'Reorder Modifier Cards');
    });
  });
}
