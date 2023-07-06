import '../state/game_state.dart';

class DrawAbilityCardCommand extends Command {
  final String ownerId;
  DrawAbilityCardCommand(this.ownerId);

  @override
  void execute() {
    Monster monster = GameMethods.getCurrentMonsters()
        .firstWhere((element) => element.id == ownerId);
    MonsterAbilityState deck = GameMethods.getDeck(monster.type.deck)!;
    if (deck.drawPile.isNotEmpty) {
      deck.draw(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Draw extra ability card";
  }
}
