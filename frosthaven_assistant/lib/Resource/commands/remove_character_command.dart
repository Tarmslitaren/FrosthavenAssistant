import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveCharacterCommand extends Command {
  final GameState _gameState;
  final List<Character> names;

  RemoveCharacterCommand(this.names, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    CharacterMethods.removeCharacters(stateAccess, names);

    if (names.length != 1 ||
        !GameMethods.isObjectiveOrEscort(names.first.characterClass)) {
      ScenarioMethods.applyDifficulty(stateAccess);
    }
  }

  @override
  void onUndo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (names.length > 1) {
      return "Remove all characters";
    }
    return "Remove ${names.first.id}";
  }
}
