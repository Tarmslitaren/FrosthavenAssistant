import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../services/service_locator.dart';

class ReturnLootCardCommand extends Command {
  final bool top;

  ReturnLootCardCommand(this.top);

  @override
  void execute() {
    getIt<GameState>().lootDeck.returnLootCard(stateAccess, top);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Return loot card";
  }
}
