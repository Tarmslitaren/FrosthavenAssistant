import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
import 'package:frosthaven_assistant/Layout/menus/condition_button.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../Resource/commands/ice_wraith_change_form_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/commands/set_as_summon_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

class StatusMenu extends StatefulWidget {
  static const double _kButtonSize = 40.0;
  static const double _kIconSize = 30.0;
  static const double _kActionButtonSize = 42.0;
  static const double _kSummonIconSize = 24.0;
  static const double _kSummonBorderRadius = 30.0;
  static const double _kSummonMargin = 1.0;
  static const double _kSummonPaddingRight = 20.0;
  static const double _kHeaderHeight = 28.0;
  static const double _kConditionIconSize = 24.0;
  static const double _kConditionMarginTop = 2.0;
  static const double _kConditionMarginRight = 2.0;
  static const double _kMonsterBoxScale = 0.9;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;
  static const double _kTextHeight = 0.5;
  static const double _kTopSpacing = 2.0;
  static const int _kMaxXp = 900;
  static const int _kMaxBlessCurse = 10;
  static const int _kMaxPlague = 3;
  static const int _kMaxChill = 12;
  static const int _kChar2Min = 1;
  static const int _kChar3Min = 2;
  static const int _kChar4Min = 3;
  static const double _kMenuWidth = 340.0;
  static const int _kMaxVimthreaderGrEmpower = 5;
  static const int _kMaxLifespeakerEnfeeble = 15;
  static const int _kMaxRuinmawEmpower = 12;

  const StatusMenu(
      {super.key,
      required this.figureId,
      this.characterId,
      this.monsterId,
      this.gameState,
      this.settings});

  final String figureId;
  final String? monsterId;
  final String? characterId;

  //conditions always:
  //stun,
  //immobilize,
  //disarm,
  //wound,
  //muddle,
  //poison,
  //bane,
  //brittle,
  //strengthen,
  //invisible,
  //regenerate,
  //ward;

  //rupture

  //only monsters:

  //only certain character:
  //poison3,
  //poison4,
  //wound2,

  //poison2,

  //dodge (only character's and 'allies' so basically everyone.

  //only characters;
  //chill, ((only certain scenarios/monsters)
  //infect,((only certain scenarios/monsters)
  //impair

  //character:
  // sliders: hp, xp, chill: normal
  //monster:
  // sliders: hp bless, curse: normal

  //monster layout:
  //stun immobilize  disarm  wound
  //muddle poison bane brittle
  //variable: rupture poison 2 OR  rupture, wound2, poison 2-4
  //strengthen invisible regenerate ward

  //character layout
  //same except line 3: infect impair rupture

  final GameState? gameState;
  final Settings? settings;

  @override
  StatusMenuState createState() => StatusMenuState();
}

