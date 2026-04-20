import '../state/game_state.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState;
  final String _scenario;
  final bool _section;

  SetScenarioCommand(this._scenario, this._section,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ScenarioMethods.setScenario(stateAccess, _scenario, _section);
  }


  @override
  String describe() {
    if (!_section) {
      return "Set Scenario";
    }
    return "Add Section";
  }
}
