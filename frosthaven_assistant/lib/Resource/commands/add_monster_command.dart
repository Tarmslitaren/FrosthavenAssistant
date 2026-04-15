import '../state/game_state.dart';

class AddMonsterCommand extends Command {
  final GameState _gameState;
  final String _name;
  final int? _level;
  final bool _isAlly;
  late Monster monster;

  AddMonsterCommand(this._name, this._level, this._isAlly,
      {required GameState gameState})
      : _gameState = gameState {
    monster =
        MonsterMethods.createMonster(stateAccess, _name, _level, _isAlly)!;
  }

  @override
  void execute() {
    RoundMethods.addToMainList(stateAccess, null, monster);
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
