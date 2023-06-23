import 'package:frosthaven_assistant/Resource/enums.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';
import '../state/monster_instance.dart';

class IceWraithChangeFormCommand extends Command {
  IceWraithChangeFormCommand(this.isElite, this.ownerId, this.figureId);
  final bool isElite;
  final String ownerId;
  final String figureId;

  @override
  void execute() {
    MonsterInstance figure =
        GameMethods.getFigure(ownerId, figureId)! as MonsterInstance;
    if (isElite) {
      figure.type = MonsterType.normal;
    } else {
      figure.type = MonsterType.elite;
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
