import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/commands.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class SetLevelMenu extends StatefulWidget {
  const SetLevelMenu({Key? key}) : super(key: key);

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
          bool isCurrentlySelected = nr == _gameState.level.value;
          bool isRecommended = _gameState.getRecommendedLevel() == nr;
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
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                        color:
                            isCurrentlySelected ? Colors.black : Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      _gameState.action(SetLevelCommand(nr));
                    }
                    Navigator.pop(context);
                  },
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 10,
        height: 160,
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text("Set Scenario Level", style: TextStyle(fontSize: 18)),
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
                Text("Solo:"),
                ValueListenableBuilder<bool>(
                    valueListenable: _gameState.solo,
                    builder: (context, value, child) {
                      return Checkbox(
                        checkColor: Colors.black,
                        activeColor: Colors.grey.shade200,
                        //side: BorderSide(color: Colors.black),
                        onChanged: (bool? newValue) {
                          _gameState.solo.value = newValue!;

                          //_gameState.solo.value = !_gameState.solo.value;
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
