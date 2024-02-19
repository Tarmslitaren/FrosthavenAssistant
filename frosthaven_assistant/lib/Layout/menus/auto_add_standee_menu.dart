import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Model/room.dart';
import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AutoAddStandeeMenu extends StatefulWidget {
  final List<RoomMonsterData> monsterData;

  const AutoAddStandeeMenu({super.key, required this.monsterData});

  @override
  AddStandeeMenuState createState() => AddStandeeMenuState();
}

class AddStandeeMenuState extends State<AutoAddStandeeMenu> {
  final GameState _gameState = getIt<GameState>();

  bool addAsSummon = false;
  int currentMonsterIndex = 0;
  late final int startCommandIndex;

  List<List<int>> initialEliteAdded = [];
  List<List<int>> initialNormalAdded = [];

  int currentEliteAdded = 0;
  int currentNormalAdded = 0;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();

    startCommandIndex = _gameState.commandIndex.value;

    for (var data in widget.monsterData) {
      Monster monster =
          _gameState.currentList.firstWhere((element) => element.id == data.name) as Monster;
      List<int> someElites = [];
      List<int> someNormals = [];
      for (var item in monster.monsterInstances) {
        if (item.type == MonsterType.elite) {
          someElites.add(item.standeeNr);
        } else {
          someNormals.add(item.standeeNr);
        }
      }

      initialEliteAdded.add(someElites);
      initialNormalAdded.add(someNormals);
    }
  }

  void closeOrNext(int nrOfElite, int nrOfNormal) {
    if (currentMonsterIndex + 1 >= widget.monsterData.length) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pop(context);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            getIt<GameState>().updateList.value++;
          });

          currentMonsterIndex++; //next set
          currentEliteAdded = 0;
          currentNormalAdded = 0;
        });
      });
    }
  }

  Widget buildNrButton(final int nr, final double scale, Monster monster, bool elite, int nrOfElite,
      int nrOfNormal) {
    bool boss = monster.type.levels[0].boss != null;
    MonsterType type = MonsterType.normal;
    Color color = Colors.white;

    if (elite) {
      color = Colors.yellow;
      type = MonsterType.elite;
    }

    if (boss) {
      color = Colors.red;
      type = MonsterType.boss;
    }
    bool isOut = false;
    for (var item in monster.monsterInstances) {
      if (item.standeeNr == nr ||
          (elite == true && nrOfElite <= currentEliteAdded) ||
          (elite == false && nrOfNormal <= currentNormalAdded)) {
        isOut = true;
        break;
      }
    }
    if (isOut) {
      color = Colors.grey;
    }
    String text = nr.toString();
    var shadow = Shadow(
      offset: Offset(1 * scale, 1 * scale),
      color: Colors.black87,
      blurRadius: 1,
    );
    return SizedBox(
      width: 40 * scale,
      height: 40 * scale,
      child: TextButton(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 18 * scale,
            shadows: [shadow],
          ),
        ),
        onPressed: () {
          if (!isOut) {
            _gameState.action(AddStandeeCommand(nr, null, monster.id, type, addAsSummon));
            if (elite) {
              setState(() {
                currentEliteAdded++;
              });
            } else {
              setState(() {
                currentNormalAdded++;
              });
            }

            setState(() {
              if (currentEliteAdded == nrOfElite && currentNormalAdded == nrOfNormal) {
                if (currentMonsterIndex + 1 >= widget.monsterData.length) {
                  //close menu
                  //Navigator.pop(context);
                } else {
                  currentMonsterIndex++; //next set
                  currentEliteAdded = 0;
                  currentNormalAdded = 0;
                }
              }
            });
          } else {
            String figureId = GameMethods.getFigureIdFromNr(monster.id, nr);
            if (figureId.isNotEmpty) {
              MonsterInstance state =
                  GameMethods.getFigure(monster.id, figureId) as MonsterInstance;
              if (!initialEliteAdded[currentMonsterIndex].contains(state.standeeNr) &&
                  !initialNormalAdded[currentMonsterIndex].contains(state.standeeNr)) {
                _gameState.action(ChangeHealthCommand(-10000, figureId, monster.id));

                setState(() {
                  if (state.type == MonsterType.elite) {
                    currentEliteAdded--;
                  } else {
                    currentNormalAdded--;
                  }
                });
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildButtonGrid(double scale, Monster monster, bool elite, int nrOfStandees, int nrLeft,
      int nrOfElite, int nrOfNormal) {
    String text;
    if (elite) {
      text = "Add $nrLeft Elite ${monster.type.display}";
      if (nrLeft > 1) {
        text += "s";
      }
    } else {
      text = "Add $nrLeft Normal ${monster.type.display}";
      if (nrLeft > 1) {
        text += "s";
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20 * scale,
        ),
        Text(text, style: getTitleTextStyle(scale)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildNrButton(1, scale, monster, elite, nrOfElite, nrOfNormal),
            nrOfStandees > 1
                ? buildNrButton(2, scale, monster, elite, nrOfElite, nrOfNormal)
                : Container(),
            nrOfStandees > 2
                ? buildNrButton(3, scale, monster, elite, nrOfElite, nrOfNormal)
                : Container(),
            nrOfStandees > 3
                ? buildNrButton(4, scale, monster, elite, nrOfElite, nrOfNormal)
                : Container(),
          ],
        ),
        nrOfStandees > 4
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  nrOfStandees > 4
                      ? buildNrButton(5, scale, monster, elite, nrOfElite, nrOfNormal)
                      : Container(),
                  nrOfStandees > 5
                      ? buildNrButton(6, scale, monster, elite, nrOfElite, nrOfNormal)
                      : Container(),
                  nrOfStandees > 6
                      ? buildNrButton(7, scale, monster, elite, nrOfElite, nrOfNormal)
                      : Container(),
                  nrOfStandees > 7
                      ? buildNrButton(8, scale, monster, elite, nrOfElite, nrOfNormal)
                      : Container(),
                ],
              )
            : Container(),
        nrOfStandees > 8
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  nrOfStandees > 8
                      ? buildNrButton(9, scale, monster, elite, nrOfElite, nrOfNormal)
                      : Container(),
                  nrOfStandees > 9
                      ? buildNrButton(10, scale, monster, elite, nrOfElite, nrOfNormal)
                      : Container(),
                ],
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int characterIndex = GameMethods.getCurrentCharacterAmount().clamp(2, 4) - 2;

    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          //handle undo from other device - needs to be same index?
          if (startCommandIndex > _gameState.commandIndex.value) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
            });
            return TextButton(
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                });
          }
          RoomMonsterData data = widget.monsterData[currentMonsterIndex];
          int nrOfElite = data.elite[characterIndex];
          int nrOfNormal = data.normal[characterIndex];
          while (nrOfElite + nrOfNormal == 0) {
            //for case where both normal and elite added are 0
            if (currentMonsterIndex < widget.monsterData.length - 1) {
              currentMonsterIndex++;
              data = widget.monsterData[currentMonsterIndex];
              nrOfElite = data.elite[characterIndex];
              nrOfNormal = data.normal[characterIndex];
            } else {
              //WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              //  Navigator.pop(context);
              //});
              break;
            }
          }

          Monster? monster = _gameState.currentList
              .firstWhereOrNull((element) => element.id == data.name) as Monster?;
          if (monster == null) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
            });
            return TextButton(
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                });
          }

          //change depending on already added standees
          int preAddedMonsters = initialEliteAdded[currentMonsterIndex].length +
              initialNormalAdded[currentMonsterIndex].length;

          int nrOfStandees = monster.type.count;
          int monstersLeft = nrOfStandees - preAddedMonsters;
          if (monstersLeft < nrOfElite) {
            nrOfNormal = 0;
            nrOfElite = monstersLeft;
          } else if (monstersLeft < (nrOfElite + nrOfNormal)) {
            nrOfNormal = monstersLeft - nrOfElite;
          }

          int currentEliteAdded = 0;
          int currentNormalAdded = 0;

          for (var item in monster.monsterInstances) {
            if (item.type == MonsterType.elite) {
              currentEliteAdded++;
            } else {
              currentNormalAdded++;
            }
          }
          currentEliteAdded -= initialEliteAdded[currentMonsterIndex].length;
          currentNormalAdded -= initialNormalAdded[currentMonsterIndex].length;

          int allAdded = currentEliteAdded +
              currentNormalAdded +
              initialNormalAdded[currentMonsterIndex].length +
              initialEliteAdded[currentMonsterIndex].length;
          if (allAdded >= monster.type.count) {
            closeOrNext(nrOfElite, nrOfNormal);
          } else if (currentEliteAdded >= nrOfElite && currentNormalAdded >= nrOfNormal) {
            closeOrNext(nrOfElite, nrOfNormal);
          }

          double scale = 1;
          if (!isPhoneScreen(context)) {
            scale = 1.5;
            if (isLargeTablet(context)) {
              scale = 2;
            }
          }
          //4 nrs per row
          double height = 140;
          if (nrOfStandees > 4) {
            height = 172;
          }
          if (nrOfStandees > 8) {
            height = 211;
          }
          if (nrOfElite > 0 && nrOfNormal > 0) {
            height *= 2;
          }

          return Container(
              width: 250 * scale,
              //need to set any width to center content, overridden by dialog default min width.
              height: height * scale,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: AssetImage(getIt<Settings>().darkMode.value
                      ? 'assets/images/bg/dark_bg.png'
                      : 'assets/images/bg/white_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ValueListenableBuilder<int>(
                  valueListenable: _gameState.commandIndex,
                  builder: (context, value, child) {
                    return Stack(children: [
                      Column(
                        children: [
                          if (nrOfElite > 0)
                            _buildButtonGrid(scale, monster, true, nrOfStandees,
                                nrOfElite - currentEliteAdded, nrOfElite, nrOfNormal),
                          if (nrOfNormal > 0)
                            _buildButtonGrid(scale, monster, false, nrOfStandees,
                                nrOfNormal - currentNormalAdded, nrOfElite, nrOfNormal),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text("Summoned:", style: getSmallTextStyle(scale)),
                            Checkbox(
                              checkColor: Colors.black,
                              activeColor: Colors.grey.shade200,
                              side: BorderSide(
                                  color: getIt<Settings>().darkMode.value
                                      ? Colors.white
                                      : Colors.black),
                              onChanged: (bool? newValue) {
                                setState(() {
                                  addAsSummon = newValue!;
                                });
                              },
                              value: addAsSummon,
                            )
                          ])
                        ],
                      ),
                      Positioned(
                          width: 100,
                          height: 40,
                          right: 0,
                          bottom: 0,
                          child: TextButton(
                              child: const Text(
                                'Close',
                                style: TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              })),
                    ]);
                  }));
        });
  }
}
