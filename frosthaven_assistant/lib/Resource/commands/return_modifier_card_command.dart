import '../state/game_state.dart';

class ReturnModifierCardCommand extends Command {
  final String name;

  ReturnModifierCardCommand(this.name);

  @override
  void execute() {
    DeckMethods.returnModifierCard(stateAccess, name);
  }

  @override
  String describe() {
    return "Return modifier card to top";
  }
}
