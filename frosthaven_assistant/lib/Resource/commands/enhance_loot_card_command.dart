import '../state/game_state.dart';
import 'command_l10n.dart';

class EnhanceLootCardCommand extends Command {
  EnhanceLootCardCommand(this.id, this.value, this.resourceType,
      {required GameState gameState})
      : _gameState = gameState;
  final int value;
  final int id;
  final String resourceType;
  final GameState _gameState;

  @override
  void execute() {
    _gameState.lootDeck.addEnhancement(stateAccess, id, value);
  }

  @override
  String describe() {
    if (value <= 0) {
      return commandL10n.cmdRemoveLootEnhancement;
    }
    return commandL10n.cmdAddLootEnhancement;
  }
}
