import 'package:frosthaven_assistant/Layout/menus/ability_cards_menu.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class RemoveCardCommand extends Command {
  final MonsterAbilityCardModel card;
  final GameState _gameState = getIt<GameState>();
  RemoveCardCommand(this.card);
  @override
  void execute() {
    for (var deck in _gameState.currentAbilityDecks) {
      if (deck.name == card.deck) {
        var drawPile = deck.drawPile.getList();
        var discardPile = deck.discardPile.getList();
        for (var drawPileCard in drawPile) {
          if (drawPileCard.nr == card.nr) {
            drawPile.remove(card);
            break;
          }
        }
        for (var discardPileCard in discardPile) {
          if (discardPileCard.nr == card.nr) {
            discardPile.remove(card);
            break;
          }
        }
        deck.shuffle();
        deck.draw();
        break;
      }
    }
    //todo: not use a sad hack, find better ui update solution
    AbilityCardMenuState.revealedList = [];
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "Remove ${card.deck} card nr ${card.nr}";
  }
}
