import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/CharacterWidget/character_widget.dart';
import 'package:frosthaven_assistant/Layout/background.dart';
import 'package:frosthaven_assistant/Layout/monster_box.dart';
import 'package:frosthaven_assistant/Layout/view_models/main_list_view_model.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:reorderables/reorderables.dart';

import '../Resource/game_data.dart';
import '../Resource/game_methods.dart';
import '../Resource/ui_utils.dart';
import 'monster_widget.dart';

class MainList extends StatefulWidget {
  const MainList({
    super.key,
    this.gameState,
    this.gameData,
    this.settings,
  });

  static void scrollToTop() {
    MainListState.scrollToTop();
  }

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  MainListState createState() => MainListState();
}

class Item extends StatelessWidget {
  static const double _kCharacterHeight = 60.0;
  static const double _kBoxSpacing = 2.0;
  static const double _kRowHeight = 32.0;
  static const double _kMonsterBodyHeight = 97.6;
  static const int _k2Columns = 2;
  static const int _k3Rows = 3;

  const Item({super.key, required this.data});
  final ListItemData data;

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    Widget child = const SizedBox.shrink();
    double height;
    double listWidth = getMainListWidth(context);
    if (data is Character) {
      Character character = data as Character;
      int? initPreset;
      if (GameMethods.isObjectiveOrEscort(character.characterClass)) {
        initPreset = character.characterState.initiative.value;
      }
      child = CharacterWidget(
          key: Key(character.id),
          characterId: character.id,
          initPreset: initPreset);
      height = _kCharacterHeight * scale;
      final summonList = character.characterState.summonList;
      if (summonList.isNotEmpty) {
        double summonsTotalWidth = 0;
        for (var monsterInstance in summonList) {
          summonsTotalWidth +=
              MonsterBox.getWidth(scale, monsterInstance) + _kBoxSpacing * scale;
        }
        double rows = summonsTotalWidth / listWidth;
        height += _kRowHeight * rows.ceil() * scale;
      }
    } else if (data is Monster) {
      Monster monster = data as Monster;
      child = MonsterWidget(key: Key(monster.id), data: monster);
      int standeeRows = 0;
      if (monster.monsterInstances.isNotEmpty) {
        standeeRows = 1;
      }
      double totalWidthOfMonsterBoxes = 0;
      for (var item in monster.monsterInstances) {
        totalWidthOfMonsterBoxes +=
            MonsterBox.getWidth(scale, item) + _kBoxSpacing * scale;
      }
      if (totalWidthOfMonsterBoxes > listWidth) {
        standeeRows = _k2Columns;
      }
      if (totalWidthOfMonsterBoxes > _k2Columns * listWidth) {
        standeeRows = _k3Rows;
      }
      height = _kMonsterBodyHeight * scale + standeeRows * _kRowHeight * scale;
    } else {
      height = 0;
    }

    return RepaintBoundary(
        child: AnimatedContainer(
      key: child.key,
      height: height,
      duration: const Duration(milliseconds: 500),
      child: child,
    ));
  }
}

class ListAnimation extends StatefulWidget {
  const ListAnimation(
      {super.key,
      required this.index,
      required this.lastIndex,
      required this.child,
      this.skipAnimation = false});

  final int index;
  final int lastIndex;
  final Widget child;
  /// When true the translation offset is forced to zero so no slide plays.
  final bool skipAnimation;

  @override
  State<StatefulWidget> createState() {
    return ListAnimationState();
  }
}

