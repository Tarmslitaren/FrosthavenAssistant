import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetCharacterLevelCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  late final int level;
  late final String characterId;

  SetCharacterLevelCommand(this.level, this.characterId);

  @override
  void execute() {
    Character? character;
    for (var item in _gameState.currentList) {
      if (item.id == characterId) {
        character = item as Character;
        break;
      }
    }
    character!.characterState.setFigureLevel(stateAccess, level);
    character.characterState.setHealth(stateAccess,
        character.characterClass.healthByLevel[level - 1]);
    character.characterState.setMaxHealth(stateAccess, character.characterState.health.value);

    if (character.id == "Beast Tyrant") {
      if (character.characterState.summonList.isNotEmpty) {
        //create the bear summon
        final int bearHp = 8 + character.characterState.level.value * 2;
        character.characterState.summonList[0].setMaxHealth(stateAccess, bearHp);
        character.characterState.summonList[0].setHealth(stateAccess, bearHp);
      }
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Set $characterId's Level";
  }
}
