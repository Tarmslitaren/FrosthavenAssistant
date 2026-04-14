import 'package:flutter/material.dart';

import '../Resource/app_constants.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import 'view_models/draw_button_view_model.dart';

class DrawButton extends StatefulWidget {
  const DrawButton({super.key, this.gameState});

  final GameState? gameState;

  @override
  DrawButtonState createState() => DrawButtonState();
}

class DrawButtonState extends State<DrawButton> {
  late final DrawButtonViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DrawButtonViewModel(gameState: widget.gameState);
  }

  void _onPressed() {
    final blockedMessage = _vm.runAction();
    if (blockedMessage != null) {
      showToast(context, blockedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final scaling = _vm.userScalingBars.value;
          final shadow = Shadow(
            offset: Offset(1 * scaling, 1 * scaling),
            color: Colors.black87,
            blurRadius: 1 * scaling,
          );

          return RepaintBoundary(
              child: Stack(alignment: Alignment.centerLeft, children: [
            ValueListenableBuilder<int>(
              valueListenable: _vm.round,
              builder: (context, value, child) {
                return Positioned(
                    bottom: 2 * scaling,
                    left: 45 * scaling,
                    child: Text(_vm.roundText,
                        style: TextStyle(
                          fontSize: kFontSizeSmall * scaling,
                          color: Colors.white,
                          shadows: [shadow],
                        )));
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: _vm.commandIndex,
              builder: (context, value, child) {
                return Container(
                    margin: EdgeInsets.zero,
                    height: 40 * scaling,
                    width: _vm.buttonWidth * scaling,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: 10 * scaling, right: 10 * scaling),
                            alignment: Alignment.center),
                        onPressed: _onPressed,
                        child: Text(
                          _vm.buttonText,
                          style: TextStyle(
                            height: 0.8,
                            fontSize: kFontSizeBody * scaling,
                            color: Colors.white,
                            shadows: [shadow],
                          ),
                        )));
              },
            )
          ]));
        });
  }
}
