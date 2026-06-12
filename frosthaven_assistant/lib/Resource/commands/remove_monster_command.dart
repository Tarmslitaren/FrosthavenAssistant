import '../state/game_state.dart';

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
      return "Remove all monsters";
    }
    if(names.isNotEmpty) {
      return "Remove ${names.first.type.display}";
    }
    return "Remove no monsters";
  }
}
