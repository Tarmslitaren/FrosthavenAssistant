
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class SetCharacterLevelCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  int _previousState = 0;
  int _previousHealth = 0;
  int level;
  String characterId;

  SetCharacterLevelCommand(this.level, this.characterId);

  @override
  void execute() {
    Character? character;
    for(var item in _gameState.currentList){
      if (item.id == characterId) {
        character = item as Character;
        break;
      }
    }
    _previousState = character!.characterState.level.value;
    _previousHealth = character.characterState.health.value;
    character.characterState.level.value = level;
    character.characterState.health.value = character.characterClass.healthByLevel[level-1];
    character.characterState.maxHealth.value = character.characterState.health.value;

    if(character.id == "Beast Tyrant") {
      if(character.characterState.summonList.value.isNotEmpty) {
        //create the bear summon
        final int bearHp = 8 + character.characterState.level.value * 2;
        character.characterState.summonList.value[0].maxHealth.value = bearHp;
        character.characterState.summonList.value[0].health.value = bearHp;

      }
    }
  }

  @override
  void undo() {
    //character.characterState.level.value = _previousState;
    //character.characterState.health.value = _previousHealth;
  }

  @override
  String toString() {
    return "Set $characterId's Level";
  }
}