class StatusMenuState extends State<StatusMenu> {
  late final GameState _gameState;
  late final Settings _settings;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
  }


  Widget buildStackableConditionButtons(
      ValueListenable<int> notifier,
      Condition stackableCondition,
      int maxValue,
      String image,
      String figureId,
      String? ownerId,
      double scale) {
    return Row(children: [
      SizedBox(
          width: StatusMenu._kButtonSize * scale,
          height: StatusMenu._kButtonSize * scale,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
              onPressed: () {
                if (notifier.value > 0) {
                  _gameState.action(RemoveConditionCommand(
                      stackableCondition, figureId, ownerId,
                      gameState: _gameState));
                }
                //increment
              })),
      Stack(children: [
        SizedBox(
          width: StatusMenu._kIconSize * scale,
          height: StatusMenu._kIconSize * scale,
          child: Image(
            image: AssetImage(image),
          ),
        ),
        ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (context, value, child) {
              String text = notifier.value.toString();
              if (notifier.value == 0) {
                text = "";
              }
              return Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(text,
                      style: TextStyle(
                          color: Colors.white,
                          height: StatusMenu._kTextHeight,
                          fontSize: kFontSizeBody * scale,
                          shadows: [
                            Shadow(
                              offset: Offset(StatusMenu._kShadowOffset * scale,
                                  StatusMenu._kShadowOffset * scale),
                              color: Colors.black87,
                              blurRadius: StatusMenu._kShadowBlur * scale,
                            )
                          ])));
            })
      ]),
      SizedBox(
          width: StatusMenu._kButtonSize * scale,
          height: StatusMenu._kButtonSize * scale,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
            onPressed: () {
              if (notifier.value < maxValue) {
                _gameState.action(AddConditionCommand(
                    stackableCondition, figureId, ownerId,
                    gameState: _gameState));
              }
              //increment
            },
          )),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    bool showCustomContent = _settings.showCustomContent.value;
    bool hasMireFoot = false;
    bool hasIncarnate = false;
    bool hasVimthreader = false;
    bool hasLifespeaker = false;
    bool hasPlagueHerald = false;
    bool isSummon = (widget.monsterId == null &&
        widget.characterId !=
            widget
                .figureId); //hack - should have monsterBox send summon data instead
    for (var item in _gameState.currentList) {
      if (item.id == "Mirefoot" && showCustomContent) {
        hasMireFoot = true;
      }
      if (item is Character &&
          item.id == "Plagueherald" &&
          item.characterClass.edition == "Gloomhaven 2nd Edition") {
        hasPlagueHerald = true;
      }
      if (item.id == "Incarnate" && showCustomContent) {
        hasIncarnate = true;
      }
      if (item.id == "Vimthreader" && showCustomContent) {
        hasVimthreader = true;
      }
      if (item.id == "Lifespeaker" && showCustomContent) {
        hasLifespeaker = true;
      }
    }

    String name = "";
    String? ownerId = "";
    if (widget.monsterId != null) {
      name = widget.monsterId!; //this is no good
      ownerId = widget.monsterId;
    } else if (widget.characterId != null) {
      name = widget.characterId!; //now this is no good either...
      ownerId = name;
    }

    String figureId = widget.figureId;
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null) {
      //close menu here, since nothing will be valid
      Navigator.pop(context);

      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    List<String> immunities = [];
    Monster? monster;
    bool isIceWraith = false;
    bool isElite = false;
    bool hasShield = false;
    bool hasRetaliate = false;
    if (figure is MonsterInstance) {
      name = (figure).name;

      if (widget.monsterId != null) {
        monster = _gameState.currentList
                .firstWhereOrNull((item) => item.id == widget.monsterId)
            as Monster?;
        if (monster != null) {
          name = "${monster.type.display} ${figure.standeeNr.toString()}";
          if (monster.type.deck == "Ice Wraith") {
            isIceWraith = true;
          }
          hasShield = GameMethods.hasShield(monster, figure);
          hasRetaliate = GameMethods.hasRetaliate(monster, figure);
          final monsterData = monster.type.levels[monster.level.value];

          if (figure.type == MonsterType.normal) {
            immunities = monsterData.normal!.immunities;
          } else if (figure.type == MonsterType.elite) {
            immunities = monsterData.elite!.immunities;
            isElite = true;
          } else if (figure.type == MonsterType.boss) {
            immunities = monsterData.boss!.immunities;
          }
        }
      }
    }
    //has to be summon

    //get id and owner Id
    final characterMatch = _gameState.currentList
        .firstWhereOrNull((item) => item.id == widget.characterId);
    Character? character = characterMatch is Character ? characterMatch : null;
    if (figure is CharacterState && character != null) {
      name = character.characterClass.name;
    }

    double scale = getModalMenuScale(context);

    int nrOfCharacters = GameMethods.getCurrentCharacterAmount();

    final ListItemData? owner =
        _gameState.currentList.firstWhereOrNull((item) => item.id == ownerId);
    if (owner == null) {
      Navigator.pop(context);
      return const SizedBox(height: 0, width: 0);
    }
    final bool isMonster = widget.monsterId != null;
    final bool isCharacter = widget.characterId != null;
    return Wrap(children: [
      ModalBackground(
          width: StatusMenu._kMenuWidth * scale,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                height: StatusMenu._kHeaderHeight * scale,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(name,
                          style: getTitleTextStyle(getModalMenuScale(context))),
                      if (figure is MonsterInstance)
                        ValueListenableBuilder<int>(
                            valueListenable: _gameState.updateList,
                            builder: (context, value, child) {
                              //handle case when health is changed to zero: don't instantiate monster box
                              if (GameMethods.getFigure(ownerId, figureId) ==
                                  null) {
                                //todo: should somehow pop context in case dead by health wheel
                                return Container();
                              }

                              return Row(children: [
                                if (hasShield)
                                  Container(
                                      height: StatusMenu._kHeaderHeight * scale,
                                      margin: EdgeInsets.only(
                                          top: StatusMenu._kConditionMarginTop *
                                              scale,
                                          right: StatusMenu
                                                  ._kConditionMarginRight *
                                              scale),
                                      child: ConditionIcon(
                                        Condition.shield,
                                        StatusMenu._kConditionIconSize * scale,
                                        owner,
                                        figure,
                                        scale: scale,
                                      )),
                                if (hasRetaliate)
                                  Container(
                                      height: StatusMenu._kHeaderHeight * scale,
                                      margin: EdgeInsets.only(
                                          top: StatusMenu._kConditionMarginTop *
                                              scale,
                                          right: StatusMenu
                                                  ._kConditionMarginRight *
                                              scale),
                                      child: ConditionIcon(
                                        Condition.retaliate,
                                        StatusMenu._kConditionIconSize * scale,
                                        owner,
                                        figure,
                                        scale: scale,
                                      )),
                                Container(
                                    height: StatusMenu._kHeaderHeight * scale,
                                    margin: EdgeInsets.only(
                                        top: StatusMenu._kConditionMarginTop *
                                            scale),
                                    child: MonsterBox(
                                        figureId: figureId,
                                        ownerId: ownerId,
                                        displayStartAnimation: "",
                                        blockInput: true,
                                        scale: scale *
                                            StatusMenu._kMonsterBoxScale))
                              ]);
                            }),
                      if (isIceWraith)
                        TextButton(
                            clipBehavior: Clip.hardEdge,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                  right:
                                      StatusMenu._kSummonPaddingRight * scale),
                            ),
                            onPressed: () {
                              setState(() {
                                _gameState.action(IceWraithChangeFormCommand(
                                    isElite, ownerId, figureId,
                                    gameState: _gameState));
                              });
                            },
                            child: Text("                     Switch Form",
                                style: TextStyle(
                                  fontSize: kFontSizeSmall * scale,
                                  color: Colors.blue,
                                )))
                    ])),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ValueListenableBuilder<int>(
                  valueListenable: _gameState.commandIndex,
                  builder: (context, value, child) {
                    ModifierDeck deck = _gameState.modifierDeck;
                    if (isMonster) {
                      for (var item in _gameState.currentList) {
                        if (item.id == widget.monsterId) {
                          if (item is Monster &&
                              item.isAlly &&
                              (_gameState.allyDeckInOGGloom.value ||
                                  !GameMethods.isOgGloomEdition())) {
                            deck = _gameState.modifierDeckAllies;
                          }
                        }
                      }
                    }
                    bool hasXp = false;
                    bool isObjective = false;
                    bool characterHasAmd = false;
                    if (isCharacter && !isSummon) {
                      hasXp = true;

                      for (var item in _gameState.currentList) {
                        if (item.id == widget.characterId &&
                            item is Character) {
                          if (GameMethods.isObjectiveOrEscort(
                              item.characterClass)) {
                            hasXp = false;
                            isObjective = true;
                          } else {
                            characterHasAmd =
                                item.characterClass.perks.isNotEmpty;
                            deck = item.characterState.modifierDeck;
                          }
                        }
                      }
                    }

                    if (isSummon) {
                      deck = GameMethods.getModifierDeck(
                          widget.characterId!, _gameState);
                    }

                    bool canBeCursed = true;
                    for (var item in immunities) {
                      if (item.substring(1, item.length - 1) == "curse") {
                        canBeCursed = false;
                      }
                    }

                    final bool showCharacterAmd = characterHasAmd &&
                            _settings.showCharacterAMD.value &&
                            isCharacter ||
                        isSummon;
                    final bool showMonsterAmd = _settings.showAmdDeck.value &&
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
                    final hasMoreThanOneEnfeeble =
                        isMonster && nrOfEnfeebles > 1;
                    final hasMoreThanOneEmpower =
                        ((isCharacter || isAlly) && nrOfEmpowers > 1) ||
                            isCharacter &&
                                character?.id == "Ruinmaw" &&
                                nrOfEmpowers > 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CounterButton(
                            notifier: figure.health,
                            command: ChangeHealthCommand(0, figureId, ownerId,
                                gameState: _gameState),
                            maxValue: figure.maxHealth.value,
                            image: "assets/images/abilities/heal.png",
                            showTotalValue: false,
                            color: Colors.red,
                            figureId: figureId,
                            ownerId: ownerId,
                            scale: scale),
                        const SizedBox(height: StatusMenu._kTopSpacing),
                        hasXp
                            ? CounterButton(
                                notifier: figure is CharacterState
                                    ? figure.xp
                                    : ValueNotifier<int>(0),
                                command: ChangeXPCommand(0, figureId, ownerId,
                                    gameState: _gameState),
                                maxValue: StatusMenu._kMaxXp,
                                image: "assets/images/psd/xp.png",
                                showTotalValue: false,
                                color: Colors.blue,
                                figureId: figureId,
                                ownerId: ownerId,
                                scale: scale)
                            : Container(),
                        SizedBox(height: hasXp ? StatusMenu._kTopSpacing : 0),
                        SizedBox(
                            //todo? why this?
                            height: !showCharacterAmd || isSummon
                                ? StatusMenu._kTopSpacing
                                : 0),
                        if (showAmd)
                          CounterButton(
                              notifier: deck.getRemovable("bless"),
                              command: ChangeBlessCommand(0, figureId, ownerId,
                                  gameState: _gameState),
                              maxValue: StatusMenu._kMaxBlessCurse,
                              image: "assets/images/abilities/bless.png",
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale),
                        SizedBox(
                            height:
                                showCharacterAmd ? StatusMenu._kTopSpacing : 0),
                        if ((canBeCursed && showMonsterAmd) || showCharacterAmd)
                          CounterButton(
                              notifier: deck.getRemovable("curse"),
                              command: ChangeCurseCommand(0, figureId, ownerId,
                                  gameState: _gameState),
                              maxValue: StatusMenu._kMaxBlessCurse,
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
                                  gameState: _gameState),
                              maxValue: StatusMenu._kMaxBlessCurse,
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
                                  gameState: _gameState),
                              maxValue: StatusMenu._kMaxBlessCurse,
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
                            (widget.characterId == "Ruinmaw" ||
                                widget.monsterId == "Ruinmaw"))
                          CounterButton(
                              notifier: deck.getRemovable("rm-empower"),
                              command: ChangeEmpowerCommand(
                                  0, "rm-empower", figureId, ownerId,
                                  gameState: _gameState),
                              maxValue: StatusMenu._kMaxRuinmawEmpower,
                              image: "assets/images/abilities/empower_old.png",
                              extraImage: hasMoreThanOneEmpower
                                  ? "assets/images/class-icons/Ruinmaw.png"
                                  : null,
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale),
                        if (showAmd &&
                            (isCharacter || isAlly) &&
                            hasVimthreader)
                          CounterButton(
                              notifier: deck.getRemovable("vi-empower"),
                              command: ChangeEmpowerCommand.deck(
                                  deck, "vi-empower", gameState: _gameState),
                              maxValue: StatusMenu._kMaxBlessCurse,
                              image: "assets/images/abilities/empower.png",
                              extraImage: hasMoreThanOneEmpower
                                  ? "assets/images/class-icons/Vimthreader.png"
                                  : null,
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: "unknown",
                              ownerId: "unknown",
                              scale: scale),
                        if (showAmd &&
                            (isCharacter || isAlly) &&
                            hasVimthreader)
                          CounterButton(
                              notifier: deck.getRemovable("vi-gr-empower"),
                              command: ChangeEmpowerCommand.deck(
                                  deck, "vi-gr-empower", gameState: _gameState),
                              maxValue: StatusMenu._kMaxVimthreaderGrEmpower,
                              image:
                                  "assets/images/abilities/greater-empower.png",
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
                              command: ChangeEnfeebleCommand.deck(
                                  deck, "vi-enfeeble", gameState: _gameState),
                              maxValue: StatusMenu._kMaxBlessCurse,
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
                              command: ChangeEnfeebleCommand.deck(
                                  deck, "vi-gr-enfeeble",
                                  gameState: _gameState),
                              maxValue: StatusMenu._kMaxVimthreaderGrEmpower,
                              image:
                                  "assets/images/abilities/greater-enfeeble.png",
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: "unknown",
                              ownerId: "unknown",
                              scale: scale),
                        if (canBeCursed &&
                            (!isCharacter ||
                                widget.characterId == "Lifespeaker") &&
                            hasLifespeaker)
                          CounterButton(
                              notifier: deck.getRemovable("li-enfeeble"),
                              command: ChangeEnfeebleCommand.deck(
                                  deck, "li-enfeeble", gameState: _gameState),
                              maxValue: StatusMenu._kMaxLifespeakerEnfeeble,
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
                          buildStackableConditionButtons( // ignore: avoid-returning-widgets, tightly-coupled state helper
                              figure.plague,
                              Condition.plague,
                              StatusMenu._kMaxPlague,
                              //technically you can have infinite, but realistically not so much
                              "assets/images/abilities/plague.png",
                              figureId,
                              ownerId,
                              scale),
                        if (showCustomContent)
                          buildStackableConditionButtons( // ignore: avoid-returning-widgets, tightly-coupled state helper
                              figure.chill,
                              Condition.chill,
                              StatusMenu._kMaxChill,
                              //technically you can have infinite, but realistically not so much
                              "assets/images/abilities/chill.png",
                              figureId,
                              ownerId,
                              scale),
                        SizedBox(
                            height: canBeCursed ? StatusMenu._kTopSpacing : 0),
                        Row(
                          children: [
                            SizedBox(
                              width: StatusMenu._kActionButtonSize * scale,
                              height: StatusMenu._kActionButtonSize * scale,
                              child: IconButton(
                                icon:
                                    Image.asset('assets/images/psd/skull.png'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _gameState.action(ChangeHealthCommand(
                                      -figure.health.value, figureId, ownerId,
                                      gameState: _gameState));
                                },
                              ),
                            ),
                            SizedBox(
                                width: StatusMenu._kActionButtonSize * scale,
                                height: StatusMenu._kActionButtonSize * scale,
                                child: IconButton(
                                  icon: Image.asset(
                                      colorBlendMode: BlendMode.multiply,
                                      'assets/images/psd/level.png'),
                                  onPressed: () {
                                    if (figure is CharacterState) {
                                      openDialog(
                                        context,
                                        SetCharacterLevelMenu(
                                            character: character!),
                                      );
                                    } else {
                                      openDialog(
                                        context,
                                        SetLevelMenu(
                                            monster: monster,
                                            figure: figure,
                                            characterId: widget.characterId),
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
                                          offset: Offset(
                                              StatusMenu._kShadowOffset * scale,
                                              StatusMenu._kShadowOffset *
                                                  scale),
                                          color: Colors.black87,
                                          blurRadius:
                                              StatusMenu._kShadowBlur * scale,
                                        )
                                      ])),
                          ],
                        )
                      ],
                    );
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: StatusMenu._kTopSpacing * scale,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConditionButton(
                          condition: Condition.stun,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.immobilize,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.disarm,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.wound,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConditionButton(
                          condition: Condition.muddle,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.poison,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.bane,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.brittle,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.safeguard,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                    ],
                  ),
                  _ExtraConditionRow(
                      isCharacter: isCharacter,
                      isSummon: isSummon,
                      hasMireFoot: hasMireFoot,
                      showCustomContent: showCustomContent,
                      figureId: figureId,
                      ownerId: ownerId,
                      immunities: immunities,
                      scale: scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConditionButton(
                          condition: Condition.strengthen,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.invisible,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.regenerate,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      ConditionButton(
                          condition: Condition.ward,
                          figureId: figureId,
                          ownerId: ownerId,
                          immunities: immunities,
                          scale: scale),
                      if (showCustomContent)
                        ConditionButton(
                            condition: Condition.dodge,
                            figureId: figureId,
                            ownerId: ownerId,
                            immunities: immunities,
                            scale: scale),
                    ],
                  ),
                  if (isMonster)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (nrOfCharacters > 0)
                          ConditionButton(
                              condition: Condition.character1,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        if (nrOfCharacters > StatusMenu._kChar2Min)
                          ConditionButton(
                              condition: Condition.character2,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        if (nrOfCharacters > StatusMenu._kChar3Min)
                          ConditionButton(
                              condition: Condition.character3,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        if (nrOfCharacters > StatusMenu._kChar4Min)
                          ConditionButton(
                              condition: Condition.character4,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        _SummonButton(figureId: figureId, ownerId: ownerId, scale: scale, gameState: _gameState, settings: _settings)
                      ],
                    ),
                ],
              ),
            ])
          ]))
    ]);
  }
}

