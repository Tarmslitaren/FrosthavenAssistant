import '../state/game_state.dart';
import 'command_l10n.dart';

class SetCampaignCommand extends Command {
  SetCampaignCommand(this.campaign);

  String campaign;

  @override
  void execute() {
    ScenarioMethods.setCampaign(stateAccess, campaign);
  }

  @override
  String describe() {
    return commandL10n.cmdSetCampaign(campaign);
  }
}
