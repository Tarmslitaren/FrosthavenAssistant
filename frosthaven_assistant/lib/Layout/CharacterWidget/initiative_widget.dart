import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../menus/numpad_menu.dart';
import '../view_models/initiative_widget_view_model.dart';

class InitiativeWidget extends StatelessWidget {
  static const double _kMarginLeft = 10.0;
  static const double _kMarginTopDivisor = 6.0;
  static const double _kInitImageHeightRatio = 0.1;
  static const double _kTextFieldMarginLeft = 11.0;
  static const double _kTextFieldTopRatio = 0.11;
  static const double _kTextFieldHeightRatio = 0.5;
  static const double _kTextFieldWidth = 25.0;
  static const int _kInitMaxLength = 2;
  static const double _kDisplayHeight = 33.0;

  const InitiativeWidget(
      {super.key,
      required this.scale,
      required this.scaledHeight,
      required this.shadow,
      required this.character,
      required this.isCharacter,
      required this.initTextFieldController,
      required this.focusNode,
      this.gameState,
      this.settings});

  final Character character;
  final double scale;
  final double scaledHeight;
  final Shadow shadow;
  final bool isCharacter;
  final TextEditingController initTextFieldController;
  final FocusNode focusNode;
  final GameState? gameState;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final vm = InitiativeWidgetViewModel(character,
        gameState: gameState, settings: settings);
    return Column(children: [
      Container(
        margin: EdgeInsets.only(top: scaledHeight / InitiativeWidget._kMarginTopDivisor, left: InitiativeWidget._kMarginLeft * scale),
        child: Image(
          height: scaledHeight * InitiativeWidget._kInitImageHeightRatio,
          image: const AssetImage("assets/images/init.png"),
        ),
      ),
      ValueListenableBuilder<int>(
          valueListenable: vm.initiative,
          builder: (context, value, child) {
            final initiative = vm.initiative.value;
            final roundState = vm.roundState;
            final secret = vm.isSecret;
            if (initTextFieldController.text != initiative.toString() &&
                initiative != 0 &&
                (initTextFieldController.text.isNotEmpty || secret)) {
              secret
                  ? initTextFieldController.text = "??"
                  : initTextFieldController.text = initiative.toString();
            }
            if (roundState == RoundState.playTurns && isCharacter) {
              initTextFieldController.clear();
            }
            if (vm.isChooseInitiative && vm.isAlive) {
              return Container(
                margin:
                    EdgeInsets.only(left: InitiativeWidget._kTextFieldMarginLeft * scale, top: scaledHeight * InitiativeWidget._kTextFieldTopRatio),
                height: scaledHeight * InitiativeWidget._kTextFieldHeightRatio,
                width: InitiativeWidget._kTextFieldWidth * scale,
                padding: EdgeInsets.zero,
                alignment: Alignment.topCenter,
                child: TextField(
                    focusNode: focusNode,
                    onTap: () {
                      initTextFieldController.clear();
                      if (vm.softNumpadInput) {
                        openDialog(
                            context,
                            NumpadMenu(
                              controller: initTextFieldController,
                              maxLength: InitiativeWidget._kInitMaxLength,
                            ));
                      }
                    },
                    onChanged: (String str) {
                      if (str.length == InitiativeWidget._kInitMaxLength) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white,
                    maxLength: InitiativeWidget._kInitMaxLength,
                    style: TextStyle(
                        height: 1,
                        fontFamily: vm.fontFamily,
                        color: Colors.white,
                        fontSize: kFontSizeHeading * scale,
                        shadows: [shadow]),
                    decoration: const InputDecoration(
                      isDense: true,
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
                    keyboardType: vm.keyboardInputType),
              );
            } else {
              if (isCharacter) {
                initTextFieldController.clear();
              }
              return Container(
                  height: InitiativeWidget._kDisplayHeight * scale,
                  width: InitiativeWidget._kTextFieldWidth * scale,
                  margin: EdgeInsets.only(left: InitiativeWidget._kMarginLeft * scale),
                  child: Text(
                    vm.initiativeDisplayText(initiative),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: vm.fontFamily,
                        color: Colors.white,
                        fontSize: kFontSizeHeading * scale,
                        shadows: [shadow]),
                  ));
            }
          }),
    ]);
  }
}
