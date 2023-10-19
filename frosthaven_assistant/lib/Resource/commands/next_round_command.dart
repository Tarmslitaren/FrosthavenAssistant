import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';

import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../settings.dart';
import '../state/character.dart';
import '../state/game_state.dart';
import '../state/monster.dart';

class NextRoundCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  void _handleTimedSpawns(var rule) {
    if (getIt<Settings>().autoAddSpawns.value == true) {
      if (rule.name.isNotEmpty) {
        //get room data and deal with spawns
        ScenarioModel? scenario = _gameState
            .modelData
            .value[_gameState.currentCampaign.value]
            ?.scenarios[_gameState.scenario.value];
        if (scenario != null) {
          ScenarioModel? spawnSection = scenario.sections.firstWhereOrNull(
              (element) => element.name.substring(1) == rule.name);
          if (spawnSection != null && spawnSection.monsterStandees != null) {
            GameMethods.autoAddStandees(
                spawnSection.monsterStandees!, rule.note);
          }
        }
      }
    }
  }

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
    if (_gameState.currentList.last.turnState != TurnsState.done) {
      GameMethods.setTurnDone(_gameState.currentList.length - 1);
    }
    if (_gameState.currentList.last.turnState != TurnsState.done) {
      GameMethods.setTurnDone(_gameState.currentList.length - 1);
    }
    GameMethods.clearTurnState(false);
    GameMethods.sortCharactersFirst();

    GameMethods.setToastMessage("");

    for (var rule in _gameState.scenarioSpecialRules) {
      if (rule.type == "Timer" && rule.startOfRound == false) {
        for (int round in rule.list) {
          //minus 1 means always
          if (round == _gameState.round.value || round == -1) {
            if (getIt<Settings>().showReminders.value == true) {
              GameMethods.setToastMessage(rule.note);
            }

            _handleTimedSpawns(rule);
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
              GameMethods.setToastMessage(
                  "${_gameState.toastMessage.value}\n\n${rule.note}");
            } else {
              if (getIt<Settings>().showReminders.value == true) {
                GameMethods.setToastMessage(
                    "${_gameState.toastMessage.value}${rule.note}");
              }
            }
            _handleTimedSpawns(rule);
          }
        }
      }
    }

    GameMethods.setRound(_gameState.round.value + 1);

    Future.delayed(const Duration(milliseconds: 600), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    });

    if (_gameState.modifierDeck.needsShuffle) {
      _gameState.modifierDeck.shuffle();
    }
    if (_gameState.modifierDeckAllies.needsShuffle) {
      _gameState.modifierDeckAllies.shuffle();
    }
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Next Round";
  }
}
