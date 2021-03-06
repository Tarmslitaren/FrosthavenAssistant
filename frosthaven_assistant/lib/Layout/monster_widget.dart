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

class MonsterWidget extends StatefulWidget {
  final Monster data;

  final updateList = ValueNotifier<int>(0);

  MonsterWidget({Key? key, required this.data}) : super(key: key);

  @override
  _MonsterWidgetState createState() => _MonsterWidgetState();
}

class _MonsterWidgetState extends State<MonsterWidget> {
  @override
  late List<MonsterInstance> lastList = [];
  void initState() {
    super.initState();
    lastList = widget.data.monsterInstances.value;
  }

  Widget buildMonsterBoxGrid(double scale) {

    int displaystartAnimation = -1;

    if(lastList.length < widget.data.monsterInstances.value.length){
      //find which is new

      for(var item in widget.data.monsterInstances.value){
        bool found = false;
        for(var oldItem in lastList) {
          if(item.standeeNr == oldItem.standeeNr){
            found = true;
            break;
          }
        }
        if (!found){
          displaystartAnimation = item.standeeNr;
          break;
        }
      }
    }

    final generatedChildren = List<Widget>.generate(
        widget.data.monsterInstances.value.length,
        (index) => AnimatedSize( //not really needed now
          key: Key(widget.data.monsterInstances.value[index].standeeNr.toString()),
    duration: const Duration(milliseconds: 300),
        child:
                  MonsterBox(
                      key: Key(widget.data.monsterInstances.value[index].standeeNr.toString()),
                      figureId: widget.data.monsterInstances.value[index].name + widget.data.monsterInstances.value[index].gfx + widget.data.monsterInstances.value[index].standeeNr.toString(),
                  ownerId: widget.data.id,
                  display: displaystartAnimation),
        )
    );
    lastList = widget.data.monsterInstances.value;
    return Wrap(
      runSpacing: 2.0 * scale,
      spacing: 2.0 * scale,
      children: generatedChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * 0.8 * 120;
          return ColorFiltered(
              colorFilter: widget.data.monsterInstances.value.isNotEmpty
                  ? ColorFilter.matrix(identity)
                  : ColorFilter.matrix(grayScale),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                SizedBox(
                  height: 120 * 0.8 * scale,
                  //this dictates size of the cards
                  width: getMainListWidth(context),
                  child: Row(
                    children: [
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
                                      fontSize: 18 * 0.8 * scale,
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
                      left: 4 * scale * 0.8,
                      right: 4 * scale * 0.8),
                  width: getMainListWidth(context) - 4 * scale * 0.8,
                  child: ValueListenableBuilder<int>(
                      valueListenable: getIt<GameState>().killMonsterStandee, // widget.data.monsterInstances,
                      builder: (context, value, child) {
                        return buildMonsterBoxGrid(scale);
                      }),
                ),
              ]));

  }
}
