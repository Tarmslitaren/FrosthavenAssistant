import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_amd_card_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:reorderables/reorderables.dart';

import '../../../Resource/game_methods.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../../services/service_locator.dart';
import 'modifier_deck_header.dart';
import 'modifier_deck_item.dart';

class ModifierDeckMenu extends StatefulWidget {
  static const double _kListWidthRatio = 0.3;
  static const int _kReorderAnimationMs = 400;
  static const double _kHeaderBorderRadius = 4.0;
  static const double _kHeaderMargin = 2.0;
  static const double _kFooterHeight = 32.0;
  static const double _kFooterBottomPos = 4.0;
  static const double _kNameLeftPos = 20.0;

  const ModifierDeckMenu({
    super.key,
    required this.name,
    this.gameState,
    this.settings,
  });

  final String name;

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  ModifierDeckMenuState createState() => ModifierDeckMenuState();
}

class ModifierDeckMenuState extends State<ModifierDeckMenu> {
  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  Settings get _settings => widget.settings ?? getIt<Settings>();
  final scrollController = ScrollController();

  bool isRevealed(ModifierCard item) {
    ModifierDeck deck = GameMethods.getModifierDeck(widget.name, _gameState);
    final drawPile = deck.drawPileContents.reversed.toList();
    for (int i = 0; i < deck.revealedCount.value; i++) {
      if (item == drawPile[i]) {
        return true;
      }
    }
    return false;
  }

  List<Widget> generateList(
      List<ModifierCard> inputList, bool allOpen, String name) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      final key = index.toString();
      final item = inputList[index];
      ModifierDeckItem value = ModifierDeckItem(
          key: Key(key),
          data: item,
          name: name,
          revealed: isRevealed(item) || allOpen);
      if (!allOpen) {
        InkWell gestureDetector = InkWell(
          key: Key(key),
          onTap: () {
            openDialog(
                context,
                SendToBottomMenu(
                  currentIndex: index,
                  length: inputList.length,
                  name: name,
                  revealed: isRevealed(item) || allOpen,
                ));
          },
          child: value,
        );
        list.add(gestureDetector);
      } else {
        InkWell gestureDetector = InkWell(
          key: Key(index.toString()),
          onTap: () {
            openDialog(context, RemoveAMDCardMenu(index: index, name: name));
          },
          child: value,
        );
        list.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            key: Key(index.toString()),
            children: [gestureDetector]));
      }
    }
    return list;
  }

  Widget buildList(
      List<ModifierCard> list, bool reorderable, bool allOpen, String name) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: SizedBox(
          width: screenWidth * ModifierDeckMenu._kListWidthRatio,
          child: reorderable
              ? ReorderableColumn(
                  needsLongPressDraggable: true,
                  scrollController: scrollController,
                  scrollAnimationDuration: const Duration(
                      milliseconds: ModifierDeckMenu._kReorderAnimationMs),
                  reorderAnimationDuration: const Duration(
                      milliseconds: ModifierDeckMenu._kReorderAnimationMs),
                  buildDraggableFeedback: defaultBuildDraggableFeedback,
                  onReorder: (index, dropIndex) {
                    setState(() {
                      dropIndex = list.length - dropIndex - 1;
                      index = list.length - index - 1;
                      list.insert(dropIndex, list.removeAt(index));
                      _gameState.action(ReorderModifierListCommand(
                          dropIndex, index, name,
                          gameState: _gameState));
                    });
                  },
                  children: generateList(list, allOpen, name),
                )
              : ListView(
                  controller: ScrollController(),
                  children: generateList(list, allOpen, name).reversed.toList(),
                ),
        ));
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          final name = widget.name;
          final deck = GameMethods.getModifierDeck(name, _gameState);
          final drawPile = deck.drawPileContents.reversed.toList();
          final discardPile = deck.discardPileContents.toList();
          final screenSize = MediaQuery.of(context).size;

          return Container(
              constraints: BoxConstraints(
                  maxWidth: screenSize.width,
                  maxHeight: screenSize.height * kMenuMaxHeightRatio),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      ModifierDeckHeader(
                          deck: deck,
                          gameState: _gameState,
                          settings: _settings,
                          name: name),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false, name),
                          buildList(discardPile, false, true, name)
                        ],
                      )),
                      Container(
                        height: ModifierDeckMenu._kFooterHeight,
                        margin: const EdgeInsets.all(
                            ModifierDeckMenu._kHeaderMargin),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    ModifierDeckMenu._kHeaderBorderRadius),
                                bottomRight: Radius.circular(
                                    ModifierDeckMenu._kHeaderBorderRadius))),
                      ),
                    ]),
                    Positioned(
                        width: kCloseButtonWidth,
                        height: kButtonSize,
                        right: 0,
                        bottom: 0,
                        child: TextButton(
                            child: Text(
                              AppLocalizations.of(context)!.close,
                              style: kButtonLabelStyle,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })),
                    Positioned(
                        bottom: ModifierDeckMenu._kFooterBottomPos,
                        left: ModifierDeckMenu._kNameLeftPos,
                        child: Text(name, style: kButtonLabelStyle))
                  ])));
        });
  }
}
