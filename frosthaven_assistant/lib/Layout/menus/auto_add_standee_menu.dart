import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Model/room.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AutoAddStandeeMenu extends StatefulWidget {
  const AutoAddStandeeMenu({
    super.key,
    required this.monsterData,
    this.gameState,
    this.settings,
  });

  final List<RoomMonsterData> monsterData;

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  AddStandeeMenuState createState() => AddStandeeMenuState();
}

class AddStandeeMenuState extends State<AutoAddStandeeMenu> {
  static const int _kButtonRowSize = 4;
  static const double _kButtonSize = 40.0;
  static const double _kButtonSpacerHeight = 20.0;
  static const double _kMenuWidth = 250.0;
  static const double _kHeightBase = 140.0;
  static const double _kHeightRow2 = 172.0;
  static const double _kHeightRow3 = 211.0;
  static const int _kCharIndexMin = 2;
  static const int _kCharIndexMax = 4;
  static const int _kBothTypesMultiplier = 2;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;
  static const int _kKillHealth = -10000;
  static const int _kStandeesRow2Threshold = _kButtonRowSize;
  static const int _kStandeesRow3Threshold = _kButtonRowSize * 2;

  late final GameState _gameState;
  late final Settings _settings;

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
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
    super.initState();
    startCommandIndex = _gameState.commandIndex.value;

    for (var data in widget.monsterData) {
      Monster? monster = _gameState.currentList.firstWhereOrNull(
              (element) => element.id == data.name && element is Monster)
          as Monster?;
      if (monster == null) {
        //to avoid exception. this is still a bug.
        continue;
      }
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

  void closeOrNext() {
    if (currentMonsterIndex + 1 >= widget.monsterData.length) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pop(context);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _gameState.updateList.value++;
          });

