import 'package:frosthaven_assistant/Resource/state/game_state.dart';

class ReturnLootCardCommand extends Command {
  final bool top;
  final GameState _gameState;

  ReturnLootCardCommand(this.top, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    _gameState.lootDeck.returnLootCard(stateAccess, top);
  }

  @override
  String describe() {
    return "Return loot card";
  }
}
