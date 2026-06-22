import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class RemoveCharacterCommand extends Command {
  final List<Character> names;

  RemoveCharacterCommand(this.names, {required GameState gameState});

  @override
  void execute() {
    CharacterMethods.removeCharacters(stateAccess, names);

    if (names.length != 1 ||
        !GameMethods.isObjectiveOrEscort(names.first.characterClass)) {
      ScenarioMethods.applyDifficulty(stateAccess);
    }
  }

  @override
  String describe() {
    if (names.length > 1) {
      return commandL10n.cmdRemoveAllCharacters;
    }
    if(names.isNotEmpty) {
      return commandL10n.cmdRemoveCharacter(names.first.id);
    }
    return commandL10n.cmdRemoveNoCharacters;
  }
}
