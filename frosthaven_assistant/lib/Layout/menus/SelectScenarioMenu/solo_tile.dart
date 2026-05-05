import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../../Model/character_class.dart';

const int _kSoloNameIndex = 0;
const int _kSoloTextIndex = 1;

class SoloTile extends StatelessWidget {
  const SoloTile({
    super.key,
    required this.name,
    required this.gameState,
    required this.gameData,
  });

  final String name;
  final GameState gameState;
  final GameData gameData;

  @override
  Widget build(BuildContext context) {
    List<String> strings = name.split(':');
    strings[0] = strings.first.replaceFirst(" ", "Å");
    String nameAndCampaign = strings.first.split("Å")[1];
    String characterName = nameAndCampaign.split("/")[_kSoloNameIndex];
    String edition = nameAndCampaign.split("/")[_kSoloTextIndex];

    String text = strings[_kSoloTextIndex];
    for (String key in gameData.modelData.value.keys) {
      for (CharacterClass character
          in gameData.modelData.value[key]!.characters) {
        if (character.name == characterName) {
          if (character.hidden &&
              !gameState.unlockedClasses.contains(character.id)) {
            text = "???";
          }
          break;
        }
      }
    }

    return ListTile(
      leading: Image(
        height: kIconSize,
        width: kIconSize,
        fit: BoxFit.scaleDown,
        image: AssetImage("assets/images/class-icons/$characterName.png"),
      ),
      title: Text(text, style: kTitleStyle),
      trailing: Text("($edition)", softWrap: true, style: kSubtitleStyle),
      onTap: () {
        Navigator.pop(context);
        gameState.action(SetScenarioCommand(name, false, gameState: gameState));
      },
    );
  }
}
