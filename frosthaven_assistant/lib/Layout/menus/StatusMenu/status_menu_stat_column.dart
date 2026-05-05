import 'package:flutter/material.dart';

import '../../../Resource/app_constants.dart';
import '../../../Resource/commands/change_stat_commands/change_bless_command.dart';
import '../../../Resource/commands/change_stat_commands/change_curse_command.dart';
import '../../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../../Resource/commands/change_stat_commands/change_xp_command.dart';
import '../../../Resource/enums.dart';
import '../../../Resource/game_methods.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../counter_button.dart';
import '../SetLevelMenu/set_level_menu.dart';
import '../set_character_level_menu.dart';
import 'status_menu_stackable_condition_buttons.dart';

class StatusMenuStatColumn extends StatelessWidget {
  static const double _kTopSpacing = 2.0;
  static const int _kMaxXp = 900;
  static const int _kMaxBlessCurse = 10;
  static const int _kMaxPlague = 3;
  static const int _kMaxChill = 12;
  static const int _kMaxVimthreaderGrEmpower = 5;
  static const int _kMaxLifespeakerEnfeeble = 15;
  static const int _kMaxRuinmawEmpower = 12;

  const StatusMenuStatColumn({
    super.key,
    required this.figure,
    required this.scale,
    required this.isMonster,
    required this.isCharacter,
    required this.isSummon,
    required this.characterId,
    required this.monsterId,
    required this.immunities,
    required this.hasVimthreader,
    required this.hasLifespeaker,
    required this.hasIncarnate,
    required this.character,
    required this.hasPlagueHerald,
    required this.figureId,
    required this.ownerId,
    required this.monster,
    required this.showCustomContent,
    required this.gameState,
    required this.settings,
  });

  final FigureState figure;
  final double scale;
  final bool isMonster;
  final bool isCharacter;
  final bool isSummon;
  final String? characterId;
  final String? monsterId;
  final List<String> immunities;
  final bool hasVimthreader;
  final bool hasLifespeaker;
  final bool hasIncarnate;
  final Character? character;
  final bool hasPlagueHerald;
  final String figureId;
  final String ownerId;
  final Monster? monster;
  final bool showCustomContent;
  final GameState gameState;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          ModifierDeck deck = gameState.modifierDeck;
          if (isMonster) {
            for (final item in gameState.currentList) {
              if (item.id == monsterId) {
                if (item is Monster &&
                    item.isAlly &&
                    (gameState.allyDeckInOGGloom.value ||
                        !GameMethods.isOgGloomEdition())) {
                  deck = gameState.modifierDeckAllies;
                }
              }
            }
          }
          bool hasXp = false;
          bool isObjective = false;
          bool characterHasAmd = false;
          if (isCharacter && !isSummon) {
            hasXp = true;
            for (final item in gameState.currentList) {
              if (item.id == characterId && item is Character) {
                if (GameMethods.isObjectiveOrEscort(item.characterClass)) {
                  hasXp = false;
                  isObjective = true;
                } else {
                  characterHasAmd = item.characterClass.perks.isNotEmpty;
                  deck = item.characterState.modifierDeck;
                }
              }
            }
          }

          final cId = characterId;
          if (isSummon && cId != null) {
            deck = GameMethods.getModifierDeck(cId, gameState);
          }

          bool canBeCursed = true;
          for (final item in immunities) {
            if (item.substring(1, item.length - 1) == "curse") {
              canBeCursed = false;
            }
          }

