import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/character_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:local_hero/local_hero.dart';
//import 'package:great_list_view/great_list_view.dart';
//import 'package:reorderableitemsview/reorderableitemsview.dart';
import 'package:reorderables/reorderables.dart';

import '../Resource/action_handler.dart';
import '../Resource/commands/reorder_list_command.dart';
import '../Resource/game_methods.dart';
import '../services/service_locator.dart';
import 'monster_widget.dart';

double tempScale = 0.8;

class Item extends StatelessWidget {
  final ListItemData data;

  const Item({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    late final Widget child;
    late final double height;
    if (data is Character) {
      Character character = data as Character;
      child = CharacterWidget(key: Key(character.id), characterClass: character.characterClass);
      height = 60 * scale; //TODO:cna I get implicit height?
      //TODO put in ListItemData, and have it change depending on summons+monster instances
    } else if (data is Monster) {
      Monster monster = data as Monster;
      child = MonsterWidget(key: Key(monster.id), data: monster);
      int standeeRows = 0;
      if (monster.monsterInstances.value.length > 0) {
        standeeRows = 1;
      }
      if (monster.monsterInstances.value.length > 4) {
        standeeRows = 2;
      }
      height = 120 * tempScale * scale + standeeRows * 50;
      //TODO put in ListItemData, and have it change depending on summons+monster instances
    } else {
      height = 0;
    }
    /*return LocalHero(
      tag: child.key.toString(),
      child: child,
    );*/
    return child;
    return AnimatedContainer(
      height: height,
      duration: const Duration(milliseconds: 500),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: child,
    );
  }
}

class MainList extends StatefulWidget {
  const MainList({Key? key}) : super(key: key);

  static void scrollToTop() {
    _MainListState.scrollToTop();
  }

  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final GameState _gameState = getIt<GameState>();
  List<Widget> _generatedList = [];

  void setCurrentTurn(int index) {
    //gray out all above, expire conditions/(un-expire if last current was lower down in list)
  }

