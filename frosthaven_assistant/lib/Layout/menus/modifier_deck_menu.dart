import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/perks_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_amd_card_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/removed_modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/add_cs_party_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_add_minus_one_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_imbue2_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_imbue_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_minus_1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/bad_omen_command.dart';
import 'package:frosthaven_assistant/Resource/commands/corrosive_spew_command.dart';
import 'package:frosthaven_assistant/Resource/commands/donate_cs_sanctuary_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_cs_party_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_cs_sanctuary_donation_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/commands/amd_remove_minus_2_command.dart';
import '../../Resource/commands/amd_remove_plus_0_command.dart';
import '../../Resource/commands/change_stat_commands/change_bless_command.dart';
import '../../Resource/commands/change_stat_commands/change_curse_command.dart';
import '../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

class ModifierDeckMenu extends StatefulWidget {
  const ModifierDeckMenu({super.key, required this.name});

  final String name;

  @override
  ModifierDeckMenuState createState() => ModifierDeckMenuState();
}

class ModifierDeckMenuState extends State<ModifierDeckMenu> {
  final GameState _gameState = getIt<GameState>();
  final scrollController = ScrollController();
  static List<ModifierCard> revealedList = [];

  @override
  initState() {
    super.initState();
  }

  void markAsOpen(int revealed, ModifierDeck deck) {
    setState(() {
      revealedList = [];
      var drawPile = deck.drawPile.getList().reversed.toList();
      for (int i = 0; i < revealed; i++) {
        revealedList.add(drawPile[i]);
      }
    });
  }

  bool isRevealed(ModifierCard item) {
    for (var card in revealedList) {
      if (card == item) {
        return true;
      }
    }
    return false;
  }

