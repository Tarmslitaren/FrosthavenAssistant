import '../../../services/service_locator.dart';
import '../../state/character_state.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeXPCommand extends ChangeStatCommand {
  ChangeXPCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {
    CharacterState figure =
        GameMethods.getFigure(ownerId, figureId)! as CharacterState;
    figure.xp.value += change;
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    if (change > 0) {
      return "Increase $figureId's xp";
    }
    return "Decrease $figureId's xp";
  }
}
