import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/character.dart';
import '../state/game_state.dart';
import '../state/list_item_data.dart';

class RemoveCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<Character> names;

  RemoveCharacterCommand(this.names);

  @override
  void execute() {
    GameMethods.removeCharacters(names);
  }

  @override
  void undo() {
    //_gameState.currentList.add(_character);
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
