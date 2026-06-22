import '../state/game_state.dart';
import 'command_l10n.dart';

class AddMonsterCommand extends Command {
  final String _name;
  final int? _level;
  final bool _isAlly;
  Monster? monster;

  AddMonsterCommand(
    this._name,
    this._level,
    this._isAlly, {
    required GameState gameState,
  }) {
    monster = MonsterMethods.createMonster(stateAccess, _name, _level, _isAlly);
  }

  @override
  void execute() {
    final m = monster;
    if (m == null) return;
    RoundMethods.addToMainList(stateAccess, null, m);
  }

  @override
  String describe() {
    return commandL10n.cmdAddMonster(monster?.type.display ?? '');
  }
}
