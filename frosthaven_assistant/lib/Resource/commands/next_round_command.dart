import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';

import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_data.dart';
import '../settings.dart';
import '../state/game_state.dart';

class NextRoundCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();

  void _handleTimedSpawns(var rule) {
    if (getIt<Settings>().autoAddSpawns.value == true) {
      if (rule.name.isNotEmpty) {
        //get room data and deal with spawns
        ScenarioModel? scenario = _gameData
            .modelData
            .value[_gameState.currentCampaign.value]
            ?.scenarios[_gameState.scenario.value];
        if (scenario != null) {
          ScenarioModel? spawnSection = scenario.sections.firstWhereOrNull(
              (element) => element.name.substring(1) == rule.name);
          if (spawnSection != null && spawnSection.monsterStandees != null) {
            GameMethods.autoAddStandees(stateAccess,
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
        item.nextRound(stateAccess);
      }
      if (item is Monster) {
        //only really needed for ice wraiths
        GameMethods.sortMonsterInstances(stateAccess, item.getMutableMonsterInstancesList(stateAccess));
      }
    }
    GameMethods.shuffleDecksIfNeeded(stateAccess);
    GameMethods.updateElements(stateAccess);
    GameMethods.setRoundState(stateAccess, RoundState.chooseInitiative);
    if (_gameState.currentList.last.turnState != TurnsState.done) {
      GameMethods.setTurnDone(stateAccess, _gameState.currentList.length - 1);
    }
    if (_gameState.currentList.last.turnState != TurnsState.done) {
      GameMethods.setTurnDone(stateAccess, _gameState.currentList.length - 1);
    }
    GameMethods.clearTurnState(stateAccess, false);
    GameMethods.sortCharactersFirst(stateAccess);

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

    GameMethods.setRound(stateAccess, _gameState.round.value + 1, false);

    Future.delayed(const Duration(milliseconds: 600), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    });

    if (_gameState.modifierDeck.needsShuffle) {
      _gameState.modifierDeck.shuffle(stateAccess);
    }
    if (_gameState.modifierDeckAllies.needsShuffle) {
      _gameState.modifierDeckAllies.shuffle(stateAccess);
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
