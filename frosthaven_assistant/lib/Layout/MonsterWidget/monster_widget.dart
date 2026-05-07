import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/MonsterAbilityCardWidget/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Layout/MonsterBox/monster_box.dart';
import 'package:frosthaven_assistant/Layout/view_models/monster_widget_view_model.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/color_matrices.dart';
import '../MonsterStatCardWidget/monster_stat_card_widget.dart';
import 'monster_image_part.dart';

class MonsterWidget extends StatefulWidget {
  const MonsterWidget({super.key, required this.data, this.gameState});

  final Monster data;
  final GameState? gameState;

  @override
  MonsterWidgetState createState() => MonsterWidgetState();
}

class MonsterWidgetState extends State<MonsterWidget> {
  static const double _kSpacing = 2.0;
  static const double _kScaledHeight = 96.0;
  static const double _kMarginH = 3.2;

  MonsterWidgetViewModel? _vmInstance;
  MonsterWidgetViewModel get _vm => _vmInstance ??=
      MonsterWidgetViewModel(widget.data, gameState: widget.gameState);
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
      for (final item in monsterInstances) {
        bool found = false;
        for (final oldItem in lastList) {
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
              duration: const Duration(milliseconds: kAnimationDurationMs),
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

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * _kScaledHeight;

    return ListenableBuilder(
        listenable: _vm.updateList,
        builder: (context, child) {
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
                              child: MonsterImagePart(
                                  data: widget.data,
                                  scale: scale,
                                  height: height,
                                  vm: _vm))
                          : MonsterImagePart(
                              data: widget.data,
                              scale: scale,
                              height: height,
                              vm: _vm),
                      RepaintBoundary(
                          child: MonsterAbilityCardWidget(data: widget.data)),
                      RepaintBoundary(
                          child: MonsterStatCardWidget(data: widget.data)),
                    ],
                  ),
                )),
            Container(
              margin: EdgeInsets.only(
                  left: _kMarginH * scale, right: _kMarginH * scale),
              width: getMainListWidth(context) - _kMarginH * scale,
              child: ValueListenableBuilder<BuiltList<MonsterInstance>>(
                  valueListenable: _vm.monsterInstancesNotifier,
                  builder: (context, value, child) {
                    return _buildMonsterBoxGrid(scale);
                  }),
            ),
          ]));
        });
  }
}
