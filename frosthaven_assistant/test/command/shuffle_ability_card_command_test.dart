import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/shuffle_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/shuffle_amd_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/shuffle_drawn_ability_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
  });

  group('ShuffleAbilityCardCommand', () {
    test('should shuffle ability deck (discard into draw pile)', () {
      // Draw some cards into discard
      DrawAbilityCardCommand(monster.id).execute();
      DrawAbilityCardCommand(monster.id).execute();
      final deck = GameMethods.getDeck(monster.type.deck)!;
      expect(deck.discardPileIsNotEmpty, isTrue);

      ShuffleAbilityCardCommand(monster.id).execute();

      expect(deck.discardPileContents, isEmpty);
      checkSaveState();
    });

    test('describe returns correct string', () {
      expect(ShuffleAbilityCardCommand(monster.id).describe(),
          'Extra ability deck shuffle');
    });
  });

  group('ShuffleDrawnAbilityCardCommand', () {
    test('should shuffle only undrawn part of ability deck', () {
      final deck = GameMethods.getDeck(monster.type.deck)!;
      final totalBefore = deck.drawPileSize + deck.discardPileSize;

      ShuffleDrawnAbilityCardCommand(monster.type.deck).execute();

      final totalAfter = deck.drawPileSize + deck.discardPileSize;
      expect(totalAfter, totalBefore);
    });

    test('describe returns correct string', () {
      expect(ShuffleDrawnAbilityCardCommand(monster.type.deck).describe(),
          'Drawn ability deck shuffle');
    });
  });

  group('ShuffleAMDCardCommand', () {
    test('describe returns correct string', () {
      expect(ShuffleAMDCardCommand('').describe(), 'Extra AMD deck shuffle');
    });

    test('should shuffle modifier deck draw pile', () {
      final deck = getIt<GameState>().modifierDeck;
      final sizeBefore = deck.drawPileSize;

      ShuffleAMDCardCommand('').execute();

      expect(deck.drawPileSize, sizeBefore);
    });
  });
}
