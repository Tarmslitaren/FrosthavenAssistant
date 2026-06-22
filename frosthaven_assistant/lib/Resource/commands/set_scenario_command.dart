import '../state/game_state.dart';
import 'command_l10n.dart';

class SetScenarioCommand extends Command {
  final String _scenario;
  final bool _section;

  SetScenarioCommand(
    this._scenario,
    this._section, {
    required GameState gameState,
  });

  @override
  void execute() {
    ScenarioMethods.setScenario(stateAccess, _scenario, _section);
  }

  @override
  String describe() {
    if (!_section) {
      return commandL10n.cmdSetScenario;
    }
    return commandL10n.cmdAddSection;
  }
}
