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

  Item({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    late final Widget child;
    late final double height;
    if (data is Character) {
      Character character = data as Character;
      child = CharacterWidget(
          key: Key(character.id), characterClass: character.characterClass);
      height = 60 * scale; //TODO:can I get implicit height?
    } else if (data is Monster) {
      double listWidth = getMainListWidth(context);
      Monster monster = data as Monster;
      child = MonsterWidget(key: Key(monster.id), data: monster);
      int standeeRows = 0;
      if (monster.monsterInstances.value.isNotEmpty) {
        standeeRows = 1;
      }
      double totalWidthOfMonsterBoxes = 0;
      for (var item in monster.monsterInstances.value) {
        totalWidthOfMonsterBoxes +=
            MonsterBox.getWidth(scale, item) + 2 * scale;
      }
      if (totalWidthOfMonsterBoxes > listWidth) {
        standeeRows = 2;
      }
      if (totalWidthOfMonsterBoxes > 2 * listWidth) {
        standeeRows = 3;
      }
      height = 122 * tempScale * scale + standeeRows * 31 * scale;
      //TODO put in ListItemData, and have it change depending on summons+monster instances
    } else {
      height = 0;
    }

    /*bool isScrolling = _MainListState.isScrolling;
    LocalHero localHero = LocalHero(
      tag: child.key.toString(),
      enabled: isScrolling? false: true,
      child: Material(
          color: Colors.transparent,
          child: child),
    );

    if(localHero.enabled == false) {
      print("ok working as inteded false!");
    }

    return localHero;*/
    //return child;

    var animatedContainer = AnimatedContainer(
      key: child.key,
      height: height,
      duration: const Duration(milliseconds: 500),
      //decoration: const BoxDecoration(
      //  color: Colors.transparent,
      //),
      child: child,
    );
    return animatedContainer;
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
  static final scrollController = ScrollController();
  //static bool isScrolling = false;

  @override
  void initState() {
    super.initState();

    /*Future.delayed(Duration(milliseconds:1000), () { //uly hack to make this late enough.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        /*scrollController.addListener(() {
          print('scrolling');
        });*/
        scrollController.position.isScrollingNotifier.addListener(() {
          if(!scrollController.position.isScrollingNotifier.value) {
            print('scroll is stopped');
            isScrolling = false;
            Future.delayed(Duration(milliseconds:100), (){
                _gameState.updateList.value++; //force rebuild
            });
            //enable hero widget here
          } else {
            print('scroll is started');
            isScrolling = true;
            _gameState.updateList.value++; //force rebuild

            //disable hero widget her
          }
        });
      });
    });*/


  }

  @override
  void dispose() {
    super.dispose();
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
  }

  int getItemsCanFitOneColumn() {
    //too bad this has to be done
    bool canFit2Columns =
        MediaQuery
            .of(context)
            .size
            .width >= getMainListWidth(context) * 2;
    if (!canFit2Columns) {
      return _gameState
          .currentList.length; //don't wrap if no space. Probably not needed
    }
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double listHeight = 0;
    double scale = getScaleByReference(context);
    double mainListWidth = getMainListWidth(context);

    List<double> widgetPositions = [];
    for (int i = 0; i < _gameState.currentList.length; i++) {
      var item = _gameState.currentList[i];
      if (item is Character) {
        listHeight += 64; //TODO: + summon list size
      }
      if (item is Monster) {
        listHeight += 124;
        if (item.monsterInstances.value.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in item.monsterInstances.value) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }

          double rows = listWidth / mainListWidth;
          listHeight += 34 * rows.ceil();
        }
      }
      widgetPositions.add(listHeight);
    }
    //if can't fit without scroll
    if (widgetPositions.last * scale > 3 * (screenHeight - 80)) {
      //find center point
      for (int i = 0; i < widgetPositions.length; i++) {
        if (widgetPositions[i] > widgetPositions.last / 2) {
          if (i + 1 < (widgetPositions.length / 2).ceil()) {
            return (widgetPositions.length / 2)
                .ceil(); //this pretty much overrides the purpose. need other solution for wraps
          }
          return i + 1;
        }
      }
    } else {
      //make all fit in screen of possible
      for (int i = 0; i < widgetPositions.length; i++) {
        if (widgetPositions[i] * scale > (screenHeight - 80)) {
          //minus height of topand bottom bars
          if (i + 1 < (widgetPositions.length / 2).ceil()) {
            return (widgetPositions.length / 2).ceil();
          }
          return i + 1;
        }
      }
    }
    return (widgetPositions.length / 2).ceil();
  }

  AnimatedSwitcher createAnimatedSwitcher(int index, int lastIndex) {
    //TODO: figure out old widget position and slide from there
    //TODO: this is wrong, should have one one way animation per item, not a switcher
    return AnimatedSwitcher(
      key: Key(index.toString()),
      duration: Duration(milliseconds: 1000),
      /*transitionBuilder: (Widget child, Animation<double> animation) {
        //TODO: the offset works well only whn all items are same size
        //switcher might be wrong idea to use, when reorder, and it's not just 2 items switching place like (0,1,2 -> 1,2,0)
        //if only we could get the actual size of widgets ;(
        //offset 1 == 1 x size of widget. soo. calc all widget heights (120 or 60 + 30x rows) + x offset if 2 colums.
        var tween = Tween<Offset>(
            begin: Offset(0, (lastIndex - index).toDouble()), end: Offset(0, 0)
        );
        return SlideTransition(
          position: tween.animate(animation),
          child: child,
        );
      },*/
      //use default animation for now.
      child: _generatedList[index],
    );
  }
  List<Widget> generateChildren() {
    List<AnimatedSwitcher> generatedListAnimators = [];
    List<int> indices = [];
    for(int i = 0; i < _gameState.currentList.length; i++){
      int index = i;
      if(_generatedList.length > i) {
        for (int j = 0; j < _generatedList.length; j++) {

          String key = _generatedList[j].key.toString();
          key = key.substring(3,key.length-3);
          if (key == _gameState.currentList[i].id) {
            if (index != j) {
              index = j;
            }
            break;
          }
        }
      }
      indices.add(index);
    }

    List<Widget> newList = List<Widget>.generate(
      _gameState.currentList.length,
      (index) {
        var item = Item(
            key: Key(_gameState.currentList[index].id),
            data: _gameState.currentList[index]);
        return item;
      },
    );

    for (int i = 0; i < newList.length; i++) {
      if (_generatedList.length > i) {
        _generatedList[i] = newList[i];
      } else {
        _generatedList.add(newList[i]);
      }
    }
    if (_generatedList.length > newList.length) {
      _generatedList = _generatedList.sublist(0, newList.length);
    }

    if (_generatedList.length > generatedListAnimators.length) {
      //make the list longer
      for (int i = generatedListAnimators.length; i < _generatedList.length; i++)
      {
        generatedListAnimators.add(
            createAnimatedSwitcher(i, indices[i])
        );
      }
    }

    if (generatedListAnimators.length > _generatedList.length) {
      for (int i = _generatedList.length;
          i < generatedListAnimators.length;
          i++) {
        _generatedList
            .add(Container()); //add empty widget to override the current
      }
    }

    return generatedListAnimators;//_generatedList;
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
        child: ValueListenableBuilder<int>(
            valueListenable: _gameState.updateList,
            builder: (context, value, child) {
              double scale = getScaleByReference(context);
              return Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Scrollbar(
                    controller: scrollController,
                    child: LocalHeroScope(
                     duration: const Duration(milliseconds: 600),
                     curve: Curves.easeInOut,
                    child: ReorderableWrap(
                      //scrollPhysics: NeverScrollableScrollPhysics(), //disables scrolling
                      runAlignment: WrapAlignment.start,
                      scrollAnimationDuration: Duration(milliseconds: 400),
                      reorderAnimationDuration: Duration(milliseconds: 400),
                      maxMainAxisCount: getItemsCanFitOneColumn(),

                      direction: Axis.vertical,
                      //scrollDirection: Axis.horizontal,
                      //ignorePrimaryScrollController: true,
                      buildDraggableFeedback: defaultBuildDraggableFeedback,
                      needsLongPressDraggable: true,
                      controller: scrollController,
                      onReorder: (int oldIndex, int newIndex) {
                        //setState(() {
                        _gameState
                            .action(ReorderListCommand(newIndex, oldIndex));
                        //});
                      },
                      children: generateChildren(),
                    ),
                    //)
                  )));
            }));
  }
}
