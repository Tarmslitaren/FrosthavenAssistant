import 'package:collection/collection.dart';

import '../../services/service_locator.dart';
import '../state/game_state.dart';

class ChangeNameCommand extends Command {
  ChangeNameCommand(this.name, this.characterId);
  final String name;
  final String characterId;

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    Character? character = gameState.currentList
        .firstWhereOrNull((element) => element.id == characterId) as Character?;
    if (character != null) {
      character.characterState.setDisplay(stateAccess, name);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "change character name";
  }
}
