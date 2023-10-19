import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Resource/state/character.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class ChangeNameCommand extends Command {
  ChangeNameCommand(this.name, this.characterId);
  final String name;
  final String characterId;

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    Character? character = gameState.currentList
        .firstWhereOrNull((element) => element.id == name) as Character?;
    if (character != null) {
      character.characterState.display.value = name;
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "change character name";
  }
}
