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
  static const double _kSmallMargin = 2.0;
  static const double _kHalfDivisor = 2.0;
  static const double _kBorderSides = 2.0;
  static const double _kInertHeight = 4.0;
  static const double _kBoxShadowBlur = 4.0;
  static const double _kIconScale = 0.65;

  late final ElementButtonViewModel _vm; // ignore: avoid-late-keyword
  late double _height; // ignore: avoid-late-keyword
  late Color _color; // ignore: avoid-late-keyword
  late BorderRadiusGeometry _borderRadius; // ignore: avoid-late-keyword

  @override
  void initState() {
    super.initState();
    _vm = ElementButtonViewModel(widget.element,
        gameState: widget.gameState, settings: widget.settings);
    final scale = _vm.userScalingBars;
    _height = widget.width * scale;
    _color = Colors.transparent;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width * scale - widget.borderWidth * scale * _kBorderSides));
  }

  double get _userScalingBars => _vm.userScalingBars;

  void _setHalf() {
    final scale = _userScalingBars;
    _color = widget.color;
    _height = widget.width * scale / _kHalfDivisor + _kSmallMargin * scale;
    _borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(widget.width * scale / _kHalfDivisor),
        bottomRight: Radius.circular(widget.width * scale / _kHalfDivisor));
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
    _height = _kInertHeight * _userScalingBars;
    _borderRadius = BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _userScalingBars;
    return Container(
        margin: EdgeInsets.only(right: _kSmallMargin * scale),
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
                    padding: EdgeInsets.only(bottom: _kSmallMargin * scale),
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
                                        widget.borderWidth * scale * _kBorderSides,
                                    height:
                                        _height - widget.borderWidth * scale * _kBorderSides,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: _color,
                                        borderRadius: _borderRadius,
                                        boxShadow: [
                                          state != ElementState.inert
                                              ? BoxShadow(
                                                  blurRadius: _kBoxShadowBlur * scale)
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
                              height: widget.width * scale * _kIconScale,
                              image: AssetImage(widget.icon),
                              color: _vm.iconColor,
                              width: widget.width * scale * _kIconScale,
                            );
                          });
                    })
              ],
            )));
  }
}