class _ExtraConditionRow extends StatelessWidget {
  const _ExtraConditionRow({
    required this.isCharacter,
    required this.isSummon,
    required this.hasMireFoot,
    required this.showCustomContent,
    required this.figureId,
    required this.ownerId,
    required this.immunities,
    required this.scale,
  });

  final bool isCharacter;
  final bool isSummon;
  final bool hasMireFoot;
  final bool showCustomContent;
  final String figureId;
  final String? ownerId;
  final List<String> immunities;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isCharacter || isSummon) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (showCustomContent)
          ConditionButton(
              condition: Condition.infect,
              figureId: figureId,
              ownerId: ownerId,
              immunities: immunities,
              scale: scale),
        if (!isSummon)
          ConditionButton(
              condition: Condition.impair,
              figureId: figureId,
              ownerId: ownerId,
              immunities: immunities,
              scale: scale),
        if (showCustomContent)
          ConditionButton(
              condition: Condition.rupture,
              figureId: figureId,
              ownerId: ownerId,
              immunities: immunities,
              scale: scale),
      ]);
    }
    if (!hasMireFoot) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (showCustomContent)
          ConditionButton(
              condition: Condition.poison2,
              figureId: figureId,
              ownerId: ownerId,
              immunities: immunities,
              scale: scale),
        if (showCustomContent)
          ConditionButton(
              condition: Condition.rupture,
              figureId: figureId,
              ownerId: ownerId,
              immunities: immunities,
              scale: scale),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ConditionButton(
          condition: Condition.wound2,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: scale),
      ConditionButton(
          condition: Condition.poison2,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: scale),
      ConditionButton(
          condition: Condition.poison3,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: scale),
      ConditionButton(
          condition: Condition.poison4,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: scale),
      ConditionButton(
          condition: Condition.rupture,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: scale),
    ]);
  }
}

