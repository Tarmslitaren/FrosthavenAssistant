import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';

import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class ElementButton extends StatefulWidget {
  final String icon;
  final double width;
  final Color color;
  final Elements element;
  final double borderWidth = 2;

  const ElementButton(
      {Key? key,
      required this.icon,
      this.width = 40,
      required this.color,
      required this.element})
      : super(key: key);

  @override
  _AnimatedContainerButtonState createState() =>
      _AnimatedContainerButtonState();
}

class _AnimatedContainerButtonState extends State<ElementButton> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.
  final GameState _gameState = getIt<GameState>();
  late double _height;
  late Color _color;
  late BorderRadiusGeometry _borderRadius;

  @override
  void initState() {
    super.initState();
    _height = widget.width;
    _color = Colors.transparent;
    _borderRadius =
        BorderRadius.all(Radius.circular(widget.width - widget.borderWidth));
  }

  void setHalf(){
    _color = widget.color;
    _height = widget.width / 2;
    _borderRadius = BorderRadius.only(
        bottomLeft:
        Radius.circular(widget.width / 2 - widget.borderWidth),
        bottomRight:
        Radius.circular(widget.width / 2 - widget.borderWidth));
    //_borderRadius = BorderRadius.only(
     //   bottomLeft: Radius.circular(_height - widget.borderWidth),
      //  bottomRight: Radius.circular(_height - widget.borderWidth));
  }

  void setFull(){
    _color = widget.color;
    _height = widget.width;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width - widget.borderWidth));
  }

  void setInert(){
    _color = Colors.transparent;
    _height = widget.width;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width - widget.borderWidth));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: () {
          setState(() {
            _gameState.elementState.value
                .update(widget.element, (value) => ElementState.half);
            _gameState.action(ImbueElementCommand(widget.element, true));
           // setHalf();
          });
        },
        onTap: () {
          setState(() {
            if (_gameState.elementState.value[widget.element] !=
                ElementState.inert) {
              _gameState.elementState.value
                  .update(widget.element, (value) => ElementState.inert);
            } else {
              _gameState.elementState.value
                  .update(widget.element, (value) => ElementState.full);
            }
            if (_gameState.elementState.value[widget.element] ==
                ElementState.half) {
              _gameState.action(ImbueElementCommand(widget.element, true));

              //setHalf();
            } else if (_gameState.elementState.value[widget.element] ==
                ElementState.full) {
              _gameState.action(ImbueElementCommand(widget.element, false));

            } else {
              _gameState.action(UseElementCommand(widget.element));
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<int>(
                  valueListenable: _gameState.commandIndex,
                  builder: (context, value, child) {
                    if (_gameState.elementState.value[widget.element] == ElementState.inert) {
                      setInert();
                    }
                    else if (_gameState.elementState.value[widget.element] == ElementState.half) {
                      setHalf();
                    }
                    else if (_gameState.elementState.value[widget.element] == ElementState.full) {
                      setFull();
                    }

                    return AnimatedContainer(
                      // Use the properties stored in the State class.
                      width: widget.width - widget.borderWidth,
                      height: _height - widget.borderWidth,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: _color,
                          borderRadius: _borderRadius,
                          boxShadow: [
                            _gameState.elementState.value[widget.element] !=
                                    ElementState.inert
                                ? const BoxShadow(
                                    //spreadRadius: 2
                                    blurRadius: 2)
                                : const BoxShadow(
                                    color: Colors.transparent,
                                  )
                          ]),
                      // Define how long the animation should take.
                      duration: const Duration(milliseconds: 500),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                    );
                  }),
            ),
            Image(
              //fit: BoxFit.contain,
              height: widget.width * 0.8,
              image: AssetImage(widget.icon),
              width: widget.width * 0.8,
            ),
          ],
        ));
  }
}
