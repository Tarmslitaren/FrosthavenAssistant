import 'package:frosthaven_assistant/Resource/state/game_state.dart';

class ReturnModifierCardCommand extends Command {
  final bool allies;

  ReturnModifierCardCommand(this.allies);

  @override
  void execute() {
    GameMethods.returnModifierCard(allies);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Return modifier card to top";
  }
}
