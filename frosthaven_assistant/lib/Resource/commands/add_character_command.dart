import '../game_methods.dart';
import '../state/game_state.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState;
  final String _id;
  final String _edition;
  final int _level;
  final String? _display;
  Character? character;

  AddCharacterCommand(this._id, this._edition, this._display, this._level,
      {required GameState gameState})
      : _gameState = gameState {
    final created = CharacterMethods.createCharacter(
        stateAccess, _id, _edition, _display, _level);
    if (created == null) {
      throw StateError('AddCharacterCommand: character class not found: $_id (edition: $_edition)');
    }
    character = created;
  }

  @override
  void execute() {
    final char = character;
    if (char == null) return;
    //add new character on top of list
    RoundMethods.addToMainList(stateAccess, 0, char);

    if (!GameMethods.isObjectiveOrEscort(char.characterClass)) {
      ScenarioMethods.applyDifficulty(stateAccess);
    }

    RoundMethods.updateForSpecialRules(stateAccess);
    ScenarioMethods.unlockClass(stateAccess, char.characterClass.id);
  }

  @override
  void onUndo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Add $_id";
  }
}
