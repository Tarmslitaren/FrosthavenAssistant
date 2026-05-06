import 'dart:math';

import 'package:flutter/material.dart';

import '../../../Resource/app_constants.dart';
import '../../../Resource/commands/add_perk_command.dart';
import '../../../Resource/commands/amd_add_minus_one_command.dart';
import '../../../Resource/commands/amd_cassandra_special_command.dart';
import '../../../Resource/commands/amd_imbue1_command.dart';
import '../../../Resource/commands/amd_imbue2_command.dart';
import '../../../Resource/commands/amd_remove_imbue_command.dart';
import '../../../Resource/commands/amd_remove_minus_1_command.dart';
import '../../../Resource/commands/amd_remove_minus_2_command.dart';
import '../../../Resource/commands/amd_remove_plus_0_command.dart';
import '../../../Resource/commands/bad_omen_command.dart';
import '../../../Resource/commands/change_stat_commands/change_bless_command.dart';
import '../../../Resource/commands/change_stat_commands/change_curse_command.dart';
import '../../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../../Resource/commands/corrosive_spew_command.dart';
import '../../../Resource/commands/donate_cs_sanctuary_command.dart';
import '../../../Resource/commands/remove_cs_party_card_command.dart';
import '../../../Resource/commands/remove_cs_sanctuary_donation_command.dart';
import '../../../Resource/game_methods.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../counter_button.dart';
import '../PerksMenu/perks_menu.dart';
import '../gh2e_faction_amd_card_menu.dart';
import '../removed_modifier_card_menu.dart';
import 'modifier_deck_party_button.dart';
import 'modifier_deck_reveal_button.dart';

class ModifierDeckHeader extends StatelessWidget {
  static const double _kHeaderMargin = 2.0;
  static const double _kHeaderBorderRadius = 4.0;
  static const int _kMaxBlessCurse = 10;
  static const int _kMaxRuinmawEmpower = 12;
  static const int _kMaxVimthreaderGrEmpower = 5;
  static const int _kMaxLifespeakerEnfeeble = 15;
  static const int _kAdvancedImbuementLevel = 2;
  static const int _kHailPerkIndex = 17;
  static const int _kCassandraPerkIndex = 15;
  static const int _kMaxRevealButtonNr = 6;
  static const int _kPartyButtonCount = 4;

  const ModifierDeckHeader({
    super.key,
    required this.deck,
    required this.gameState,
    required this.settings,
    required this.name,
  });

  final ModifierDeck deck;
  final GameState gameState;
  final Settings settings;
  final String name;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    bool hasDiviner = false;
    for (final item in gameState.currentList) {
      if (item is Character && item.characterClass.name == "Diviner") {
        hasDiviner = true;
      }
    }

    final bool isCharacter = name.isNotEmpty && name != "allies";
    final character = isCharacter ? GameMethods.getCharacterByName(name) : null;
    final badOmen = deck.badOmen.value;
    final corrosiveSpew = deck.corrosiveSpew.value;

    final characterHail = GameMethods.getCharacterByName("Hail");
    final bool hasHailPerk = characterHail != null
        ? characterHail.characterState.perkList[_kHailPerkIndex]
        : false;

    final characterCassandra = GameMethods.getCharacterByName("Cassandra");
    final bool hasCassandraPerk = characterCassandra != null
        ? characterCassandra.characterState.perkList[_kCassandraPerkIndex]
        : false;

    final monsterDeck = name.isEmpty;
    final hasIncarnate =
        GameMethods.getFigure("Incarnate", "Incarnate") != null;
    final hasVimthreader =
        GameMethods.getFigure("Vimthreader", "Vimthreader") != null;
    final hasLifespeaker =
        GameMethods.getFigure("Lifespeaker", "Lifespeaker") != null;

    final imbuement = deck.imbuement.value;
    final textStyle = kBodyBlackStyle;

    final campaign = gameState.currentCampaign.value;
    final bool isCSCampaign =
        campaign == "Crimson Scales" || campaign == "Trail of Ashes";

    final donatedCS = isCharacter && deck.hasCSSanctuary();
    final addedPartyCard = isCharacter && deck.hasPartyCard();
    final hasPlus0Card = deck.hasCard("plus0");

