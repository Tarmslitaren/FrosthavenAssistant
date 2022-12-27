
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class EnfeeblingHexCommand extends Command {
  EnfeeblingHexCommand();

  @override
  void execute() {
    getIt<GameState>().modifierDeck.addMinusOne();
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Add minus one";
  }
}