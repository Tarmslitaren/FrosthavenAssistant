import 'package:frosthaven_assistant/Resource/enums.dart';

import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class IceWraithChangeFormCommand extends Command {
  IceWraithChangeFormCommand(this.isElite, this.ownerId, this.figureId,
      {required GameState gameState})
      : _gameState = gameState;
  final bool isElite;
  final String? ownerId;
  final String figureId;
  final GameState _gameState;

  @override
  void execute() {
    final figure = GameMethods.getFigure(ownerId, figureId);
    if (figure is! MonsterInstance) return;
    if (isElite) {
      figure.setType(stateAccess, MonsterType.normal);
    } else {
      figure.setType(stateAccess, MonsterType.elite);
    }
    _gameState.updateList.notify();
  }

  @override
  String describe() {
    if (!isElite) {
      return commandL10n.cmdIceWraithTurnNormal;
    }
    return commandL10n.cmdIceWraithTurnElite;
  }
}