    final removedPile = deck.removedPileContents.toList();
    final drawPile = deck.drawPileContents.reversed.toList();

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
        width: screenWidth,
        margin: const EdgeInsets.all(_kHeaderMargin),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_kHeaderBorderRadius),
                topRight: Radius.circular(_kHeaderBorderRadius))),
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 0,
            spacing: 0,
            children: [
              if (hasDiviner && !isCharacter)
                if (badOmen == 0)
                  TextButton(
                    onPressed: () {
                      gameState.action(BadOmenCommand(name == "allies",
                          gameState: gameState));
                    },
                    child: const Text("Bad Omen"),
                  ),
              if (badOmen > 0) Text("BadOmensLeft: $badOmen", style: textStyle),
              if (name == "Ruinmaw" && !corrosiveSpew)
                TextButton(
                  onPressed: () {
                    gameState
                        .action(CorrosiveSpewCommand(gameState: gameState));
                  },
                  child: const Text("Corrosive Spew"),
                ),
              if (corrosiveSpew) Text(" Empowers on top", style: textStyle),
              TextButton(
                onPressed: () {
                  gameState.action(
                      AmdAddMinusOneCommand(name, gameState: gameState));
                },
                child:
                    Text("Add -1 card (added : ${deck.addedMinusOnes.value})"),
              ),
              TextButton(
                onPressed: () {
                  if (deck.hasMinus1()) {
                    gameState.action(
                        AMDRemoveMinus1Command(name, gameState: gameState));
                  }
                },
                child: const Text("Remove -1 card"),
              ),
              if (!isCharacter)
                TextButton(
                  onPressed: () {
                    gameState.action(AMDRemoveMinus2Command(name == "allies",
                        gameState: gameState));
                  },
                  child: Text(
                    deck.hasMinus2() ? "Remove -2 card" : "-2 card removed",
                  ),
                ),
              if (isCharacter && (hasPlus0Card || deck.hasCard("plus0")))
                TextButton(
                  onPressed: () {
                    gameState.action(AmdRemovePlus0Command(name, hasPlus0Card,
                        gameState: gameState));
                  },
                  child: Text(
                    hasPlus0Card ? "Remove +0 card" : "+0 card removed",
                  ),
                ),
              if (monsterDeck)
                TextButton(
                  onPressed: () {
                    if (deck.imbuement.value > 0) {
                      gameState
                          .action(AMDRemoveImbueCommand(gameState: gameState));
                    } else {
                      gameState.action(AMDImbue1Command(gameState: gameState));
                    }
                  },
                  child: Text(imbuement > 0 ? "Remove Imbue" : "Imbue"),
                ),
              if (imbuement != _kAdvancedImbuementLevel && monsterDeck)
                TextButton(
                  onPressed: () {
                    gameState.action(AMDImbue2Command(gameState: gameState));
                  },
                  child: const Text("Advanced Imbue"),
                ),
              if (name.isEmpty && characterHail != null)
                TextButton(
                  onPressed: () {
                    gameState.action(AddPerkCommand("Hail", _kHailPerkIndex));
                  },
                  child: Text(
                    hasHailPerk ? "Remove Hail Perk" : "Add Hail Perk",
                  ),
                ),
              if (characterCassandra != null &&
                  !settings.showCharacterAMD.value)
                TextButton(
                  onPressed: () {
                    gameState.action(
                        AddPerkCommand("Cassandra", _kCassandraPerkIndex));
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
                    gameState.action(AMDCassandraSpecialCommand(
                        deck.name, !deck.cassandraSpecial.value,
                        gameState: gameState));
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
                    openDialog(context, RemovedModifierCardMenu(name: name));
                  },
                  child: Text("Removed: ${removedPile.length}"),
                ),
              if (isCSCampaign && isCharacter)
                TextButton(
                  onPressed: () {
                    donatedCS
                        ? gameState.action(RemoveCSSanctuaryDonationCommand(
                            name,
                            gameState: gameState))
                        : gameState.action(DonateCSSanctuaryCommand(name,
                            gameState: gameState));
                  },
                  child: Text(
                      donatedCS ? "Remove\nDonation" : "Donate to\nSanctuary"),
                ),
              if (isCSCampaign && isCharacter)
                addedPartyCard
                    ? TextButton(
                        onPressed: () {
                          gameState.action(RemoveCSPartyCardCommand(name,
                              gameState: gameState));
                        },
                        child: const Text("Remove\nParty Card:"),
                      )
                    : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                            const Text("Add Party\n Card:"),
                            ...List.generate(
                              _kPartyButtonCount,
                              (i) => ModifierDeckPartyButton(
                                  nr: i + 1, gameState: gameState, name: name),
                            ),
                          ]),
              if (isCharacter && gameState.unlockedClasses.contains("Demons"))
                IconButton(
                  icon: Image.asset("assets/images/demons.png"),
                  onPressed: () {
                    openDialog(context,
                        GH2eFactionAMDCardMenu(faction: "Demons", name: name));
                  },
                ),
              if (isCharacter &&
                  gameState.unlockedClasses.contains("Merchant-Guild"))
                IconButton(
                  icon: Image.asset("assets/images/merchant-guild.png"),
                  onPressed: () {
                    openDialog(
                        context,
                        GH2eFactionAMDCardMenu(
                            faction: "Merchant-Guild", name: name));
                  },
                ),
              if (isCharacter && gameState.unlockedClasses.contains("Military"))
                IconButton(
                  icon: Image.asset("assets/images/military.png"),
                  onPressed: () {
                    openDialog(
                        context,
                        GH2eFactionAMDCardMenu(
                            faction: "Military", name: name));
                  },
                ),
              CounterButton(
                  notifier: deck.getRemovable("bless"),
                  command: ChangeBlessCommand.deck(deck, gameState: gameState),
                  maxValue: _kMaxBlessCurse,
                  image: "assets/images/abilities/bless.png",
                  showTotalValue: true,
                  color: Colors.white,
                  figureId: "unknown",
                  ownerId: "unknown",
                  scale: 1),
              CounterButton(
                  notifier: deck.getRemovable("curse"),
                  command: ChangeCurseCommand.deck(deck, gameState: gameState),
                  maxValue: _kMaxBlessCurse,
                  image: "assets/images/abilities/curse.png",
                  showTotalValue: true,
                  color: Colors.white,
                  figureId: "unknown",
                  ownerId: "unknown",
                  scale: 1),
              if (hasIncarnate && !isCharacter)
                CounterButton(
                    notifier: deck.getRemovable("in-enfeeble"),
                    command: ChangeEnfeebleCommand.deck(deck, "in-enfeeble",
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/enfeeble_old.png",
                    extraImage: hasMoreThanOneEnfeeble
                        ? "assets/images/class-icons/Incarnate.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if ((isCharacter || name == "allies") && hasIncarnate)
                CounterButton(
                    notifier: deck.getRemovable("in-empower"),
                    command: ChangeEmpowerCommand.deck(deck, "in-empower",
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/empower_old.png",
                    extraImage: hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Incarnate.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if (name == "Ruinmaw")
                CounterButton(
                    notifier: deck.getRemovable("rm-empower"),
                    command: ChangeEmpowerCommand.deck(deck, "rm-empower",
                        gameState: gameState),
                    maxValue: _kMaxRuinmawEmpower,
                    image: "assets/images/abilities/empower_old.png",
                    extraImage: hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Ruinmaw.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if ((isCharacter || name == "allies") && hasVimthreader)
                CounterButton(
                    notifier: deck.getRemovable("vi-empower"),
                    command: ChangeEmpowerCommand.deck(deck, "vi-empower",
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/empower.png",
                    extraImage: hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Vimthreader.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if ((isCharacter || name == "allies") && hasVimthreader)
                CounterButton(
                    notifier: deck.getRemovable("vi-gr-empower"),
                    command: ChangeEmpowerCommand.deck(deck, "vi-gr-empower",
                        gameState: gameState),
                    maxValue: _kMaxVimthreaderGrEmpower,
                    image: "assets/images/abilities/greater-empower.png",
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if (!isCharacter && hasVimthreader)
                CounterButton(
                    notifier: deck.getRemovable("vi-enfeeble"),
                    command: ChangeEnfeebleCommand.deck(deck, "vi-enfeeble",
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/enfeeble.png",
                    extraImage: hasMoreThanOneEnfeeble
                        ? "assets/images/class-icons/Vimthreader.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if (!isCharacter && hasVimthreader)
                CounterButton(
                    notifier: deck.getRemovable("vi-gr-enfeeble"),
                    command: ChangeEnfeebleCommand.deck(deck, "vi-gr-enfeeble",
                        gameState: gameState),
                    maxValue: _kMaxVimthreaderGrEmpower,
                    image: "assets/images/abilities/greater-enfeeble.png",
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: 1),
              if ((!isCharacter || name == "Lifespeaker") && hasLifespeaker)
                CounterButton(
                    notifier: deck.getRemovable("li-enfeeble"),
                    command: ChangeEnfeebleCommand.deck(deck, "li-enfeeble",
                        gameState: gameState),
                    maxValue: _kMaxLifespeakerEnfeeble,
                    image: "assets/images/abilities/enfeeble.png",
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
                    openDialog(context, PerksMenu(character: character));
                  },
                  child: const Text("Perks"),
                ),
              const Text("   Reveal\n    cards:"),
              ...List.generate(
                min(drawPile.length + 1, _kMaxRevealButtonNr + 1),
                (i) => ModifierDeckRevealButton(
                    nrOfButtons: drawPile.length,
                    nr: i,
                    gameState: gameState,
                    name: name),
              ),
            ]));
  }
}
