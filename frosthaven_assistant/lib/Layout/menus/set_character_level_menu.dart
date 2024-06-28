import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/change_name_command.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/commands/change_stat_commands/change_max_health_command.dart';
import '../../Resource/commands/set_character_level_command.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

class SetCharacterLevelMenu extends StatefulWidget {
  const SetCharacterLevelMenu({super.key, required this.character});

  final Character character;

  @override
  SetCharacterLevelMenuState createState() => SetCharacterLevelMenuState();
}

class SetCharacterLevelMenuState extends State<SetCharacterLevelMenu> {
  final GameState _gameState = getIt<GameState>();
  final TextEditingController nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void _focusNodeListener() {
    if (!focusNode.hasFocus) {
      if (nameController.text.isNotEmpty) {
        _gameState.action(ChangeNameCommand(nameController.text, widget.character.id));
      }
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_focusNodeListener);
    super.dispose();
  }

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();

    focusNode.addListener(_focusNodeListener);
  }

  Widget buildLevelButton(int nr, double scale) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          bool isCurrentlySelected = nr == widget.character.characterState.level.value;
          String text = nr.toString();
          bool darkMode = getIt<Settings>().darkMode.value;
          return SizedBox(
            width: 40 * scale,
            height: 40 * scale,
            child: TextButton(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 18 * scale,
                    shadows: [
                      Shadow(
                        offset: Offset(1 * scale, 1 * scale),
                        color: isCurrentlySelected ? Colors.black54 : Colors.black87,
                        blurRadius: 1 * scale,
                      ),
                    ],
                    color: isCurrentlySelected
                        ? (darkMode ? Colors.white : Colors.black)
                        : Colors.grey),
              ),
              onPressed: () {
                if (!isCurrentlySelected) {
                  _gameState.action(SetCharacterLevelCommand(nr, widget.character.id));
                }
              },
            ),
          );
        });
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
    bool isObjective = GameMethods.isObjectiveOrEscort(widget.character.characterClass);

    return Container(
        width: 240 * scale,
        height: 240 * scale,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value
                ? 'assets/images/bg/dark_bg.png'
                : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20 * scale,
              ),
              ValueListenableBuilder<String>(
                  valueListenable: widget.character.characterState.display,
                  // widget.data.monsterInstances,
                  builder: (context, value, child) {
                    return Text(
                        isObjective
                            ? "Set ${widget.character.characterState.display.value}'s Health"
                            : "Set ${widget.character.characterState.display.value}'s Level",
                        style: getTitleTextStyle(scale));
                  }),
              if (!isObjective)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildLevelButton(1, scale),
                    buildLevelButton(2, scale),
                    buildLevelButton(3, scale),
                    buildLevelButton(4, scale),
                  ],
                ),
              if (!isObjective)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildLevelButton(5, scale),
                    buildLevelButton(6, scale),
                    buildLevelButton(7, scale),
                    buildLevelButton(8, scale),
                    buildLevelButton(9, scale),
                  ],
                ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CounterButton(
                    widget.character.characterState.maxHealth,
                    ChangeMaxHealthCommand(0, widget.character.id, widget.character.id),
                    900,
                    "assets/images/abilities/heal.png",
                    true,
                    Colors.red,
                    figureId: widget.character.id,
                    ownerId: widget.character.id,
                    scale: scale)
              ]),
              Text("Change name:", style: getTitleTextStyle(scale)),
              SizedBox(
                  width: 160,
                  child: TextField(
                    controller: nameController,
                    focusNode: focusNode,
                    style: getTitleTextStyle(scale),
                    onSubmitted: (String string) {
                      //set the name
                      if (nameController.text.isNotEmpty) {
                        _gameState
                            .action(ChangeNameCommand(nameController.text, widget.character.id));
                      }
                    },
                  ))
            ],
          ),
        ]));
  }
}
