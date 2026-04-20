import '../enums.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class ActivateMonsterTypeCommand extends Command {
  final String name;
  final bool activate;
  final GameState _gameState;

  ActivateMonsterTypeCommand(this.name, this.activate,
      {required GameState gameState})
      : _gameState = gameState;

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
        RoundMethods.sortCharactersFirst(stateAccess);
      } else if (roundState == RoundState.playTurns) {
        DeckMethods.drawAbilityCardFromInactiveDeck(stateAccess);
        if (monster != null) {
          RoundMethods.sortItemToPlace(
              stateAccess, name, GameMethods.getInitiative(monster));
        }
      }
    }
    if (_gameState.roundState.value == RoundState.playTurns) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _gameState.updateList.notify();
      });
    } else {
      _gameState.updateList.notify();
    }
  }


  @override
  String describe() {
    if (activate) {
      return "Activate $name";
    }
    return "Deactivate $name";
  }
}
