import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class DrawLootCardCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawLootCardCommand();

  @override
  void execute() {
    if (_gameState.lootDeck.drawPile.isNotEmpty) {
      _gameState.lootDeck.draw();
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Draw loot card";
  }
}
