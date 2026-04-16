import 'package:collection/collection.dart';

import '../../Layout/menus/ability_cards_menu.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class ShuffleAbilityCardCommand extends Command {
  final String ownerId;
  ShuffleAbilityCardCommand(this.ownerId);

  @override
  void execute() {
    final Monster? monster = GameMethods.getCurrentMonsters()
        .firstWhereOrNull((element) => element.id == ownerId);
    if (monster == null) return;
    final MonsterAbilityState? deck = GameMethods.getDeck(monster.type.deck);
    if (deck == null) return;
    deck.shuffle(stateAccess);
    AbilityCardsMenuState.revealedList = [];
  }

  @override
  String describe() {
    return "Extra ability deck shuffle";
  }
}
