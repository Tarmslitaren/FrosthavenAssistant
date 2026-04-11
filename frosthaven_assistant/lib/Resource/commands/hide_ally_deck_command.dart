import '../state/game_state.dart';

class HideAllyDeckCommand extends Command {
  HideAllyDeckCommand();

  @override
  void execute() {
    MonsterMethods.hideAllyDeck(stateAccess);
  }

  @override
  String describe() {
    return "Hide Ally Deck";
  }
}
