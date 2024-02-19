import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Model/summon.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_data.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddSummonMenu extends StatefulWidget {
  final Character character;

  const AddSummonMenu({super.key, required this.character});

  @override
  AddSummonMenuState createState() => AddSummonMenuState();
}

class AddSummonMenuState extends State<AddSummonMenu> {
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  int chosenNr = 1;
  String chosenGfx = "blue";

  final List<SummonModel> _summonList = [];
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();

    //populate the summon list
    //_summonList.addAll(widget.character.characterClass.summons);
    for (var item in widget.character.characterClass.summons) {
      if (item.level <= widget.character.characterState.level.value) {
        int standeesOut = 0;
        for (var item2 in widget.character.characterState.summonList) {
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

    if (getIt<Settings>().showCustomContent.value == false) {
      //-4 because there are 4 custom summons. I know.
      _summonList.removeRange(_summonList.length - 4, _summonList.length);
    }
  }

  Widget buildGraphicButton(String summonGfx, double scale) {
    bool isCurrentlySelected;
    isCurrentlySelected = summonGfx == chosenGfx;
    Color color = Colors.transparent;
    if (isCurrentlySelected) {
      color = getIt<Settings>().darkMode.value ? Colors.white : Colors.black;
    }
    return SizedBox(
      width: 42 * scale,
      height: 42 * scale,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30 * scale))),
          child: IconButton(
            onPressed: () {
              if (!isCurrentlySelected) {
                setState(() {
                  chosenGfx = summonGfx;
                });
              }
              //if all selected then pop
              //Navigator.pop(context);
            },
            icon: Image.asset('assets/images/summon/$summonGfx.png'),
            //iconSize: 30,,
          )),
    );
  }

  Widget buildNrButton(int nr, double scale) {
    bool isCurrentlySelected;
    isCurrentlySelected = nr == chosenNr;
    Color color = Colors.transparent;
    if (isCurrentlySelected) {
      //color = Colors.black;
    }
    String text = nr.toString();
    bool darkMode = getIt<Settings>().darkMode.value;
    return SizedBox(
      width: 42 * scale,
      height: 42 * scale,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(30))),
          child: TextButton(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 18 * scale,
                  color: isCurrentlySelected
                      ? darkMode
                          ? Colors.white
                          : Colors.black
                      : Colors.grey),
            ),
            onPressed: () {
              if (!isCurrentlySelected) {
                setState(() {
                  chosenNr = nr;
                });
              }
              //do if last thing
              //Navigator.pop(context);
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;
    if (!isPhoneScreen(context)) {
      scale = 1.5;
      if (isLargeTablet(context)) {
        scale = 2;
      }
    }
    return Container(
      width: 336 * scale,
      height: 452 * scale,
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
          image: AssetImage(getIt<Settings>().darkMode.value
              ? 'assets/images/bg/dark_bg.png'
              : 'assets/images/bg/white_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(children: [
        SizedBox(
          height: 20 * scale,
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
          children: [
            buildNrButton(1, scale),
            buildNrButton(2, scale),
            buildNrButton(3, scale),
            buildNrButton(4, scale),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildNrButton(5, scale),
            buildNrButton(6, scale),
            buildNrButton(7, scale),
            buildNrButton(8, scale),
          ],
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
                        if (model.standees < 2) {
                          showNr = false;
                        }
                      }

                      return ListTile(
                          leading: Stack(alignment: Alignment.center, children: [
                            Image(
                              height: 30 * scale,
                              width: 30 * scale,
                              image: AssetImage("assets/images/summon/$gfx.png"),
                            ),
                            if (showNr)
                              Text(chosenNr.toString(),
                                  style: TextStyle(
                                      fontSize: 18 * scale,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1 * scale, 1 * scale),
                                          color: Colors.black87,
                                          blurRadius: 1 * scale,
                                        )
                                      ])),
                          ]),
                          //iconColor: _foundMonsters[index].color,
                          title: Text(_summonList[index].name, style: getTitleTextStyle(scale)),
                          onTap: () {
                            setState(() {
                              SummonModel model = _summonList[index];
                              String gfx = chosenGfx;
                              if (model.gfx.isNotEmpty) {
                                gfx = model.gfx;
                              }
                              if (model.standees < 2 && model.gfx.isNotEmpty) {
                                chosenNr =
                                    0; //don't show on monster box unless standees are numbered
                              }
                              SummonData summonData = SummonData(chosenNr, model.name, model.health,
                                  model.move, model.attack, model.range, gfx);
                              _gameState.action(AddStandeeCommand(chosenNr, summonData,
                                  widget.character.id, MonsterType.summon, true));
                            });
                            Navigator.pop(context);
                            //open the level menu here for convenience
                            openDialog(
                                context,
                                SetLevelMenu(
                                  figure: widget.character.characterState.summonList.last,
                                  characterId: widget.character.id,
                                ));
                          });
                    }))),
        SizedBox(
          height: 20 * scale,
        ),
      ]),
    );
  }
}
