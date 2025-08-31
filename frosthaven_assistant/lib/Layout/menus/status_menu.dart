import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
import 'package:frosthaven_assistant/Layout/menus/condition_button.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/change_stat_commands/change_chill_command.dart';
import '../../Resource/commands/change_stat_commands/change_empower_command.dart';
import '../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../Resource/commands/ice_wraith_change_form_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/commands/set_as_summon_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

class StatusMenu extends StatefulWidget {
  const StatusMenu(
      {super.key, required this.figureId, this.characterId, this.monsterId});

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

  @override
  StatusMenuState createState() => StatusMenuState();
}

class StatusMenuState extends State<StatusMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  void activateCondition(Condition condition, FigureState figure) {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;
  }

  Widget buildChillButtons(ValueListenable<int> notifier, int maxValue,
      String image, String figureId, String? ownerId, double scale) {
    return Row(children: [
      SizedBox(
          width: 40 * scale,
          height: 40 * scale,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
              onPressed: () {
                if (notifier.value > 0) {
                  _gameState.action(ChangeChillCommand(-1, figureId, ownerId));
                  _gameState.action(RemoveConditionCommand(
                      Condition.chill, figureId, ownerId));
                }
                //increment
              })),
      Stack(children: [
        SizedBox(
          width: 30 * scale,
          height: 30 * scale,
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
                          height: 0.5,
                          fontSize: 16 * scale,
                          shadows: [
                            Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: Colors.black87,
                              blurRadius: 1 * scale,
                            )
                          ])));
            })
      ]),
      SizedBox(
          width: 40 * scale,
          height: 40 * scale,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
            onPressed: () {
              if (notifier.value < maxValue) {
                _gameState.action(ChangeChillCommand(1, figureId, ownerId));
                _gameState.action(
                    AddConditionCommand(Condition.chill, figureId, ownerId));
              }
              //increment
            },
          )),
    ]);
  }

  Widget buildSummonButton(String figureId, String? ownerId, double scale) {
    String imagePath = "assets/images/summon/green.png";
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          Color color = Colors.transparent;
          FigureState? figure = GameMethods.getFigure(ownerId, figureId);
          if (figure == null) {
            return Container();
          }

          bool isActive = (figure as MonsterInstance).roundSummoned != -1;
          if (isActive) {
            color =
                getIt<Settings>().darkMode.value ? Colors.white : Colors.black;
          }

          return Container(
              width: 42 * scale,
              height: 42 * scale,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(1 * scale),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30 * scale))),
              child: IconButton(
                  icon: isActive
                      ? Image(
                          height: 24 * scale,
                          filterQuality: FilterQuality.medium,
                          image: AssetImage(imagePath))
                      : Image.asset(
                          filterQuality: FilterQuality.medium,
                          //needed because of the edges
                          height: 24 * scale,
                          width: 24 * scale,
                          imagePath),
                  onPressed: () {
                    if (!isActive) {
                      _gameState
                          .action(SetAsSummonCommand(true, figureId, ownerId));
                    } else {
                      _gameState
                          .action(SetAsSummonCommand(false, figureId, ownerId));
                    }
                  }));
        });
  }

  @override
  Widget build(BuildContext context) {
    bool showCustomContent = getIt<Settings>().showCustomContent.value;
    bool hasMireFoot = false;
    bool hasIncarnate = false;
    bool isSummon = (widget.monsterId == null &&
        widget.characterId !=
            widget
                .figureId); //hack - should have monsterBox send summon data instead
    for (var item in _gameState.currentList) {
      if (item.id == "Mirefoot" && showCustomContent) {
        hasMireFoot = true;
      }
      if (item.id == "Incarnate" && showCustomContent) {
        hasIncarnate = true;
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
    Character? character = _gameState.currentList
            .firstWhereOrNull((item) => item.id == widget.characterId)
        as Character?;
    if (figure is CharacterState && character != null) {
      name = character.characterClass.name;
    }

    double scale = getModalMenuScale(context);

    int nrOfCharacters = GameMethods.getCurrentCharacterAmount();

    ListItemData owner =
        _gameState.currentList.firstWhereOrNull((item) => item.id == ownerId)!;
    final bool isMonster = widget.monsterId != null;
    final bool isCharacter = widget.characterId != null;
    return Wrap(children: [
      Container(
          width: 340 * scale,
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), BlendMode.dstATop),
              image: AssetImage(getIt<Settings>().darkMode.value
                  ? 'assets/images/bg/dark_bg.png'
                  : 'assets/images/bg/white_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                height: 28 * scale,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(name, style: getTitleTextStyle(scale)),
                      if (figure is MonsterInstance)
                        ValueListenableBuilder<int>(
                            valueListenable: getIt<GameState>().updateList,
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
                                      height: 28 * scale,
                                      margin: EdgeInsets.only(
                                          top: 2 * scale, right: 2 * scale),
                                      child: ConditionIcon(
                                        Condition.shield,
                                        24 * scale,
                                        owner,
                                        figure,
                                        scale: scale,
                                      )),
                                if (hasRetaliate)
                                  Container(
                                      height: 28 * scale,
                                      margin: EdgeInsets.only(
                                          top: 2 * scale, right: 2 * scale),
                                      child: ConditionIcon(
                                        Condition.retaliate,
                                        24 * scale,
                                        owner,
                                        figure,
                                        scale: scale,
                                      )),
                                Container(
                                    height: 28 * scale,
                                    margin: EdgeInsets.only(top: 2 * scale),
                                    child: MonsterBox(
                                        figureId: figureId,
                                        ownerId: ownerId,
                                        displayStartAnimation: "",
                                        blockInput: true,
                                        scale: scale * 0.9))
                              ]);
                            }),
                      if (isIceWraith)
                        TextButton(
                            clipBehavior: Clip.hardEdge,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(right: 20 * scale),
                            ),
                            onPressed: () {
                              setState(() {
                                _gameState.action(IceWraithChangeFormCommand(
                                    isElite, ownerId, figureId));
                              });
                            },
                            child: Text("                     Switch Form",
                                style: TextStyle(
                                  fontSize: 14 * scale,
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
                              (getIt<GameState>().allyDeckInOGGloom.value ||
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
                        if (item.id == widget.characterId) {
                          if (GameMethods.isObjectiveOrEscort(
                              (item as Character).characterClass)) {
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
                            getIt<Settings>().showCharacterAMD.value &&
                            isCharacter ||
                        isSummon;
                    final bool showMonsterAmd =
                        getIt<Settings>().showAmdDeck.value &&
                            (isObjective || (isMonster && !isSummon));
                    final bool showAmd = showCharacterAmd || showMonsterAmd;

                    final isAlly = deck.name == "allies";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CounterButton(
                            notifier: figure.health,
                            command: ChangeHealthCommand(0, figureId, ownerId),
                            maxValue: figure.maxHealth.value,
                            image: "assets/images/abilities/heal.png",
                            showTotalValue: false,
                            color: Colors.red,
                            figureId: figureId,
                            ownerId: ownerId,
                            scale: scale),
                        const SizedBox(height: 2),
                        hasXp
                            ? CounterButton(
                                notifier: (figure as CharacterState).xp,
                                command: ChangeXPCommand(0, figureId, ownerId),
                                maxValue: 900,
                                image: "assets/images/psd/xp.png",
                                showTotalValue: false,
                                color: Colors.blue,
                                figureId: figureId,
                                ownerId: ownerId,
                                scale: scale)
                            : Container(),
                        SizedBox(height: hasXp ? 2 : 0),
                        SizedBox(
                            //todo? why this?
                            height: !showCharacterAmd || isSummon ? 2 : 0),
                        if (showAmd)
                          CounterButton(
                              notifier: deck.getRemovable("bless"),
                              command: ChangeBlessCommand(0, figureId, ownerId),
                              maxValue: 10,
                              image: "assets/images/abilities/bless.png",
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale),
                        SizedBox(height: showCharacterAmd ? 2 : 0),
                        if ((canBeCursed && showMonsterAmd) || showCharacterAmd)
                          CounterButton(
                              notifier: deck.getRemovable("curse"),
                              command: ChangeCurseCommand(0, figureId, ownerId),
                              maxValue: 10,
                              image: "assets/images/abilities/curse.png",
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale),
                        if (showMonsterAmd && hasIncarnate)
                          CounterButton(
                              notifier: deck.getRemovable("in-enfeeble"),
                              command: ChangeEnfeebleCommand(
                                  0, "in-enfeeble", figureId, ownerId),
                              maxValue: 10,
                              image: "assets/images/abilities/enfeeble.png",
                              extraImage:
                                  "assets/images/class-icons/incarnate.png",
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale),
                        if (showAmd && (isCharacter || isAlly) && hasIncarnate)
                          CounterButton(
                              notifier: deck.getRemovable("in-empower"),
                              command: ChangeEmpowerCommand(
                                  0, "in-empower", figureId, ownerId),
                              maxValue: 10,
                              image: "assets/images/abilities/empower.png",
                              extraImage:
                                  "assets/images/class-icons/incarnate.png",
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
                                  0, "rm-empower", figureId, ownerId),
                              maxValue: 12,
                              image:
                                  "assets/images/abilities/empower.png", //add character icon here too
                              extraImage:
                                  "assets/images/class-icons/ruinmaw.png",
                              showTotalValue: true,
                              color: Colors.white,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale),
                        if (showCustomContent)
                          buildChillButtons(
                              figure.chill,
                              12,
                              //technically you can have infinite, but realistically not so much
                              "assets/images/abilities/chill.png",
                              figureId,
                              ownerId,
                              scale),
                        SizedBox(height: canBeCursed ? 2 : 0),
                        Row(
                          children: [
                            SizedBox(
                              width: 42 * scale,
                              height: 42 * scale,
                              child: IconButton(
                                icon:
                                    Image.asset('assets/images/psd/skull.png'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _gameState.action(ChangeHealthCommand(
                                      -figure.health.value, figureId, ownerId));
                                },
                              ),
                            ),
                            SizedBox(
                                width: 42 * scale,
                                height: 42 * scale,
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
                                      fontSize: 14 * scale,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1 * scale, 1 * scale),
                                          color: Colors.black87,
                                          blurRadius: 1 * scale,
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
                    height: 2 * scale,
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
                  isCharacter || isSummon
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                          ],
                        )
                      : !hasMireFoot
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                              ],
                            ),
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
                        if (nrOfCharacters > 1)
                          ConditionButton(
                              condition: Condition.character2,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        if (nrOfCharacters > 2)
                          ConditionButton(
                              condition: Condition.character3,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        if (nrOfCharacters > 3)
                          ConditionButton(
                              condition: Condition.character4,
                              figureId: figureId,
                              ownerId: ownerId,
                              immunities: immunities,
                              scale: scale),
                        buildSummonButton(figureId, ownerId, scale)
                      ],
                    ),
                ],
              ),
            ])
          ]))
    ]);
  }
}
