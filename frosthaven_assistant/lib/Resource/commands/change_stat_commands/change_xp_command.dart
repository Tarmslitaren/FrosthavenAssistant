
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../../services/service_locator.dart';
import '../../game_state.dart';
import 'change_stat_command.dart';

class ChangeXPCommand extends ChangeStatCommand {
  ChangeXPCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    CharacterState figure = GameMethods.getFigure(ownerId, figureId)! as CharacterState;
    figure.xp.value += change;

  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String toString() {
    return "change xp";
  }
}