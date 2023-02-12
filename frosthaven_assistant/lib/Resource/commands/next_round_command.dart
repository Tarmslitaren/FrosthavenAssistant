
import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../settings.dart';
import '../state/character.dart';
import '../state/game_state.dart';
import '../state/monster.dart';
import '../ui_utils.dart';

class NextRoundCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  @override
  void execute() {
    for (var item in _gameState.currentList) {
      if (item is Character) {
        item.nextRound();
      }
      if (item is Monster) {
        //only really needed for ice wraiths
        GameMethods.sortMonsterInstances(item.monsterInstances.value);
      }
    }
    GameMethods.shuffleDecksIfNeeded();
    GameMethods.updateElements();
    GameMethods.setRoundState(RoundState.chooseInitiative);
    if(_gameState.currentList.last.turnState != TurnsState.done) {
      GameMethods.setTurnDone(_gameState.currentList.length - 1);
    }
    if(_gameState.currentList.last.turnState != TurnsState.done) {
      GameMethods.setTurnDone(_gameState.currentList.length - 1);
    }
    GameMethods.clearTurnState(false);
    GameMethods.sortCharactersFirst();

    _gameState.toastMessage.value = "";
    if(getIt<Settings>().showReminders.value == true) {
      for (var rule in _gameState.scenarioSpecialRules) {
        if (rule.type == "Timer" && rule.startOfRound == false) {
          for (int round in rule.list) {
            //minus 1 means always
            if (round == _gameState.round.value || round == -1) {
              _gameState.toastMessage.value = rule.note;
            }
          }
        }
      }

      //start of next round is now
      for (var rule in _gameState.scenarioSpecialRules) {
        if (rule.type == "Timer" && rule.startOfRound == true) {
          for (int round in rule.list) {
            //minus 1 means always
            if (round - 1 == _gameState.round.value || round == -1) {
              if (_gameState.toastMessage.value.isNotEmpty) {
                _gameState.toastMessage.value += "\n\n${rule.note}";
              } else {
                _gameState.toastMessage.value += rule.note;
              }
            }
          }
        }
      }
    }


    _gameState.round.value++;

    Future.delayed(const Duration(milliseconds: 600), () {
        _gameState.updateList.value++;
        MainList.scrollToTop();
    });

    if(_gameState.modifierDeck.needsShuffle) {
      _gameState.modifierDeck.shuffle();
    }
    if(_gameState.modifierDeckAllies.needsShuffle) {
      _gameState.modifierDeckAllies.shuffle();
    }
  }

  @override
  void undo() {
    //GameMethods.setRoundState(RoundState.playTurns);
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Next Round";
  }
}