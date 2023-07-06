import '../state/game_state.dart';

class SetCampaignCommand extends Command {
  SetCampaignCommand(this.campaign);

  String campaign;

  @override
  void execute() {
    GameMethods.setCampaign(stateAccess, campaign);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "set $campaign campaign";
  }
}
