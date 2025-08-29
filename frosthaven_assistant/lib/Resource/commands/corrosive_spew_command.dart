import '../../services/service_locator.dart';
import '../state/game_state.dart';

class CorrosiveSpewCommand extends Command {
  CorrosiveSpewCommand();

  @override
  void execute() {
    //todo: test
    GameState gameState = getIt<GameState>();
    GameMethods.getModifierDeck("Ruinmaw", gameState)
        .setCorrosiveSpew(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Corrosive Spew";
  }
}
