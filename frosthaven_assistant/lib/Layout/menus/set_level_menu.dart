import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import '../../Resource/commands/set_level_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class SetLevelMenu extends StatefulWidget {
  const SetLevelMenu({Key? key, this.monster}) : super(key: key);

  final Monster? monster;

  @override
  _SetLevelMenuState createState() => _SetLevelMenuState();
}

class _SetLevelMenuState extends State<SetLevelMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildLevelButton(int nr) {
    return ValueListenableBuilder<bool>(
        valueListenable: _gameState.solo,
        builder: (context, value, child) {
          bool isCurrentlySelected;
          if(widget.monster != null) {
            isCurrentlySelected = nr == widget.monster!.level.value;
          }else {
            isCurrentlySelected = nr == _gameState.level.value;
          }
          bool isRecommended = GameMethods.getRecommendedLevel() == nr;
          Color color = Colors.transparent;
          if (isRecommended) {
            color = Colors.grey;
          }
          if (isCurrentlySelected) {
            //color = Colors.black;
          }
          String text = nr.toString();
          return SizedBox(
            width: 32,
            height: 32,
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
                        color:
                            isCurrentlySelected ? Colors.black : Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      _gameState.action(SetLevelCommand(nr, widget.monster));
                    }
                    Navigator.pop(context);
                  },
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String title = "Set Scenario Level";
    if(widget.monster != null) {
      title = "Set " + widget.monster!.type.display + "'s level";
    }
    return Container(
        width: 10,
        height: 160,
        decoration: BoxDecoration(
          //color: Colors.black,
          //borderRadius: BorderRadius.all(Radius.circular(8)),

          /*border: Border.fromBorderSide(BorderSide(
            color: Colors.blueGrey,
            width: 10
          )),*/
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
              image: AssetImage('assets/images/bg/white_bg.png'),
              fit: BoxFit.fitWidth,
          ),
        ),
        child: Stack(
            //alignment: Alignment.center,
            children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(title, style: TextStyle(fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLevelButton(0),
                  buildLevelButton(1),
                  buildLevelButton(2),
                  buildLevelButton(3),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLevelButton(4),
                  buildLevelButton(5),
                  buildLevelButton(6),
                  buildLevelButton(7),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Solo:"),
                ValueListenableBuilder<bool>(
                    valueListenable: _gameState.solo,
                    builder: (context, value, child) {
                      return Checkbox(
                        checkColor: Colors.black,
                        activeColor: Colors.grey.shade200,
                        //side: BorderSide(color: Colors.black),
                        onChanged: (bool? newValue) {
                          _gameState.solo.value = newValue!;
                        },
                        value: _gameState.solo.value,
                      );
                    })
              ]),
            ],
          ),
        ]));
  }
}
