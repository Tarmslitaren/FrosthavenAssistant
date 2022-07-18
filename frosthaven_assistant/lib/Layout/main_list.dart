
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/character_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import 'package:reorderables/reorderables.dart';
import '../Resource/commands/reorder_list_command.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'monster_widget.dart';


class Item extends StatelessWidget {
  final ListItemData data;

  const Item({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    late final Widget child;
    double height;
    double listWidth = getMainListWidth(context);
    if (data is Character) {
      Character character = data as Character;
      int? initPreset;
      if(character.characterClass.name == "Escort" || character.characterClass.name == "Objective") {
        initPreset = character.characterState.initiative;
      }
      child = CharacterWidget(
          key: Key(character.characterState.display), character: character, initPreset: initPreset);
      height = 60 * scale;
      if (character.characterState.summonList.value.isNotEmpty) {
        double summonsTotalWidth = 0;
        for (var monsterInstance in character.characterState.summonList.value) {
          summonsTotalWidth += MonsterBox.getWidth(scale, monsterInstance) + 2*scale;
        }
        double rows = summonsTotalWidth / listWidth;
        height += 32 * rows.ceil() * scale;
      }


    } else if (data is Monster) {
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
      height = 122 * 0.8 * scale + standeeRows * 32 * scale;
    } else {
      height = 0;
    }

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

class ListAnimation extends StatefulWidget {
  final int index;
  final int lastIndex;
  final Widget child;
  const ListAnimation({Key? key, required this.index, required this.lastIndex, required this.child}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return ListAnimationState();
  }
}

class ListAnimationState extends State<ListAnimation>{
  bool blockAnimation = false;
  @override
  Widget build(BuildContext context) {{
      //need also last positions
      List<double> positions = _MainListState.getItemHeights(context);// - the end resulting positions.
      double position = 0;
      if(widget.index > 0){
        position = positions[widget.index-1];
      }

      double lastPosition = 0;
      if(widget.lastIndex > 0){
        if(_MainListState.lastPositions.length >=widget.lastIndex) { //should be ok except for on reload as we don't bother saving lastPositions ot disk
          lastPosition = _MainListState.lastPositions[widget.lastIndex - 1];
        }
      }

      double diff = lastPosition - position;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _MainListState.lastPositions = positions;
      });

      return TranslationAnimatedWidget.tween(
        translationDisabled: Offset(0, blockAnimation? diff : 0),
        translationEnabled: const Offset(0,  0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.linearToEaseOut, // Curves.decelerate,
        child: widget.child,
        animationFinished: (bool finished){
          blockAnimation = true;
        },


      );
    }
  }
}

class _MainListState extends State<MainList> {
  final GameState _gameState = getIt<GameState>();
  List<Widget> _generatedList = [];
  static final scrollController = ScrollController();

  static late List<double> lastPositions;

  @override
  void initState() {
    super.initState();

    //this does cause a index o
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lastPositions = getItemHeights(context);
    });
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
        child: ValueListenableBuilder<Map<String,CampaignModel>>(
            valueListenable: _gameState.modelData,
            builder: (context, value, child) {
              return _gameState.modelData.value.isNotEmpty != null
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

  static List<double> getItemHeights(BuildContext context){
    GameState gameState = getIt<GameState>();
    double listHeight = 0;
    double scale = getScaleByReference(context);
    double mainListWidth = getMainListWidth(context);

    List<double> widgetPositions = [];
    for (int i = 0; i < gameState.currentList.length; i++) {
      var item = gameState.currentList[i];
      if (item is Character) {
        listHeight += 60;
        if (item.characterState.summonList.value.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in item.characterState.summonList.value) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }
          double rows = listWidth / mainListWidth;
          listHeight += 32 * (rows.ceil());
        }
      }
      if (item is Monster) {
        listHeight += 120 * 0.8;
        if (item.monsterInstances.value.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in item.monsterInstances.value) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }

          double rows = listWidth / mainListWidth;
          listHeight += 32 * rows.ceil();
        }
      }
      widgetPositions.add(listHeight * scale);
    }
    return widgetPositions;

  }

  int getItemsCanFitOneColumn(List<double> widgetPositions) {
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

    //if can't fit without scroll
    if(widgetPositions.length > 0) {
      if (widgetPositions.last > 2 * (screenHeight - 80)) {
        //find center point
        for (int i = 0; i < widgetPositions.length; i++) {
          if (widgetPositions[i] > widgetPositions.last / 2) {
            return i + 1;
          }
        }
      }
      else {
        //make all fit in screen of possible
        for (int i = 0; i < widgetPositions.length; i++) {
          if (widgetPositions[i] > (screenHeight - 80)) {
            //minus height of top and bottom bars
            return i + 1;
          }
        }
      }
    }
    return widgetPositions.length;
  }

  List<Widget> generateChildren() {
    List<Widget> generatedListAnimators = [];
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
        generatedListAnimators.add(ListAnimation(index: i, lastIndex: indices[i], child: _generatedList[i])
            //createAnimatedSwitcher(i, indices[i])
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


  Widget buildList() {
    return ValueListenableBuilder<int>(
            valueListenable: _gameState.updateList,
            builder: (context, value, child) {
              double scale = getScaleByReference(context);
              bool canFit2Columns = MediaQuery.of(context).size.width >= getMainListWidth(context) * 2;
              List<double> itemHeights = getItemHeights(context);
              int itemsPerColumn = getItemsCanFitOneColumn(itemHeights); //no good
              bool ignoreScroll = false;
              if(canFit2Columns && itemHeights.last < 2 * MediaQuery.of(context).size.height -160){
                ignoreScroll = true;
              }
              return Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Scrollbar(

                    controller: scrollController,
                    child: ReorderableWrap(
                      padding: EdgeInsets.only(bottom: 30),
                      
                      runAlignment: WrapAlignment.start,
                      scrollAnimationDuration: Duration(milliseconds: 400),
                      reorderAnimationDuration: Duration(milliseconds: 400),
                      maxMainAxisCount: itemsPerColumn,
                      ignorePrimaryScrollController: ignoreScroll, //this makes it wrap at screen height. turn on if can fit 2 columns and can fit all items in screen

                      direction: Axis.vertical,
                      //ignorePrimaryScrollController: true,
                      buildDraggableFeedback: defaultBuildDraggableFeedback,
                      needsLongPressDraggable: true,
                      controller: scrollController,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          _gameState.action(ReorderListCommand(newIndex, oldIndex));
                        });
                      },
                      children: generateChildren(),
                    ),
                    //)
                  //)
              )
              );
            });
  }
}
