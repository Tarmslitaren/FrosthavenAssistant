import 'package:flutter/material.dart';

import '../../Resource/enums.dart';
import '../../Resource/scaling.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../menus/numpad_menu.dart';
import '../view_models/character_widget_internal_view_model.dart';
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
      this.initPreset,
      this.gameState,
      this.settings});

  final Character character;
  final bool isCharacter;
  final String characterId;
  final int? initPreset;

  static final Set<String> localCharacterInitChanges = {};

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  CharacterInternalWidgetState createState() => CharacterInternalWidgetState();
}

class CharacterInternalWidgetState extends State<CharacterWidgetInternal> {
  late final CharacterWidgetInternalViewModel _vm;
  bool isCharacter = true;
  final _initTextFieldController = TextEditingController();
  late List<MonsterInstance> lastList = [];
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _vm = CharacterWidgetInternalViewModel(widget.character,
        gameState: widget.gameState, settings: widget.settings);
    final character = widget.character;
    lastList = character.characterState.summonList.toList();

    if (widget.initPreset != null) {
      _initTextFieldController.text = widget.initPreset.toString();
    }
    _initTextFieldController.addListener(_textFieldControllerListener);

    isCharacter = !_vm.isObjectiveOrEscort;
    if (isCharacter) {
      _initTextFieldController.clear();
    }
    if (_vm.roundState.index >= 0) {
      // clear on playTurns
      if (_vm.roundState == RoundState.playTurns) {
        CharacterWidgetInternal.localCharacterInitChanges.clear();
      }
    }
  }

  void _textFieldControllerListener() {
    final text = _initTextFieldController.value.text;
    if (_vm.handleInitTextChange(text)) {
      CharacterWidgetInternal.localCharacterInitChanges
          .add(widget.character.id);
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
            if (_vm.isAlive)
              InkWell(
                  onTap: () {
                    if (_vm.isChooseInitiative) {
                      if (_vm.softNumpadInput) {
                        openDialog(
                            context,
                            NumpadMenu(
                              controller: _initTextFieldController,
                              maxLength: 2,
                            ));
                      } else {
                        _focusNode.requestFocus();
                      }
                    } else {
                      _vm.endTurn();
                    }
                  },
                  child: SizedBox(
                    height: 60 * scale,
                    width: 70 * scale,
                  )),
          ],
        ));
  }
}
