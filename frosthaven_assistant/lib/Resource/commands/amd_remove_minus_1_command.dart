import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class AMDRemoveMinus1Command extends Command {
  String name;
  AMDRemoveMinus1Command(this.name);

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    deck.removeMinusOne(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Remove minus one";
  }
}
