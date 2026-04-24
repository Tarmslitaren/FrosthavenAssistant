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
          summonsTotalWidth += MonsterBox.getWidth(scale, monsterInstance) +
              _kBoxSpacing * scale;
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

/// Wraps a list item and plays a FLIP translation animation when [animateFrom]
/// is called with the item's previous global position.
///
/// Uses [ValueKey] (not GlobalKey) so that [ReorderableWrap] can safely
/// duplicate this widget into the drag-feedback overlay without triggering
/// the "multiple widgets used the same GlobalKey" error. State registration
/// with the parent [_GameListState] uses the [onRegister]/[onUnregister]
/// callbacks; the feedback copy is ignored because the original state is
/// still mounted when the copy registers.
class _FlipItem extends StatefulWidget {
  const _FlipItem({
    required super.key, // ValueKey(itemId)
    required this.itemId,
    required this.onRegister,
    required this.onUnregister,
    required this.child,
  });

  final String itemId;
  final void Function(String id, _FlipItemState state) onRegister;
  final void Function(String id, _FlipItemState state) onUnregister;
  final Widget child;

  @override
  State<_FlipItem> createState() => _FlipItemState();
}

class _FlipItemState extends State<_FlipItem>
    with SingleTickerProviderStateMixin {
  static const Duration _kDuration = Duration(milliseconds: 500);

  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  Offset _startOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kDuration);
    _curved =
        CurvedAnimation(parent: _controller, curve: Curves.linearToEaseOut);
    widget.onRegister(widget.itemId, this);
  }

  @override
  void didUpdateWidget(_FlipItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId) {
      oldWidget.onUnregister(oldWidget.itemId, this);
    }
    widget.onRegister(widget.itemId, this);
  }

  @override
  void dispose() {
    widget.onUnregister(widget.itemId, this);
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Called after the new layout has settled. [globalFrom] is the item's
  /// screen position before the list changed (the "First" in FLIP). Measures
  /// the current "Last" position, computes the invert offset, and plays.
  void animateFrom(Offset globalFrom) {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final globalTo = box.localToGlobal(Offset.zero);
    _startOffset = globalFrom - globalTo;
    if (_startOffset == Offset.zero) return;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, child) => Transform.translate(
          offset: _startOffset * (1 - _curved.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class MainListState extends State<MainList> {
  static const int _kTwoColumns = 2;

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

  MainListViewModel? _vmInstance;
  MainListViewModel get _vm => _vmInstance ??= MainListViewModel(
        gameState: widget.gameState,
        gameData: widget.gameData,
        settings: widget.settings,
      );

  static final scrollController = ScrollController();

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
                          return buildList();
                        });
                  }));
        });
  }

  Widget buildList() {
    final screenSize = MediaQuery.of(context).size;
    double width = getMainListWidth(context);
    bool canFit2Columns = screenSize.width >= width * _kTwoColumns;
    if (canFit2Columns) {
      width *= _kTwoColumns;
    }

    return Container(
        alignment: Alignment.topCenter,
        child: RepaintBoundary(
            child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                        alignment: Alignment.center,
                        width: screenSize.width,
                        child: RepaintBoundary(
                          child: _GameList(vm: _vm),
                        ))))));
  }
}

class _GameList extends StatefulWidget {
  const _GameList({required this.vm});

  final MainListViewModel vm;

  @override
  State<_GameList> createState() => _GameListState();
}

class _GameListState extends State<_GameList> {
  static const int _kTwoColumns = 2;
  static const double _kTopBarHeight = 80.0;
  static const double _kHalfHeightFactor = 0.5;

  /// Live references to mounted [_FlipItemState]s, keyed by item ID.
  /// The drag-feedback copy of a [_FlipItem] is silently ignored in
  /// [_registerFlipState] because the original state is still mounted.
  final Map<String, _FlipItemState> _flipStates = {};
  List<Widget> _cachedChildren = const [];
  bool _skipNextAnimation = false;
  bool _isDragging = false;