          final bool showCharacterAmd = characterHasAmd &&
                  settings.showCharacterAMD.value &&
                  isCharacter ||
              isSummon;
          final bool showMonsterAmd = settings.showAmdDeck.value &&
              (isObjective || (isMonster && !isSummon));
          final bool showAmd = showCharacterAmd || showMonsterAmd;
          final isAlly = deck.name == "allies";

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
          final hasMoreThanOneEnfeeble = isMonster && nrOfEnfeebles > 1;
          final hasMoreThanOneEmpower =
              ((isCharacter || isAlly) && nrOfEmpowers > 1) ||
                  isCharacter && character?.id == "Ruinmaw" && nrOfEmpowers > 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CounterButton(
                  notifier: figure.health,
                  command: ChangeHealthCommand(0, figureId, ownerId,
                      gameState: gameState),
                  maxValue: figure.maxHealth.value,
                  image: "assets/images/abilities/heal.png",
                  showTotalValue: false,
                  color: Colors.red,
                  figureId: figureId,
                  ownerId: ownerId,
                  scale: scale),
              const SizedBox(height: _kTopSpacing),
              hasXp
                  ? CounterButton(
                      notifier: figure is CharacterState
                          ? (figure as CharacterState).xp
                          : ValueNotifier<int>(0),
                      command: ChangeXPCommand(0, figureId, ownerId,
                          gameState: gameState),
                      maxValue: _kMaxXp,
                      image: "assets/images/psd/xp.png",
                      showTotalValue: false,
                      color: Colors.blue,
                      figureId: figureId,
                      ownerId: ownerId,
                      scale: scale)
                  : Container(),
              SizedBox(height: hasXp ? _kTopSpacing : 0),
              SizedBox(
                  //todo? why this?
                  height: !showCharacterAmd || isSummon ? _kTopSpacing : 0),
              if (showAmd)
                CounterButton(
                    notifier: deck.getRemovable("bless"),
                    command: ChangeBlessCommand(0, figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/bless.png",
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              SizedBox(height: showCharacterAmd ? _kTopSpacing : 0),
              if ((canBeCursed && showMonsterAmd) || showCharacterAmd)
                CounterButton(
                    notifier: deck.getRemovable("curse"),
                    command: ChangeCurseCommand(0, figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/curse.png",
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (canBeCursed &&
                  showMonsterAmd &&
                  hasIncarnate &&
                  character == null)
                CounterButton(
                    notifier: deck.getRemovable("in-enfeeble"),
                    command: ChangeEnfeebleCommand(
                        0, "in-enfeeble", figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/enfeeble_old.png",
                    extraImage: hasMoreThanOneEnfeeble
                        ? "assets/images/class-icons/Incarnate.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (showAmd && (isCharacter || isAlly) && hasIncarnate)
                CounterButton(
                    notifier: deck.getRemovable("in-empower"),
                    command: ChangeEmpowerCommand(
                        0, "in-empower", figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/empower_old.png",
                    extraImage: hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Incarnate.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (showAmd &&
                  (characterId == "Ruinmaw" || monsterId == "Ruinmaw"))
                CounterButton(
                    notifier: deck.getRemovable("rm-empower"),
                    command: ChangeEmpowerCommand(
                        0, "rm-empower", figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxRuinmawEmpower,
                    image: "assets/images/abilities/empower_old.png",
                    extraImage: hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Ruinmaw.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (showAmd && (isCharacter || isAlly) && hasVimthreader)
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
                    scale: scale),
              if (showAmd && (isCharacter || isAlly) && hasVimthreader)
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
                    scale: scale),
              if (canBeCursed &&
                  showMonsterAmd &&
                  (!isCharacter || !isSummon) &&
                  hasVimthreader)
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
                    scale: scale),
              if (canBeCursed &&
                  showMonsterAmd &&
                  (!isCharacter || !isSummon) &&
                  hasVimthreader)
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
                    scale: scale),
              if (canBeCursed &&
                  (!isCharacter || characterId == "Lifespeaker") &&
                  hasLifespeaker)
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
                    scale: scale),
              if (hasPlagueHerald && isMonster)
                StatusMenuStackableConditionButtons(
                    notifier: figure.plague,
                    stackableCondition: Condition.plague,
                    maxValue: _kMaxPlague,
                    //technically you can have infinite, but realistically not so much
                    image: "assets/images/abilities/plague.png",
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale,
                    gameState: gameState),
              if (showCustomContent)
                StatusMenuStackableConditionButtons(
                    notifier: figure.chill,
                    stackableCondition: Condition.chill,
                    maxValue: _kMaxChill,
                    //technically you can have infinite, but realistically not so much
                    image: "assets/images/abilities/chill.png",
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale,
                    gameState: gameState),
              SizedBox(height: canBeCursed ? _kTopSpacing : 0),
              Row(
                children: [
                  SizedBox(
                    width: kConditionButtonSize * scale,
                    height: kConditionButtonSize * scale,
                    child: IconButton(
                      icon: Image.asset('assets/images/psd/skull.png'),
                      onPressed: () {
                        Navigator.pop(context);
                        gameState.action(ChangeHealthCommand(
                            -figure.health.value, figureId, ownerId,
                            gameState: gameState));
                      },
                    ),
                  ),
                  SizedBox(
                      width: kConditionButtonSize * scale,
                      height: kConditionButtonSize * scale,
                      child: IconButton(
                        icon: Image.asset(
                            colorBlendMode: BlendMode.multiply,
                            'assets/images/psd/level.png'),
                        onPressed: () {
                          final c = character;
                          if (figure is CharacterState && c != null) {
                            openDialog(
                              context,
                              SetCharacterLevelMenu(character: c),
                            );
                          } else {
                            openDialog(
                              context,
                              SetLevelMenu(
                                  monster: monster,
                                  figure: figure,
                                  characterId: characterId),
                            );
                          }
                        },
                      )),
                  if (!isObjective)
                    Text(figure.level.value.toString(),
                        style: TextStyle(
                            fontSize: kFontSizeSmall * scale,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(kShadowOffset * scale,
                                    kShadowOffset * scale),
                                color: Colors.black87,
                                blurRadius: kShadowOffset * scale,
                              )
                            ])),
                ],
              )
            ],
          );
        });
  }
}
