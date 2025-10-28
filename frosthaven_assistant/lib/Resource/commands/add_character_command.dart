import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _id;
  final String _edition;
  final int _level;
  final String? _display;
  late Character character;

  AddCharacterCommand(this._id, this._edition, this._display, this._level) {
    character = MutableGameMethods.createCharacter(
        stateAccess, _id, _edition, _display, _level)!;
  }

  @override
  void execute() {
    //add new character on top of list
    MutableGameMethods.addToMainList(stateAccess, 0, character);

    if (!GameMethods.isObjectiveOrEscort(character.characterClass)) {
      MutableGameMethods.applyDifficulty(stateAccess);
    }

    MutableGameMethods.updateForSpecialRules(stateAccess);
    _gameState.updateList.value++;
    MutableGameMethods.unlockClass(stateAccess, character.characterClass.id);
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
