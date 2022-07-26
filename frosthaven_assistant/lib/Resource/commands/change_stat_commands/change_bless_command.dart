
import '../../../services/service_locator.dart';
import '../../game_state.dart';
import 'change_stat_command.dart';

class ChangeBlessCommand extends ChangeStatCommand {
  ChangeBlessCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {
    getIt<GameState>().modifierDeck.blesses.value += change;
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String toString() {
    return "change bless";
  }
}