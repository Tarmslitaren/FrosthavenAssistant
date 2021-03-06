
import '../../../services/service_locator.dart';
import '../../game_methods.dart';
import '../../game_state.dart';
import 'change_stat_command.dart';

class ChangeMaxHealthCommand extends ChangeStatCommand {
  ChangeMaxHealthCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    Figure figure = GameMethods.getFigure(ownerId, figureId)!;

    figure.maxHealth.value += change;

    //lower healh if max health lowers
    if (figure.maxHealth.value < figure.health.value) {
      figure.health.value = figure.maxHealth.value;
    }
    //if health same as maxhealth, then let health follow?
    if (figure.maxHealth.value - change ==  figure.health.value) {
      figure.health.value = figure.maxHealth.value;
    }

    if (figure.maxHealth.value <= 0) {
      handleDeath();
    }
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String toString() {
    return "change max health";
  }
}