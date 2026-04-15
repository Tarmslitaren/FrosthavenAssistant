import '../game_methods.dart';
import '../state/game_state.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState;
  final String _id;
  final String _edition;
  final int _level;
  final String? _display;
  late Character character;

  AddCharacterCommand(this._id, this._edition, this._display, this._level,
      {required GameState gameState})
      : _gameState = gameState {
    character = CharacterMethods.createCharacter(
        stateAccess, _id, _edition, _display, _level)!;
  }

  @override
  void execute() {
    //add new character on top of list
    RoundMethods.addToMainList(stateAccess, 0, character);

    if (!GameMethods.isObjectiveOrEscort(character.characterClass)) {
      ScenarioMethods.applyDifficulty(stateAccess);
    }

    RoundMethods.updateForSpecialRules(stateAccess);
    ScenarioMethods.unlockClass(stateAccess, character.characterClass.id);
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Add $_id";
  }
}
