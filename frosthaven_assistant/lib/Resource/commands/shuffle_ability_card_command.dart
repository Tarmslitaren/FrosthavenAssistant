import '../../Layout/menus/ability_cards_menu.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class ShuffleAbilityCardCommand extends Command {
  final String ownerId;
  ShuffleAbilityCardCommand(this.ownerId);

  @override
  void execute() {
    Monster monster = GameMethods.getCurrentMonsters()
        .firstWhere((element) => element.id == ownerId);
    MonsterAbilityState deck = GameMethods.getDeck(monster.type.deck)!;
    deck.shuffle(stateAccess);
    AbilityCardsMenuState.revealedList = [];
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Extra ability deck shuffle";
  }
}
