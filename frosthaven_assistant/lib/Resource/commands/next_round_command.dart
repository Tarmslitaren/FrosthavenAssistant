import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';

import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_data.dart';
import '../game_methods.dart';
import '../settings.dart';
import '../state/game_state.dart';

class NextRoundCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();

  @override
  void execute() {
    //todo: move code to GameMethods?
    for (var item in _gameState.currentList) {
      if (item is Character) {
        item.nextRound(stateAccess);
      }
      if (item is Monster) {
        //only really needed for ice wraiths
        MutableGameMethods.sortMonsterInstances(
            stateAccess, item.getMutableMonsterInstancesList(stateAccess));
      }
    }
    MutableGameMethods.shuffleDecksIfNeeded(stateAccess);
    MutableGameMethods.updateElements(stateAccess);
    MutableGameMethods.setRoundState(stateAccess, RoundState.chooseInitiative);
    if (_gameState.currentList.last.turnState.value != TurnsState.done) {
      MutableGameMethods.setTurnDone(
          stateAccess, _gameState.currentList.length - 1);
    }
    if (_gameState.currentList.last.turnState.value != TurnsState.done) {
      MutableGameMethods.setTurnDone(
          stateAccess, _gameState.currentList.length - 1);
    }
    MutableGameMethods.clearTurnState(stateAccess, false);
    MutableGameMethods.sortCharactersFirst(stateAccess);

    MutableGameMethods.setToastMessage("");

    for (var rule in _gameState.scenarioSpecialRules) {
      if (rule.type == "Timer" && !rule.startOfRound) {
        for (int round in rule.list) {
          //minus 1 means always
          if (round == _gameState.round.value || round == -1) {
            if (getIt<Settings>().showReminders.value) {
              MutableGameMethods.setToastMessage(rule.note);
            }

            _handleTimedSpawns(rule);
          }
        }
      }
    }

    //start of next round is now
    for (var rule in _gameState.scenarioSpecialRules) {
      if (rule.type == "Timer" && rule.startOfRound) {
        for (int round in rule.list) {
          //minus 1 means always
          final toastMessage = _gameState.toastMessage.value;
          if (round - 1 == _gameState.round.value || round == -1) {
            if (toastMessage.isNotEmpty) {
              MutableGameMethods.setToastMessage(
                  "$toastMessage\n\n${rule.note}");
            } else {
              if (getIt<Settings>().showReminders.value) {
                MutableGameMethods.setToastMessage("$toastMessage${rule.note}");
              }
            }
            _handleTimedSpawns(rule);
          }
        }
      }
    }

    MutableGameMethods.setRound(stateAccess, _gameState.round.value + 1);

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
    final characters = GameMethods.getCurrentCharacters();
    for (final character in characters) {
      final modifierDeck = character.characterState.modifierDeck;
      if (modifierDeck.needsShuffle) {
        modifierDeck.shuffle(stateAccess);
      }
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

  void _handleTimedSpawns(SpecialRule rule) {
    if (getIt<Settings>().autoAddSpawns.value) {
      if (rule.name.isNotEmpty) {
        //get room data and deal with spawns
        ScenarioModel? scenario = _gameData
            .modelData
            .value[_gameState.currentCampaign.value]
            ?.scenarios[_gameState.scenario.value];
        if (scenario != null) {
          ScenarioModel? spawnSection = scenario.sections.firstWhereOrNull(
              (element) => element.name.substring(1) == rule.name);
          if (spawnSection != null) {
            final monsterStandees = spawnSection.monsterStandees;
            if (monsterStandees != null) {
              MutableGameMethods.autoAddStandees(
                  stateAccess, monsterStandees, rule.note);
            }
          }
        }
      }
    }
  }
}
