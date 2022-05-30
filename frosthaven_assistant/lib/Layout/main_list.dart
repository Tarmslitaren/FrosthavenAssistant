import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frosthaven_assistant/Layout/character_widget.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:great_list_view/great_list_view.dart';

import '../Resource/action_handler.dart';
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
      height = 60 *
          scale; //TODO put in ListItemData, and have it change depending on summons+monster instances
    } else if (data is Monster) {
      Monster monster = data as Monster;
      child = MonsterWidget(data: monster.type, level: monster.level);
      height = 120 *tempScale*
          scale; //TODO put in ListItemData, and have it change depending on summons+monster instances
    } else {
      height = 0;
    }
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
      _gameState.sortByInitiative();
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

  Widget buildList() {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: ValueListenableBuilder<int>(
            valueListenable: _gameState.commandIndex,
            builder: (context, value, child) {
              //find which are added or  removed?
              /*if (_gameState.commands.isNotEmpty) {
                Command command = _gameState.getCurrent();
                if (command is RemoveCharacterCommand) {
                } else if (command is AddCharacterCommand) {
                } else if (command is DrawCommand) {
                  //do i need ot do something?
                }
              }*/

              double scale = getScaleByReference(context);
              return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: getMainListMargin(context)),
                  //TODO: honestly this is the  hackiest solution for a thing that should be automatically super easy to do but flutter sometimes really suck.
                  //TODO: the real solution is likely to make the items wrap on Expand or similar to take max width of parent.

                  child: Scrollbar(
                    controller: scrollController,
                    child: AutomaticAnimatedListView<ListItemData>(
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
                    ),
                  ));
            }));
  }

  final scrollController =
      ScrollController(); //use to animate to position in list:
  final controller = AnimatedListController();
}