          currentMonsterIndex++; //next set
          currentEliteAdded = 0;
          currentNormalAdded = 0;
        });
      });
    }
  }

  bool _isStandeeOut(int nr, Monster monster, bool elite, int nrOfElite, int nrOfNormal) {
    for (var item in monster.monsterInstances) {
      if (item.standeeNr == nr ||
          (elite && nrOfElite <= currentEliteAdded) ||
          (!elite && nrOfNormal <= currentNormalAdded)) {
        return true;
      }
    }
    return false;
  }

  void _handleStandeePress(int nr, Monster monster, MonsterType type,
      bool elite, bool isOut, int nrOfElite, int nrOfNormal) {
    if (!isOut) {
      _gameState.action(AddStandeeCommand(
          nr, null, monster.id, type, addAsSummon,
          gameState: _gameState));
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
          if (currentMonsterIndex + 1 < widget.monsterData.length) {
            currentMonsterIndex++;
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
          _gameState.action(ChangeHealthCommand(
              _kKillHealth, figureId, monster.id,
              gameState: _gameState));
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
  }

  String _pluralize(String text) {
    if (text.endsWith("s")) {
      return text;
    }
    if (text.endsWith("y")) {
      return "${text.substring(0, text.length - 1)}ies";
    }
    return "${text}s";
  }

  Widget _buildButtonGrid(double scale, Monster monster, bool elite,
      int nrOfStandees, int nrLeft, int nrOfElite, int nrOfNormal) {
    String text = elite
        ? "Add $nrLeft Elite ${monster.type.display}"
        : "Add $nrLeft Normal ${monster.type.display}";
    if (nrLeft > 1) {
      text = _pluralize(text);
    }

    final rows = <Widget>[];
    for (int start = 1; start <= nrOfStandees; start += _kButtonRowSize) {
      final end = (start + _kButtonRowSize - 1).clamp(1, nrOfStandees);
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          end - start + 1,
          (i) { // ignore: avoid-returning-widgets, widget generator lambda
            final nr = start + i;
            bool boss = monster.type.levels.first.boss != null;
            MonsterType type = elite ? MonsterType.elite : (boss ? MonsterType.boss : MonsterType.normal);
            Color color = elite ? Colors.yellow : (boss ? Colors.red : Colors.white);
            bool isOut = _isStandeeOut(nr, monster, elite, nrOfElite, nrOfNormal);
            if (isOut) color = Colors.grey;
            return _StandeeNrButton(
              nr: nr, scale: scale, color: color,
              onPressed: () => _handleStandeePress(nr, monster, type, elite, isOut, nrOfElite, nrOfNormal),
            );
          },
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: _kButtonSpacerHeight * scale),
        Text(text, style: getTitleTextStyle(scale)),
        ...rows,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int characterIndex =
        GameMethods.getCurrentCharacterAmount().clamp(_kCharIndexMin, _kCharIndexMax) - _kCharIndexMin;

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
                  style: kButtonLabelStyle,
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
              break;
            }
          }

          Monster? monster = _gameState.currentList.firstWhereOrNull(
                  (element) => element.id == data.name && element is Monster)
              as Monster?;
          if (monster == null) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
            });
            return TextButton(
                child: const Text(
                  'Close',
                  style: kButtonLabelStyle,
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
            closeOrNext();
          } else if (currentEliteAdded >= nrOfElite &&
              currentNormalAdded >= nrOfNormal) {
            closeOrNext();
          }

          double scale = getModalMenuScale(context);
          double height = _kHeightBase;
          if (nrOfStandees > _kStandeesRow2Threshold) {
            height = _kHeightRow2;
          }
          if (nrOfStandees > _kStandeesRow3Threshold) {
            height = _kHeightRow3;
          }
          if (nrOfElite > 0 && nrOfNormal > 0) {
            height *= _kBothTypesMultiplier;
          }

          return ModalBackground(
              width: _kMenuWidth * scale,
              //need to set any width to center content, overridden by dialog default min width.
              height: height * scale,
              child: ValueListenableBuilder<int>(
                  valueListenable: _gameState.commandIndex,
                  builder: (context, value, child) {
                    return Stack(children: [
                      Column(
                        children: [
                          if (nrOfElite > 0)
                            _buildButtonGrid( // ignore: avoid-returning-widgets, internal layout helper
                                scale,
                                monster,
                                true,
                                nrOfStandees,
                                nrOfElite - currentEliteAdded,
                                nrOfElite,
                                nrOfNormal),
                          if (nrOfNormal > 0)
                            _buildButtonGrid( // ignore: avoid-returning-widgets, internal layout helper
                                scale,
                                monster,
                                false,
                                nrOfStandees,
                                nrOfNormal - currentNormalAdded,
                                nrOfElite,
                                nrOfNormal),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Summoned:",
                                    style: getSmallTextStyle(scale)),
                                Checkbox(
                                  checkColor: Colors.black,
                                  activeColor: Colors.grey.shade200,
                                  side: BorderSide(
                                      color: _settings.darkMode.value
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
                          width: kCloseButtonWidth,
                          height: kButtonSize,
                          right: 0,
                          bottom: 0,
                          child: TextButton(
                              child: const Text(
                                'Close',
                                style: kButtonLabelStyle,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              })),
                    ]);
                  }));
        });
  }
}

class _StandeeNrButton extends StatelessWidget {
  const _StandeeNrButton({
    required this.nr,
    required this.scale,
    required this.color,
    required this.onPressed,
  });

  final int nr;
  final double scale;
  final Color color;
  final VoidCallback onPressed;

  static const double _kButtonSize = 40.0;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;

  @override
  Widget build(BuildContext context) {
    var shadow = Shadow(
      offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: _kShadowBlur,
    );
    return SizedBox(
      width: _kButtonSize * scale,
      height: _kButtonSize * scale,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          nr.toString(),
          style: TextStyle(
            color: color,
            fontSize: kFontSizeTitle * scale,
            shadows: [shadow],
          ),
        ),
      ),
    );
  }
}
