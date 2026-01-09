import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class AmdAddMinusOneCommand extends Command {
  String name;
  AmdAddMinusOneCommand(this.name);

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    deck.addMinusOne(stateAccess);
  }

  @override
  String describe() {
    return "Add minus one";
  }
}
