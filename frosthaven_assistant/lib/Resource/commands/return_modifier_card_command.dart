import 'package:frosthaven_assistant/Resource/state/game_state.dart';

class ReturnModifierCardCommand extends Command {
  final String name;

  ReturnModifierCardCommand(this.name);

  @override
  void execute() {
    GameMethods.returnModifierCard(name);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Return modifier card to top";
  }
}
