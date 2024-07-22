import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/commands/add_loot_card_command.dart';
import '../../services/service_locator.dart';

class AddLootCardMenu extends StatefulWidget {
  const AddLootCardMenu({super.key});

  @override
  AddLootCardMenuState createState() => AddLootCardMenuState();
}

class AddLootCardMenuState extends State<AddLootCardMenu> {
  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget createListTile(name, index) {
    ListTile listTile = ListTile(
      onTap: () {
        setState(() {
          getIt<GameState>().action(AddLootCardCommand(name));
        });
      },
      contentPadding: const EdgeInsets.only(left: 14),
      minVerticalPadding: 0,
      minLeadingWidth: 0,
      horizontalTitleGap: 6,
      leading:
          Image(
        filterQuality: FilterQuality.medium,
        height: 30,
        width: 30,
        fit: BoxFit.contain,
        image: AssetImage("assets/images/loot/${name}_icon.png"),
      ),
      title: Text(
        name,
        overflow: TextOverflow.visible,
        maxLines: 1,
      ),
      trailing: Text("added: ${getIt<GameState>().lootDeck.addedCards[index]}   ",
          style: const TextStyle(
            fontSize: 18,
          )),
    );
    return listTile;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

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
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Column(
                            children: [
                              const Text(
                                "Add Extra Loot Card",
                                style: TextStyle(fontSize: 18),
                              ),
                              //TODO: only show what can be added?
                              createListTile("hide", 0),
                              createListTile("lumber", 1),
                              createListTile("metal", 2),

                              createListTile("arrowvine", 3),
                              createListTile("axenut", 4),
                              createListTile("corpsecap", 5),
                              createListTile("flamefruit", 6),
                              createListTile("rockroot", 7),
                              createListTile("snowthistle", 8),
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