  void _registerFlipState(String id, _FlipItemState state) {
    _flipStates[id] = state;
  }

  void _unregisterFlipState(String id, _FlipItemState state) {
    if (_flipStates[id] == state) _flipStates.remove(id);
  }

  /// Snapshot each currently-mounted item's global top-left position.
  Map<String, Offset> _capturePositions() {
    final result = <String, Offset>{};
    for (final entry in _flipStates.entries) {
      if (!entry.value.mounted) continue;
      final box =
          entry.value.context.findRenderObject() as RenderBox?;
      if (box != null && box.attached) {
        result[entry.key] = box.localToGlobal(Offset.zero);
      }
    }
    return result;
  }

  /// After the new layout has rendered, trigger FLIP on every item that has
  /// a captured "from" position.
  void _playFlipAnimations(Map<String, Offset> fromPositions) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final entry in fromPositions.entries) {
        _flipStates[entry.key]?.animateFrom(entry.value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.vm.updateList.addListener(_onUpdateList);
    _cachedChildren = _buildChildren();
  }

  @override
  void didUpdateWidget(_GameList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.vm, widget.vm)) {
      oldWidget.vm.updateList.removeListener(_onUpdateList);
      widget.vm.updateList.addListener(_onUpdateList);
    }
  }

  @override
  void dispose() {
    widget.vm.updateList.removeListener(_onUpdateList);
    super.dispose();
  }

  void _onUpdateList() {
    final skipAnimation = _skipNextAnimation || _isDragging;
    _skipNextAnimation = false;
    final fromPositions = skipAnimation ? null : _capturePositions();
    setState(() {
      _cachedChildren = _buildChildren();
    });
    if (fromPositions != null) {
      _playFlipAnimations(fromPositions);
    }
  }

  List<Widget> _buildChildren() {
    final vm = widget.vm;
    final currentIds = <String>{};
    final children = List<Widget>.generate(
      vm.currentListLength,
      (i) {
        final id = vm.itemIdAt(i);
        currentIds.add(id);
        return RepaintBoundary(
          child: _FlipItem(
            key: ValueKey(id),
            itemId: id,
            onRegister: _registerFlipState,
            onUnregister: _unregisterFlipState,
            child: Item(key: Key(id), data: vm.itemAt(i)),
          ),
        );
      },
    );
    _flipStates.removeWhere(
        (id, state) => !currentIds.contains(id) && !state.mounted);
    return children;
  }

  int _getItemsForHalfTotalHeight(
      List<double> widgetPositions, Size screenSize) {
    double listWidth = getMainListWidth(context);
    bool canFit2Columns = screenSize.width >= listWidth * _kTwoColumns;
    if (!canFit2Columns) {
      return widget.vm.currentListLength;
    }
    double screenHeight =
        screenSize.height - _kTopBarHeight * widget.vm.userScalingBars;

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    List<double> itemHeights = widget.vm.getItemHeights(context);
    int itemsPerColumn = _getItemsForHalfTotalHeight(itemHeights, screenSize);
    int itemsColumn2 = itemHeights.length - itemsPerColumn;
    itemsPerColumn = max(itemsPerColumn, itemsColumn2);
    double paddingBottom = _kHalfHeightFactor * screenSize.height;

    return ReorderableWrap(
      padding: EdgeInsets.only(bottom: paddingBottom),
      scrollAnimationDuration: const Duration(milliseconds: 400),
      reorderAnimationDuration: const Duration(milliseconds: 400),
      maxMainAxisCount: itemsPerColumn,
      ignorePrimaryScrollController: false,
      direction: Axis.vertical,
      buildDraggableFeedback: defaultBuildDraggableFeedback,
      needsLongPressDraggable: true,
      onReorderStarted: (index) {
        _isDragging = true;
      },
      onNoReorder: (index) {
        _isDragging = false;
      },
      onReorder: (int oldIndex, int newIndex) {
        _isDragging = false;
        _skipNextAnimation = true;
        widget.vm.reorderItem(oldIndex, newIndex);
      },
      children: _cachedChildren,
    );
  }
}
