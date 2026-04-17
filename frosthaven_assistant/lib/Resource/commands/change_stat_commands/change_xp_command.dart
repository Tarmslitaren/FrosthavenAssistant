import '../../game_methods.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeXPCommand extends ChangeStatCommand {
  ChangeXPCommand(super.change, super.figureId, super.ownerId,
      {required super.gameState});

  @override
  void execute() {
    final figure = GameMethods.getFigure(ownerId, figureId);
    if (figure is! CharacterState) return;
    figure.setXp(stateAccess, figure.xp.value + change);
  }

  @override
  String describe() {
    if (change > 0) {
      return "Increase $figureId's xp by $change";
    }
    return "Decrease $figureId's xp by ${change.abs()}";
  }
}
