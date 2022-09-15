
import '../../../services/service_locator.dart';
import '../../game_methods.dart';
import '../../game_state.dart';
import 'change_stat_command.dart';

class ChangeChillCommand extends ChangeStatCommand {
  ChangeChillCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    Figure figure = GameMethods.getFigure(ownerId, figureId)!;

    figure.chill.value += change;

  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    //not correct for summons
    if(change > 0) {

      return "Increase $ownerId's chill";
    }
    return "Decrease $ownerId's chill";
  }
}