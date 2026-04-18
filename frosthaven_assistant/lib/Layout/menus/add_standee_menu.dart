import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/commands/add_standee_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddStandeeMenu extends StatefulWidget {
  static const double _kButtonSize = 40.0;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;
  static const double _kMenuWidth = 250.0;
  static const double _kTopSpacing = 20.0;
  static const double _kHeightOneRow = 140.0;
  static const double _kHeightTwoRows = 172.0;
  static const double _kHeightThreeRows = 211.0;
  static const int _kRow1Max = 4;
  static const int _kRow2Max = 8;
  static const Map<int, Color> _kBnBColors = {
    1: Colors.green,
    2: Colors.blue,
    3: Colors.purple,
    4: Colors.red,
  };

  const AddStandeeMenu({
    super.key,
    required this.monster,
    required this.elite,
    this.gameState,
    this.settings,
  });

  final Monster monster;
  final bool elite;

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  AddStandeeMenuState createState() => AddStandeeMenuState();
}

class AddStandeeMenuState extends State<AddStandeeMenu> {
  late final GameState _gameState;
  late final Settings _settings;

  bool addAsSummon = false;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
  }

  Widget buildNrButton(final int nr, final double scale) {
    bool boss = widget.monster.type.levels.first.boss != null;
    MonsterType type = MonsterType.normal;
    Color color = Colors.white;

    if (widget.elite) {
      color = Colors.yellow;
      type = MonsterType.elite;
    }

    if (boss) {
      color = Colors.red;
      type = MonsterType.boss;
    }

    if (_gameState.currentCampaign.value == "Buttons and Bugs") {
      color = AddStandeeMenu._kBnBColors[nr] ?? color;
    }

    bool isOut = false;
    for (var item in widget.monster.monsterInstances) {
      if (item.standeeNr == nr) {
        isOut = true;
        break;
      }
    }
    if (isOut) {
      color = Colors.grey;
    }
    String text = nr.toString();
    var shadow = Shadow(
      offset: Offset(AddStandeeMenu._kShadowOffset * scale, AddStandeeMenu._kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: AddStandeeMenu._kShadowBlur,
    );
    return SizedBox(
      width: AddStandeeMenu._kButtonSize * scale,
      height: AddStandeeMenu._kButtonSize * scale,
      child: TextButton(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: kFontSizeTitle * scale,
            shadows: [shadow],
          ),
        ),
        onPressed: () {
          if (!isOut) {
            _gameState.action(AddStandeeCommand(
                nr, null, widget.monster.id, type, addAsSummon,
                gameState: _gameState));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int nrOfStandees = widget.monster.type.count;
    double scale = getModalMenuScale(context);
    //4 nrs per row
    double height = AddStandeeMenu._kHeightOneRow;
    if (nrOfStandees > AddStandeeMenu._kRow1Max) {
      height = AddStandeeMenu._kHeightTwoRows;
    }
    if (nrOfStandees > AddStandeeMenu._kRow2Max) {
      height = AddStandeeMenu._kHeightThreeRows;
    }
    return ModalBackground(
        width: AddStandeeMenu._kMenuWidth * scale,
        //need to set any width to center content, overridden by dialog default min width.
        height: height * scale,
        child: Stack(children: [
          ValueListenableBuilder<int>(
              valueListenable: _gameState.commandIndex,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: AddStandeeMenu._kTopSpacing * scale,
                    ),
                    Text("Add Standee Nr", style: getTitleTextStyle(scale)),
                    ...List.generate(
                      (nrOfStandees + AddStandeeMenu._kRow1Max - 1) ~/ AddStandeeMenu._kRow1Max,
                      (rowIdx) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          AddStandeeMenu._kRow1Max,
                          (colIdx) {
                            final nr = rowIdx * AddStandeeMenu._kRow1Max + colIdx + 1;
                            return nr <= nrOfStandees ? buildNrButton(nr, scale) : Container();
                          },
                        ),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Summoned:", style: getSmallTextStyle(scale)),
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
                );
              }),
        ]));
  }
}
