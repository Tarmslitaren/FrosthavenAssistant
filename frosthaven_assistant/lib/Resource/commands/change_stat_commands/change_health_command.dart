import '../../game_methods.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeHealthCommand extends ChangeStatCommand {
  ChangeHealthCommand(super.change, super.figureId, super.ownerId,
      {required super.gameState});

  @override
  void execute() {
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure != null) {
      final previousValue = figure.health.value;
      if (previousValue + change < 0) {
        //no negative values
        figure.setHealth(stateAccess, 0);
      } else {
        figure.setHealth(stateAccess, figure.health.value + change);
      }
      final newValue = figure.health.value;
      if (previousValue <= 0 && newValue > 0) {
        //un death
        gameState.updateList.notify();
      }

      if (newValue <= 0) {
        handleDeath();
      }
    }
  }

  @override
  String describe() {
    if (change > 0) {
      //TODO: looks bad
      return "Increase $figureId's health by $change";
    }
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null || figure.health.value <= 0) {
      return "Kill $ownerId";
    }
    //TODO: incorrect for character summons
    return "Decrease $ownerId's health by ${-change}";
  }
}
