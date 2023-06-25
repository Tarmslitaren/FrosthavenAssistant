import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class ShowAllyDeckCommand extends Command {

  ShowAllyDeckCommand();

  @override
  void execute() {
    GameMethods.showAllyDeck();
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Show Ally Deck";
  }
}
