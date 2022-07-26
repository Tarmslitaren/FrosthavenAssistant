
import '../../../services/service_locator.dart';
import '../../game_state.dart';
import 'change_stat_command.dart';

class ChangeCurseCommand extends ChangeStatCommand {
  ChangeCurseCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    //Figure figure = getFigure(ownerId, figureId)!;

    //figure.chill.value += change;
    getIt<GameState>().modifierDeck.curses.value += change;

  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String toString() {
    return "change curse";
  }
}