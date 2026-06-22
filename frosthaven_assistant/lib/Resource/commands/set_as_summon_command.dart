import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class SetAsSummonCommand extends Command {
  final bool summoned;
  final String? ownerId;
  final String figureId;
  final GameState _gameState;

  SetAsSummonCommand(this.summoned, this.figureId, this.ownerId,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final figure = GameMethods.getFigure(ownerId, figureId);
    if (figure is! MonsterInstance) return;
    if (summoned) {
      figure.setRoundSummoned(stateAccess, _gameState.round.value);
    } else {
      figure.setRoundSummoned(stateAccess, -1);
    }
    _gameState.updateList.notify();
  }


  @override
  String describe() {
    if (summoned) {
      return commandL10n.cmdMarkAsSummon(ownerId ?? '');
    }
    return commandL10n.cmdRemoveSummonMark(ownerId ?? '');
  }
}
