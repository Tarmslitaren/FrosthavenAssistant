import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Resource/scaling.dart';
import '../services/service_locator.dart';

class SelectHealthWheel extends StatefulWidget {
  final FigureState data;
  final String figureId;
  final String ownerId;
  final ValueNotifier<double> delta;
  final ValueNotifier<int> time;

  const SelectHealthWheel(
      {super.key,
      required this.data,
      required this.figureId,
      required this.ownerId,
      required this.delta,
      required this.time});

  @override
  SelectHealthWheelState createState() => SelectHealthWheelState();
}

class SelectHealthWheelState extends State<SelectHealthWheel> {
  late int selected;
  late final FixedExtentScrollController scrollController;
  double currentScrollOffset = 0;
  late int itemIndex;
  final double itemExtent = 25;
  bool scrollInited = false;

  @override
  void initState() {
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
        getIt<GameState>().action(ChangeHealthCommand(value, widget.figureId, widget.ownerId));
      }
      selected =
          widget.data.maxHealth.value - (widget.data.maxHealth.value - widget.data.health.value);
    }
  }

  void scrollTheWheel(double delta, int timeMicroSeconds, double scale) {
    int maxHealth = widget.data.maxHealth.value;
    double deltaMod = min(widget.data.maxHealth.value * 0.4, 6.5);
    deltaMod = max(deltaMod, 2.5);

    deltaMod *= delta;
    if (Platform.isIOS || Platform.isMacOS) {
      deltaMod /= 2;
    }

    double initialPosition = scrollController.initialItem * itemExtent * scale;
    if (currentScrollOffset == 0 && !scrollInited) {
      scrollInited = true;
      currentScrollOffset = initialPosition;
    }
    if (scrollController.hasClients) {
      if (timeMicroSeconds > 0) {
        scrollController.animateTo(currentScrollOffset - deltaMod,
            duration: Duration(microseconds: timeMicroSeconds), curve: Curves.linear);
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
      offset: Offset(0.4 * scale, 0.4 * scale),
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
                  blurRadius: 4 * scale,
                  offset: Offset(2 * scale, 4 * scale), // Shadow position
                ),
              ],
            ),
            width: 140,
            height: 10,
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
                                width: x == selected ? 60 * scale : 50 * scale,
                                height: x == selected ? 30 * scale : 20 * scale,
                                alignment: Alignment.center,
                                child: Text(
                                  _buildNrString(x),
                                  maxLines: 1,
                                  style: TextStyle(
                                      height: 1,
                                      color: x == selected ? Colors.red : Colors.white,
                                      fontSize: x == selected ? 18 * scale : 16 * scale,
                                      shadows: [shadow]),
                                ))),
                      ));
                })));
  }
}
