import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/set_loot_owner_command.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class SetLootOwnerMenu extends StatefulWidget {
  final LootCard card;

  const SetLootOwnerMenu({
    super.key,
    required this.card,
  });

  @override
  SetLootOwnerMenuState createState() => SetLootOwnerMenuState();
}

class SetLootOwnerMenuState extends State<SetLootOwnerMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
  }

  Widget buildCharacterButton(Character character) {
    return Column(children: [
      const SizedBox(
        height: 10,
      ),
      TextButton(
          onPressed: () {
            _gameState.action(SetLootOwnerCommand(character.characterClass.name, widget.card));
            Navigator.pop(context);
          },
          child: Row(children: [
            Image(
                filterQuality: FilterQuality.medium,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
                image:
                    AssetImage("assets/images/class-icons/${character.characterClass.name}.png")),
            const SizedBox(
              width: 10,
            ),
            Text(character.id, textAlign: TextAlign.center, style: getTitleTextStyle(1))
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Character> characters = GameMethods.getCurrentCharacters();
    return Container(
        width: 300,
        height: 280,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value
                ? 'assets/images/bg/dark_bg.png'
                : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            "Set Loot Owner:",
            style: getTitleTextStyle(1),
          ),
          if (characters.length > 0) buildCharacterButton(characters[0]),
          if (characters.length > 1) buildCharacterButton(characters[1]),
          if (characters.length > 2) buildCharacterButton(characters[2]),
          if (characters.length > 3) buildCharacterButton(characters[3]),
        ]));
  }
}
