//portrait + name
//ability card
//stat sheet
//monster boxes
import 'package:flutter/material.dart';

//import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
//import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Resource/color_matrices.dart';
import 'monster_stat_card.dart';

double tempScale = 0.8;

class MonsterWidget extends StatefulWidget {
  final Monster data;

  const MonsterWidget({Key? key, required this.data}) : super(key: key);

  @override
  _MonsterWidgetState createState() => _MonsterWidgetState();
}

class _MonsterWidgetState extends State<MonsterWidget> {
  @override
  void initState() {
    super.initState();
  }

  /*
  MasonryGridView.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  itemBuilder: (context, index) {
    return Tile(
      index: index,
      extent: (index % 5 + 1) * 100,
    );
  },
);
   */

  /*int getRowsNeeded(){
    return 2;
  }*/

  Widget buildMonsterBoxGrid() {
    final generatedChildren = List<Widget>.generate(
      widget.data.monsterInstances.value.length,
      (index) => Container(
        key: Key(widget.data.monsterInstances.value[index].toString()),
        child: MonsterBox(data: widget.data.monsterInstances.value[index]),
      ),
    );
    return Wrap(
      runSpacing: 4.0,
      spacing: 4.0,
      children: generatedChildren,
    );
  }

  /*Widget buildMonsterBoxGrid_old_2() {
    return MasonryGridView.count(
        crossAxisCount: getRowsNeeded(),
        //crossAxisCount: ViewStateHelper.getColumnCount(_viewState),
        itemCount: widget.data.monsterInstances.value.length,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        scrollDirection: Axis.horizontal,


        itemBuilder: (context, index) {
          return MonsterBox(
            data: widget.data.monsterInstances.value[index]
          );
        });



    /*return ReorderableBuilder(
      children: generatedChildren,
      enableDraggable: false,
      enableLongPress: false,
      enableScrollingWhileDragging: false,
      builder: (children) {
        return GridView(

          scrollDirection: Axis.horizontal,
          //key: _gridViewKey,
          //controller: _scrollController,

          //shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            //crossAxisCount: 2, //fucked up that this dictates size of children
            maxCrossAxisExtent: 60,//getMainListWidth(context),
            mainAxisExtent: 120,

            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          //key: _gridViewKey,
          //controller: _scrollController,
          children: children,

        );
      },
    );*/
  }*/

  /*Widget buildMonsterBoxGrid_old() {
    final generatedChildren = List<Widget>.generate(
      widget.data.monsterInstances.value.length,
      (index) => Container(
        key: Key(widget.data.monsterInstances.value[index].toString()),
        child:  MonsterBox(data: widget.data.monsterInstances.value[index]),
      ),
    );
    return ReorderableBuilder(
      //key: Key(_gridViewKey.toString()),
      children: generatedChildren,
      //onReorder: _handleReorder,
      //lockedIndices: lockedIndices,
      //onDragStarted: _handleDragStarted,
      //onDragEnd: _handleDragEnd,
      //scrollController: _scrollController,
      enableDraggable: false,
      enableLongPress: false,
      enableScrollingWhileDragging: false,
      builder: (children) {
        return GridView(

          scrollDirection: Axis.horizontal,
          //key: _gridViewKey,
          //controller: _scrollController,

          //shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            //crossAxisCount: 2, //fucked up that this dictates size of children
            maxCrossAxisExtent: 60,//getMainListWidth(context),
            mainAxisExtent: 120,

            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          //key: _gridViewKey,
          //controller: _scrollController,
          children: children,

        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * tempScale * 120;
    bool active = false;
    if (widget.data.monsterInstances.value.isNotEmpty) {
      active = true;
    }
    return ColorFiltered(
        colorFilter: active
            ? ColorFilter.matrix(identity)
            : ColorFilter.matrix(grayScale),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          SizedBox(
            height: 120 * tempScale * scale, //this dictates size of the cards
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
                    child: Stack(alignment: Alignment.bottomCenter, children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 4 * scale, top: 4 * scale),
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
                                  offset: Offset(1 * scale, 1 * scale),
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
            width: getMainListWidth(context),
            child: ValueListenableBuilder<List<MonsterInstance>>(
                valueListenable: widget.data.monsterInstances,
                builder: (context, value, child) {
                  return buildMonsterBoxGrid();
                }),
          ),
          //TODO: add standees list here (AnimatbleGrid?)
        ]));
  }
}
