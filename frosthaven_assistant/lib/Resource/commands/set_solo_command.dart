import '../state/game_state.dart';
import 'command_l10n.dart';

class SetSoloCommand extends Command {
  SetSoloCommand(this.solo);

  bool solo;

  @override
  void execute() {
    ScenarioMethods.setSolo(stateAccess, solo);
    ScenarioMethods.applyDifficulty(stateAccess);
  }

  @override
  String describe() {
    if (solo) {
      return commandL10n.cmdSetSoloOn;
    }
    return commandL10n.cmdSetSoloOff;
  }
}
