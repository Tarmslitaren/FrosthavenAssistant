import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/commands/add_loot_card_command.dart';
import '../../services/service_locator.dart';

class AddLootCardMenu extends StatelessWidget {
  const AddLootCardMenu({super.key});

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
                        child: Column(children: [
                          const Text(
                            "Add Extra Loot Card",
                            style: TextStyle(fontSize: 18),
                          ),
                          //TODO: only show what can be added?
                          LootCardListTile(name: "hide", index: 0),
                          LootCardListTile(name: "lumber", index: 1),
                          LootCardListTile(name: "metal", index: 2),
                          LootCardListTile(name: "arrowvine", index: 3),
                          LootCardListTile(name: "axenut", index: 4),
                          LootCardListTile(name: "corpsecap", index: 5),
                          LootCardListTile(name: "flamefruit", index: 6),
                          LootCardListTile(name: "rockroot", index: 7),
                          LootCardListTile(name: "snowthistle", index: 8),
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

class LootCardListTile extends StatefulWidget {
  const LootCardListTile({super.key, required this.name, required this.index});

  final String name;
  final int index;

  @override
  State<StatefulWidget> createState() => LootCardListTileState();
}

class LootCardListTileState extends State<LootCardListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          getIt<GameState>().action(AddLootCardCommand(widget.name));
        });
      },
      contentPadding: const EdgeInsets.only(left: 14),
      minVerticalPadding: 0,
      minLeadingWidth: 0,
      horizontalTitleGap: 6,
      leading: Image(
        filterQuality: FilterQuality.medium,
        height: 30,
        width: 30,
        fit: BoxFit.contain,
        image: AssetImage("assets/images/loot/${widget.name}_icon.png"),
      ),
      title: Text(
        widget.name,
        overflow: TextOverflow.visible,
        maxLines: 1,
      ),
      trailing: Text(
          "added: ${getIt<GameState>().lootDeck.addedCards[widget.index]}   ",
          style: const TextStyle(
            fontSize: 18,
          )),
    );
  }
}
