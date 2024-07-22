import '../../../services/service_locator.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeChillCommand extends ChangeStatCommand {
  ChangeChillCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {
    FigureState figure = GameMethods.getFigure(ownerId, figureId)!;

    figure.setChill(stateAccess, figure.chill.value + change);
  }

  @override
  void undo() {
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