  void sortList() {
    GameMethods.sortByInitiative();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //alignment: Alignment.center,
        //width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
              image: AssetImage('assets/images/bg/frosthaven-bg.png')),
        ),
        child: ValueListenableBuilder<CampaignModel?>(
            valueListenable: _gameState.modelData,
            builder: (context, value, child) {
              return _gameState.modelData.value != null
                  ? buildList()
                  : const Center(child: CircularProgressIndicator());
            }));
  }

  bool isSameContent(ListItemData a, ListItemData b) {
    //todo: notify difference if height changes (i.e. monster/summon added
    return true; //
  }

  bool isSameItem(ListItemData a, ListItemData b) {
    return a.id == b.id;
  }

  static void scrollToTop() {
    scrollController.animateTo(
      0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
    //scrollController.jumpTo(0);
  }

  int getItemsCanFitOneColumn() {
    //too bad this has to be done
    bool canFit2Columns =
        MediaQuery.of(context).size.width >= getMainListWidth(context) * 2;
    if (!canFit2Columns) {
      return _gameState
          .currentList.length; //don't wrap if no space. Probably not needed
    }
    double screenHeight = MediaQuery.of(context).size.height;
    double listHeight = 0;
    double scale = getScaleByReference(context);
    double mainListWidth = getMainListWidth(context);

    List<double> widgetPositions = [];
    for (int i = 0; i < _gameState.currentList.length; i++) {
      var item = _gameState.currentList[i];
      if (item is Character) {
        listHeight += 62; //TODO: + summon list size
      }
      if (item is Monster) {
        listHeight += 130;
        if (item.monsterInstances.value.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in item.monsterInstances.value) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }

          double rows = listWidth.toInt() / mainListWidth.toInt();
          listHeight += 40 * (rows.floor().toDouble() + 1);
        }
      }
      widgetPositions.add(listHeight);
    }
    if (widgetPositions.last > 2 * screenHeight) {
      //find center point
      for (int i = 0; i < widgetPositions.length; i++) {
        if (widgetPositions[i] > widgetPositions.last / 2) {
          return i + 1;
        }
      }
    } else {
      //make all fit in screen of possible
      for (int i = 0; i < widgetPositions.length; i++) {
        if (widgetPositions[i] > screenHeight * 0.8) {
          //TODO: use real values instead of leeway.
          return i;
        }
      }
    }
    return _gameState.currentList.length;
  }



  List<Widget> generateChildren() {
    //insert, remove and reorder. don't recreate. let's see about them animations.
    //this causes items not to update their inner shit unless they are moved.
    //I suppose I could do special hacks her since I know which items move where - add some hacky animation solution?
    /*for (int i = 0; i < _gameState.currentList.length; i++) {
      var data = _gameState.currentList[i];
      bool found = false;

      for(int j = 0; j <_generatedList.length; j++) {
        var widget = _generatedList[j];
        if(widget.data == data) {
          //reorder
          found = true;
          if(i != j) {
            _generatedList.insert(i, _generatedList.removeAt(j));
          }
          break;
        }
      }
      if(!found) {
        //create new
        _generatedList.insert(i,
          Item(data: data), //TODO: do I need the container or key?
        );
      }
    }

    //remove extras
    if(_generatedList.length > _gameState.currentList.length){
      for(var item in _generatedList) {
        bool found = false;
        for (var data in _gameState.currentList){
          if(item.data == data) {
            found = true;
            break;
          }
        }
        if (!found){
          _generatedList.remove(item);
        }
      }
    }*/



    _generatedList = List<Widget>.generate(
      //TODO: this is probably super inefficient and also blocks animation
      _gameState.currentList.length,
      (index) => Item(key: Key(_gameState.currentList[index].id), data: _gameState.currentList[index]),
    );
    return _generatedList;
  }

  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
        elevation: 6.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child: Card(
            //shadowColor: Colors.red,
            color: Colors.transparent,
            child: ConstrainedBox(constraints: constraints, child: child)),
      ),
    );
  }

  Widget buildList() {
    return Theme(
        data: Theme.of(context).copyWith(
            //not needed
            ),
        child: ValueListenableBuilder<int>( //todo listen for changes in list, not all commands?
            valueListenable: _gameState.updateList,
            builder: (context, value, child) {
              double scale = getScaleByReference(context);
              return Container(
                  alignment: Alignment.topCenter,
                  child: Scrollbar(
                    controller: scrollController,
                    //child: LocalHeroScope(
                     // duration: const Duration(milliseconds: 300),
                     // curve: Curves.easeInOut,
                    child: ReorderableWrap(
                      runAlignment: WrapAlignment.start,
                      scrollAnimationDuration: Duration(milliseconds: 500),
                      reorderAnimationDuration: Duration(milliseconds: 500),
                      maxMainAxisCount: getItemsCanFitOneColumn(),

                      direction: Axis.vertical,
                      //scrollDirection: Axis.horizontal,
                      //ignorePrimaryScrollController: true,
                      buildDraggableFeedback: defaultBuildDraggableFeedback,
                      needsLongPressDraggable: true,
                      controller: scrollController,
                      onReorder: (int oldIndex, int newIndex) {
                        //setState(() {
                          _gameState.action(ReorderListCommand(newIndex, oldIndex));
                          //_gameState.currentList.insert(newIndex,
                          //    _gameState.currentList.removeAt(oldIndex));
                        //});
                      },
                      children: generateChildren(),
                    ),
                    /*AutomaticAnimatedListView<ListItemData>(
                      animator: const DefaultAnimatedListAnimator(
                          //dismissIncomingDuration: Duration(milliseconds: 1000),
                          //reorderDuration: Duration(milliseconds: 2000),

                          //dismissIncomingDuration: const Duration(milliseconds: 150),
                          //resizeDuration: const Duration(milliseconds: 200),
                          ),
                      list: _gameState.currentList,
                      comparator: AnimatedListDiffListComparator<ListItemData>(
                          sameItem: (a, b) => isSameItem(a, b),
                          sameContent: (a, b) => isSameContent(a, b)),
                      itemBuilder: (context, item, data) => data.measuring
                          ? Container(
                              color: Colors.transparent,
                              height:
                                  item is Monster ? 120 * tempScale* scale : 60 * scale,
                              //TODO: these are for smooth animations. need to be same size as the items
                              //margin: const EdgeInsets.all(5), height: 60
                            )
                          : Item(data: item),
                      listController: controller,
                      scrollController: scrollController,
                      addLongPressReorderable: true,

                      /*reorderModel: AnimatedListReorderModel(


                onReorderStart: (index, dx, dy) {
                  // only monster+character items can be reordered
                  return true;
                },
                onReorderMove: (index, dropIndex) {
                  // pink-colored items cannot be swapped
                  return true;//list[dropIndex].color != 3;
                },
                onReorderComplete: (index, dropIndex, slot) {
                  _gameState.currentList.insert(dropIndex, _gameState.currentList.removeAt(index));
                  return true;
                },
              ),*/

                      reorderModel: AutomaticAnimatedListReorderModel(
                          _gameState.currentList),
                    ),*/
                  //)
              ));
            }));
  }

  static final scrollController = ScrollController();

  //use to animate to position in list:
  //final controller = AnimatedListController();
}
