import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetAsSummonCommand extends Command {
  final bool summoned;
  final String? ownerId;
  final String figureId;
  SetAsSummonCommand(this.summoned, this.figureId, this.ownerId);
  @override
  void execute() {
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (summoned) {
      (figure as MonsterInstance)
          .setRoundSummoned(stateAccess, getIt<GameState>().round.value);
    } else {
      (figure as MonsterInstance).setRoundSummoned(stateAccess, -1);
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
