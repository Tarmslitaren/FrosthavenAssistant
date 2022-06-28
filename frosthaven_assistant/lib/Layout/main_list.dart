import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/character_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:great_list_view/great_list_view.dart';
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

class LocalHeroOverlay extends StatefulWidget {
  const LocalHeroOverlay({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  _LocalHeroOverlayState createState() => _LocalHeroOverlayState();
}

class _LocalHeroOverlayState extends State<LocalHeroOverlay> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(builder: (context) => widget.child!),
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final ListItemData data;

  const Item({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (data is Character) {
      Character character = data as Character;
      child = CharacterWidget(
          key: Key(character.id), characterClass: character.characterClass);
    } else if (data is Monster) {
      Monster monster = data as Monster;
      child = MonsterWidget(key: Key(monster.id), data: monster);
    }
    return LocalHero(
      tag: child.key.toString(),
      enabled: !_MainListState.isDragging,
      child: child,
    );
  }
}

class MainList extends StatefulWidget {
  const MainList({Key? key}) : super(key: key);

  static void scrollToTop() {
    //would it work if I turn off the hero animations temporarily?
    _MainListState.scrollToTop();
  }

  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final GameState _gameState = getIt<GameState>();
  List<Widget> _generatedList = [];
  static bool isDragging = false;

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

  static void scrollToTop() {
    scrollController.animateTo(
      0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
    //scrollController.jumpTo(0);
  }

  double getListHeight(){
    double mainListWidth = getMainListWidth(context);
    double scale = getScaleByReference(context);
    double tempScale = 0.8;
    double listHeight = 0;
    for (int i = 0; i < _gameState.currentList.length; i++) {
      var item = _gameState.currentList[i];
      if (item is Character) {
        listHeight += 64; //TODO: + summon list size
      }
      if (item is Monster) {
        listHeight += 124 * tempScale;
        if (item.monsterInstances.value.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in item.monsterInstances.value) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }

          double rows = listWidth.ceil() / mainListWidth.toInt();
          listHeight += 34 * tempScale * (rows.ceil().toDouble());
        }
      }
    }

    return listHeight * 1.2 * scale;
  }

  int getItemsCanFitOneColumn(double listHeight) {
    //too bad this has to be done
    bool canFit2Columns =
        MediaQuery.of(context).size.width >= getMainListWidth(context) * 2;
    if (!canFit2Columns) {
      return _gameState
          .currentList.length; //don't wrap if no space. Probably not needed
    }
    double screenHeight = MediaQuery.of(context).size.height;
    if(listHeight > 2 * screenHeight) {
      //just divide equally
      return (_gameState.currentList.length/2).ceil();
    }
    //TODO: put as many items as possible in first column
    return (_gameState.currentList.length/2).ceil();
  }

  List<Widget> generateChildren() {
    _generatedList = List<Widget>.generate(
      _gameState.currentList.length,
      (index) => Item(
          key: Key(_gameState.currentList[index].id),
          data: _gameState.currentList[index]),
    );
    return _generatedList;
  }


  List<Widget> generateSomeChildren(int startIndex, int length) {
    _generatedList = List<Widget>.generate(
      length,
          (index) => Item(
          key: Key(_gameState.currentList[index+startIndex].id),
          data: _gameState.currentList[index+startIndex]),
    );
    return _generatedList;
  }


  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    //disable the heroes from here? and then re-enable afterwards
    isDragging = true;
    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,

      child: Material(
        elevation: 6.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child: Card(
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
        child: ValueListenableBuilder<int>(
            valueListenable: _gameState.updateList,
            builder: (context, value, child) {
              //1 check can fit 2 columns
              //2 if not, size the container to fix all items
              //3 if can not fit, divide items equally and size containers to fit all items
              //4 todo: reorderable column

              bool canFit2Columns = MediaQuery.of(context).size.width >= getMainListWidth(context) * 2;
              double listHeight = getListHeight();
              int items = getItemsCanFitOneColumn(listHeight);
              int items2 = _gameState.currentList.length-items;

              double heightFor2Columns = listHeight / 2;
              if(heightFor2Columns < MediaQuery.of(context).size.height ) {
                heightFor2Columns = MediaQuery.of(context).size.height;
              }
              //List<Widget> children = generateChildren();

              return  SingleChildScrollView(
                padding: EdgeInsets.zero,
               // margin: EdgeInsets.zero,
                     controller: scrollController,
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width,
                    height: canFit2Columns? heightFor2Columns: listHeight,
                      child: LocalHeroOverlay(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column( //TODO: try reorderable table next
                              //scrollAnimationDuration: Duration(milliseconds: 500),
                              //reorderAnimationDuration: Duration(milliseconds: 500),
                              //maxMainAxisCount: getItemsCanFitOneColumn(),
                              verticalDirection: VerticalDirection.down,
                              //buildDraggableFeedback: defaultBuildDraggableFeedback,
                              //needsLongPressDraggable: true,
                              /*onReorder: (int oldIndex, int newIndex) {
                                //TODO: check draggable example from local_hero instead of this combo that doesn't work properly anyway
                                Future.delayed(Duration(milliseconds: 10), () {
                                  isDragging = false;
                                  //the next sort, the moved object comes from wrong position.

                                });
                                _gameState
                                    .action(ReorderListCommand(newIndex, oldIndex));
                              },*/

                              children: generateSomeChildren(0, items)// children.sublist(0,items),
                            ),
                            canFit2Columns?
                            Column(
                              verticalDirection: VerticalDirection.down,
                              //buildDraggableFeedback: defaultBuildDraggableFeedback,
                              //needsLongPressDraggable: true,
                              /*onReorder: (int oldIndex, int newIndex) {
                                Future.delayed(Duration(milliseconds: 10), () {
                                  isDragging = false;
                                  //the next sort, the moved object comes from wrong position.
                                });
                                _gameState
                                    .action(ReorderListCommand(newIndex, oldIndex));
                              },*/

                              children: generateSomeChildren(items, _gameState.currentList.length-items),// children.sublist(items,children.length),
                            )
                                :Container(
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                            )
                          ],
                        )


                      )
                      ),
                //Container()
              //])
             // )
              );
            }));
  }

  static final scrollController = ScrollController();
}
