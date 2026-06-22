import '../state/game_state.dart';
import 'command_l10n.dart';

class RemoveMonsterCommand extends Command {
  final List<Monster> names;

  RemoveMonsterCommand(this.names, {required GameState gameState});

  @override
  void execute() {
    MonsterMethods.removeMonsters(stateAccess, names);
  }

  @override
  String describe() {
    if (names.length > 1) {
      return commandL10n.cmdRemoveAllMonsters;
    }
    if(names.isNotEmpty) {
      return commandL10n.cmdRemoveMonster(names.first.type.display);
    }
    return commandL10n.cmdRemoveNoMonsters;
  }
}
