import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

import '../../../Model/room.dart';
import '../../../Resource/app_constants.dart';
import '../../../Resource/commands/add_standee_command.dart';
import '../../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../../Resource/enums.dart';
import '../../../Resource/game_methods.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../services/service_locator.dart';
import '../../widgets/modal_background.dart';
import 'standee_button_grid.dart';

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
  static const double _kMenuWidth = 250.0;
  static const double _kHeightBase = 140.0;
  static const double _kHeightRow2 = 172.0;
  static const double _kHeightRow3 = 211.0;
  static const int _kCharIndexMin = 2;
  static const int _kCharIndexMax = 4;
  static const int _kBothTypesMultiplier = 2;
  static const int _kKillHealth = -10000;
  static const int _kStandeesRow2Threshold = 4;
  static const int _kStandeesRow3Threshold = 8;

  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  Settings get _settings => widget.settings ?? getIt<Settings>();

  bool addAsSummon = false;
  int currentMonsterIndex = 0;
  int startCommandIndex = 0;
  bool _closing = false;

  List<List<int>> initialEliteAdded = [];
  List<List<int>> initialNormalAdded = [];

  int currentEliteAdded = 0;
  int currentNormalAdded = 0;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    startCommandIndex = _gameState.commandIndex.value;

    for (final data in widget.monsterData) {
      Monster? monster = _gameState.currentList.firstWhereOrNull(
              (element) => element.id == data.name && element is Monster)
          as Monster?;
      if (monster == null) {
        //to avoid exception. this is still a bug.
        continue;
      }
      List<int> someElites = [];
      List<int> someNormals = [];
      for (final item in monster.monsterInstances) {
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

  // Guards against multiple Navigator.pop calls being scheduled in the same
  // frame. closeOrNext() can be reached more than once per user action because
  // the ValueListenableBuilder in build() re-runs its builder on every parent
  // rebuild (setState from _handleStandeePress fires after commandIndex
  // already changed). The mounted check handles the case where the widget is
  // fully disposed before the callback fires.
  void _scheduleClose() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) Navigator.pop(context);
    });
  }

  void closeOrNext() {
    if (currentMonsterIndex + 1 >= widget.monsterData.length) {
      _scheduleClose();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _gameState.updateList.notify();
          });

          currentMonsterIndex++; //next set
          currentEliteAdded = 0;
          currentNormalAdded = 0;
        });
      });
    }
  }

  bool _isStandeeOut(
      int nr, Monster monster, bool elite, int nrOfElite, int nrOfNormal) {
    for (final item in monster.monsterInstances) {
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
        if (currentEliteAdded == nrOfElite &&
            currentNormalAdded == nrOfNormal) {
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
            !initialNormalAdded[currentMonsterIndex]
                .contains(state.standeeNr)) {
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

  @override
  Widget build(BuildContext context) {
    int characterIndex = GameMethods.getCurrentCharacterAmount()
            .clamp(_kCharIndexMin, _kCharIndexMax) -
        _kCharIndexMin;

    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          //handle undo from other device - needs to be same index?
          if (startCommandIndex > _gameState.commandIndex.value) {
            _scheduleClose();
            return TextButton(
                child: Text(
                  AppLocalizations.of(context)!.close,
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
            _scheduleClose();
            return TextButton(
                child: Text(
                  AppLocalizations.of(context)!.close,
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

          for (final item in monster.monsterInstances) {
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
                            StandeeButtonGrid(
                                scale: scale,
                                monster: monster,
                                elite: true,
                                nrOfStandees: nrOfStandees,
                                nrLeft: nrOfElite - currentEliteAdded,
                                nrOfElite: nrOfElite,
                                nrOfNormal: nrOfNormal,
                                isStandeeOut: _isStandeeOut,
                                onStandeePress: _handleStandeePress),
                          if (nrOfNormal > 0)
                            StandeeButtonGrid(
                                scale: scale,
                                monster: monster,
                                elite: false,
                                nrOfStandees: nrOfStandees,
                                nrLeft: nrOfNormal - currentNormalAdded,
                                nrOfElite: nrOfElite,
                                nrOfNormal: nrOfNormal,
                                isStandeeOut: _isStandeeOut,
                                onStandeePress: _handleStandeePress),
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
                                      addAsSummon = newValue ?? false;
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