class ListAnimationState extends State<ListAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  CurvedAnimation? _curved;
  double _diff = 0;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller = ctrl;
    _curved = CurvedAnimation(parent: ctrl, curve: Curves.linearToEaseOut);
    // Start animation after first build has computed _diff.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_diff != 0 && mounted) ctrl.forward(from: 0.0);
    });
  }

  @override
  void didUpdateWidget(ListAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.lastIndex != widget.lastIndex) {
      // build() will run before the callback fires, so _diff will be current.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_diff != 0 && mounted) _controller?.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _curved?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //need also last positions
    final positions = MainListState.getItemHeights(context);
    double position = widget.index > 0 ? positions[widget.index - 1] : 0;

    double lastPosition = 0;
    if (widget.lastIndex > 0) {
      if (MainListState.lastPositions.length >= widget.lastIndex) {
        //should be ok except for on reload as we don't bother saving lastPositions to disk
        lastPosition = MainListState.lastPositions[widget.lastIndex - 1];
      }
    }

    // When the caller flags skipAnimation (e.g. a manual reorder) we set _diff
    // to zero so no slide plays, while still letting lastPositions update below.
    _diff = widget.skipAnimation ? 0 : lastPosition - position;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainListState.lastPositions..clear()..addAll(positions);
    });

    final curved = _curved;
    if (curved == null) return widget.child;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - curved.value) * _diff),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class MainListState extends State<MainList> {
  static const int _kTwoColumns = 2;
  static const double _kTopBarHeight = 80.0;
  static const int _kKeyOffset = 3;
  static const double _kHalfHeightFactor = 0.5;

  static void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  static void scrollToPosition(int _) {
    //TODO: implement
  }

  static List<double> getItemHeights(BuildContext context,
      {GameState? gameState}) {
    return MainListState._staticVm?.getItemHeights(context) ??
        MainListViewModel(gameState: gameState).getItemHeights(context);
  }

  static MainListViewModel? _staticVm;

  MainListViewModel? _vmInstance;
  MainListViewModel get _vm => _vmInstance ??= MainListViewModel(
      gameState: widget.gameState,
      gameData: widget.gameData,
      settings: widget.settings,
    );
  List<Widget> _generatedList = [];
  static final scrollController = ScrollController();

  static final List<double> lastPositions = [];

  /// Set to true by [onReorder] so the next [_generateChildren] call skips
  /// the translation animation (the drag widget already animates the move).
  bool _skipNextAnimation = false;

  @override
  void initState() {
    super.initState();
    _staticVm = _vm;

    //this does cause a index 0
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lastPositions..clear()..addAll(_vm.getItemHeights(context));
    });
  }

  @override
  void dispose() {
    _staticVm = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _vm.darkMode,
        builder: (context, value, child) {
          return BackGround(
              child: ValueListenableBuilder<Map<String, CampaignModel>>(
                  valueListenable: _vm.modelData,
                  builder: (context, value, child) {
                    return ValueListenableBuilder<double>(
                        valueListenable: _vm.userScalingMainList,
                        builder: (context, value, child) {
                          return buildList(); // ignore: avoid-returning-widgets, internal layout helper
                        });
                  }));
        });
  }

  int _getItemsForHalfTotalHeight(List<double> widgetPositions) {
    final screenSize = MediaQuery.of(context).size;
    bool canFit2Columns = screenSize.width >= getMainListWidth(context) * _kTwoColumns;
    if (!canFit2Columns) {
      return _vm.currentListLength;
    }
    double screenHeight = screenSize.height - _kTopBarHeight * _vm.userScalingBars;

    if (widgetPositions.isNotEmpty) {
      bool allFitInView = widgetPositions.last < screenHeight * _kTwoColumns;

      for (int i = 0; i < widgetPositions.length; i++) {
        if (widgetPositions[i] > widgetPositions.last / _kTwoColumns) {
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

  List<Widget> _generateChildren() {
    final skipAnimation = _skipNextAnimation;
    _skipNextAnimation = false;

    List<Widget> generatedListAnimators = [];
    List<int> indices = [];
    for (int i = 0; i < _vm.currentListLength; i++) {
      int index = i;
      if (_generatedList.length > i) {
        for (int j = 0; j < _generatedList.length; j++) {
          String key = _generatedList[j].key.toString();
          key = key.substring(_kKeyOffset, key.length - _kKeyOffset);
          if (key == _vm.itemIdAt(i)) {
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
      _vm.currentListLength,
      (index) {
        return Item(
            key: Key(_vm.itemIdAt(index)), data: _vm.itemAt(index));
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
      for (int i = generatedListAnimators.length;
          i < _generatedList.length;
          i++) {
        generatedListAnimators.add(RepaintBoundary(
            child: ListAnimation(
                index: i,
                lastIndex: indices[i],
                skipAnimation: skipAnimation,
                child: _generatedList[i])));
      }
    }

    if (generatedListAnimators.length > _generatedList.length) {
      for (int i = _generatedList.length;
          i < generatedListAnimators.length;
          i++) {
        _generatedList.add(Container());
      }
    }

    return generatedListAnimators;
  }

  Widget buildList() {
    return ValueListenableBuilder<int>(
        valueListenable: _vm.updateList,
        builder: (context, value, child) {
          double width = getMainListWidth(context);
          final screenSize = MediaQuery.of(context).size;
          bool canFit2Columns = screenSize.width >= width * _kTwoColumns;
          if (canFit2Columns) {
            width *= _kTwoColumns;
          }
          List<double> itemHeights = _vm.getItemHeights(context);
          int itemsPerColumn = _getItemsForHalfTotalHeight(itemHeights);
          int itemsColumn2 = itemHeights.length - itemsPerColumn;
          itemsPerColumn = max(itemsPerColumn, itemsColumn2);
          bool ignoreScroll = false;
          double paddingBottom = _kHalfHeightFactor * screenSize.height;

          return Container(
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                  child: Scrollbar(
                      interactive: !ignoreScroll,
                      controller: scrollController,
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              child: RepaintBoundary(
                                child: ReorderableWrap(
                                  padding:
                                      EdgeInsets.only(bottom: paddingBottom),
                                  scrollAnimationDuration:
                                      const Duration(milliseconds: 400),
                                  reorderAnimationDuration:
                                      const Duration(milliseconds: 400),
                                  maxMainAxisCount: itemsPerColumn,
                                  ignorePrimaryScrollController: ignoreScroll,
                                  direction: Axis.vertical,
                                  buildDraggableFeedback:
                                      defaultBuildDraggableFeedback,
                                  needsLongPressDraggable: true,
                                  onReorder: (int oldIndex, int newIndex) {
                                    _skipNextAnimation = true;
                                    setState(() {
                                      _vm.reorderItem(oldIndex, newIndex);
                                    });
                                  },
                                  children: _generateChildren(), // ignore: avoid-returning-widgets, list-returning helper for ReorderableListView children
                                ),
                              ))))));
        });
  }
}
