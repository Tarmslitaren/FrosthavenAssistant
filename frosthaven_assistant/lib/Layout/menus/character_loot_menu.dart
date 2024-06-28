import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../services/service_locator.dart';

class CharacterLootMenu extends StatefulWidget {
  const CharacterLootMenu({super.key});

  @override
  CharacterLootMenuState createState() => CharacterLootMenuState();
}

class CharacterLootMenuState extends State<CharacterLootMenu> {
  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  int getLootAmount(String characterId, String lootName) {
    int value = 0;
    for (var item in getIt<GameState>().lootDeck.discardPile.getList()) {
      if (item.owner == characterId && item.gfx.contains(lootName)) {
        if (lootName == "coin") {
          if (item.gfx.endsWith("3")) {
            value += 3;
          } else if (item.gfx.endsWith("2")) {
            value += 2;
          } else {
            value += 1;
          }
          value += item.enhanced;
        } else {
          var itemValue = item.getValue();
          if (itemValue != null) {
            value += itemValue;
          }
        }
      }
    }
    return value;
  }

  Widget createListTile(String lootName, String characterId) {
    int amount = getLootAmount(characterId, lootName);
    if (amount == 0) {
      return Container();
    }
    ListTile listTile = ListTile(
        contentPadding: const EdgeInsets.only(left: 14),
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        horizontalTitleGap: 6,
        leading: Image(
          filterQuality: FilterQuality.medium,
          height: 30,
          width: 30,
          fit: BoxFit.contain,
          image: AssetImage("assets/images/loot/${lootName}_icon.png"),
        ),
        title: Text(
          lootName,
          overflow: TextOverflow.visible,
          maxLines: 1,
        ),
        trailing: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              "$amount",
              style: const TextStyle(
                fontSize: 24,
              ),
            )));

    return listTile;
  }

  Widget buildCharacterLootWidget(String characterId, String characterName) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(children: [
        const Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image(
                filterQuality: FilterQuality.medium,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
                image: AssetImage("assets/images/class-icons/$characterId.png"),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "$characterName's loot:",
                style: const TextStyle(fontSize: 18),
              )
            ]),
        createListTile("coin", characterId),
        createListTile("hide", characterId),
        createListTile("lumber", characterId),
        createListTile("metal", characterId),
        createListTile("arrowvine", characterId),
        createListTile("axenut", characterId),
        createListTile("corpsecap", characterId),
        createListTile("flamefruit", characterId),
        createListTile("rockroot", characterId),
        createListTile("snowthistle", characterId),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    List<Character> characters = GameMethods.getCurrentCharacters();

    return Card(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      for (Character character in characters)
                        buildCharacterLootWidget(character.characterClass.id, character.characterState.display.value),
                      const SizedBox(
                        height: 34,
                      ),
                    ],
                  ),
                  Positioned(
                      width: 100,
                      height: 40,
                      right: 0,
                      bottom: 0,
                      child: TextButton(
                          child: const Text(
                            'Close',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ]))));
  }
}
