import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Resource/color_matrices.dart';
import '../services/service_locator.dart';
import 'monster_stat_card.dart';

class MonsterWidget extends StatefulWidget {
  final Monster data;

  final updateList = ValueNotifier<int>(0);

  MonsterWidget({super.key, required this.data});

  @override
  MonsterWidgetState createState() => MonsterWidgetState();
}

class MonsterWidgetState extends State<MonsterWidget> {
  late List<MonsterInstance> lastList = [];

  @override
  void initState() {
    super.initState();
    lastList = widget.data.monsterInstances.asList();
  }

  Widget buildMonsterBoxGrid(double scale) {
    String displayStartAnimation = "";

    if (lastList.length < widget.data.monsterInstances.length) {
      //find which is new

      for (var item in widget.data.monsterInstances) {
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
        widget.data.monsterInstances.length,
        (index) => AnimatedSize(
              key:
                  Key(widget.data.monsterInstances[index].standeeNr.toString()),
              duration: const Duration(milliseconds: 300),
              child: MonsterBox(
                  key: Key(
                      widget.data.monsterInstances[index].standeeNr.toString()),
                  figureId: widget.data.monsterInstances[index].name +
                      widget.data.monsterInstances[index].gfx +
                      widget.data.monsterInstances[index].standeeNr.toString(),
                  ownerId: widget.data.id,
                  displayStartAnimation: displayStartAnimation,
                  blockInput: false,
                  scale: scale),
            ));
    lastList = widget.data.monsterInstances.toList();
    return Wrap(
      runSpacing: 2.0 * scale,
      spacing: 2.0 * scale,
      children: generatedChildren,
    );
  }

  Widget buildImagePart(double height, double scale) {
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(widget.data.type);
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
          margin: EdgeInsets.only(bottom: 4 * scale, top: 4 * scale),
          child: PhysicalShape(
            color: widget.data.turnState.value == TurnsState.current
                ? Colors.tealAccent
                : Colors.transparent,
            //or bleu if current
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
          margin: EdgeInsets.only(bottom: frosthavenStyle ? 2 * scale : 0),
          child: Text(
            textAlign: TextAlign.center,
            widget.data.type.display,
            style: TextStyle(
                fontFamily: frosthavenStyle ? "GermaniaOne" : 'Pirata',
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * 96;
    return ValueListenableBuilder<int>(
        valueListenable: getIt<GameState>().updateList,
        builder: (context, value, child) {
          return Column(mainAxisSize: MainAxisSize.max, children: [
            ColorFiltered(
                colorFilter: (widget.data.monsterInstances.isNotEmpty ||
                            widget.data.isActive) &&
                        (widget.data.turnState.value != TurnsState.done ||
                            getIt<GameState>().roundState.value ==
                                RoundState.chooseInitiative)
                    ? ColorFilter.matrix(identity)
                    : ColorFilter.matrix(grayScale),
                child: SizedBox(
                  height: 96 * scale,
                  //this dictates size of the cards
                  width: getMainListWidth(context),
                  child: Row(
                    children: [
                      getIt<GameState>().roundState.value ==
                                  RoundState.playTurns &&
                              (widget.data.monsterInstances.isNotEmpty ||
                                  widget.data.isActive)
                          ? InkWell(
                              canRequestFocus: false,
                              onTap: () {
                                getIt<GameState>()
                                    .action(TurnDoneCommand(widget.data.id));
                              },
                              child: buildImagePart(height, scale))
                          : buildImagePart(height, scale),
                      MonsterAbilityCardWidget(data: widget.data),
                      MonsterStatCardWidget(data: widget.data),
                    ],
                  ),
                )),
            Container(
              margin: EdgeInsets.only(left: 3.2 * scale, right: 3.2 * scale),
              width: getMainListWidth(context) - 3.2 * scale,
              child: ValueListenableBuilder<int>(
                  valueListenable: getIt<GameState>().killMonsterStandee,
                  builder: (context, value, child) {
                    return buildMonsterBoxGrid(scale);
                  }),
            ),
          ]);
        });
  }
}
