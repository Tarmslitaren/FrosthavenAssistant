import 'dart:math';

import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/character_widget.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import 'package:reorderables/reorderables.dart';
import '../Resource/commands/reorder_list_command.dart';
import '../Resource/state/character.dart';
import '../Resource/state/list_item_data.dart';
import '../Resource/state/monster.dart';
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
      if (character.characterClass.name == "Escort" ||
          character.characterClass.name == "Objective") {
        initPreset = character.characterState.initiative.value;
      }
      child = CharacterWidget(
          key: Key(character.id),
          characterId: character.id,
          initPreset: initPreset);
      height = 60 * scale;
      if (character.characterState.summonList.value.isNotEmpty) {
        double summonsTotalWidth = 0;
        for (var monsterInstance in character.characterState.summonList.value) {
          summonsTotalWidth +=
              MonsterBox.getWidth(scale, monsterInstance) + 2 * scale;
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
    MainListState.scrollToTop();
  }

  @override
  MainListState createState() => MainListState();
}

class ListAnimation extends StatefulWidget {
  final int index;
  final int lastIndex;
  final Widget child;

  const ListAnimation(
      {Key? key,
      required this.index,
      required this.lastIndex,
      required this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListAnimationState();
  }
}

class ListAnimationState extends State<ListAnimation> {
  bool blockAnimation = false;

  @override
  Widget build(BuildContext context) {
    {
      //need also last positions
      List<double> positions = MainListState.getItemHeights(
          context); // - the end resulting positions.
      double position = 0;
      if (widget.index > 0) {
        position = positions[widget.index - 1];
      }

      double lastPosition = 0;
      if (widget.lastIndex > 0) {
        if (MainListState.lastPositions.length >= widget.lastIndex) {
          //should be ok except for on reload as we don't bother saving lastPositions ot disk
          lastPosition = MainListState.lastPositions[widget.lastIndex - 1];
        }
      }

      double diff = lastPosition - position;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        MainListState.lastPositions = positions;
      });

      return TranslationAnimatedWidget.tween(
        translationDisabled: Offset(0, blockAnimation ? diff : 0),
        translationEnabled: const Offset(0, 0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.linearToEaseOut,
        // Curves.decelerate,
        child: widget.child,
        animationFinished: (bool finished) {
          blockAnimation = true;
        },
      );
    }
  }
}

