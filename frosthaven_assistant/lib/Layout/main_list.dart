import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/character_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:reorderableitemsview/reorderableitemsview.dart';
import 'package:reorderables/reorderables.dart';

import '../Resource/action_handler.dart';
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
      child = CharacterWidget(characterClass: character.characterClass);
      height = 60 * scale; //TODO:cna I get implicit height?
      //TODO put in ListItemData, and have it change depending on summons+monster instances
    } else if (data is Monster) {
      Monster monster = data as Monster;
      child = MonsterWidget(data: monster);
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
    //_MainListState.scrollToTop();
  }

  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final GameState _gameState = getIt<GameState>();

  void setCurrentTurn(int index) {
    //gray out all above, expire conditions/(un-expire if last current was lower down in list)
  }

  void sortList() {
    setState(() {
      GameMethods.sortByInitiative();
    });
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
    //TODO: doesn't work. also screws up everything?
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
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

  Widget buildList() {
    return Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
            //needed to make background transparent if reorder is enabled
            backgroundColor: Colors.transparent,
            cardColor: Colors.transparent,
            focusColor: Colors.transparent,
            dialogBackgroundColor: Colors.transparent,
            primaryColor: Colors.transparent,
            highlightColor: Colors.transparent,
            accentColor: Colors.transparent,
            applyElevationOverlayColor: false,
            buttonColor: Colors.transparent,
            disabledColor: Colors.transparent,
            hintColor: Colors.transparent,
            cardTheme: CardTheme(
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
//TODO: how to make move widget not have white bg?
            //other styles
            ),
        child: ValueListenableBuilder<int>(
            valueListenable: _gameState.commandIndex,
            builder: (context, value, child) {
              double scale = getScaleByReference(context);
              final generatedChildren = List<Widget>.generate(
                _gameState.currentList.length,
                (index) => Container(
                    key: Key(_gameState.currentList[index].toString()),
                    child: Item(data: _gameState.currentList[index])),
              );
              return Container(
                  alignment: Alignment.topCenter,
                  child: Scrollbar(
                    controller: scrollController,
                    child: ReorderableWrap(
                      runAlignment: WrapAlignment.start,
                      scrollAnimationDuration: Duration(milliseconds: 500),
                      reorderAnimationDuration: Duration(milliseconds: 500),
                      maxMainAxisCount: getItemsCanFitOneColumn(),
                      //TODO: does not update list (blocked by ValueListenableBuilder?)

                      direction: Axis.vertical,
                      //scrollDirection: Axis.horizontal,
                      //ignorePrimaryScrollController: true,
                      needsLongPressDraggable: true,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          //TODO: should be a command.
                          _gameState.currentList.insert(newIndex,
                              _gameState.currentList.removeAt(oldIndex));
                        });
                      },
                      children: generatedChildren,
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
                  ));
            }));
  }

  static final scrollController = ScrollController();

  //use to animate to position in list:
  final controller = AnimatedListController();
}
