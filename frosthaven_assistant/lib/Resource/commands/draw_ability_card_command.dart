import 'package:collection/collection.dart';

import '../game_methods.dart';
import '../state/game_state.dart';

class DrawAbilityCardCommand extends Command {
  final String ownerId;
  DrawAbilityCardCommand(this.ownerId);

  @override
  void execute() {
    final Monster? monster = GameMethods.getCurrentMonsters()
        .firstWhereOrNull((element) => element.id == ownerId);
    if (monster == null) return;
    final MonsterAbilityState? deck = GameMethods.getDeck(monster.type.deck);
    if (deck == null) return;
    if (deck.drawPileIsNotEmpty) {
      deck.draw(stateAccess);
    }
  }

  @override
  String describe() {
    return "Draw extra ability card";
  }
}
