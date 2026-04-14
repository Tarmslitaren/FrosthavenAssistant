import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class CharacterWidgetInternalViewModel {
  CharacterWidgetInternalViewModel(
      this.character, {GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Character character;
  final GameState _gameState;
  final Settings _settings;

  // Derived state
  bool get isObjectiveOrEscort =>
      GameMethods.isObjectiveOrEscort(character.characterClass);

  RoundState get roundState => _gameState.roundState.value;

  bool get isChooseInitiative => roundState == RoundState.chooseInitiative;

  bool get softNumpadInput => _settings.softNumpadInput.value;

  bool get isAlive => character.characterState.health.value > 0;

  /// Processes a text field change and dispatches SetInitCommand if valid.
  /// Returns true if a command was dispatched.
  bool handleInitTextChange(String text) {
    for (var item in _gameState.currentList) {
      if (item is Character && item.id == character.id) {
        final currentInit = character.characterState.initiative.value;
        if (text.isNotEmpty &&
            text != currentInit.toString() &&
            text != "??") {
          final init = int.tryParse(text);
          if (init != null && init != 0) {
            _gameState.action(
                SetInitCommand(character.id, init, gameState: _gameState));
            return true;
          }
        }
        break;
      }
    }
    return false;
  }

  void endTurn() {
    _gameState.action(TurnDoneCommand(character.id, gameState: _gameState));
  }
}
