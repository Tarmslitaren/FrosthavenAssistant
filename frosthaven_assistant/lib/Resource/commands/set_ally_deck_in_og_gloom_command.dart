import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetAllyDeckInOgGloomCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final bool set;

  SetAllyDeckInOgGloomCommand(this.set);

  @override
  void execute() {
    _gameState.setAllyDeckInOGGloom(stateAccess, set);
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (!set) {
      return "No ally deck in 1st edition Gloomhaven campaigns";
    }
    return "Use Ally Deck in 1st edition Gloomhaven Campaigns";
  }
}
