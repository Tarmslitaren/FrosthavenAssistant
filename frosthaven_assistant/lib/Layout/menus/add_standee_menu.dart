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
  late final GameState _gameState; // ignore: avoid-late-keyword
  late final Settings _settings; // ignore: avoid-late-keyword

  bool addAsSummon = false;

  @override
  initState() {
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
  }

  @override
  Widget build(BuildContext context) {
    bool boss = widget.monster.type.levels.first.boss != null;
    MonsterType type = MonsterType.normal;
    Color baseColor = Colors.white;

    if (widget.elite) {
      baseColor = Colors.yellow;
      type = MonsterType.elite;
    }
    if (boss) {
      baseColor = Colors.red;
      type = MonsterType.boss;
    }

    int nrOfStandees = widget.monster.type.count;
    double scale = getModalMenuScale(context);
    double height = AddStandeeMenu._kHeightOneRow;
    if (nrOfStandees > AddStandeeMenu._kRow1Max) {
      height = AddStandeeMenu._kHeightTwoRows;
    }
    if (nrOfStandees > AddStandeeMenu._kRow2Max) {
      height = AddStandeeMenu._kHeightThreeRows;
    }
    return ModalBackground(
        width: AddStandeeMenu._kMenuWidth * scale,
        height: height * scale,
        child: Stack(children: [
          ValueListenableBuilder<int>(
              valueListenable: _gameState.commandIndex,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: AddStandeeMenu._kTopSpacing * scale),
                    Text("Add Standee Nr", style: getTitleTextStyle(scale)),
                    ...List.generate(
                      (nrOfStandees + AddStandeeMenu._kRow1Max - 1) ~/ AddStandeeMenu._kRow1Max,
                      (rowIdx) => Row( // ignore: avoid-returning-widgets, widget generator lambda
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          AddStandeeMenu._kRow1Max,
                          (colIdx) { // ignore: avoid-returning-widgets, widget generator lambda
                            final nr = rowIdx * AddStandeeMenu._kRow1Max + colIdx + 1;
                            if (nr > nrOfStandees) return Container();
                            bool isOut = widget.monster.monsterInstances
                                .any((item) => item.standeeNr == nr);
                            Color color = isOut
                                ? Colors.grey
                                : (_gameState.currentCampaign.value == "Buttons and Bugs"
                                    ? (AddStandeeMenu._kBnBColors[nr] ?? baseColor)
                                    : baseColor);
                            return _StandeeNrButton(
                              nr: nr,
                              scale: scale,
                              color: color,
                              onPressed: isOut
                                  ? null
                                  : () => _gameState.action(AddStandeeCommand(
                                      nr, null, widget.monster.id, type, addAsSummon,
                                      gameState: _gameState)),
                            );
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
                            addAsSummon = newValue!; // ignore: avoid-non-null-assertion
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
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    var shadow = Shadow(
      offset: Offset(AddStandeeMenu._kShadowOffset * scale, AddStandeeMenu._kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: AddStandeeMenu._kShadowBlur,
    );
    return SizedBox(
      width: AddStandeeMenu._kButtonSize * scale,
      height: AddStandeeMenu._kButtonSize * scale,
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
