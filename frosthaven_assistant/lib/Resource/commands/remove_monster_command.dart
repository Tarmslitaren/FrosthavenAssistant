
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class RemoveMonsterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<Monster> names;

  RemoveMonsterCommand(this.names);

  @override
  void execute() {
    List<String> deckIds = [];
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Monster) {
        bool remove = false;
        for(var name in names) {
          if (item.id == name.id) {
            remove = true;
            deckIds.add(item.type.deck);
          }
        }
        if (!remove) {
          newList.add(item);
        }
      } else {
        newList.add(item);
      }
    }


    _gameState.currentList = newList;

    for (var deck in deckIds) {
    bool removeDeck = true;
    for(var item in _gameState.currentList) {
      if (item is Monster){
        if(item.type.deck == deck){
          removeDeck = false;
        }
      }
    }

    if(removeDeck) {
      for (var item in _gameState.currentAbilityDecks) {
        if(item.name == deck) {
          _gameState.currentAbilityDecks.remove(item);
          break;
        }
      }
    }
    }

    _gameState.updateList.value++;
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if(names.length > 1) {
      return "Remove all monsters";
    }
    return "Remove ${names[0].type.display}";
  }


}