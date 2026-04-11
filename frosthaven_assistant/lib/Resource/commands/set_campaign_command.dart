import '../state/game_state.dart';

class SetCampaignCommand extends Command {
  SetCampaignCommand(this.campaign);

  String campaign;

  @override
  void execute() {
    ScenarioMethods.setCampaign(stateAccess, campaign);
  }

  @override
  String describe() {
    return "set $campaign campaign";
  }
}
