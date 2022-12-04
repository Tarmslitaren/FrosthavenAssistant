import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/enhance_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import '../../services/service_locator.dart';

class LootCardEnhancementMenu extends StatefulWidget {
  const LootCardEnhancementMenu({Key? key}) : super(key: key);

  @override
  LootCardEnhancementMenuState createState() => LootCardEnhancementMenuState();
}

class LootCardEnhancementMenuState extends State<LootCardEnhancementMenu> {
  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget createListTile(
      name, int startIndex, int amount, List<bool> reference, String materialName) {
    ListTile listTile = ListTile(
      contentPadding: const EdgeInsets.only(left: 14),
      minVerticalPadding: 0,
      minLeadingWidth: 0,
      horizontalTitleGap: 6,
      leading:
      //Row(children: [
        Image(
          filterQuality: FilterQuality.medium,
          height: 30,
          width:  30,
          fit: BoxFit.contain,
          image: AssetImage("assets/images/loot/${materialName}_icon.png"),),
        title: Text(name,

          overflow: TextOverflow.visible,
          maxLines: 1,
        ),
     // ]), //todo: use the icon and put in row
      trailing: Container(
          width: amount * 48,
          child: Row(
            children: [
              Checkbox(
                checkColor: Colors.black,
                activeColor: Colors.grey.shade200,
                onChanged: (bool? newValue) {
                  setState(() {
                    getIt<GameState>().action(EnhanceLootCardCommand(newValue!, startIndex, materialName));
                  });
                },
                value: reference[startIndex],
              ),
              Checkbox(
                value: reference[startIndex + 1],
                checkColor: Colors.black,
                activeColor: Colors.grey.shade200,
                onChanged: (bool? newValue) {
                  setState(() {
                    getIt<GameState>().action(EnhanceLootCardCommand(newValue!, startIndex + 1, materialName));
                  });
                },
              ),
              if (amount == 3)
                Checkbox(
                  value: reference[startIndex + 2],
                  checkColor: Colors.black,
                  activeColor: Colors.grey.shade200,
                  onChanged: (bool? newValue) {
                    setState(() {
                      getIt<GameState>().action(EnhanceLootCardCommand(newValue!, startIndex + 2, materialName));
                    });
                  },
                )
            ],
          )),
    );
    return listTile;
  }

  @override
  Widget build(BuildContext context) {
    GameState _gameState = getIt<GameState>();

    return Card(
        child: Scrollbar(
            child: SingleChildScrollView(
                child: Stack(children: [
      Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Loot Card Enhancements",
                    style: TextStyle(fontSize: 18),
                  ),
                  createListTile(
                      "lumber 1", 0, 2, _gameState.lootDeck.lumberEnhancements, "lumber"),
                  createListTile("lumber 2 for 2p ", 2, 3,
                      _gameState.lootDeck.lumberEnhancements,"lumber"),
                  createListTile("lumber 2 for 2-3p", 5, 3,
                      _gameState.lootDeck.lumberEnhancements,"lumber"),
                  createListTile(
                      "hide 1", 0, 2, _gameState.lootDeck.hideEnhancements, "hide"),
                  createListTile("hide 2 for 2p ", 2, 3,
                      _gameState.lootDeck.hideEnhancements, "hide"),
                  createListTile("hide 2 for 2-3p", 5, 3,
                      _gameState.lootDeck.hideEnhancements, "hide"),
                  createListTile(
                      "metal 1", 0, 2, _gameState.lootDeck.metalEnhancements, "metal"),
                  createListTile("metal 2 for 2p", 2, 3,
                      _gameState.lootDeck.metalEnhancements, "metal"),
                  createListTile("metal 2 for 2-3p", 5, 3,
                      _gameState.lootDeck.metalEnhancements, "metal"),
                  createListTile(
                      "arrowvine", 0, 2, _gameState.lootDeck.arrowvineEnhancements, "arrowvine"),
                  createListTile(
                      "axenut", 0, 2, _gameState.lootDeck.axenutEnhancements, "axenut"),
                  createListTile(
                      "corpsecap", 0, 2, _gameState.lootDeck.corpsecapEnhancements, "corpsecap"),
                  createListTile(
                      "flamefruit", 0, 2, _gameState.lootDeck.flamefruitEnhancements, "flamefruit"),
                  createListTile(
                      "rockroot", 0, 2, _gameState.lootDeck.rockrootEnhancements, "rockroot"),
                  createListTile(
                      "snowthistle", 0, 2, _gameState.lootDeck.snowthistleEnhancements, "snowthistle"),
                ]),
          ),
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