class MainListState extends State<MainList> {
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
    return ValueListenableBuilder<bool>(
        valueListenable: getIt<Settings>().darkMode,
        builder: (context, value, child) {
          return Container(
              //alignment: Alignment.center,
              //width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    //repeat: ImageRepeat.repeat,
                    image: AssetImage(getIt<Settings>().darkMode.value
                        ? 'assets/images/bg/bg.png'
                        : 'assets/images/bg/frosthaven-bg.png')),
              ),
              child: ValueListenableBuilder<Map<String, CampaignModel>>(
                  //TODO: show loading animation while waiting to load from disk.
                  valueListenable: _gameState.modelData,
                  builder: (context, value, child) {
                    return ValueListenableBuilder<double>(
                        valueListenable: getIt<Settings>().userScalingMainList,
                        builder: (context, value, child) {
                          return buildList();
                        });
                  }));
        });
  }

  static void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  static void scrollToPosition(int index) {
    //TODO: implement
  }

  static List<double> getItemHeights(BuildContext context) {
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
        MediaQuery.of(context).size.width >= getMainListWidth(context) * 2;
    if (!canFit2Columns) {
      return _gameState
          .currentList.length; //don't wrap if no space. Probably not needed
    }
    double screenHeight = MediaQuery.of(context).size.height -
        80 * getIt<Settings>().userScalingBars.value;

    //if can't fit without scroll
    if (widgetPositions.isNotEmpty) {
      if (widgetPositions.last > 2 * screenHeight) {
        //find center point
        for (int i = 0; i < widgetPositions.length; i++) {
          if (widgetPositions[i] > widgetPositions.last / 2) {
            return i + 1;
          }
        }
      } else {
        //make all fit in screen if possible
        for (int i = 0; i < widgetPositions.length; i++) {
          if (widgetPositions[i] > screenHeight) {
            //minus height of top and bottom bars
            return i + 1;
          }
        }
      }
    }
    return widgetPositions.length;
  }

  int getItemsForHalfTotalHeight(List<double> widgetPositions) {
    //too bad this has to be done
    bool canFit2Columns =
        MediaQuery.of(context).size.width >= getMainListWidth(context) * 2;
    if (!canFit2Columns) {
      return _gameState
          .currentList.length; //don't wrap if no space. Probably not needed
    }
    double screenHeight = MediaQuery.of(context).size.height -
        80 * getIt<Settings>().userScalingBars.value;

    if (widgetPositions.isNotEmpty) {
      bool allFitInView = false;
      if (widgetPositions.last < screenHeight * 2) {
        //can fit all??
        allFitInView = true;
      }

      //find center point
      for (int i = 0; i < widgetPositions.length; i++) {
        if (widgetPositions[i] > widgetPositions.last / 2) {
          if (allFitInView) {
            if (widgetPositions[i] > screenHeight) {
              return i;
            }
          }
          return i + 1;
        }
      }
    }
    return widgetPositions.length;
  }

  List<Widget> generateChildren() {
    List<Widget> generatedListAnimators = [];
    List<int> indices = [];
    for (int i = 0; i < _gameState.currentList.length; i++) {
      int index = i;
      if (_generatedList.length > i) {
        for (int j = 0; j < _generatedList.length; j++) {
          String key = _generatedList[j].key.toString();
          key = key.substring(3, key.length - 3);
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
      for (int i = generatedListAnimators.length;
          i < _generatedList.length;
          i++) {
        generatedListAnimators.add(ListAnimation(
                index: i, lastIndex: indices[i], child: _generatedList[i])
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

    return generatedListAnimators; //_generatedList;
  }

  Widget buildList() {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.updateList,
        builder: (context, value, child) {
          double width = getMainListWidth(context);
          bool canFit2Columns = MediaQuery.of(context).size.width >= width * 2;
          if (canFit2Columns) {
            width *= 2;
          }
          double paddingLeft = (MediaQuery.of(context).size.width -
                  2 * getMainListWidth(context)) /
              2;
          List<double> itemHeights = getItemHeights(context);
          int itemsPerColumn =
              getItemsForHalfTotalHeight(itemHeights); //no good
          int itemsColumn2 = itemHeights.length - itemsPerColumn;
          itemsPerColumn = max(itemsPerColumn, itemsColumn2);
          bool ignoreScroll = false;
          /*bool canFit2ColumnsWithoutScroll = canFit2Columns &&
              itemHeights.isNotEmpty &&
              itemHeights.last <
                  2 * MediaQuery.of(context).size.height -
                      160 * getIt<Settings>().userScalingBars.value;
          //ignoreScroll = true;
          if (canFit2ColumnsWithoutScroll) {
            ignoreScroll = true;
          }
          ignoreScroll = false;*/ //there is no easy way to add nice amount of padding for this mode.

          double paddingBottom = 0.5 * MediaQuery.of(context).size.height;
          return Container(
              margin: canFit2Columns
                  ? EdgeInsets.only(left: paddingLeft, right: paddingLeft)
                  : null,
              alignment:
                  canFit2Columns ? Alignment.topLeft : Alignment.topCenter,
              width: canFit2Columns ? width : MediaQuery.of(context).size.width,
              //height: 200,
              child: Scrollbar(
                interactive: !ignoreScroll,
                controller: scrollController,
                child: ReorderableWrap(
                  padding: EdgeInsets.only(bottom: paddingBottom),
                  scrollAnimationDuration: const Duration(milliseconds: 400),
                  reorderAnimationDuration: const Duration(milliseconds: 400),
                  maxMainAxisCount: itemsPerColumn,
                  ignorePrimaryScrollController: ignoreScroll,
                  //this makes it wrap at screen height. turn on if can fit 2 columns and can fit all items in screen

                  direction: Axis.vertical,
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
                // )
                //)
              ));
        });
  }
}
