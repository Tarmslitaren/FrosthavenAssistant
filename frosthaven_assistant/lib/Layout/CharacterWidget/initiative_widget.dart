import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/network/network.dart';
import '../../services/service_locator.dart';
import '../menus/numpad_menu.dart';
import 'character_widget_internal.dart';

class InitiativeWidget extends StatelessWidget {
  const InitiativeWidget(
      {super.key,
      required this.scale,
      required this.scaledHeight,
      required this.shadow,
      required this.character,
      required this.isCharacter,
      required this.initTextFieldController,
      required this.focusNode});

  final Character character;
  final double scale;
  final double scaledHeight;
  final Shadow shadow;
  final bool isCharacter;
  final TextEditingController initTextFieldController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final gameState = getIt<GameState>();
    return Column(children: [
      Container(
        margin: EdgeInsets.only(top: scaledHeight / 6, left: 10 * scale),
        child: Image(
          height: scaledHeight * 0.1,
          image: const AssetImage("assets/images/init.png"),
        ),
      ),
      ValueListenableBuilder<int>(
          valueListenable: character.characterState.initiative,
          builder: (context, value, child) {
            final initiative = character.characterState.initiative.value;
            final roundState = gameState.roundState.value;
            bool secret = (getIt<Settings>().server.value ||
                    getIt<Settings>().client.value == ClientState.connected) &&
                (!CharacterWidgetInternal.localCharacterInitChanges
                    .contains(character.id));
            if (initTextFieldController.text != initiative.toString() &&
                initiative != 0 &&
                (initTextFieldController.text.isNotEmpty || secret)) {
              //handle secret if originating from other device
              secret
                  ? initTextFieldController.text = "??"
                  : initTextFieldController.text = initiative.toString();
            }
            if (roundState == RoundState.playTurns && isCharacter) {
              initTextFieldController.clear();
            }
            if (roundState == RoundState.chooseInitiative &&
                character.characterState.health.value > 0) {
              return Container(
                margin:
                    EdgeInsets.only(left: 11 * scale, top: scaledHeight * 0.11),
                height: scaledHeight * 0.5,
                width: 25 * scale,
                padding: EdgeInsets.zero,
                alignment: Alignment.topCenter,
                child: TextField(
                    focusNode: focusNode,
                    onTap: () {
                      //clear on enter focus
                      initTextFieldController.clear();
                      if (getIt<Settings>().softNumpadInput.value) {
                        openDialog(
                            context,
                            NumpadMenu(
                              controller: initTextFieldController,
                              maxLength: 2,
                            ));
                      }
                    },
                    onChanged: (String str) {
                      //close soft keyboard on 2 chars entered
                      if (str.length == 2) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white,
                    maxLength: 2,
                    style: TextStyle(
                        height: 1,
                        //quick fix for web-phone disparity.
                        fontFamily: GameMethods.isFrosthavenStyle(null)
                            ? 'GermaniaOne'
                            : 'Pirata',
                        color: Colors.white,
                        fontSize: 24 * scale,
                        shadows: [shadow]),
                    decoration: const InputDecoration(
                      isDense: true,
                      //this is what fixes the height issue
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide:
                            BorderSide(width: 0, color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide:
                            BorderSide(width: 0, color: Colors.transparent),
                      ),
                    ),
                    controller: initTextFieldController,
                    keyboardType: getIt<Settings>().softNumpadInput.value
                        ? TextInputType.none
                        : TextInputType.number),
              );
            } else {
              if (isCharacter) {
                initTextFieldController.clear();
              }
              final characterState = character.characterState;
              final initiative = characterState.initiative.value;
              return Container(
                  height: 33 * scale,
                  width: 25 * scale,
                  margin: EdgeInsets.only(left: 10 * scale),
                  child: Text(
                    characterState.health.value > 0 && initiative > 0
                        ? initiative.toString()
                        : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: GameMethods.isFrosthavenStyle(null)
                            ? 'GermaniaOne'
                            : 'Pirata',
                        color: Colors.white,
                        fontSize: 24 * scale,
                        shadows: [shadow]),
                  ));
            }
          }),
    ]);
  }
}
