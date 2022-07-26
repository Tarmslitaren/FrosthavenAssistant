
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
  String toString() {
    return "change health";
  }
}