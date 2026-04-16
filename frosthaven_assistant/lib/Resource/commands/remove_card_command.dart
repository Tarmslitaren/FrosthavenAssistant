import 'package:frosthaven_assistant/Layout/menus/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';

import '../state/game_state.dart';

class RemoveCardCommand extends Command {
  final MonsterAbilityCardModel card;
  final GameState _gameState;

  RemoveCardCommand(this.card, {required GameState gameState})
      : _gameState = gameState;
  @override
  void execute() {
    for (var deck in _gameState.currentAbilityDecks) {
      if (deck.name == card.deck) {
        for (var drawPileCard in deck.drawPileContents) {
          if (drawPileCard.nr == card.nr) {
            deck.removeFromDrawPile(stateAccess, card);
            break;
          }
        }
        for (var discardPileCard in deck.discardPileContents) {
          if (discardPileCard.nr == card.nr) {
            deck.removeFromDiscardPile(stateAccess, card);
            break;
          }
        }
        deck.shuffle(stateAccess);
        deck.draw(stateAccess);
        break;
      }
    }
    //todo: not use a sad hack, find better ui update solution
    AbilityCardsMenuState.revealedList = [];
  }

  @override
  void onUndo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Remove ${card.deck} card nr ${card.nr}";
  }
}
