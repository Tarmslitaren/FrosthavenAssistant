import '../../game_event.dart';
import '../../game_methods.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';
import '../command_l10n.dart';

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
  GameEvent get event => HealthChangedEvent(figureId, ownerId ?? '', change);

  @override
  String describe() {
    if (change > 0) {
      //TODO: looks bad
      return commandL10n.cmdIncreaseHealth(figureId, change);
    }
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null || figure.health.value <= 0) {
      return commandL10n.cmdKill(ownerId ?? '');
    }
    //TODO: incorrect for character summons
    return commandL10n.cmdDecreaseHealth(ownerId ?? '', -change);
  }
}
