import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/line_builder/token_applier.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/commands/add_perk_command.dart';
import '../../services/service_locator.dart';

class PerksMenu extends StatelessWidget {
  const PerksMenu({super.key, required this.perks, required this.characterId});
  final List<PerkModel> perks;
  final String characterId;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    List<Widget> tiles = [];
    tiles.add(Text(
      "Add Perks",
      style: TextStyle(fontSize: 18),
    ));
    for (int i = 0; i < perks.length; i++) {
      tiles.add(
          PerkListTile(characterId: characterId, index: i, perk: perks[i]));
    }

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
                        child: Column(children: tiles),
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

class PerkListTile extends StatefulWidget {
  const PerkListTile(
      {super.key,
      required this.characterId,
      required this.index,
      required this.perk});

  final String characterId;
  final int index;
  final PerkModel perk;

  @override
  State<StatefulWidget> createState() => LootCardListTileState();
}

class LootCardListTileState extends State<PerkListTile> {
  @override
  Widget build(BuildContext context) {
    final Character? character =
        GameMethods.getCharacterByName(widget.characterId);
    final bool added = character != null
        ? character.characterState.perkList[widget.index]
        : false;
    return CheckboxListTile(
      contentPadding: const EdgeInsets.only(left: 14),
      //minVerticalPadding: 0,
      // minLeadingWidth: 0,
      //horizontalTitleGap: 6,

      title: TokenApplier.applyTokensForPerks(widget.perk.text),

      onChanged: (bool? value) {
        setState(() {
          getIt<GameState>()
              .action(AddPerkCommand(widget.characterId, widget.index));
        });
      },
      value: added,
    );
  }
}
