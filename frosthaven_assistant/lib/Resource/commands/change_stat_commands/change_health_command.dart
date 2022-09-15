
import '../../../services/service_locator.dart';
import '../../game_methods.dart';
import '../../game_state.dart';
import 'change_stat_command.dart';

class ChangeHealthCommand extends ChangeStatCommand {
  ChangeHealthCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    Figure figure = GameMethods.getFigure(ownerId, figureId)!;

    figure.health.value += change;
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
      return "Increase $figureId's health";
    }
    Figure? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null || figure.health.value <= 0) {
      return "Kill $ownerId";
    }
    return "Decrease $ownerId's health";
  }
}