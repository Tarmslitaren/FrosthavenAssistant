import 'package:flutter/material.dart';

import '../../Resource/commands/next_turn_command.dart';
import '../../Resource/commands/set_init_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/scaling.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../menus/numpad_menu.dart';
import 'character_background_widget.dart';
import 'character_health_widget.dart';
import 'character_icon_widget.dart';
import 'character_level_widget.dart';
import 'character_summons_button.dart';
import 'character_xp_widget.dart';
import 'initiative_widget.dart';

class CharacterWidgetInternal extends StatefulWidget {
  const CharacterWidgetInternal(
      {super.key,
      required this.character,
      required this.isCharacter,
      required this.characterId,
      this.initPreset});

  final Character character;
  final bool isCharacter;
  final String characterId;
  final int? initPreset;

  static final Set<String> localCharacterInitChanges =
      {}; //if it's been changed locally then it's not hidden

  @override
  CharacterInternalWidgetState createState() => CharacterInternalWidgetState();
}

class CharacterInternalWidgetState extends State<CharacterWidgetInternal> {
  final GameState _gameState = getIt<GameState>();
  bool isCharacter = true;
  final _initTextFieldController = TextEditingController();
  late List<MonsterInstance> lastList = [];
  final _focusNode = FocusNode();

  @override
  void initState() {
    final character = widget.character;
    super.initState();
    lastList = character.characterState.summonList.toList();

    if (widget.initPreset != null) {
      _initTextFieldController.text = widget.initPreset.toString();
    }
    _initTextFieldController.addListener(_textFieldControllerListener);

    if (GameMethods.isObjectiveOrEscort(character.characterClass)) {
      isCharacter = false;
    }
    if (isCharacter) {
      _initTextFieldController.clear();
    }
    if (_gameState.roundState.value == RoundState.playTurns) {
      CharacterWidgetInternal.localCharacterInitChanges.clear();
    }
  }

  void _textFieldControllerListener() {
    final character = widget.character;
    for (var item in _gameState.currentList) {
      if (item is Character) {
        if (item.id == character.id) {
          final text = _initTextFieldController.value.text;
          if (text.isNotEmpty &&
              text != character.characterState.initiative.value.toString() &&
              text.isNotEmpty &&
              text != "??") {
            int? init = int.tryParse(_initTextFieldController.value.text);
            if (init != null && init != 0) {
              CharacterWidgetInternal.localCharacterInitChanges
                  .add(character.id);
              _gameState.action(SetInitCommand(character.id, init));
            }
          }
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _initTextFieldController.removeListener(_textFieldControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double scaledHeight = 60 * scale;

    var shadow = Shadow(
      offset: Offset(1 * scale, 1 * scale),
      color: Colors.black87,
      blurRadius: 1 * scale,
    );

    final character = widget.character;
    return SizedBox(
        width: getMainListWidth(context),
        height: 60 * scale,
        child: Stack(
          children: [
            CharacterBackgroundWidget(
                character: character, scale: scale, shadow: shadow),
            Row(
              children: [
                CharacterIconWidget(
                  character: character,
                  scale: scale,
                  shadow: shadow,
                  scaledHeight: scaledHeight,
                  isCharacter: isCharacter,
                ),
                InitiativeWidget(
                  scale: scale,
                  scaledHeight: scaledHeight,
                  shadow: shadow,
                  isCharacter: isCharacter,
                  character: character,
                  initTextFieldController: _initTextFieldController,
                  focusNode: _focusNode,
                ),
                CharacterHealthWidget(
                  character: character,
                  scale: scale,
                  shadow: shadow,
                  scaledHeight: scaledHeight,
                )
              ],
            ),
            if (isCharacter)
              Positioned(
                  top: 10 * scale,
                  left: 314 * scale,
                  child: CharacterXPWidget(
                      character: character, scale: scale, shadow: shadow)),
            if (isCharacter)
              Positioned(
                  top: 28 * scale,
                  left: 316 * scale,
                  child: CharacterLevelWidget(
                    character: character,
                    scale: scale,
                    shadow: shadow,
                  )),
            if (isCharacter)
              Positioned(
                right: 19 * scale,
                top: 4 * scale,
                child:
                    CharacterSummonsButton(scale: scale, character: character),
              ),
            //make left side of character widget start initiative interaction on tap
            if (character.characterState.health.value > 0)
              InkWell(
                  canRequestFocus: false,
                  onTap: () {
                    if (_gameState.roundState.value ==
                        RoundState.chooseInitiative) {
                      //if in choose mode - focus the input or open the soft numpad if that option is on
                      if (getIt<Settings>().softNumpadInput.value) {
                        openDialog(
                            context,
                            NumpadMenu(
                              controller: _initTextFieldController,
                              maxLength: 2,
                            ));
                      } else {
                        //focus on
                        _focusNode.requestFocus();
                      }
                    } else {
                      getIt<GameState>().action(TurnDoneCommand(character.id));
                    }
                    //if in choose mode - focus the input or open the soft numpad if that option is on
                    //else: mark as done
                  },
                  child: SizedBox(
                    height: 60 * scale,
                    width: 70 * scale,
                  )),
          ],
        ));
  }
}
