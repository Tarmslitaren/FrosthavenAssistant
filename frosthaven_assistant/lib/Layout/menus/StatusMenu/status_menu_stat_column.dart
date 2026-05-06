import 'package:flutter/material.dart';

import '../../../Resource/app_constants.dart';
import '../../../Resource/commands/change_stat_commands/change_bless_command.dart';
import '../../../Resource/commands/change_stat_commands/change_curse_command.dart';
import '../../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../../Resource/commands/change_stat_commands/change_xp_command.dart';
import '../../../Resource/enums.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../counter_button.dart';
import '../../view_models/status_menu_stat_column_view_model.dart';
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
          final vm = StatusMenuStatColumnViewModel(
            figure: figure,
            isMonster: isMonster,
            isCharacter: isCharacter,
            isSummon: isSummon,
            characterId: characterId,
            monsterId: monsterId,
            immunities: immunities,
            hasVimthreader: hasVimthreader,
            hasLifespeaker: hasLifespeaker,
            hasIncarnate: hasIncarnate,
            character: character,
            gameState: gameState,
            settings: settings,
          );

          final deck = vm.deck;

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
              vm.hasXp
                  ? CounterButton(
                      notifier: vm.xpNotifier,
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
              SizedBox(height: vm.hasXp ? _kTopSpacing : 0),
              SizedBox(
                  height: !vm.showCharacterAmd || isSummon ? _kTopSpacing : 0),
              if (vm.showAmd)
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
              SizedBox(height: vm.showCharacterAmd ? _kTopSpacing : 0),
              if ((vm.canBeCursed && vm.showMonsterAmd) || vm.showCharacterAmd)
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
              if (vm.canBeCursed &&
                  vm.showMonsterAmd &&
                  hasIncarnate &&
                  character == null)
                CounterButton(
                    notifier: deck.getRemovable("in-enfeeble"),
                    command: ChangeEnfeebleCommand(
                        0, "in-enfeeble", figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/enfeeble_old.png",
                    extraImage: vm.hasMoreThanOneEnfeeble
                        ? "assets/images/class-icons/Incarnate.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (vm.showAmd && (isCharacter || vm.isAlly) && hasIncarnate)
                CounterButton(
                    notifier: deck.getRemovable("in-empower"),
                    command: ChangeEmpowerCommand(
                        0, "in-empower", figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/empower_old.png",
                    extraImage: vm.hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Incarnate.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (vm.showAmd &&
                  (characterId == "Ruinmaw" || monsterId == "Ruinmaw"))
                CounterButton(
                    notifier: deck.getRemovable("rm-empower"),
                    command: ChangeEmpowerCommand(
                        0, "rm-empower", figureId, ownerId,
                        gameState: gameState),
                    maxValue: _kMaxRuinmawEmpower,
                    image: "assets/images/abilities/empower_old.png",
                    extraImage: vm.hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Ruinmaw.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale),
              if (vm.showAmd && (isCharacter || vm.isAlly) && hasVimthreader)
                CounterButton(
                    notifier: deck.getRemovable("vi-empower"),
                    command: ChangeEmpowerCommand.deck(deck, "vi-empower",
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/empower.png",
                    extraImage: vm.hasMoreThanOneEmpower
                        ? "assets/images/class-icons/Vimthreader.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: scale),
              if (vm.showAmd && (isCharacter || vm.isAlly) && hasVimthreader)
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
              if (vm.canBeCursed &&
                  vm.showMonsterAmd &&
                  (!isCharacter || !isSummon) &&
                  hasVimthreader)
                CounterButton(
                    notifier: deck.getRemovable("vi-enfeeble"),
                    command: ChangeEnfeebleCommand.deck(deck, "vi-enfeeble",
                        gameState: gameState),
                    maxValue: _kMaxBlessCurse,
                    image: "assets/images/abilities/enfeeble.png",
                    extraImage: vm.hasMoreThanOneEnfeeble
                        ? "assets/images/class-icons/Vimthreader.png"
                        : null,
                    showTotalValue: true,
                    color: Colors.white,
                    figureId: "unknown",
                    ownerId: "unknown",
                    scale: scale),
              if (vm.canBeCursed &&
                  vm.showMonsterAmd &&
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
              if (vm.canBeCursed &&
                  (!isCharacter || characterId == "Lifespeaker") &&
                  hasLifespeaker)
                CounterButton(
                    notifier: deck.getRemovable("li-enfeeble"),
                    command: ChangeEnfeebleCommand.deck(deck, "li-enfeeble",
                        gameState: gameState),
                    maxValue: _kMaxLifespeakerEnfeeble,
                    image: "assets/images/abilities/enfeeble.png",
                    extraImage: vm.hasMoreThanOneEnfeeble
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
                    image: "assets/images/abilities/chill.png",
                    figureId: figureId,
                    ownerId: ownerId,
                    scale: scale,
                    gameState: gameState),
              SizedBox(height: vm.canBeCursed ? _kTopSpacing : 0),
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
                  if (!vm.isObjective)
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
