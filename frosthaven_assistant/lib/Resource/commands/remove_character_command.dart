import '../../services/service_locator.dart';
import '../state/game_state.dart';

class RemoveCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<Character> names;

  RemoveCharacterCommand(this.names);

  @override
  void execute() {
    GameMethods.removeCharacters(stateAccess, names);

    if (names.length != 1 ||
        (names.first.characterClass.name != "Escort" &&
            names.first.characterClass.name != "Objective")) {
      GameMethods.applyDifficulty(stateAccess);
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
