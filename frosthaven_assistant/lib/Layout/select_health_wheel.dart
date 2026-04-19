import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Resource/game_methods.dart';
import '../Resource/scaling.dart';
import '../services/service_locator.dart';

class SelectHealthWheel extends StatefulWidget {
  final FigureState data;
  final String figureId;
  final String? ownerId;
  final ValueNotifier<double> delta;
  final ValueNotifier<int> time;
  final GameState? gameState;

  const SelectHealthWheel(
      {super.key,
      required this.data,
      required this.figureId,
      required this.ownerId,
      required this.delta,
      required this.time,
      this.gameState});

  @override
  SelectHealthWheelState createState() => SelectHealthWheelState();
}

class SelectHealthWheelState extends State<SelectHealthWheel> {
  static const double _kScrollDeltaRatio = 0.4;
  static const double _kScrollDeltaMax = 6.5;
  static const double _kScrollDeltaMin = 2.5;
  static const int _kIOSDivider = 2;
  static const double _kShadowOffset = 0.4;
  static const double _kBoxShadowBlur = 4.0;
  static const double _kBoxShadowOffsetX = 2.0;
  static const double _kWheelWidth = 140.0;
  static const double _kWheelHeight = 10.0;
  static const double _kSelectedWidth = 60.0;
  static const double _kUnselectedWidth = 50.0;
  static const double _kSelectedHeight = 30.0;
  static const double _kUnselectedHeight = 20.0;
  static const double _kSelectedFontSize = 18.0;
  static const double _kUnselectedFontSize = 16.0;

  int selected = 0;
  FixedExtentScrollController? scrollController;
  late final GameState _gameState;
  double currentScrollOffset = 0;
  final double itemExtent = 25;
  bool scrollInited = false;

  @override
  void initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    super.initState();
    int count = widget.data.maxHealth.value;
    selected = count - (widget.data.maxHealth.value - widget.data.health.value);
    scrollController = FixedExtentScrollController(initialItem: selected);
  }

  @override
  void deactivate() {
    super.deactivate();
    end();
  }

  void end() {
    int value = selected - widget.data.health.value;
    if (value != 0) {
      //in case figure killed by other device double check
      if (GameMethods.getFigure(widget.ownerId, widget.figureId) != null) {
        _gameState.action(
            ChangeHealthCommand(value, widget.figureId, widget.ownerId, gameState: _gameState));
      }
      selected = widget.data.maxHealth.value -
          (widget.data.maxHealth.value - widget.data.health.value);
    }
  }

  void scrollTheWheel(double delta, int timeMicroSeconds, double scale) {
    int maxHealth = widget.data.maxHealth.value;
    double deltaMod = min(widget.data.maxHealth.value * _kScrollDeltaRatio, _kScrollDeltaMax);
    deltaMod = max(deltaMod, _kScrollDeltaMin);

    deltaMod *= delta;
    if (Platform.isIOS || Platform.isMacOS) {
      deltaMod /= _kIOSDivider;
    }

    final sc = scrollController;
    if (sc == null) return;
    double initialPosition = sc.initialItem * itemExtent * scale;
    if (currentScrollOffset == 0 && !scrollInited) {
      scrollInited = true;
      currentScrollOffset = initialPosition;
    }
    if (sc.hasClients) {
      if (timeMicroSeconds > 0) {
        sc.animateTo(currentScrollOffset - deltaMod,
            duration: Duration(microseconds: timeMicroSeconds),
            curve: Curves.linear);
        currentScrollOffset = currentScrollOffset - deltaMod;
        //don't go over limit/don't account for extra drag at end of range
        if (currentScrollOffset > itemExtent * scale * maxHealth) {
          currentScrollOffset = itemExtent * scale * maxHealth;
        }
        if (currentScrollOffset < 0) {
          currentScrollOffset = 0;
        }
      }
    }
  }

  String _buildNrString(int index) {
    String retVal = '${index - widget.data.health.value}';
    if (index - widget.data.health.value > 0) {
      retVal = "+$retVal";
    }
    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);

    var shadow = Shadow(
      offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: 1 * scale,
    );

    return RotatedBox(
        quarterTurns: -1,
        child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: _kBoxShadowBlur * scale,
                  offset: Offset(_kBoxShadowOffsetX * scale, _kBoxShadowBlur * scale), // Shadow position
                ),
              ],
            ),
            width: _kWheelWidth,
            height: _kWheelHeight,
            child: ValueListenableBuilder<double>(
                valueListenable: widget.delta,
                builder: (context, value, child) {
                  scrollTheWheel(widget.delta.value, widget.time.value, scale);

                  return ListWheelScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      //force android scrolling...
                      renderChildrenOutsideViewport: true,
                      clipBehavior: Clip.none,
                      onSelectedItemChanged: (x) {
                        setState(() {
                          selected = x;
                        });
                      },
                      controller: scrollController,
                      itemExtent: itemExtent * scale,
                      children: List.generate(
                        widget.data.maxHealth.value + 1,
                        (x) => RotatedBox(
                            quarterTurns: 1,
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: x == selected ? _kSelectedWidth * scale : _kUnselectedWidth * scale,
                                height: x == selected ? _kSelectedHeight * scale : _kUnselectedHeight * scale,
                                alignment: Alignment.center,
                                child: Text(
                                  _buildNrString(x),
                                  maxLines: 1,
                                  style: TextStyle(
                                      height: 1,
                                      color: x == selected
                                          ? Colors.red
                                          : Colors.white,
                                      fontSize: x == selected
                                          ? _kSelectedFontSize * scale
                                          : _kUnselectedFontSize * scale,
                                      shadows: [shadow]),
                                ))),
                      ));
                })));
  }
}
