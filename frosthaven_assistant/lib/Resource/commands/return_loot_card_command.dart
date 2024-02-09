import 'package:frosthaven_assistant/Resource/state/game_state.dart';


class ReturnLootCardCommand extends Command {
  final bool top;

  ReturnLootCardCommand(this.top);

  @override
  void execute() {
    GameMethods.returnLootCard(top);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Return loot card";
  }
}
