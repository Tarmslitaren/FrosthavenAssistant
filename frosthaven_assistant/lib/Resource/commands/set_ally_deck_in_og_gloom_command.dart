import '../state/game_state.dart';
import 'command_l10n.dart';

class SetAllyDeckInOgGloomCommand extends Command {
  final GameState _gameState;
  final bool set;

  SetAllyDeckInOgGloomCommand(this.set, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    _gameState.setAllyDeckInOGGloom(stateAccess, set);
  }


  @override
  String describe() {
    if (!set) {
      return commandL10n.cmdNoAllyDeckInOgGloom;
    }
    return commandL10n.cmdUseAllyDeckInOgGloom;
  }
}
