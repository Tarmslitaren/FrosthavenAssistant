import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class RemoveCardMenuViewModel {
  RemoveCardMenuViewModel(this.card, {GameState? gameState})
      : _gameState = gameState ?? getIt<GameState>();

  final MonsterAbilityCardModel card;
  final GameState _gameState;

  bool get isInDrawPile {
    for (final item in _gameState.currentAbilityDecks) {
      if (item.name == card.deck) {
        for (final c in item.drawPileContents) {
          if (c.nr == card.nr) return true;
        }
        break;
      }
    }
    return false;
  }

  int get drawPileIndex {
    for (final item in _gameState.currentAbilityDecks) {
      if (item.name == card.deck) {
        final list = item.drawPileContents.toList();
        for (int i = 0; i < list.length; i++) {
          if (list[i].nr == card.nr) return i;
        }
        break;
      }
    }
    return 0;
  }
}
