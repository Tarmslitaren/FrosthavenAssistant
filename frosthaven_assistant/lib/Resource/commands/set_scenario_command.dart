import '../state/game_state.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState;
  late final String _scenario;
  late final bool _section;

  SetScenarioCommand(this._scenario, this._section,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ScenarioMethods.setScenario(stateAccess, _scenario, _section);
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
