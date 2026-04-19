import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Layout/view_models/monster_widget_view_model.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Resource/color_matrices.dart';
import 'monster_stat_card_widget.dart';

class MonsterWidget extends StatefulWidget {
  MonsterWidget({super.key, required this.data, this.gameState});

  final Monster data;
  final GameState? gameState;
  final updateList = ValueNotifier<int>(0);

  @override
  MonsterWidgetState createState() => MonsterWidgetState();
}

class MonsterWidgetState extends State<MonsterWidget> {
  static const int _kAnimationDurationMs = 300;
  static const double _kSpacing = 2.0;
  static const double _kImageMarginV = 4.0;
  static const double _kElevation = 8.0;
  static const double _kImageTopMargin = 2.0;
  static const double _kNameWidthRatio = 0.95;
  static const double _kNameMarginBottom = 2.0;
  static const double _kFontSize = 14.4;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;
  static const double _kScaledHeight = 96.0;
  static const double _kMarginH = 3.2;

  MonsterWidgetViewModel? _vmInstance;
  MonsterWidgetViewModel get _vm => _vmInstance ??= MonsterWidgetViewModel(widget.data, gameState: widget.gameState);
  List<MonsterInstance> lastList = [];

  @override
  void initState() {
    super.initState();
    lastList = widget.data.monsterInstances.asList();
  }

  Widget _buildMonsterBoxGrid(double scale) {
    String displayStartAnimation = "";
    final monsterInstances = widget.data.monsterInstances;

    if (lastList.length < monsterInstances.length) {
      for (var item in monsterInstances) {
        bool found = false;
        for (var oldItem in lastList) {
          if (item.standeeNr == oldItem.standeeNr) {
            found = true;
            break;
          }
        }
        if (!found) {
          displayStartAnimation = item.getId();
          break;
        }
      }
    }

    final generatedChildren = List<Widget>.generate(
        monsterInstances.length,
        (index) => RepaintBoundary(
                child: AnimatedSize(
              key: Key(monsterInstances[index].standeeNr.toString()),
              duration: const Duration(milliseconds: _kAnimationDurationMs),
              child: MonsterBox(
                  key: Key(monsterInstances[index].standeeNr.toString()),
                  figureId: monsterInstances[index].name +
                      monsterInstances[index].gfx +
                      monsterInstances[index].standeeNr.toString(),
                  ownerId: widget.data.id,
                  displayStartAnimation: displayStartAnimation,
                  blockInput: false,
                  scale: scale),
            )));
    lastList = monsterInstances.toList();
    return Wrap(
      runSpacing: _kSpacing * scale,
      spacing: _kSpacing * scale,
      children: generatedChildren,
    );
  }

  Widget _buildImagePart(double height, double scale) {
    return RepaintBoundary(
        child: Stack(alignment: Alignment.bottomCenter, children: [
      Container(
          margin: EdgeInsets.only(bottom: _kImageMarginV * scale, top: _kImageMarginV * scale),
          child: PhysicalShape(
            color: _vm.turnState == TurnsState.current
                ? Colors.tealAccent
                : Colors.transparent,
            shadowColor: Colors.black,
            elevation: _kElevation,
            clipper: const ShapeBorderClipper(shape: CircleBorder()),
            child: Container(
              margin: EdgeInsets.only(bottom: 0, top: _kImageTopMargin * scale),
              child: Image(
                fit: BoxFit.contain,
                height: height,
                width: height,
                image: AssetImage(
                    "assets/images/monsters/${widget.data.type.gfx}.png"),
              ),
            ),
          )),
      Container(
          width: height * _kNameWidthRatio,
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: _vm.frosthavenStyle ? _kNameMarginBottom * scale : 0),
          child: Text(
            textAlign: TextAlign.center,
            widget.data.type.display,
            style: TextStyle(
                fontFamily: _vm.frosthavenStyle ? "GermaniaOne" : 'Pirata',
                color: Colors.white,
                fontSize: _kFontSize * scale,
                shadows: [
                  Shadow(
                    offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
                    color: Colors.black87,
                    blurRadius: _kShadowBlur * scale,
                  )
                ]),
          ))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * _kScaledHeight;

    return ValueListenableBuilder<int>(
        valueListenable: _vm.updateList,
        builder: (context, value, child) {
          return RepaintBoundary(
              child: Column(mainAxisSize: MainAxisSize.max, children: [
            ColorFiltered(
                colorFilter: _vm.isGrayScale
                    ? ColorFilter.matrix(grayScale)
                    : ColorFilter.matrix(identity),
                child: SizedBox(
                  height: _kScaledHeight * scale,
                  width: getMainListWidth(context),
                  child: Row(
                    children: [
                      _vm.showTurnTap
                          ? InkWell(
                              onTap: () {
                                _vm.endTurn();
                              },
                              child: _buildImagePart(height, scale)) // ignore: avoid-returning-widgets, internal layout helper
                          : _buildImagePart(height, scale), // ignore: avoid-returning-widgets, internal layout helper
                      RepaintBoundary(
                          child: MonsterAbilityCardWidget(data: widget.data)),
                      RepaintBoundary(
                          child: MonsterStatCardWidget(data: widget.data)),
                    ],
                  ),
                )),
            Container(
              margin: EdgeInsets.only(left: _kMarginH * scale, right: _kMarginH * scale),
              width: getMainListWidth(context) - _kMarginH * scale,
              child: ValueListenableBuilder<BuiltList<MonsterInstance>>(
                  valueListenable: _vm.monsterInstancesNotifier,
                  builder: (context, value, child) {
                    return _buildMonsterBoxGrid(scale); // ignore: avoid-returning-widgets, internal layout helper
                  }),
            ),
          ]));
        });
  }
}
