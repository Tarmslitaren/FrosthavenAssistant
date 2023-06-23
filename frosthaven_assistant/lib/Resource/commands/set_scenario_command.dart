import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  late final String _scenario;
  late final bool _section;

  SetScenarioCommand(this._scenario, this._section);

  @override
  void execute() {
    GameMethods.setScenario(_scenario, _section);
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (!_section) {
      return "Set Scenario";
    }
    return "Add Section";
  }
}
