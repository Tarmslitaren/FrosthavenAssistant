import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class ActivateMonsterTypeCommand extends Command {
  final String name;
  final bool activate;
  final GameState _gameState = getIt<GameState>();

  ActivateMonsterTypeCommand(this.name, this.activate);

  @override
  void execute() {
    Monster? monster;
    for (var item in _gameState.currentList) {
      if (item.id == name) {
        if (item is Monster) {
          item.setActive(stateAccess, activate);
          monster = item;
        }
      }
    }
    if (activate) {
      final roundState = _gameState.roundState.value;
      if (roundState == RoundState.chooseInitiative) {
        MutableGameMethods.sortCharactersFirst(stateAccess);
      } else if (roundState == RoundState.playTurns) {
        MutableGameMethods.drawAbilityCardFromInactiveDeck(stateAccess);
        MutableGameMethods.sortItemToPlace(
            stateAccess, name, GameMethods.getInitiative(monster!));
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
