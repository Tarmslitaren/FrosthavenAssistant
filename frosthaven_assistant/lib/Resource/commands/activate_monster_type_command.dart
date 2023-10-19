import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../state/game_state.dart';
import '../state/monster.dart';

class ActivateMonsterTypeCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String name;
  final bool activate;

  ActivateMonsterTypeCommand(this.name, this.activate);

  @override
  void execute() {
    Monster? monster;
    for (var item in _gameState.currentList) {
      if (item.id == name) {
        if (item is Monster) {
          item.isActive = activate;
          monster = item;
        }
      }
    }
    if (activate) {
      if (getIt<GameState>().roundState.value == RoundState.chooseInitiative) {
        GameMethods.sortCharactersFirst();
      } else if (getIt<GameState>().roundState.value == RoundState.playTurns) {
        GameMethods.drawAbilityCardFromInactiveDeck();
        GameMethods.sortItemToPlace(name, GameMethods.getInitiative(monster!));
      }
    }
    if (getIt<GameState>().roundState.value == RoundState.playTurns) {
      Future.delayed(const Duration(milliseconds: 600), () {
        getIt<GameState>().updateList.value++;
      });
    } else {
      getIt<GameState>().updateList.value++;
    }
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (activate) {
      return "Activate $name";
    }
    return "Deactivate $name";
  }
}
