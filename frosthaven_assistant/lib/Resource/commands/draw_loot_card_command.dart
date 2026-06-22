import '../game_event.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class DrawLootCardCommand extends Command {
  final GameState _gameState;

  DrawLootCardCommand({required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (_gameState.lootDeck.drawPileIsNotEmpty) {
      _gameState.lootDeck.draw(stateAccess);
    }
  }

  @override
  String describe() {
    return commandL10n.cmdDrawLootCard;
  }

  @override
  GameEvent get event => const LootCardDrawnEvent();
}
