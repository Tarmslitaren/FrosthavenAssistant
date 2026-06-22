import 'package:collection/collection.dart';

import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class ShuffleDrawnAbilityCardCommand extends Command {
  final String deck;
  ShuffleDrawnAbilityCardCommand(this.deck);

  @override
  void execute() {
    Monster? monster = GameMethods.getCurrentMonsters()
        .firstWhereOrNull((element) => element.type.deck == deck);
    if (monster != null) {
      MonsterAbilityState? deck = GameMethods.getDeck(monster.type.deck);
      deck?.shuffleUnDrawn(stateAccess);
    }
  }

  @override
  String describe() {
    return commandL10n.cmdDrawnAbilityShuffle;
  }
}
