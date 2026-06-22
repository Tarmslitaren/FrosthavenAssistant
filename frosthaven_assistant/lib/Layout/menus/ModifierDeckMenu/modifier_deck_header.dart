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
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../counter_button.dart';
import '../../view_models/modifier_deck_header_view_model.dart';
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
  static const int _kMaxRevealButtonNr = 6;
  static const int _kMaxRevealButtonNrWithCassandra = 8;
  static const int _kPartyButtonCount = 4;
  static const int _kHailPerkIndex = 17;
  static const int _kCassandraPerkIndex = 15;

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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final vm = ModifierDeckHeaderViewModel(
      deck: deck,
      gameState: gameState,
      settings: settings,
      name: name,
    );

    final imbuement = deck.imbuement.value;
    final badOmen = deck.badOmen.value;
    final corrosiveSpew = deck.corrosiveSpew.value;
    final removedPile = deck.removedPileContents.toList();
    final drawPile = deck.drawPileContents.reversed.toList();
    final textStyle = kBodyBlackStyle;

    final maxRevealButtonNr = vm.hasCassandra
        ? _kMaxRevealButtonNrWithCassandra
        : _kMaxRevealButtonNr;

    return Container(
      width: screenWidth,
      margin: const EdgeInsets.all(_kHeaderMargin),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_kHeaderBorderRadius),
          topRight: Radius.circular(_kHeaderBorderRadius),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 0,
        spacing: 0,
        children: [
          if (vm.hasDiviner && !vm.isCharacter)
            if (badOmen == 0)
              TextButton(
                onPressed: () {
                  gameState.action(
                    BadOmenCommand(name == "allies", gameState: gameState),
                  );
                },
                child: Text(l10n.badOmen),
              ),
          if (badOmen > 0) Text(l10n.badOmensLeft(badOmen), style: textStyle),
          if (name == "Ruinmaw" && !corrosiveSpew)
            TextButton(
              onPressed: () {
                gameState.action(CorrosiveSpewCommand(gameState: gameState));
              },
              child: Text(l10n.corrosiveSpew),
            ),
          if (corrosiveSpew) Text(l10n.empowersOnTop, style: textStyle),
          TextButton(
            onPressed: () {
              gameState.action(
                AmdAddMinusOneCommand(name, gameState: gameState),
              );
            },
            child: Text(l10n.addMinusOneCard(deck.addedMinusOnes.value)),
          ),
          TextButton(
            onPressed: () {
              if (deck.hasMinus1()) {
                gameState.action(
                  AMDRemoveMinus1Command(name, gameState: gameState),
                );
              }
            },
            child: Text(l10n.removeMinusOneCard),
          ),
          if (!vm.isCharacter)
            TextButton(
              onPressed: () {
                gameState.action(
                  AMDRemoveMinus2Command(
                    name == "allies",
                    gameState: gameState,
                  ),
                );
              },
              child: Text(
                deck.hasMinus2() ? l10n.removeMinusTwoCard : l10n.minusTwoCardRemoved,
              ),
            ),
          if (vm.isCharacter && (vm.hasPlus0Card || deck.hasCard("plus0")))
            TextButton(
              onPressed: () {
                gameState.action(
                  AmdRemovePlus0Command(
                    name,
                    vm.hasPlus0Card,
                    gameState: gameState,
                  ),
                );
              },
              child: Text(
                vm.hasPlus0Card ? l10n.removePlusZeroCard : l10n.plusZeroCardRemoved,
              ),
            ),
          if (vm.monsterDeck)
            TextButton(
              onPressed: () {
                if (deck.imbuement.value > 0) {
                  gameState.action(AMDRemoveImbueCommand(gameState: gameState));
                } else {
                  gameState.action(AMDImbue1Command(gameState: gameState));
                }
              },
              child: Text(imbuement > 0 ? l10n.removeImbue : l10n.imbue),
            ),
          if (imbuement != _kAdvancedImbuementLevel && vm.monsterDeck)
            TextButton(
              onPressed: () {
                gameState.action(AMDImbue2Command(gameState: gameState));
              },
              child: Text(l10n.advancedImbue),
            ),
          if (name.isEmpty && vm.characterHail != null)
            TextButton(
              onPressed: () {
                gameState.action(AddPerkCommand("Hail", _kHailPerkIndex));
              },
              child: Text(
                vm.hasHailPerk ? l10n.removeHailPerk : l10n.addHailPerk,
              ),
            ),
          if (vm.characterCassandra != null && !settings.showCharacterAMD.value)
            TextButton(
              onPressed: () {
                gameState.action(
                  AddPerkCommand("Cassandra", _kCassandraPerkIndex),
                );
              },
              child: Text(
                vm.hasCassandraPerk
                    ? l10n.removeCassandraPerk
                    : l10n.addCassandraPerk,
              ),
            ),
          if (vm.hasCassandraPerk)
            TextButton(
              onPressed: () {
                gameState.action(
                  AMDCassandraSpecialCommand(
                    deck.name,
                    !deck.cassandraSpecial.value,
                    gameState: gameState,
                  ),
                );
              },
              child: Text(
                deck.cassandraSpecial.value
                    ? l10n.dontSaveRevealedCards
                    : l10n.saveRevealedCards,
              ),
            ),
          if (removedPile.isNotEmpty)
            TextButton(
              onPressed: () {
                openDialog(context, RemovedModifierCardMenu(name: name));
              },
              child: Text(l10n.removedCountLabel(removedPile.length)),
            ),
          if (vm.isCSCampaign && vm.isCharacter)
            TextButton(
              onPressed: () {
                vm.donatedCS
                    ? gameState.action(
                        RemoveCSSanctuaryDonationCommand(
                          name,
                          gameState: gameState,
                        ),
                      )
                    : gameState.action(
                        DonateCSSanctuaryCommand(name, gameState: gameState),
                      );
              },
              child: Text(
                vm.donatedCS ? l10n.removeDonation : l10n.donateSanctuary,
              ),
            ),
          if (vm.isCSCampaign && vm.isCharacter)
            vm.addedPartyCard
                ? TextButton(
                    onPressed: () {
                      gameState.action(
                        RemoveCSPartyCardCommand(name, gameState: gameState),
                      );
                    },
                    child: Text(l10n.removePartyCard),
                  )
                : Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.addPartyCard),
                      ...List.generate(
                        _kPartyButtonCount,
                        (i) => ModifierDeckPartyButton(
                          nr: i + 1,
                          gameState: gameState,
                          name: name,
                        ),
                      ),
                    ],
                  ),
          if (vm.isCharacter && gameState.unlockedClasses.contains("Demons"))
            IconButton(
              icon: Image.asset("assets/images/demons.png"),
              onPressed: () {
                openDialog(
                  context,
                  GH2eFactionAMDCardMenu(faction: "Demons", name: name),
                );
              },
            ),
          if (vm.isCharacter &&
              gameState.unlockedClasses.contains("Merchant-Guild"))
            IconButton(
              icon: Image.asset("assets/images/merchant-guild.png"),
              onPressed: () {
                openDialog(
                  context,
                  GH2eFactionAMDCardMenu(faction: "Merchant-Guild", name: name),
                );
              },
            ),
          if (vm.isCharacter && gameState.unlockedClasses.contains("Military"))
            IconButton(
              icon: Image.asset("assets/images/military.png"),
              onPressed: () {
                openDialog(
                  context,
                  GH2eFactionAMDCardMenu(faction: "Military", name: name),
                );
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
            scale: 1,
          ),
          CounterButton(
            notifier: deck.getRemovable("curse"),
            command: ChangeCurseCommand.deck(deck, gameState: gameState),
            maxValue: _kMaxBlessCurse,
            image: "assets/images/abilities/curse.png",
            showTotalValue: true,
            color: Colors.white,
            figureId: "unknown",
            ownerId: "unknown",
            scale: 1,
          ),
          if (vm.hasIncarnate && !vm.isCharacter)
            CounterButton(
              notifier: deck.getRemovable("in-enfeeble"),
              command: ChangeEnfeebleCommand.deck(
                deck,
                "in-enfeeble",
                gameState: gameState,
              ),
              maxValue: _kMaxBlessCurse,
              image: "assets/images/abilities/enfeeble_old.png",
              extraImage: vm.hasMoreThanOneEnfeeble
                  ? "assets/images/class-icons/Incarnate.png"
                  : null,
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if ((vm.isCharacter || name == "allies") && vm.hasIncarnate)
            CounterButton(
              notifier: deck.getRemovable("in-empower"),
              command: ChangeEmpowerCommand.deck(
                deck,
                "in-empower",
                gameState: gameState,
              ),
              maxValue: _kMaxBlessCurse,
              image: "assets/images/abilities/empower_old.png",
              extraImage: vm.hasMoreThanOneEmpower
                  ? "assets/images/class-icons/Incarnate.png"
                  : null,
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if (name == "Ruinmaw")
            CounterButton(
              notifier: deck.getRemovable("rm-empower"),
              command: ChangeEmpowerCommand.deck(
                deck,
                "rm-empower",
                gameState: gameState,
              ),
              maxValue: _kMaxRuinmawEmpower,
              image: "assets/images/abilities/empower_old.png",
              extraImage: vm.hasMoreThanOneEmpower
                  ? "assets/images/class-icons/Ruinmaw.png"
                  : null,
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if ((vm.isCharacter || name == "allies") && vm.hasVimthreader)
            CounterButton(
              notifier: deck.getRemovable("vi-empower"),
              command: ChangeEmpowerCommand.deck(
                deck,
                "vi-empower",
                gameState: gameState,
              ),
              maxValue: _kMaxBlessCurse,
              image: "assets/images/abilities/empower.png",
              extraImage: vm.hasMoreThanOneEmpower
                  ? "assets/images/class-icons/Vimthreader.png"
                  : null,
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if ((vm.isCharacter || name == "allies") && vm.hasVimthreader)
            CounterButton(
              notifier: deck.getRemovable("vi-gr-empower"),
              command: ChangeEmpowerCommand.deck(
                deck,
                "vi-gr-empower",
                gameState: gameState,
              ),
              maxValue: _kMaxVimthreaderGrEmpower,
              image: "assets/images/abilities/greater-empower.png",
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if (!vm.isCharacter && vm.hasVimthreader)
            CounterButton(
              notifier: deck.getRemovable("vi-enfeeble"),
              command: ChangeEnfeebleCommand.deck(
                deck,
                "vi-enfeeble",
                gameState: gameState,
              ),
              maxValue: _kMaxBlessCurse,
              image: "assets/images/abilities/enfeeble.png",
              extraImage: vm.hasMoreThanOneEnfeeble
                  ? "assets/images/class-icons/Vimthreader.png"
                  : null,
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if (!vm.isCharacter && vm.hasVimthreader)
            CounterButton(
              notifier: deck.getRemovable("vi-gr-enfeeble"),
              command: ChangeEnfeebleCommand.deck(
                deck,
                "vi-gr-enfeeble",
                gameState: gameState,
              ),
              maxValue: _kMaxVimthreaderGrEmpower,
              image: "assets/images/abilities/greater-enfeeble.png",
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if ((!vm.isCharacter || name == "Lifespeaker") && vm.hasLifespeaker)
            CounterButton(
              notifier: deck.getRemovable("li-enfeeble"),
              command: ChangeEnfeebleCommand.deck(
                deck,
                "li-enfeeble",
                gameState: gameState,
              ),
              maxValue: _kMaxLifespeakerEnfeeble,
              image: "assets/images/abilities/enfeeble.png",
              extraImage: vm.hasMoreThanOneEnfeeble
                  ? "assets/images/class-icons/Lifespeaker.png"
                  : null,
              showTotalValue: true,
              color: Colors.white,
              figureId: "unknown",
              ownerId: "unknown",
              scale: 1,
            ),
          if (vm.isCharacter &&
              vm.character != null &&
              vm.character!.characterClass.perks.isNotEmpty)
            TextButton(
              onPressed: () {
                openDialog(context, PerksMenu(character: vm.character!));
              },
              child: Text(l10n.perks),
            ),
          Text(l10n.revealCards),
          ...List.generate(
            min(drawPile.length + 1, maxRevealButtonNr + 1),
            (i) => ModifierDeckRevealButton(
              nrOfButtons: drawPile.length,
              nr: i,
              gameState: gameState,
              name: name,
            ),
          ),
        ],
      ),
    );
  }
}
