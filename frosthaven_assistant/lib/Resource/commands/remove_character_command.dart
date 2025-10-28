import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<Character> names;

  RemoveCharacterCommand(this.names);

  @override
  void execute() {
    MutableGameMethods.removeCharacters(stateAccess, names);

    if (names.length != 1 ||
        !GameMethods.isObjectiveOrEscort(names.first.characterClass)) {
      MutableGameMethods.applyDifficulty(stateAccess);
    }
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (names.length > 1) {
      return "Remove all characters";
    }
    return "Remove ${names[0].id}";
  }
}
