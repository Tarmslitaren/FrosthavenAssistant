import 'package:collection/collection.dart';

import '../state/game_state.dart';

class ChangeNameCommand extends Command {
  ChangeNameCommand(this.name, this.characterId, {required GameState gameState})
      : _gameState = gameState;
  final String name;
  final String characterId;
  final GameState _gameState;

  @override
  void execute() {
    final match = _gameState.currentList
        .firstWhereOrNull((element) => element.id == characterId);
    final Character? character = match is Character ? match : null;
    if (character != null) {
      character.characterState.setDisplay(stateAccess, name);
    }
  }

  @override
  String describe() {
    return "change character name";
  }
}
