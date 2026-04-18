// ignore_for_file: avoid-returning-widgets, file uses widget helper methods for summon color/number buttons
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Model/summon_model.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/stat_calculator.dart';
import '../../Resource/game_data.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddSummonMenu extends StatefulWidget {
  const AddSummonMenu({
    super.key,
    required this.character,
    this.gameState,
    this.gameData,

    this.settings,
    });

  final Character character;

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  AddSummonMenuState createState() => AddSummonMenuState();
}

class AddSummonMenuState extends State<AddSummonMenu> {
  static const int _kCustomSummonCount = 4;
  static const double _kButtonSize = 42.0;
  static const double _kButtonBorderRadius = 30.0;
  static const double _kMenuWidth = 336.0;
  static const double _kMenuHeight = 452.0;
  static const double _kTopSpacing = 20.0;
  static const double _kIconSize = 30.0;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;
  static const int _kNrButtonRowSize = 4;
  static const int _kMinStandeesForNr = 2;
  static const int _kDefaultHealth = 2;

  late final GameState _gameState;
  late final GameData _gameData;
  late final Settings _settings;
  int chosenNr = 1;
  String chosenGfx = "blue";

  final List<SummonModel> _summonList = [];
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _gameData = widget.gameData ?? getIt<GameData>();
    _settings = widget.settings ?? getIt<Settings>();

    //populate the summon list
    for (var item in widget.character.characterClass.summons) {
      final characterState = widget.character.characterState;
      if (item.level <= characterState.level.value) {
        int standeesOut = 0;
        for (var item2 in characterState.summonList) {
          if (item2.name == item.name) {
            standeesOut++;
          }
        }
        //only add to list if can summon more
        if (standeesOut < item.standees) {
          _summonList.add(item);
        }
      }
    }
    _summonList.addAll(_gameData.itemSummonData);

    if (!_settings.showCustomContent.value) {
      //-4 because there are 4 custom summons. I know.
      _summonList.removeRange(_summonList.length - _kCustomSummonCount, _summonList.length);
    }
  }

  Widget buildGraphicButton(String summonGfx, double scale) {
    bool isCurrentlySelected;
    isCurrentlySelected = summonGfx == chosenGfx;
    Color color = Colors.transparent;
    if (isCurrentlySelected) {
      color = _settings.darkMode.value ? Colors.white : Colors.black;
    }
    return SizedBox(
      width: _kButtonSize * scale,
      height: _kButtonSize * scale,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
              ),
              borderRadius: BorderRadius.all(Radius.circular(_kButtonBorderRadius * scale))),
          child: IconButton(
            onPressed: () {
              if (!isCurrentlySelected) {
                setState(() {
                  chosenGfx = summonGfx;
                });
              }
            },
            icon: Image.asset(
              'assets/images/summon/$summonGfx.png',
              cacheHeight: kMonsterImageCacheHeight,
            ),
          )),
    );
  }

  Widget buildNrButton(int nr, double scale) {
    bool isCurrentlySelected;
    isCurrentlySelected = nr == chosenNr;
    Color color = Colors.transparent;
    String text = nr.toString();
    bool darkMode = _settings.darkMode.value;
    Color selectedTextColor = darkMode ? Colors.white : Colors.black;
    Color textColor = isCurrentlySelected ? selectedTextColor : Colors.grey;
    return SizedBox(
      width: _kButtonSize * scale,
      height: _kButtonSize * scale,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
              ),
              borderRadius: BorderRadius.all(Radius.circular(_kButtonBorderRadius))),
          child: TextButton(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: kFontSizeTitle * scale,
                  color: textColor),
            ),
            onPressed: () {
              if (!isCurrentlySelected) {
                setState(() {
                  chosenNr = nr;
                });
              }
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = getModalMenuScale(context);
    return ModalBackground(
      width: _kMenuWidth * scale,
      height: _kMenuHeight * scale,
      child: Column(children: [
        SizedBox(
          height: _kTopSpacing * scale,
        ),
        Text("Add Summon", style: getTitleTextStyle(scale)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildGraphicButton("blue", scale),
            buildGraphicButton("green", scale),
            buildGraphicButton("yellow", scale),
            buildGraphicButton("orange", scale),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildGraphicButton("white", scale),
            buildGraphicButton("purple", scale),
            buildGraphicButton("pink", scale),
            buildGraphicButton("red", scale),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kNrButtonRowSize, (i) => buildNrButton(i + 1, scale)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kNrButtonRowSize, (i) => buildNrButton(_kNrButtonRowSize + i + 1, scale)),
        ),
        Expanded(
            child: Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _summonList.length,
                    itemBuilder: (context, index) {
                      SummonModel model = _summonList[index];
                      String gfx = chosenGfx;
                      bool showNr = true;
                      if (model.gfx.isNotEmpty) {
                        gfx = model.gfx;
                        if (model.standees < _kMinStandeesForNr) {
                          showNr = false;
                        }
                      }

                      return ListTile(
                          leading:
                              Stack(alignment: Alignment.center, children: [
                            Image(
                              height: _kIconSize * scale,
                              width: _kIconSize * scale,
                              image:
                                  AssetImage("assets/images/summon/$gfx.png"),
                            ),
                            if (showNr)
                              Text(chosenNr.toString(),
                                  style: TextStyle(
                                      fontSize: kFontSizeTitle * scale,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
                                          color: Colors.black87,
                                          blurRadius: _kShadowBlur * scale,
                                        )
                                      ])),
                          ]),
                          title: Text(_summonList[index].name,
                              style: getTitleTextStyle(scale)),
                          onTap: () {
                            setState(() {
                              SummonModel model = _summonList[index];
                              String gfx = chosenGfx;
                              if (model.gfx.isNotEmpty) {
                                gfx = model.gfx;
                              }
                              if (model.standees < _kMinStandeesForNr && model.gfx.isNotEmpty) {
                                chosenNr =
                                    0; //don't show on monster box unless standees are numbered
                              }
                              SummonData summonData = SummonData(
                                  chosenNr,
                                  model.name,
                                  StatCalculator.calculateFormula(
                                          model.health) ??
                                      _kDefaultHealth,
                                  model.move,
                                  model.attack,
                                  model.range,
                                  gfx);
                              _gameState.action(AddStandeeCommand(
                                  chosenNr,
                                  summonData,
                                  widget.character.id,
                                  MonsterType.summon,
                                  true,
                                  gameState: _gameState));
                            });
                            Navigator.pop(context);
                            //open the level menu here for convenience
                            openDialog(
                                context,
                                SetLevelMenu(
                                  figure: widget
                                      .character.characterState.summonList.last,
                                  characterId: widget.character.id,
                                ));
                          });
                    }))),
        SizedBox(
          height: _kTopSpacing * scale,
        ),
      ]),
    );
  }
}
