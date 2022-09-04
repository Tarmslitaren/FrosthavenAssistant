import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/commands/change_stat_commands/change_max_health_command.dart';
import '../../Resource/commands/set_character_level_command.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

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
          bool darkMode = getIt<Settings>().darkMode.value;
          return SizedBox(
            width: 40,
            height: 40,
            child: TextButton(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                    shadows: [

                Shadow(
                offset: const Offset(1, 1),
                color: isCurrentlySelected ? Colors.black54 : Colors.black87,
                blurRadius: 1,
              ),
                    ],
                    color:
                    isCurrentlySelected ?
                    (darkMode? Colors.white : Colors.black) :
                    Colors.grey),
              ),
              onPressed: () {
                if (!isCurrentlySelected) {
                  _gameState.action(SetCharacterLevelCommand(nr, widget.character.id));
                }
                //Navigator.pop(context);
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 10,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value?
            'assets/images/bg/dark_bg.png'
                :'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              //TODO: set the name of the char in this here text.
              Text(
                  "Set ${widget.character.id}'s Level", style: getTitleTextStyle()),
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
              //TODO: add a change name widget
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CounterButton(
                        widget.character.characterState.maxHealth,
                        ChangeMaxHealthCommand(0, widget.character.id, widget.character.id),
                        900,
                        "assets/images/blood.png",
                        true,
                        Colors.red,
                        figureId: widget.character.id,
                        ownerId: widget.character.id)
                  ])
            ],
          ),
        ]));
  }
}
