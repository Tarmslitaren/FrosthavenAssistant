import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';
import '../state/list_item_data.dart';
import '../state/monster.dart';

class RemoveMonsterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<Monster> names;

  RemoveMonsterCommand(this.names);

  @override
  void execute() {
    GameMethods.removeMonsters(names);
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (names.length > 1) {
      return "Remove all monsters";
    }
    return "Remove ${names[0].type.display}";
  }
}
