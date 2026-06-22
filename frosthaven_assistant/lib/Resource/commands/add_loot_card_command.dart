import '../state/game_state.dart';
import 'command_l10n.dart';

class AddLootCardCommand extends Command {
  AddLootCardCommand(this.resourceType, {required GameState gameState})
      : _gameState = gameState;
  final String resourceType;
  final GameState _gameState;

  @override
  void execute() {
    _gameState.lootDeck.addExtraCard(stateAccess, resourceType);
  }

  @override
  String describe() {
    return commandL10n.cmdAddLootCard(resourceType);
  }
}
