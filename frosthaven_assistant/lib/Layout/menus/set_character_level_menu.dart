import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/change_name_command.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/commands/change_stat_commands/change_max_health_command.dart';
import '../../Resource/commands/set_character_level_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

class SetCharacterLevelMenu extends StatefulWidget {
  const SetCharacterLevelMenu({
    super.key,
    required this.character,
    this.gameState,
  });

  final Character character;

  final GameState? gameState;

  @override
  SetCharacterLevelMenuState createState() => SetCharacterLevelMenuState();
}

class SetCharacterLevelMenuState extends State<SetCharacterLevelMenu> {
  static const double _kButtonSize = 40.0;
  static const double _kMenuSize = 240.0;
  static const double _kTopSpacing = 20.0;
  static const int _kLevelRow1Count = 5;
  static const int _kLevelRow2Count = 4;
  static const int _kMaxHealth = 900;
  static const double _kNameFieldWidth = 160.0;

  late final GameState _gameState; // ignore: avoid-late-keyword
  final TextEditingController nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void _focusNodeListener() {
    if (!focusNode.hasFocus) {
      if (nameController.text.isNotEmpty) {
        _gameState.action(ChangeNameCommand(
            nameController.text, widget.character.id,
            gameState: _gameState));
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
    _gameState = widget.gameState ?? getIt<GameState>();

    focusNode.addListener(_focusNodeListener);
  }



  @override
  Widget build(BuildContext context) {
    double scale = getModalMenuScale(context);
    bool isObjective =
        GameMethods.isObjectiveOrEscort(widget.character.characterClass);

    return ModalBackground(
        width: _kMenuSize * scale,
        height: _kMenuSize * scale,
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _kTopSpacing * scale,
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
                  children: List.generate(
                    _kLevelRow1Count,
                    (i) => _LevelButton(nr: i + 1, scale: scale, character: widget.character, gameState: _gameState), // ignore: avoid-returning-widgets, widget generator lambda
                  ),
                ),
              if (!isObjective &&
                  widget.character.characterClass.healthByLevel.length > _kLevelRow1Count)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _kLevelRow2Count,
                    (i) => _LevelButton(nr: _kLevelRow1Count + i + 1, scale: scale, character: widget.character, gameState: _gameState), // ignore: avoid-returning-widgets, widget generator lambda
                  ),
                ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CounterButton(
                    notifier: widget.character.characterState.maxHealth,
                    command: ChangeMaxHealthCommand(
                        0, widget.character.id, widget.character.id,
                        gameState: _gameState),
                    maxValue: _kMaxHealth,
                    image: "assets/images/abilities/heal.png",
                    showTotalValue: true,
                    color: Colors.red,
                    figureId: widget.character.id,
                    ownerId: widget.character.id,
                    scale: scale)
              ]),
              Text("Change name:", style: getTitleTextStyle(scale)),
              SizedBox(
                  width: _kNameFieldWidth,
                  child: TextField(
                    controller: nameController,
                    focusNode: focusNode,
                    style: getTitleTextStyle(scale),
                    onSubmitted: (String string) {
                      //set the name
                      if (nameController.text.isNotEmpty) {
                        _gameState.action(ChangeNameCommand(
                            nameController.text, widget.character.id,
                            gameState: _gameState));
                      }
                    },
                  ))
            ],
          ),
        ]));
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.nr,
    required this.scale,
    required this.character,
    required this.gameState,
  });

  final int nr;
  final double scale;
  final Character character;
  final GameState gameState;

  static const double _kButtonSize = 40.0;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          bool isCurrentlySelected = nr == character.characterState.level.value;
          String text = nr.toString();
          bool darkMode = getIt<Settings>().darkMode.value;
          Color selectedTextColor = darkMode ? Colors.white : Colors.black;
          Color textColor = isCurrentlySelected ? selectedTextColor : Colors.grey;
          return SizedBox(
            width: _kButtonSize * scale,
            height: _kButtonSize * scale,
            child: TextButton(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: kFontSizeTitle * scale,
                    shadows: [
                      Shadow(
                        offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
                        color: isCurrentlySelected ? Colors.black54 : Colors.black87,
                        blurRadius: _kShadowBlur * scale,
                      ),
                    ],
                    color: textColor),
              ),
              onPressed: () {
                if (!isCurrentlySelected) {
                  gameState.action(SetCharacterLevelCommand(nr, character.id));
                }
              },
            ),
          );
        });
  }
}
