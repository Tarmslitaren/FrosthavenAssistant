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
  static const double _kShadowOffset = 1.0;
  static const double _kRoundTextBottom = 2.0;
  static const double _kRoundTextLeft = 45.0;
  static const double _kButtonHeight = 40.0;
  static const double _kButtonPadding = 10.0;
  static const double _kTextHeight = 0.8;

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
            offset: Offset(_kShadowOffset * scaling, _kShadowOffset * scaling),
            color: Colors.black87,
            blurRadius: _kShadowOffset * scaling,
          );

          return RepaintBoundary(
              child: Stack(alignment: Alignment.centerLeft, children: [
            ValueListenableBuilder<int>(
              valueListenable: _vm.round,
              builder: (context, value, child) {
                return Positioned(
                    bottom: _kRoundTextBottom * scaling,
                    left: _kRoundTextLeft * scaling,
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
                    height: _kButtonHeight * scaling,
                    width: _vm.buttonWidth * scaling,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: _kButtonPadding * scaling, right: _kButtonPadding * scaling),
                            alignment: Alignment.center),
                        onPressed: _onPressed,
                        child: Text(
                          _vm.buttonText,
                          style: TextStyle(
                            height: _kTextHeight,
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
