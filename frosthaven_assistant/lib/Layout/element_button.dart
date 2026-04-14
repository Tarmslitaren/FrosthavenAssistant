import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import 'view_models/element_button_view_model.dart';

class ElementButton extends StatefulWidget {
  const ElementButton(
      {super.key,
      required this.icon,
      required this.color,
      required this.element,
      this.gameState,
      this.settings});
  final String icon;
  final Color color;
  final Elements element;
  final double width = 40;
  final double borderWidth = 2;

  final GameState? gameState;
  final Settings? settings;

  @override
  AnimatedContainerButtonState createState() => AnimatedContainerButtonState();
}

class AnimatedContainerButtonState extends State<ElementButton> {
  late final ElementButtonViewModel _vm;
  late double _height;
  late Color _color;
  late BorderRadiusGeometry _borderRadius;

  @override
  void initState() {
    super.initState();
    _vm = ElementButtonViewModel(widget.element,
        gameState: widget.gameState, settings: widget.settings);
    final scale = _vm.userScalingBars;
    _height = widget.width * scale;
    _color = Colors.transparent;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width * scale - widget.borderWidth * scale * 2));
  }

  double get _userScalingBars => _vm.userScalingBars;

  void _setHalf() {
    final scale = _userScalingBars;
    _color = widget.color;
    _height = widget.width * scale / 2 + 2 * scale;
    _borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(widget.width * scale / 2),
        bottomRight: Radius.circular(widget.width * scale / 2));
  }

  void _setFull() {
    final scale = _userScalingBars;
    _color = widget.color;
    _height = widget.width * scale;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width * scale - widget.borderWidth * scale));
  }

  void _setInert() {
    _color = Colors.transparent;
    _height = 4 * _userScalingBars;
    _borderRadius = BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _userScalingBars;
    return Container(
        margin: EdgeInsets.only(right: 2 * scale),
        child: InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: const Color(0x44000000),
            highlightColor: Colors.transparent,
            onLongPress: () {
              setState(() {
                _vm.imbue(half: true);
              });
            },
            onTap: () {
              _vm.tap();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    padding: EdgeInsets.only(bottom: 2 * scale),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ValueListenableBuilder<int>(
                          valueListenable: _vm.commandIndex,
                          builder: (context, value, child) {
                            final state = _vm.elementState;
                            if (state == ElementState.inert) {
                              _setInert();
                            } else if (state == ElementState.half) {
                              _setHalf();
                            } else if (state == ElementState.full) {
                              _setFull();
                            }

                            return RepaintBoundary(
                                child: AnimatedContainer(
                                    width: widget.width * scale -
                                        widget.borderWidth * scale * 2,
                                    height:
                                        _height - widget.borderWidth * scale * 2,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: _color,
                                        borderRadius: _borderRadius,
                                        boxShadow: [
                                          state != ElementState.inert
                                              ? BoxShadow(
                                                  blurRadius: 4 * scale)
                                              : const BoxShadow(
                                                  color: Colors.transparent,
                                                )
                                        ]),
                                    duration:
                                        const Duration(milliseconds: 350),
                                    curve: Curves.decelerate));
                          }),
                    )),
                ValueListenableBuilder<bool>(
                    valueListenable: _vm.darkMode,
                    builder: (context, value, child) {
                      return ValueListenableBuilder<int>(
                          valueListenable: _vm.commandIndex,
                          builder: (context, value, child) {
                            return Image(
                              height: widget.width * scale * 0.65,
                              image: AssetImage(widget.icon),
                              color: _vm.iconColor,
                              width: widget.width * scale * 0.65,
                            );
                          });
                    })
              ],
            )));
  }
}
