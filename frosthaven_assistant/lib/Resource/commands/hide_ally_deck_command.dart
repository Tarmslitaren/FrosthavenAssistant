import '../state/game_state.dart';

class HideAllyDeckCommand extends Command {
  HideAllyDeckCommand();

  @override
  void execute() {
    MutableGameMethods.hideAllyDeck(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Hide Ally Deck";
  }
}
