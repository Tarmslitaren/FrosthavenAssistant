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
  late final MonsterWidgetViewModel _vm;
  List<MonsterInstance> lastList = [];

  @override
  void initState() {
    super.initState();
    _vm = MonsterWidgetViewModel(widget.data, gameState: widget.gameState);
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
              duration: const Duration(milliseconds: 300),
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
      runSpacing: 2.0 * scale,
      spacing: 2.0 * scale,
      children: generatedChildren,
    );
  }

  Widget _buildImagePart(double height, double scale) {
    return RepaintBoundary(
        child: Stack(alignment: Alignment.bottomCenter, children: [
      Container(
          margin: EdgeInsets.only(bottom: 4 * scale, top: 4 * scale),
          child: PhysicalShape(
            color: _vm.turnState == TurnsState.current
                ? Colors.tealAccent
                : Colors.transparent,
            shadowColor: Colors.black,
            elevation: 8,
            clipper: const ShapeBorderClipper(shape: CircleBorder()),
            child: Container(
              margin: EdgeInsets.only(bottom: 0 * scale, top: 2 * scale),
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
          width: height * 0.95,
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
              bottom: _vm.frosthavenStyle ? 2 * scale : 0),
          child: Text(
            textAlign: TextAlign.center,
            widget.data.type.display,
            style: TextStyle(
                fontFamily: _vm.frosthavenStyle ? "GermaniaOne" : 'Pirata',
                color: Colors.white,
                fontSize: 14.4 * scale,
                shadows: [
                  Shadow(
                    offset: Offset(1 * scale, 1 * scale),
                    color: Colors.black87,
                    blurRadius: 1 * scale,
                  )
                ]),
          ))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * 96;

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
                  height: 96 * scale,
                  width: getMainListWidth(context),
                  child: Row(
                    children: [
                      _vm.showTurnTap
                          ? InkWell(
                              onTap: () {
                                _vm.endTurn();
                              },
                              child: _buildImagePart(height, scale))
                          : _buildImagePart(height, scale),
                      RepaintBoundary(
                          child: MonsterAbilityCardWidget(data: widget.data)),
                      RepaintBoundary(
                          child: MonsterStatCardWidget(data: widget.data)),
                    ],
                  ),
                )),
            Container(
              margin: EdgeInsets.only(left: 3.2 * scale, right: 3.2 * scale),
              width: getMainListWidth(context) - 3.2 * scale,
              child: ValueListenableBuilder<int>(
                  valueListenable: _vm.killMonsterStandee,
                  builder: (context, value, child) {
                    return _buildMonsterBoxGrid(scale);
                  }),
            ),
          ]));
        });
  }
}
