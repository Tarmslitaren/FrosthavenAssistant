import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddStandeeMenu extends StatefulWidget {
  final Monster monster;
  final bool elite;

  const AddStandeeMenu({super.key, required this.monster, required this.elite});

  @override
  AddStandeeMenuState createState() => AddStandeeMenuState();
}

class AddStandeeMenuState extends State<AddStandeeMenu> {
  final GameState _gameState = getIt<GameState>();

  bool addAsSummon = false;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildNrButton(final int nr, final double scale) {
    bool boss = widget.monster.type.levels[0].boss != null;
    MonsterType type = MonsterType.normal;
    Color color = Colors.white;

    if (widget.elite) {
      color = Colors.yellow;
      type = MonsterType.elite;
    }

    if (boss) {
      color = Colors.red;
      type = MonsterType.boss;
    }
    bool isOut = false;
    for (var item in widget.monster.monsterInstances) {
      if (item.standeeNr == nr) {
        isOut = true;
        break;
      }
    }
    if (isOut) {
      color = Colors.grey;
    }
    String text = nr.toString();
    var shadow = Shadow(
      offset: Offset(1 * scale, 1 * scale),
      color: Colors.black87,
      blurRadius: 1,
    );
    return SizedBox(
      width: 40 * scale,
      height: 40 * scale,
      child: TextButton(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 18 * scale,
            shadows: [shadow],
          ),
        ),
        onPressed: () {
          if (!isOut) {
            _gameState.action(AddStandeeCommand(nr, null, widget.monster.id, type, addAsSummon));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int nrOfStandees = widget.monster.type.count;
    double scale = 1;
    if (!isPhoneScreen(context)) {
      scale = 1.5;
      if (isLargeTablet(context)) {
        scale = 2;
      }
    }
    //4 nrs per row
    double height = 140;
    if (nrOfStandees > 4) {
      height = 172;
    }
    if (nrOfStandees > 8) {
      height = 211;
    }
    return Container(
        width: 250 * scale,
        //need to set any width to center content, overridden by dialog default min width.
        height: height * scale,
        decoration: BoxDecoration(
          //color: Colors.black,
          //borderRadius: BorderRadius.all(Radius.circular(8)),

          /*border: Border.fromBorderSide(BorderSide(
            color: Colors.blueGrey,
            width: 10
          )),*/
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value
                ? 'assets/images/bg/dark_bg.png'
                : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(children: [
          ValueListenableBuilder<int>(
              valueListenable: _gameState.commandIndex,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20 * scale,
                    ),
                    Text("Add Standee Nr", style: getTitleTextStyle(scale)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildNrButton(1, scale),
                        nrOfStandees > 1 ? buildNrButton(2, scale) : Container(),
                        nrOfStandees > 2 ? buildNrButton(3, scale) : Container(),
                        nrOfStandees > 3 ? buildNrButton(4, scale) : Container(),
                      ],
                    ),
                    nrOfStandees > 4
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              nrOfStandees > 4 ? buildNrButton(5, scale) : Container(),
                              nrOfStandees > 5 ? buildNrButton(6, scale) : Container(),
                              nrOfStandees > 6 ? buildNrButton(7, scale) : Container(),
                              nrOfStandees > 7 ? buildNrButton(8, scale) : Container(),
                            ],
                          )
                        : Container(),
                    nrOfStandees > 8
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              nrOfStandees > 8 ? buildNrButton(9, scale) : Container(),
                              nrOfStandees > 9 ? buildNrButton(10, scale) : Container(),
                            ],
                          )
                        : Container(),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Summoned:", style: getSmallTextStyle(scale)),
                      Checkbox(
                        checkColor: Colors.black,
                        activeColor: Colors.grey.shade200,
                        side: BorderSide(
                            color: getIt<Settings>().darkMode.value ? Colors.white : Colors.black),
                        onChanged: (bool? newValue) {
                          setState(() {
                            addAsSummon = newValue!;
                          });
                        },
                        value: addAsSummon,
                      )
                    ])
                  ],
                );
              }),
        ]));
  }
}
