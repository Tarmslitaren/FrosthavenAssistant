import '../game_methods.dart';
import '../state/game_state.dart';

class DrawAbilityCardCommand extends Command {
  final String ownerId;
  DrawAbilityCardCommand(this.ownerId);

  @override
  void execute() {
    Monster monster = GameMethods.getCurrentMonsters()
        .firstWhere((element) => element.id == ownerId);
    MonsterAbilityState deck = GameMethods.getDeck(monster.type.deck)!;
    if (deck.drawPileIsNotEmpty) {
      deck.draw(stateAccess);
    }
  }

  @override
  String describe() {
    return "Draw extra ability card";
  }
}
