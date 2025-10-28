import 'package:frosthaven_assistant/Resource/enums.dart';

import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class IceWraithChangeFormCommand extends Command {
  IceWraithChangeFormCommand(this.isElite, this.ownerId, this.figureId);
  final bool isElite;
  final String? ownerId;
  final String figureId;

  @override
  void execute() {
    MonsterInstance figure =
        GameMethods.getFigure(ownerId, figureId)! as MonsterInstance;
    if (isElite) {
      figure.setType(stateAccess, MonsterType.normal);
    } else {
      figure.setType(stateAccess, MonsterType.elite);
    }
    getIt<GameState>().updateList.value++;
    /*for (var item in getIt<GameState>().currentList) {
      if (item.id == ownerId && item is Monster) {
        var newList = item.monsterInstances.value;
        GameMethods.sortMonsterInstances(newList);
        item.monsterInstances.value = newList;
      }
    }*/
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (isElite == false) {
      return "Ice Wraith turn normal";
    }
    return "Ice Wraith turn elite";
  }
}
