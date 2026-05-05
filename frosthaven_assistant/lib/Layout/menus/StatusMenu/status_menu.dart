import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../Resource/enums.dart';
import '../../../Resource/game_methods.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../../services/service_locator.dart';
import '../../widgets/modal_background.dart';
import 'status_menu_condition_panel.dart';
import 'status_menu_header.dart';
import 'status_menu_stat_column.dart';

class StatusMenu extends StatefulWidget {
  static const double _kMenuWidth = 340.0;

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
  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  Settings get _settings => widget.settings ?? getIt<Settings>();

  @override
  initState() {
    super.initState();
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
    for (final item in _gameState.currentList) {
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
    String ownerId = "";
    final monsterId = widget.monsterId;
    final characterId = widget.characterId;
    if (monsterId != null) {
      name = monsterId; //this is no good
      ownerId = monsterId;
    } else if (characterId != null) {
      name = characterId; //now this is no good either...
      ownerId = name;
    }

    String figureId = widget.figureId;
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null) {
      //close menu here, since nothing will be valid
      Navigator.pop(context);
      return const SizedBox(height: 0, width: 0);
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
            StatusMenuHeader(
              name: name,
              figure: figure,
              scale: scale,
              hasShield: hasShield,
              hasRetaliate: hasRetaliate,
              owner: owner,
              figureId: figureId,
              ownerId: ownerId,
              isIceWraith: isIceWraith,
              isElite: isElite,
              gameState: _gameState,
              onIceWraithSwitch: () => setState(() {}),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              StatusMenuStatColumn(
                figure: figure,
                scale: scale,
                isMonster: isMonster,
                isCharacter: isCharacter,
                isSummon: isSummon,
                characterId: characterId,
                monsterId: widget.monsterId,
                immunities: immunities,
                hasVimthreader: hasVimthreader,
                hasLifespeaker: hasLifespeaker,
                hasIncarnate: hasIncarnate,
                character: character,
                hasPlagueHerald: hasPlagueHerald,
                figureId: figureId,
                ownerId: ownerId,
                monster: monster,
                showCustomContent: showCustomContent,
                gameState: _gameState,
                settings: _settings,
              ),
              StatusMenuConditionPanel(
                figureId: figureId,
                ownerId: ownerId,
                immunities: immunities,
                scale: scale,
                isMonster: isMonster,
                isCharacter: isCharacter,
                isSummon: isSummon,
                nrOfCharacters: nrOfCharacters,
                showCustomContent: showCustomContent,
                hasMireFoot: hasMireFoot,
                gameState: _gameState,
                settings: _settings,
              ),
            ])
          ]))
    ]);
  }
}
