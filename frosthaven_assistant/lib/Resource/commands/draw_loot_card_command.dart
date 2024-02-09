import '../../services/service_locator.dart';
import '../state/game_state.dart';

class DrawLootCardCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawLootCardCommand();

  @override
  void execute() {
    if (_gameState.lootDeck.drawPile.isNotEmpty) {
      _gameState.lootDeck.draw(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Draw loot card";
  }
}
