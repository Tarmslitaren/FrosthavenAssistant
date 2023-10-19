import 'package:frosthaven_assistant/Resource/state/monster_instance.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/figure_state.dart';
import '../state/game_state.dart';

class SetAsSummonCommand extends Command {
  final bool summoned;
  final String ownerId;
  final String figureId;
  SetAsSummonCommand(this.summoned, this.figureId, this.ownerId);
  @override
  void execute() {
    FigureState figure = GameMethods.getFigure(ownerId, figureId)!;
    if (summoned) {
      (figure as MonsterInstance).roundSummoned =
          getIt<GameState>().round.value;
    } else {
      (figure as MonsterInstance).roundSummoned = -1;
    }
    getIt<GameState>().updateList.value++;
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    if (summoned) {
      return "Mark $ownerId as summon";
    }
    return "Remove $ownerId's summon mark";
  }
}