class _SummonButton extends StatelessWidget {
  const _SummonButton({
    required this.figureId,
    required this.ownerId,
    required this.scale,
    required this.gameState,
    required this.settings,
  });

  final String figureId;
  final String? ownerId;
  final double scale;
  final GameState gameState;
  final Settings settings;

  static const String _kImagePath = "assets/images/summon/green.png";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          Color color = Colors.transparent;
          FigureState? figure = GameMethods.getFigure(ownerId, figureId);
          if (figure == null) {
            return Container();
          }

          if (figure is! MonsterInstance) return Container();
          bool isActive = figure.roundSummoned != -1;
          if (isActive) {
            color = settings.darkMode.value ? Colors.white : Colors.black;
          }

          return Container(
              width: StatusMenu._kActionButtonSize * scale,
              height: StatusMenu._kActionButtonSize * scale,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(StatusMenu._kSummonMargin * scale),
              decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.all(
                      Radius.circular(StatusMenu._kSummonBorderRadius * scale))),
              child: IconButton(
                  icon: isActive
                      ? Image(
                          height: StatusMenu._kSummonIconSize * scale,
                          filterQuality: FilterQuality.medium,
                          image: const AssetImage(_kImagePath))
                      : Image.asset(
                          filterQuality: FilterQuality.medium,
                          height: StatusMenu._kSummonIconSize * scale,
                          width: StatusMenu._kSummonIconSize * scale,
                          _kImagePath),
                  onPressed: () {
                    gameState.action(SetAsSummonCommand(
                        !isActive, figureId, ownerId,
                        gameState: gameState));
                  }));
        });
  }
}
