import '../../Layout/menus/modifier_card_menu.dart';
import '../../services/service_locator.dart';
import '../state/game_state.dart';

class ShuffleAMDCardCommand extends Command {
  final String name;
  ShuffleAMDCardCommand(this.name);

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    deck.shuffleUnDrawn(stateAccess);
    ModifierCardMenuState.revealedList = [];
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Extra AMD deck shuffle";
  }
}
