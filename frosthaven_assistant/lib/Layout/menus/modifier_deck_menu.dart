import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/perks_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_amd_card_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/removed_modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/add_cs_party_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_add_minus_one_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_cassandra_special_command.dart';
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
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/commands/amd_remove_minus_2_command.dart';
import '../../Resource/commands/amd_remove_plus_0_command.dart';
import '../../Resource/commands/amd_reveal_command.dart';
import '../../Resource/commands/change_stat_commands/change_bless_command.dart';
import '../../Resource/commands/change_stat_commands/change_curse_command.dart';
import '../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';
import 'gh2e_faction_amd_card_menu.dart';

class ModifierDeckMenu extends StatefulWidget {
  static const double _kRevealButtonWidth = 32.0;
  static const double _kListWidthRatio = 0.3;
  static const int _kReorderAnimationMs = 400;
  static const double _kMaxHeightRatio = 0.9;
  static const int _kMaxBlessCurse = 10;
  static const int _kMaxRuinmawEmpower = 12;
  static const int _kMaxVimthreaderGrEmpower = 5;
  static const int _kMaxLifespeakerEnfeeble = 15;
  static const double _kHeaderBorderRadius = 4.0;
  static const int _kAdvancedImbuementLevel = 2;
  static const int _kHailPerkIndex = 17;
  static const int _kCassandraPerkIndex = 15;
  static const int _kMaxRevealButtonNr = 6;
  static const int _kPartyButtonCount = 4;
  static const double _kHeaderMargin = 2.0;
  static const double _kFooterHeight = 32.0;
  static const double _kFooterBottomPos = 4.0;
  static const double _kNameLeftPos = 20.0;
  static const double _kItemHeightCount = 12.0;
  static const double _kItemBaseHeight = 40.0;
  static const double _kItemMarginMultiplier = 2.0;

  const ModifierDeckMenu({
    super.key,
    required this.name,
    this.gameState,
    this.settings,
  });

  final String name;

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  ModifierDeckMenuState createState() => ModifierDeckMenuState();
}

class ModifierDeckMenuState extends State<ModifierDeckMenu> {
  late final GameState _gameState;
  late final Settings _settings;
  final scrollController = ScrollController();

