
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class ReorderAbilityListCommand extends Command {
  final int newIndex;
  final int oldIndex;
  String deck;
  ReorderAbilityListCommand(this.deck, this.newIndex, this.oldIndex);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    for(var item in gameState.currentAbilityDecks){
      if(item.name == deck) {
        List<MonsterAbilityCardModel> list = List.from(item.drawPile.getList());
        list.insert(newIndex, list.removeAt(oldIndex));
        item.drawPile.setList(list);
        break;
      }
    }
  }

  @override
  void undo() {
    // TODO: implement undo
  }
}