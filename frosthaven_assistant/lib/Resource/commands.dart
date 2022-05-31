import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/action_handler.dart';

import '../Model/character_class.dart';
import '../Model/monster.dart';
import '../services/service_locator.dart';
import 'game_state.dart';

void doListMagic() {}

class DrawCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawCommand();

  @override
  void execute() {
    _gameState.drawAbilityCards();
    _gameState.sortByInitiative();
    _gameState.round.value++;
    _gameState.setRoundState(RoundState.playTurns);
  }

  @override
  void undo() {
    _gameState.unDrawAbilityCards();
    _gameState.round.value--;
    _gameState.setRoundState(RoundState.chooseInitiative);
    //TODO: un draw the cards (need to save the random nr used. unsort the list
  }
}

class NextRoundCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  @override
  void execute() {
    for (var item in _gameState.currentList) {
      if (item is Character) {
        item.characterState.initiative = 0;
      }
    }
    _gameState.updateElements();
    _gameState.setRoundState(RoundState.chooseInitiative);
    _gameState.sortCharactersFirst();

    //TODO: a million more things: save a bunch of state: all current initiatives and monster deck states
  }

  @override
  void undo() {
    _gameState.setRoundState(RoundState.playTurns);
    //TODO: a million more things: reapply a bunch of state: all current initiatives and monster deck states
  }
}

//For use with save states and when starting a scenario (adding a bunch of monsters and special characters at once)
class InitListCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<ListItemData> items;

  InitListCommand(this.items);

  @override
  void execute() {
    _gameState.currentList.addAll(items);
  }

  @override
  void undo() {
    _gameState.currentList.clear();
  }

  //helper to make the init list.
  static Character? createCharacter(String name, int level) {
    for (CharacterClass characterClass
        in getIt<GameState>().modelData.value!.characters) {
      if (characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;
        characterState.health.value = characterClass.healthByLevel[level - 1];
        return Character(characterState, characterClass);
      }
    }
    return null;
  }
}

//helper to make the init list.
Monster? createMonster(String name, int level) {
  for (MonsterModel monster in getIt<GameState>().modelData.value!.monsters) {
    if (monster.name == name) {
      Monster monster = Monster(name, level);
      return monster;
    }
  }
  return null;
}

class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int _level;
  late Character character;

  AddCharacterCommand(this._name, this._level) {
    _createCharacter(_name, _level);
  }

  @override
  void execute() {
    //add new character on top of list
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      newList.add(item);
    }
    newList.insert(0, character);
    _gameState.currentList = newList;
  }

  @override
  void undo() {
    _gameState.currentList.remove(character);
  }

  void _createCharacter(String name, int level) {
    for (CharacterClass characterClass
        in _gameState.modelData.value!.characters) {
      if (characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;
        characterState.health.value = characterClass.healthByLevel[level - 1];
        character = Character(characterState, characterClass);
      }
    }
  }
}

class RemoveCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<String> names;
  final List<Character> _characters = [];

  RemoveCharacterCommand(this.names);

  @override
  void execute() {
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Character) {
        bool remove = false;
        for (var name in names) {
          if (item.id == name) {
            remove = true;
            break;
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
  }

  @override
  void undo() {
    //TODO: implement (and retain index)
    //_gameState.currentList.add(_character);
  }
}

class SetScenarioCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _scenario;

  SetScenarioCommand(this._scenario);

  @override
  void execute() {
    //first reset state
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Character) {
        newList.add(item);
        item.characterState.initiative = 0;
      }
    }
    List<String> monsters =
        _gameState.modelData.value!.scenarios[_scenario]!.monsters;
    for (String monster in monsters) {
      newList.add(createMonster(monster, _gameState.level.value)!);
    }

    _gameState.currentList = newList;
    _gameState.updateElements();
    _gameState.updateElements(); //twice to make sure they are inert.
    _gameState.setRoundState(RoundState.chooseInitiative);
    _gameState.sortCharactersFirst();
    _gameState.scenario.value = _scenario;
  }

  @override
  void undo() {
    //TODO: implement
  }
}

class UseElementCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final Elements element;
  ElementState? _previousState;

  UseElementCommand(this.element);

  @override
  void execute() {
    _previousState = _gameState.elementState.value[element];
    _gameState.elementState.value[element] = ElementState.inert;
  }

  @override
  void undo() {
    _gameState.elementState.value[element] = _previousState!;
  }
}

class ImbueElementCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final Elements element;
  final bool half;
  ElementState? _previousState;

  ImbueElementCommand(this.element, this.half);

  @override
  void execute() {
    _previousState = _gameState.elementState.value[element];
    _gameState.elementState.value[element] = ElementState.full;
    if (half) {
      _gameState.elementState.value[element] = ElementState.half;
    }
  }

  @override
  void undo() {
    _gameState.elementState.value[element] = _previousState!;
  }
}
