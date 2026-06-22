import '../game_event.dart';
import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class DrawModifierCardCommand extends Command {
  final String name;
  final GameState _gameState;

  DrawModifierCardCommand(this.name, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.draw(stateAccess);
  }

  @override
  String describe() {
    if (name.isNotEmpty) {
      return commandL10n.cmdDrawModifierCard(name);
    }
    return commandL10n.cmdDrawMonsterModifierCard;
  }

  @override
  GameEvent get event => ModifierCardDrawnEvent(name);
}
