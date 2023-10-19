import '../../../services/service_locator.dart';
import '../../state/figure_state.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeChillCommand extends ChangeStatCommand {
  ChangeChillCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {
    FigureState figure = GameMethods.getFigure(ownerId, figureId)!;

    figure.chill.value += change;
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    //todo: not correct for summons?
    if (change > 0) {
      return "Increase $ownerId's chill";
    }
    return "Decrease $ownerId's chill";
  }
}
