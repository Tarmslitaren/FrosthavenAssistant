import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/commands.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class SetCharacterLevelMenu extends StatefulWidget {
  const SetCharacterLevelMenu({Key? key, required this.character}) : super(key: key);

  final Character character;

  @override
  _SetCharacterLevelMenuState createState() => _SetCharacterLevelMenuState();
}

class _SetCharacterLevelMenuState extends State<SetCharacterLevelMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildLevelButton(int nr) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          bool isCurrentlySelected = nr == widget.character.characterState.level.value;
          String text = nr.toString();
          return SizedBox(
            width: 32,
            height: 32,
            child: Container(
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                        color:
                        isCurrentlySelected ? Colors.black : Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      _gameState.action(SetCharacterLevelCommand(nr, widget.character));
                    }
                    //Navigator.pop(context);
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
              //TODO: set the name of the char in this here text.
              const Text("Set Character Level", style: TextStyle(fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  buildLevelButton(1),
                  buildLevelButton(2),
                  buildLevelButton(3),
                  buildLevelButton(4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLevelButton(5),
                  buildLevelButton(6),
                  buildLevelButton(7),
                  buildLevelButton(8),
                  buildLevelButton(9),
                ],
              ),
              //TODO: add a change name widget and a set health directly widget
            ],
          ),
        ]));
  }
}
