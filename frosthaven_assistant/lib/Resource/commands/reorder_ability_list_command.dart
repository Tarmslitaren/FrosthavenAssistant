import 'package:frosthaven_assistant/Model/MonsterAbility.dart';

import '../../services/service_locator.dart';
import '../state/game_state.dart';

class ReorderAbilityListCommand extends Command {
  late final int newIndex;
  late final int oldIndex;
  late final String deck;
  ReorderAbilityListCommand(this.deck, this.newIndex, this.oldIndex);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    for (var item in gameState.currentAbilityDecks) {
      if (item.name == deck) {
        item.reorderDrawPile(stateAccess, oldIndex, newIndex);
        break;
      }
    }
  }

  @override
  String describe() {
    return "Reorder Ability Cards";
  }
}
