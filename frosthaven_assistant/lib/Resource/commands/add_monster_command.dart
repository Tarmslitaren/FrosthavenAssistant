import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AddMonsterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int? _level;
  final bool _isAlly;
  late Monster monster;

  AddMonsterCommand(this._name, this._level, this._isAlly) {
    monster = GameMethods.createMonster(stateAccess, _name, _level, _isAlly)!;
  }

  @override
  void execute() {
    GameMethods.addToMainList(stateAccess, null, monster);

    _gameState.updateList.value++;
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Add ${monster.type.display}";
  }
}
