import '../state/game_state.dart';

class ShowAllyDeckCommand extends Command {

  ShowAllyDeckCommand();

  @override
  void execute() {
    GameMethods.showAllyDeck(stateAccess);
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Show Ally Deck";
  }
}
