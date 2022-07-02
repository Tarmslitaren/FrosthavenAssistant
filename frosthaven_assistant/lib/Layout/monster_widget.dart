//portrait + name
//ability card
//stat sheet
//monster boxes
import 'package:flutter/material.dart';

import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Resource/color_matrices.dart';
import '../services/service_locator.dart';
import 'monster_stat_card.dart';

double tempScale = 0.8;

class MonsterWidget extends StatefulWidget {
  final Monster data;

  final updateList = ValueNotifier<int>(0);

  MonsterWidget({Key? key, required this.data}) : super(key: key);

  @override
  _MonsterWidgetState createState() => _MonsterWidgetState();
}

class _MonsterWidgetState extends State<MonsterWidget> {
  @override
  late int lastListLength;
  void initState() {
    super.initState();
    lastListLength = widget.data.monsterInstances.value.length;
  }

  Widget buildMonsterBoxGrid(double scale) {

    bool display = lastListLength != widget.data.monsterInstances.value.length;

    final generatedChildren = List<Widget>.generate(
        widget.data.monsterInstances.value.length,
        (index) => AnimatedSwitcher( //TODO: why is this not working?
            key: Key(widget.data.monsterInstances.value[index].standeeNr.toString()),
          duration: Duration(milliseconds: 1600),
              child:
                  MonsterBox(
                      key: Key(widget.data.monsterInstances.value[index].standeeNr.toString()),
                      data: widget.data.monsterInstances.value[index],
                  display: display),
            //)
        ));
    lastListLength = generatedChildren.length;
    return Wrap(
      runSpacing: 2.0 * scale,
      spacing: 2.0 * scale,
      children: generatedChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * tempScale * 120;
          return ColorFiltered(
              colorFilter: widget.data.monsterInstances.value.isNotEmpty
                  ? ColorFilter.matrix(identity)
                  : ColorFilter.matrix(grayScale),
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                SizedBox(
                  height: 120 * tempScale * scale,
                  //this dictates size of the cards
                  width: getMainListWidth(context),
                  child: Row(
                    children: [
                      /*GestureDetector( //reason to remove this: blocks drag and drop non long press
                onVerticalDragStart: (details) {
                  //start moving the widget in the list
                },
                onVerticalDragUpdate: (details) {
                  //update widget position?
                },
                onVerticalDragEnd: (details) {
                  //place back in list
                },
                onTap: () {
                  //open stats menu
                  setState(() {});
                },
                child:*/
                      Container(
                          //margin: EdgeInsets.all(2*tempScale*scale),
                          child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: 4 * scale, top: 4 * scale),
                              child: Image(
                                //fit: BoxFit.contain,
                                height: height,
                                width: height,
                                image: AssetImage(
                                    "assets/images/monsters/${widget.data.type.gfx}.png"),
                                //width: widget.height*0.8,
                              ),
                            ),
                            Container(
                                width: height * 0.95,
                                //height: height,
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  widget.data.type.display,
                                  style: TextStyle(
                                      fontFamily: 'Pirata',
                                      color: Colors.white,
                                      fontSize: 18 * tempScale * scale,
                                      shadows: [
                                        Shadow(
                                            offset:
                                                Offset(1 * scale, 1 * scale),
                                            color: Colors.black)
                                      ]),
                                ))
                          ])
                          //)
                          ),
                      MonsterAbilityCardWidget(data: widget.data),
                      MonsterStatCardWidget(data: widget.data),
                    ],
                  ),
                ),
                Container(
                  //color: Colors.amber,
                  //height: 50,
                  margin: EdgeInsets.only(
                      left: 4 * scale * tempScale,
                      right: 4 * scale * tempScale),
                  width: getMainListWidth(context) - 4 * scale * tempScale,
                  child: ValueListenableBuilder<int>(
                      valueListenable: getIt<GameState>().killMonsterStandee, // widget.data.monsterInstances,
                      builder: (context, value, child) {
                        return buildMonsterBoxGrid(scale);
                      }),
                ),
              ]));

  }
}
