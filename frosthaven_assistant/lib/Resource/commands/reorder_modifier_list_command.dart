import '../../services/service_locator.dart';
import '../state/game_state.dart';

class ReorderModifierListCommand extends Command {
  final int newIndex;
  final int oldIndex;
  final String name;
  ReorderModifierListCommand(this.newIndex, this.oldIndex, this.name);
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    List<ModifierCard> list = List.of(deck.drawPile.getList());

    var item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    deck.drawPile.setList(list);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Reorder Modifier Cards";
  }
}
