import 'package:frosthaven_assistant/Resource/game_methods.dart';
import '../action_handler.dart';
import '../state/monster.dart';
import '../state/monster_ability_state.dart';

class ShuffleAbilityCardCommand extends Command {
  final String ownerId;
  ShuffleAbilityCardCommand(this.ownerId);


  @override
  void execute() {
    Monster monster = GameMethods.getCurrentMonsters().firstWhere((element) => element.id == ownerId);
    MonsterAbilityState deck = GameMethods.getDeck(monster.type.deck)!;
    deck.shuffle();
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Extra ability deck shuffle";
  }
}