  Widget buildRevealButton(int nrOfButtons, int nr, ModifierDeck deck) {
    String text = "All";
    if (nr < nrOfButtons) {
      text = nr.toString();
    }
    return SizedBox(
        width: 32,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            markAsOpen(nr, deck);
          },
        ));
  }

  Widget buildPartyButton(int nr, String id) {
    String text = nr.toString();
    return SizedBox(
        width: 32,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            _gameState.action(AddCSPartyCardCommand(widget.name, 1));
          },
        ));
  }

  List<Widget> generateList(
      List<ModifierCard> inputList, bool allOpen, String name) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      final key = index.toString();
      var item = inputList[index];
      Item value = Item(
          key: Key(key),
          data: item,
          name: name,
          revealed: isRevealed(item) || allOpen);
      if (!allOpen) {
        InkWell gestureDetector = InkWell(
          key: Key(key),
          onTap: () {
            //open remove card menu
            openDialog(
                context,
                SendToBottomMenu(
                  currentIndex: int.parse(value.key
                      .toString()
                      .substring(3, value.key.toString().length - 3)),
                  length: inputList.length,
                  name: name,
                  revealed: isRevealed(item) || allOpen,
                ));
          },
          child: value,
        );
        list.add(gestureDetector);
      } else {
        InkWell gestureDetector = InkWell(
          key: Key(index.toString()),
          onTap: () {
            //open remove card menu
            openDialog(context, RemoveAMDCardMenu(index: index, name: name));
          },
          child: value,
        );
        //reason for row is to force wrap width of ListView
        list.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            key: Key(index.toString()),
            children: [gestureDetector]));
      }
    }
    return list;
  }

  Widget buildList(
      List<ModifierCard> list, bool reorderable, bool allOpen, String name) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
          width: screenWidth * 0.3,
          child: reorderable
              ? ReorderableColumn(
                  needsLongPressDraggable: true,
                  scrollController: scrollController,
                  scrollAnimationDuration: const Duration(milliseconds: 400),
                  reorderAnimationDuration: const Duration(milliseconds: 400),
                  buildDraggableFeedback: defaultBuildDraggableFeedback,
                  onReorder: (index, dropIndex) {
                    setState(() {
                      dropIndex = list.length - dropIndex - 1;
                      index = list.length - index - 1;
                      list.insert(dropIndex, list.removeAt(index));
                      _gameState.action(
                          ReorderModifierListCommand(dropIndex, index, name));
                    });
                  },
                  children: generateList(list, allOpen, name),
                )
              : ListView(
                  controller: ScrollController(),
                  children: generateList(list, allOpen, name).reversed.toList(),
                ),
        ));
  }

  @override
  void deactivate() {
    revealedList = [];
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          String name = widget.name;
          ModifierDeck deck =
              GameMethods.getModifierDeck(widget.name, _gameState);
          final drawPile = deck.drawPile.getList().reversed.toList();
          final discardPile = deck.discardPile.getList();
          final removedPile = deck.removedPile.getList();

          bool hasDiviner = false;
          for (final item in _gameState.currentList) {
            if (item is Character && item.characterClass.name == "Diviner") {
              hasDiviner = true;
            }
          }

          bool isCharacter = widget.name.isNotEmpty && widget.name != "allies";
          final character =
              isCharacter ? GameMethods.getCharacterByName(widget.name) : null;
          final screenSize = MediaQuery.of(context).size;
          final badOmen = deck.badOmen.value;
          final corrosiveSpew = deck.corrosiveSpew.value;

          final characterHail = GameMethods.getCharacterByName("Hail");
          bool hasHailPerk = characterHail != null
              ? characterHail.characterState.perkList[17]
              : false;
          final monsterDeck = widget.name.isEmpty;
          final hasIncarnate =
              GameMethods.getFigure("Incarnate", "Incarnate") != null;

          final hasVimthreader =
              GameMethods.getFigure("Vimthreader", "Vimthreader") != null;

          final hasLifespeaker =
              GameMethods.getFigure("Lifespeaker", "Lifespeaker") != null;

          final imbuement = deck.imbuement.value;

          final textStyle = TextStyle(fontSize: 16, color: Colors.black);

          final campaign = _gameState.currentCampaign.value;
          final bool isCSCampaign =
              campaign == "Crimson Scales" || campaign == "Trail of Ashes";

          bool donatedCS = false;
          bool addedPartyCard = false;
          if (isCharacter && deck.hasCSSanctuary()) {
            donatedCS = true;
          }
          if (isCharacter && deck.hasPartyCard()) {
            addedPartyCard = true;
          }

          bool hasPlus0Card = deck.hasCard("plus0");

          int nrOfEnfeebles = 0;
          int nrOfEmpowers = 0;
          if (hasVimthreader) {
            nrOfEnfeebles++;
            nrOfEmpowers++;
          }
          if (hasLifespeaker) {
            nrOfEnfeebles++;
          }
          if (hasIncarnate) {
            nrOfEnfeebles++;
            nrOfEmpowers++;
          }
          final hasMoreThanOneEnfeeble = monsterDeck && nrOfEnfeebles > 1;
          final hasMoreThanOneEmpower =
              ((isCharacter || name == "allies") && nrOfEmpowers > 1) ||
                  isCharacter && character?.id == "Ruinmaw" && nrOfEmpowers > 0;

          return Container(
              constraints: BoxConstraints(
                  maxWidth: screenSize.width,
                  maxHeight: screenSize.height * 0.9),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                          width: screenSize.width, //need some width to fill out
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4))),
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 0,
                              spacing: 0,
                              children: [
                                if (hasDiviner && !isCharacter)
                                  if (badOmen == 0)
                                    TextButton(
                                      onPressed: () {
                                        _gameState.action(
                                            BadOmenCommand(name == "allies"));
                                      },
                                      child: const Text("Bad Omen"),
                                    ),
                                if (badOmen > 0)
                                  Text("BadOmensLeft: $badOmen",
                                      style: textStyle),
                                if (widget.name == "Ruinmaw" && !corrosiveSpew)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(CorrosiveSpewCommand());
                                    },
                                    child: Text(
                                      "Corrosive Spew",
                                    ),
                                  ),
                                if (corrosiveSpew)
                                  Text(" Empowers on top", style: textStyle),
                                TextButton(
                                  onPressed: () {
                                    _gameState
                                        .action(AmdAddMinusOneCommand(name));
                                  },
                                  child: Text(
                                      "Add -1 card (added : ${deck.addedMinusOnes.value})"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (deck.hasMinus1()) {
                                      _gameState
                                          .action(AMDRemoveMinus1Command(name));
                                    }
                                  },
                                  child: const Text("Remove -1 card"),
                                ),
                                if (!isCharacter)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(AMDRemoveMinus2Command(
                                          name == "allies"));
                                    },
                                    child: Text(
                                      deck.hasMinus2()
                                          ? "Remove -2 card"
                                          : "-2 card removed",
                                    ),
                                  ),
                                if (isCharacter &&
                                    (hasPlus0Card || deck.hasCard("plus0")))
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(AmdRemovePlus0Command(
                                          name, hasPlus0Card));
                                    },
                                    child: Text(
                                      hasPlus0Card
                                          ? "Remove +0 card"
                                          : "+0 card removed",
                                    ),
                                  ),
                                if (monsterDeck)
                                  TextButton(
                                    onPressed: () {
                                      if (deck.imbuement.value > 0) {
                                        _gameState
                                            .action(AMDRemoveImbueCommand());
                                      } else {
                                        _gameState.action(AMDImbue1Command());
                                      }
                                    },
                                    child: Text(
                                      imbuement > 0 ? "Remove Imbue" : "Imbue",
                                    ),
                                  ),
                                if (imbuement != 2 && monsterDeck)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(AMDImbue2Command());
                                    },
                                    child: Text("Advanced Imbue"),
                                  ),
                                if (widget.name.isEmpty &&
                                    characterHail != null)
                                  TextButton(
                                    onPressed: () {
                                      _gameState
                                          .action(AddPerkCommand("Hail", 17));
                                    },
                                    child: Text(
                                      hasHailPerk
                                          ? "Remove Hail Perk"
                                          : "Add Hail Perk",
                                    ),
                                  ),
                                if (removedPile.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      openDialog(
                                          context,
                                          RemovedModifierCardMenu(
                                            name: widget.name,
                                          ));
                                    },
                                    child:
                                        Text("Removed: ${removedPile.length}"),
                                  ),
                                if (isCSCampaign && isCharacter)
                                  TextButton(
                                    onPressed: () {
                                      donatedCS
                                          ? _gameState.action(
                                              RemoveCSSanctuaryDonationCommand(
                                                  widget.name))
                                          : _gameState.action(
                                              DonateCSSanctuaryCommand(
                                                  widget.name));
                                    },
                                    child: Text(donatedCS
                                        ? "Remove\nDonation"
                                        : "Donate to\nSanctuary"),
                                  ),
                                if (isCSCampaign && isCharacter)
                                  addedPartyCard
                                      ? TextButton(
                                          onPressed: () {
                                            _gameState.action(
                                                RemoveCSPartyCardCommand(
                                                    widget.name));
                                          },
                                          child: Text("Remove\nParty Card:"),
                                        )
                                      : Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                              Text("Add Party\n Card:"),
                                              buildPartyButton(
                                                  1,
                                                  widget
                                                      .name), //todo: make own menu for this, just like for gh2e special
                                              buildPartyButton(2, widget.name),
                                              buildPartyButton(3, widget.name),
                                              buildPartyButton(4, widget.name),
                                            ]),
                                if (isCharacter &&
                                    _gameState.unlockedClasses
                                        .contains("Demons"))
                                  IconButton(
                                    icon:
                                        Image.asset("assets/images/demons.png"),
                                    onPressed: () {
                                      //todo: open menu
                                    },
                                  ),
                                if (isCharacter &&
                                    _gameState.unlockedClasses
                                        .contains("Merchant-Guild"))
                                  IconButton(
                                    icon: Image.asset(
                                        "assets/images/merchant-guild.png"),
                                    onPressed: () {
                                      //todo: open menu
                                    },
                                  ),
                                if (isCharacter &&
                                    _gameState.unlockedClasses
                                        .contains("Military"))
                                  IconButton(
                                    icon: Image.asset(
                                        "assets/images/military.png"),
                                    onPressed: () {
                                      //todo: open menu
                                    },
                                  ),
                                CounterButton(
                                    notifier: deck.getRemovable("bless"),
                                    command: ChangeBlessCommand.deck(deck),
                                    maxValue: 10,
                                    image: "assets/images/abilities/bless.png",
                                    showTotalValue: true,
                                    color: Colors.white,
                                    figureId: "unknown",
                                    ownerId: "unknown",
                                    scale: 1),
                                CounterButton(
                                    notifier: deck.getRemovable("curse"),
                                    command: ChangeCurseCommand.deck(deck),
                                    maxValue: 10,
                                    image: "assets/images/abilities/curse.png",
                                    showTotalValue: true,
                                    color: Colors.white,
                                    figureId: "unknown",
                                    ownerId: "unknown",
                                    scale: 1),
                                if (hasIncarnate && !isCharacter)
                                  CounterButton(
                                      notifier:
                                          deck.getRemovable("in-enfeeble"),
                                      command: ChangeEnfeebleCommand.deck(
                                          deck, "in-enfeeble"),
                                      maxValue: 10,
                                      image:
                                          "assets/images/abilities/enfeeble.png",
                                      extraImage: hasMoreThanOneEnfeeble
                                          ? "assets/images/class-icons/incarnate.png"
                                          : null,
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((isCharacter || widget.name == "allies") &&
                                    hasIncarnate)
                                  CounterButton(
                                      notifier: deck.getRemovable("in-empower"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "in-empower"),
                                      maxValue: 10,
                                      image:
                                          "assets/images/abilities/empower.png",
                                      extraImage: hasMoreThanOneEmpower
                                          ? "assets/images/class-icons/incarnate.png"
                                          : null,
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((widget.name == "Ruinmaw"))
                                  CounterButton(
                                      notifier: deck.getRemovable("rm-empower"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "rm-empower"),
                                      maxValue: 12,
                                      image:
                                          "assets/images/abilities/empower.png",
                                      extraImage: hasMoreThanOneEmpower
                                          ? "assets/images/class-icons/ruinmaw.png"
                                          : null,
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((isCharacter || widget.name == "allies") &&
                                    hasVimthreader)
                                  CounterButton(
                                      notifier: deck.getRemovable("vi-empower"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "vi-empower"),
                                      maxValue: 10,
                                      image:
                                          "assets/images/abilities/empower2.png",
                                      extraImage: hasMoreThanOneEmpower
                                          ? "assets/images/class-icons/vimthreader.png"
                                          : null,
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((isCharacter || widget.name == "allies") &&
                                    hasVimthreader)
                                  CounterButton(
                                      notifier:
                                          deck.getRemovable("vi-gr-empower"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "vi-gr-empower"),
                                      maxValue: 5,
                                      image:
                                          "assets/images/abilities/greater-empower.png",
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((!isCharacter) && hasVimthreader)
                                  CounterButton(
                                      notifier:
                                          deck.getRemovable("vi-enfeeble"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "vi-enfeeble"),
                                      maxValue: 10,
                                      image:
                                          "assets/images/abilities/enfeeble2.png",
                                      extraImage: hasMoreThanOneEnfeeble
                                          ? "assets/images/class-icons/vimthreader.png"
                                          : null,
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((!isCharacter) && hasVimthreader)
                                  CounterButton(
                                      notifier:
                                          deck.getRemovable("vi-gr-enfeeble"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "vi-gr-enfeeble"),
                                      maxValue: 5,
                                      image:
                                          "assets/images/abilities/greater-enfeeble.png",
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if ((!isCharacter ||
                                        widget.name == "Lifespeaker") &&
                                    hasLifespeaker)
                                  CounterButton(
                                      notifier:
                                          deck.getRemovable("li-enfeeble"),
                                      command: ChangeEmpowerCommand.deck(
                                          deck, "li-enfeeble"),
                                      maxValue: 15,
                                      image:
                                          "assets/images/abilities/enfeeble2.png",
                                      extraImage: hasMoreThanOneEnfeeble
                                          ? "assets/images/class-icons/lifespeaker.png"
                                          : null,
                                      showTotalValue: true,
                                      color: Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),
                                if (isCharacter &&
                                    character != null &&
                                    character.characterClass.perks.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      openDialog(
                                          context,
                                          PerksMenu(
                                            character: character,
                                          ));
                                    },
                                    child: const Text("Perks"),
                                  ),
                                const Text(
                                  "   Reveal\n    cards:",
                                ),
                                drawPile.isNotEmpty
                                    ? buildRevealButton(
                                        drawPile.length, 1, deck)
                                    : Container(),
                                drawPile.length > 1
                                    ? buildRevealButton(
                                        drawPile.length, 2, deck)
                                    : Container(),
                                drawPile.length > 2
                                    ? buildRevealButton(
                                        drawPile.length, 3, deck)
                                    : Container(),
                                drawPile.length > 3
                                    ? buildRevealButton(
                                        drawPile.length, 4, deck)
                                    : Container(),
                                drawPile.length > 4
                                    ? buildRevealButton(
                                        drawPile.length, 5, deck)
                                    : Container(),
                                drawPile.length > 5
                                    ? buildRevealButton(
                                        drawPile.length, 6, deck)
                                    : Container(),
                              ])),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false, widget.name),
                          buildList(discardPile, false, true, widget.name)
                        ],
                      )),
                      Container(
                        height: 32,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4))),
                      ),
                    ]),
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
                            })),
                    Positioned(
                        bottom: 4,
                        left: 20,
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 20),
                        ))
                  ])));
        });
  }
}

class Item extends StatelessWidget {
  const Item(
      {super.key,
      required this.data,
      required this.revealed,
      required this.name});

  final ModifierCard data;
  final bool revealed;
  final String name;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double scale = max((screenSize.height / (40 * 12)), 1);
    final Widget child = revealed
        ? ModifierCardWidget.buildFront(data, name, scale, 2.5)
        : ModifierCardWidget.buildRear(scale, name);

    return Container(margin: EdgeInsets.all(2 * scale), child: child);
  }
}
