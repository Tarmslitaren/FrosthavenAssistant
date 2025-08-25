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
  String _cardText(String gfx) {
    if (gfx.startsWith("perks/")) {
      gfx = gfx.substring("perks/".length);
    }
    bool negative = gfx.startsWith("minus");
    String retVal = "+";
    if (negative) {
      retVal = "-";
      gfx = gfx.substring("minus".length);
    } else {
      gfx = gfx.substring("plus".length);
    }
    retVal += gfx[0]; //nr
    if (gfx.length > 1) {
      gfx = gfx.substring(1);
      String flip = "";
      String range = "";
      String target = "";
      if (gfx.endsWith("flip")) {
        flip = "%flip%";
        gfx = gfx.substring(0, gfx.length - "flip".length);
      }
      if (gfx.contains("range")) {
        range = " %range% ${gfx.substring(gfx.length - 1)}";
        gfx = gfx.substring(0, gfx.length - "range".length - 1);
      }
      String ally = "";
      if (gfx.contains("ally")) {
        ally = ", %target%1 ally";
        gfx = gfx.substring(
            0, gfx.length - "ally".length); //should be %target% 1 ally?
      }
      if (gfx.contains("target")) {
        target = " %target% ${gfx.substring(gfx.length - 1)}";
        gfx = gfx.substring(0, gfx.length - "target".length - 1);
      }
      String mainMod = "";
      String maybeNr = "";
      if (gfx.length > 1) {
        maybeNr = gfx.substring(gfx.length - 1);
        int? nr = int.tryParse(maybeNr);
        if (nr == null) {
          maybeNr = "";
        } else {
          gfx = gfx.substring(0, gfx.length - 1);
        }
        mainMod = "%$gfx%";
      }

      //self check
      bool positiveMod = gfx == "invisible" ||
              gfx == "heal" ||
              gfx == "strengthen" ||
              gfx == "regenerate"
          //|| gfx == "bless"
          //|| gfx == "ward"
          //|| gfx == "safeguard"
          //|| gfx == "dodge"
          ;
      if (ally.isEmpty && positiveMod && range.isEmpty) {
        ally = ", self";
      }

      String quotes = "";
      String initialQuoteSpace = "";
      if (mainMod.isNotEmpty &&
          (ally.isNotEmpty || maybeNr.isNotEmpty || range.isNotEmpty)) {
        quotes = "\"";
        initialQuoteSpace = " ";
      }

      if (mainMod.isEmpty && target.isNotEmpty) {
        //target is main mod
        target =
            "+ ${target.substring(target.length - 1, target.length)}%target%";
      }

      return "$retVal$initialQuoteSpace$quotes$mainMod$maybeNr$range$target$ally$quotes$flip";
    }
    return retVal;
  }

  String _nrTextFromDigit(int digit) {
    if (digit == 1) {
      return "one ";
    }
    if (digit == 2) {
      return "two ";
    }
    if (digit == 3) {
      return "three ";
    }
    if (digit == 4) {
      return "four ";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final Character? character =
        GameMethods.getCharacterByName(widget.characterId);
    final bool added = character != null
        ? character.characterState.perkList[widget.index]
        : false;

    String description = widget.perk.text;
    if (description.isEmpty) {
      //only works for remove and add same cards
      final adds = widget.perk.add;
      final removes = widget.perk.remove;
      description = "";
      final removeAmount = removes.length;
      final addsAmount = adds.length;

      if (adds.isNotEmpty && removes.isEmpty) {
        description = "Add ";
        description += _nrTextFromDigit(addsAmount);
        final addCard = adds.first;
        description += "${_cardText(addCard)} card";
        if (addsAmount > 1) {
          description += "s";
        }
      } else if (adds.isEmpty && removes.isNotEmpty) {
        description = "Remove ";
        description += _nrTextFromDigit(removeAmount);
        final removeCard = removes.first;
        description += "${_cardText(removeCard)} card";
        if (removeAmount > 1) {
          description += "s";
        }
      } else if (adds.isNotEmpty && removes.isNotEmpty) {
        description = "Replace ";
        description += _nrTextFromDigit(removes.length);
        description += "${_cardText(removes.first)} card";
        if (adds.length > 1) {
          description += "s";
        }
        description += " with ";
        final addsAmount = adds.length;
        description += _nrTextFromDigit(addsAmount);
        final addCard = adds.first;
        description += "${_cardText(addCard)} card";
        if (addsAmount > 1) {
          description += "s";
        }
      }
    }

    return CheckboxListTile(
      contentPadding: EdgeInsets.only(left: 14),
      title: TokenApplier.applyTokensForPerks(description),
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