  bool isRevealed(ModifierCard item) {
    ModifierDeck deck = GameMethods.getModifierDeck(widget.name, _gameState);
    var drawPile = deck.drawPileContents.reversed.toList();
    for (int i = 0; i < deck.revealedCount.value; i++) {
      if (item == drawPile[i]) {
        return true;
      }
    }
    return false;
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
                  currentIndex: index,
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
          width: screenWidth * ModifierDeckMenu._kListWidthRatio,
          child: reorderable
              ? ReorderableColumn(
                  needsLongPressDraggable: true,
                  scrollController: scrollController,
                  scrollAnimationDuration: const Duration(milliseconds: ModifierDeckMenu._kReorderAnimationMs),
                  reorderAnimationDuration: const Duration(milliseconds: ModifierDeckMenu._kReorderAnimationMs),
                  buildDraggableFeedback: defaultBuildDraggableFeedback,
                  onReorder: (index, dropIndex) {
                    setState(() {
                      dropIndex = list.length - dropIndex - 1;
                      index = list.length - index - 1;
                      list.insert(dropIndex, list.removeAt(index));
                      _gameState.action(ReorderModifierListCommand(
                          dropIndex, index, name,
                          gameState: _gameState));
                    });
                  },
                  children: generateList(list, allOpen, name), // ignore: avoid-returning-widgets, list-returning helper for ListView children
                )
              : ListView(
                  controller: ScrollController(),
                  children: generateList(list, allOpen, name).reversed.toList(), // ignore: avoid-returning-widgets, list-returning helper for ListView children
                ),
        ));
  }

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
  }

  @override
  void deactivate() {
    //revealedList = [];
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
          final drawPile = deck.drawPileContents.reversed.toList();
          final discardPile = deck.discardPileContents.toList();
          final removedPile = deck.removedPileContents.toList();

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

          final characterCassandra =
              GameMethods.getCharacterByName("Cassandra");
          bool hasCassandraPerk = characterCassandra != null
              ? characterCassandra.characterState.perkList[15]
              : false;

          final monsterDeck = widget.name.isEmpty;
          final hasIncarnate =
              GameMethods.getFigure("Incarnate", "Incarnate") != null;

          final hasVimthreader =
              GameMethods.getFigure("Vimthreader", "Vimthreader") != null;

          final hasLifespeaker =
              GameMethods.getFigure("Lifespeaker", "Lifespeaker") != null;

          final imbuement = deck.imbuement.value;

          final textStyle = kBodyBlackStyle;

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
                  maxHeight: screenSize.height * ModifierDeckMenu._kMaxHeightRatio),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                          width: screenSize.width, //need some width to fill out
                          margin: const EdgeInsets.all(ModifierDeckMenu._kHeaderMargin),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(ModifierDeckMenu._kHeaderBorderRadius),
                                  topRight: Radius.circular(ModifierDeckMenu._kHeaderBorderRadius))),
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 0,
                              spacing: 0,
                              children: [
                                if (hasDiviner && !isCharacter)
                                  if (badOmen == 0)
                                    TextButton(
                                      onPressed: () {
                                        _gameState.action(BadOmenCommand(
                                            name == "allies",
                                            gameState: _gameState));
                                      },
                                      child: const Text("Bad Omen"),
                                    ),
                                if (badOmen > 0)
                                  Text("BadOmensLeft: $badOmen",
                                      style: textStyle),
                                if (widget.name == "Ruinmaw" && !corrosiveSpew)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(CorrosiveSpewCommand(
                                          gameState: _gameState));
                                    },
                                    child: Text(
                                      "Corrosive Spew",
                                    ),
                                  ),
                                if (corrosiveSpew)
                                  Text(" Empowers on top", style: textStyle),
                                TextButton(
                                  onPressed: () {
                                    _gameState.action(AmdAddMinusOneCommand(
                                        name,
                                        gameState: _gameState));
                                  },
                                  child: Text(
                                      "Add -1 card (added : ${deck.addedMinusOnes.value})"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (deck.hasMinus1()) {
                                      _gameState.action(AMDRemoveMinus1Command(
                                          name,
                                          gameState: _gameState));
                                    }
                                  },
                                  child: const Text("Remove -1 card"),
                                ),
                                if (!isCharacter)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(AMDRemoveMinus2Command(
                                          name == "allies",
                                          gameState: _gameState));
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
                                          name, hasPlus0Card,
                                          gameState: _gameState));
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
                                        _gameState.action(AMDRemoveImbueCommand(
                                            gameState: _gameState));
                                      } else {
                                        _gameState.action(AMDImbue1Command(
                                            gameState: _gameState));
                                      }
                                    },
                                    child: Text(
                                      imbuement > 0 ? "Remove Imbue" : "Imbue",
                                    ),
                                  ),
                                if (imbuement != ModifierDeckMenu._kAdvancedImbuementLevel && monsterDeck)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(AMDImbue2Command(
                                          gameState: _gameState));
                                    },
                                    child: Text("Advanced Imbue"),
                                  ),
                                if (widget.name.isEmpty &&
                                    characterHail != null)
                                  TextButton(
                                    onPressed: () {
                                      _gameState
                                          .action(AddPerkCommand("Hail", ModifierDeckMenu._kHailPerkIndex));
                                    },
                                    child: Text(
                                      hasHailPerk
                                          ? "Remove Hail Perk"
                                          : "Add Hail Perk",
                                    ),
                                  ),
                                if (characterCassandra != null &&
                                    !_settings.showCharacterAMD.value)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(
                                          AddPerkCommand("Cassandra", ModifierDeckMenu._kCassandraPerkIndex));
                                    },
                                    child: Text(
                                      hasCassandraPerk
                                          ? "Remove\nCassandra Perk"
                                          : "Add\nCassandra Perk",
                                    ),
                                  ),
                                if (hasCassandraPerk)
                                  TextButton(
                                    onPressed: () {
                                      _gameState.action(
                                          AMDCassandraSpecialCommand(deck.name,
                                              !deck.cassandraSpecial.value,
                                              gameState: _gameState));
                                    },
                                    child: Text(
                                      deck.cassandraSpecial.value
                                          ? "Don't Save \nRevealed Cards"
                                          : "Save\nRevealed Cards",
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
                                                  widget.name,
                                                  gameState:
                                                      _gameState))
                                          : _gameState.action(
                                              DonateCSSanctuaryCommand(
                                                  widget.name,
                                                  gameState:
                                                      _gameState));
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
                                                    widget.name,
                                                    gameState:
                                                        _gameState));
                                          },
                                          child: Text("Remove\nParty Card:"),
                                        )
                                      : Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                              Text("Add Party\n Card:"),
                                              ...List.generate(
                                                ModifierDeckMenu._kPartyButtonCount,
                                                (i) => _PartyButton(nr: i + 1, gameState: _gameState, name: widget.name), // ignore: avoid-returning-widgets, widget generator lambda
                                              ), //todo: make own menu for this, just like for gh2e special
                                            ]),
                                if (isCharacter &&
                                    _gameState.unlockedClasses
                                        .contains("Demons"))
                                  IconButton(
                                    icon:
                                        Image.asset("assets/images/demons.png"),
                                    onPressed: () {
                                      openDialog(
                                          context,
                                          GH2eFactionAMDCardMenu(
                                            faction: "Demons",
                                            name: widget.name,
                                          ));
                                    },
                                  ),
                                if (isCharacter &&
                                    _gameState.unlockedClasses
                                        .contains("Merchant-Guild"))
                                  IconButton(
                                    icon: Image.asset(
                                        "assets/images/merchant-guild.png"),
                                    onPressed: () {
                                      openDialog(
                                          context,
                                          GH2eFactionAMDCardMenu(
                                            faction: "Merchant-Guild",
                                            name: widget.name,
                                          ));
                                    },
                                  ),
                                if (isCharacter &&
                                    _gameState.unlockedClasses
                                        .contains("Military"))
                                  IconButton(
                                    icon: Image.asset(
                                        "assets/images/military.png"),
                                    onPressed: () {
                                      openDialog(
                                          context,
                                          GH2eFactionAMDCardMenu(
                                            faction: "Military",
                                            name: widget.name,
                                          ));
                                    },
                                  ),
                                CounterButton(
                                    notifier: deck.getRemovable("bless"),
                                    command: ChangeBlessCommand.deck(deck,
                                        gameState: _gameState),
                                    maxValue: ModifierDeckMenu._kMaxBlessCurse,
                                    image: "assets/images/abilities/bless.png",
                                    showTotalValue: true,
                                    color: Colors.white,
                                    figureId: "unknown",
                                    ownerId: "unknown",
                                    scale: 1),
                                CounterButton(
                                    notifier: deck.getRemovable("curse"),
                                    command: ChangeCurseCommand.deck(deck,
                                        gameState: _gameState),
                                    maxValue: ModifierDeckMenu._kMaxBlessCurse,
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
                                          deck, "in-enfeeble",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxBlessCurse,
                                      image:
                                          "assets/images/abilities/enfeeble_old.png",
                                      extraImage: hasMoreThanOneEnfeeble
                                          ? "assets/images/class-icons/Incarnate.png"
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
                                          deck, "in-empower",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxBlessCurse,
                                      image:
                                          "assets/images/abilities/empower_old.png",
                                      extraImage: hasMoreThanOneEmpower
                                          ? "assets/images/class-icons/Incarnate.png"
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
                                          deck, "rm-empower",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxRuinmawEmpower,
                                      image:
                                          "assets/images/abilities/empower_old.png",
                                      extraImage: hasMoreThanOneEmpower
                                          ? "assets/images/class-icons/Ruinmaw.png"
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
                                          deck, "vi-empower",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxBlessCurse,
                                      image:
                                          "assets/images/abilities/empower.png",
                                      extraImage: hasMoreThanOneEmpower
                                          ? "assets/images/class-icons/Vimthreader.png"
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
                                          deck, "vi-gr-empower",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxVimthreaderGrEmpower,
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
                                      command: ChangeEnfeebleCommand.deck(
                                          deck, "vi-enfeeble",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxBlessCurse,
                                      image:
                                          "assets/images/abilities/enfeeble.png",
                                      extraImage: hasMoreThanOneEnfeeble
                                          ? "assets/images/class-icons/Vimthreader.png"
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
                                      command: ChangeEnfeebleCommand.deck(
                                          deck, "vi-gr-enfeeble",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxVimthreaderGrEmpower,
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
                                      notifier: deck.getRemovable(
                                          "li-enfeeble"),
                                      command: ChangeEnfeebleCommand.deck(
                                          deck, "li-enfeeble",
                                          gameState: _gameState),
                                      maxValue: ModifierDeckMenu._kMaxLifespeakerEnfeeble,
                                      image:
                                          "assets/images/abilities/enfeeble.png",
                                      extraImage: hasMoreThanOneEnfeeble
                                          ? "assets/images/class-icons/Lifespeaker.png"
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
                                ...List.generate(
                                  min(drawPile.length + 1, ModifierDeckMenu._kMaxRevealButtonNr + 1),
                                  (i) => _RevealButton(nrOfButtons: drawPile.length, nr: i, gameState: _gameState, name: widget.name), // ignore: avoid-returning-widgets, widget generator lambda
                                ),
                              ])),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false, widget.name), // ignore: avoid-returning-widgets, list-returning helper for Row children
                          buildList(discardPile, false, true, widget.name) // ignore: avoid-returning-widgets, list-returning helper for Row children
                        ],
                      )),
                      Container(
                        height: ModifierDeckMenu._kFooterHeight,
                        margin: const EdgeInsets.all(ModifierDeckMenu._kHeaderMargin),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(ModifierDeckMenu._kHeaderBorderRadius),
                                bottomRight: Radius.circular(ModifierDeckMenu._kHeaderBorderRadius))),
                      ),
                    ]),
                    Positioned(
                        width: kCloseButtonWidth,
                        height: kButtonSize,
                        right: 0,
                        bottom: 0,
                        child: TextButton(
                            child: const Text(
                              'Close',
                              style: kButtonLabelStyle,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })),
                    Positioned(
                        bottom: ModifierDeckMenu._kFooterBottomPos,
                        left: ModifierDeckMenu._kNameLeftPos,
                        child: Text(
                          name,
                          style: kButtonLabelStyle,
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
    double scale = max((screenSize.height / (ModifierDeckMenu._kItemBaseHeight * ModifierDeckMenu._kItemHeightCount)), 1);
    final Widget child = revealed
        ? ModifierCardFront(card: data, name: name, scale: scale)
        : ModifierCardRear(scale: scale, name: name);

    return Container(margin: EdgeInsets.all(ModifierDeckMenu._kItemMarginMultiplier * scale), child: child);
  }
}

class _RevealButton extends StatelessWidget {
  const _RevealButton({
    required this.nrOfButtons,
    required this.nr,
    required this.gameState,
    required this.name,
  });

  final int nrOfButtons;
  final int nr;
  final GameState gameState;
  final String name;

  @override
  Widget build(BuildContext context) {
    String text = nr < nrOfButtons ? nr.toString() : "All";
    return SizedBox(
        width: ModifierDeckMenu._kRevealButtonWidth,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            gameState.action(AMDRevealCommand(
                amount: nr, name: name, gameState: gameState));
          },
        ));
  }
}

class _PartyButton extends StatelessWidget {
  const _PartyButton({
    required this.nr,
    required this.gameState,
    required this.name,
  });

  final int nr;
  final GameState gameState;
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: ModifierDeckMenu._kRevealButtonWidth,
        child: TextButton(
          child: Text(nr.toString()),
          onPressed: () {
            gameState.action(AddCSPartyCardCommand(name, 1,
                gameState: gameState));
          },
        ));
  }
}
