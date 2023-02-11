
import '../../../services/service_locator.dart';
import '../../game_methods.dart';
import '../../state/figure_state.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeHealthCommand extends ChangeStatCommand {
  ChangeHealthCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    FigureState figure = GameMethods.getFigure(ownerId, figureId)!;

    if((0 <= (figure.health.value + change)) && ((figure.health.value + change) <= figure.maxHealth.value)){
      figure.health.value += change;
    }

    if(change > 0 && figure.health.value == 1) {
      //un death
      getIt<GameState>().updateList.value++;
    }

    if (figure.health.value <= 0) {
      handleDeath();
    }
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    if(change > 0) {
      //TODO: looks bad
      return "Increase $figureId's health by $change";
    }
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null || figure.health.value <= 0) {
      return "Kill $ownerId";
    }
    //TODO: incorrect for chracger summons
    return "Decrease $ownerId's health by ${-change}";
  }
}