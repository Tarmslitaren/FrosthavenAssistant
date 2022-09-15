
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class AddStandeeMenu extends StatefulWidget {
  final Monster monster;
  final bool elite;

  const AddStandeeMenu({Key? key, required this.monster, required this.elite})
      : super(key: key);

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

  Widget buildNrButton(int nr) {
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
    for (var item in widget.monster.monsterInstances.value) {
      if (item.standeeNr == nr) {
        isOut = true;
        break;
      }
    }
    if (isOut) {
      color = Colors.grey;
    }
    String text = nr.toString();
    var shadow = const Shadow(
      offset: Offset(1, 1),
      color: Colors.black87,
      blurRadius: 1,
    );
    return SizedBox(
      width: 40,
      height: 40,
      child: Container(
          child: TextButton(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 18,
            shadows: [shadow],
          ),
        ),
        onPressed: () {
          if (!isOut) {
            _gameState.action(AddStandeeCommand(nr, null, widget.monster.id, type, addAsSummon));
          }
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    int nrOfStandees = widget.monster.type.count;
    //4 nrs per row
    double height =140;
    if (nrOfStandees > 4) {
      height = 172;
    }
    if (nrOfStandees > 8) {
      height = 211;
    }
    return Container(
        width: 250, //need to set any width to center content, overridden by dialog default min width.
        height: height,
        decoration: BoxDecoration(
          //color: Colors.black,
          //borderRadius: BorderRadius.all(Radius.circular(8)),

          /*border: Border.fromBorderSide(BorderSide(
            color: Colors.blueGrey,
            width: 10
          )),*/
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value?
            'assets/images/bg/dark_bg.png'
                :'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
            //alignment: Alignment.center,
            children: [
              ValueListenableBuilder<List<MonsterInstance>>(
                  valueListenable: widget.monster.monsterInstances,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text("Add Standee Nr",
                            style: getTitleTextStyle()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildNrButton(1),
                            nrOfStandees > 1 ? buildNrButton(2) : Container(),
                            nrOfStandees > 2 ? buildNrButton(3) : Container(),
                            nrOfStandees > 3 ? buildNrButton(4) : Container(),
                          ],
                        ),
                        nrOfStandees > 4
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  nrOfStandees > 4
                                      ? buildNrButton(5)
                                      : Container(),
                                  nrOfStandees > 5
                                      ? buildNrButton(6)
                                      : Container(),
                                  nrOfStandees > 6
                                      ? buildNrButton(7)
                                      : Container(),
                                  nrOfStandees > 7
                                      ? buildNrButton(8)
                                      : Container(),
                                ],
                              )
                            : Container(),
                        nrOfStandees > 8
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  nrOfStandees > 8
                                      ? buildNrButton(9)
                                      : Container(),
                                  nrOfStandees > 9
                                      ? buildNrButton(10)
                                      : Container(),
                                ],
                              )
                            : Container(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Summoned:", style: getSmallTextStyle()),
                              Checkbox(
                                checkColor: Colors.black,
                                activeColor: Colors.grey.shade200,
                                side: BorderSide(
                                    color: getIt<Settings>().darkMode.value
                                        ? Colors.white
                                        : Colors.black),
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
