import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/action_handler.dart';

import '../Model/character_class.dart';
import '../Model/monster.dart';
import '../services/service_locator.dart';
import 'game_state.dart';

class DrawCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  DrawCommand();

  @override
  void execute() {
    _gameState.drawAbilityCards();
    _gameState.sortByInitiative();
    _gameState.round.value++;
    _gameState.setRoundState(RoundState.playTurns);

    //draw:

    //TODO: draw the cards and sort by initiative
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

  //TODO: deal also with monsters here
  InitListCommand(this.items);

  @override
  void execute() {
    _gameState.currentList.addAll(items);
    /*for(int i = 0; i < items.length; i++) {
      if (_gameState.listKey.currentState != null) {
        _gameState.listKey.currentState!.insertItem(i, duration: Duration.zero);
      }
    }*/

  }

  @override
  void undo() {
    _gameState.currentList.clear();
  }

  //helper to make the init list.
  static Character? createCharacter(String name, int level){
    for (CharacterClass characterClass in getIt<GameState>().modelData.value!.characters) {
      if(characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;
        characterState.health.value = characterClass.healthByLevel[level-1];
        //TODO: temp test for init value. should be 0 nad not set here.
        characterState.initiative.value = 78;
        return Character(characterState, characterClass);
      }
    }
    return null;
  }

  //helper to make the init list.
  static Monster? createMonster(String name, int level){
    for (MonsterModel monster in getIt<GameState>().modelData.value!.monsters) {
      if(monster.name == name) {
        Monster monster = Monster(name, level);
        return monster;
      }
    }
    return null;
  }
}


class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int _level;
  late Character character;

  AddCharacterCommand(this._name, this._level){
    _createCharacter(_name, _level);
  }

  @override
  void execute() {
    //add new character on top of list
    _gameState.currentList.insert(0, character);
  }

  @override
  void undo() {
    _gameState.currentList.remove(character);
  }

  void _createCharacter(String name, int level){
    for (CharacterClass characterClass in _gameState.modelData.value!.characters) {
      if(characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;
        characterState.health.value = characterClass.healthByLevel[level-1];
        //TODO: temp test
        characterState.initiative.value = 78;
        character = Character(characterState, characterClass);
      }
    }
  }
}

class RemoveCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String name;
  late Character _character;

  RemoveCharacterCommand(this.name);

  @override
  void execute() {
    for (ListItemData character in _gameState.currentList) {
      if(character.id == name) {
        _character = character as Character;
      }
    }
    _gameState.currentList.remove(_character);
  }

  @override
  void undo() {
    //TODO: retain index
    _gameState.currentList.add(_character);
  }
}