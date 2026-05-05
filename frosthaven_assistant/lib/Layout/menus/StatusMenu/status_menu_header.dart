import 'package:flutter/material.dart';

import '../../../Resource/commands/ice_wraith_change_form_command.dart';
import '../../../Resource/enums.dart';
import '../../../Resource/game_methods.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../condition_icon.dart';
import '../../monster_box.dart';

class StatusMenuHeader extends StatelessWidget {
  static const double _kHeaderHeight = 28.0;
  static const double _kConditionIconSize = 24.0;
  static const double _kConditionMarginTop = 2.0;
  static const double _kConditionMarginRight = 2.0;
  static const double _kMonsterBoxScale = 0.9;
  static const double _kSummonPaddingRight = 20.0;

  const StatusMenuHeader({
    super.key,
    required this.name,
    required this.figure,
    required this.scale,
    required this.hasShield,
    required this.hasRetaliate,
    required this.owner,
    required this.figureId,
    required this.ownerId,
    required this.isIceWraith,
    required this.isElite,
    required this.gameState,
    required this.onIceWraithSwitch,
  });

  final String name;
  final FigureState figure;
  final double scale;
  final bool hasShield;
  final bool hasRetaliate;
  final ListItemData owner;
  final String figureId;
  final String ownerId;
  final bool isIceWraith;
  final bool isElite;
  final GameState gameState;
  final VoidCallback onIceWraithSwitch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: _kHeaderHeight * scale,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(name, style: getTitleTextStyle(getModalMenuScale(context))),
              if (figure is MonsterInstance)
                ListenableBuilder(
                    listenable: gameState.updateList,
                    builder: (context, child) {
                      //handle case when health is changed to zero: don't instantiate monster box
                      if (GameMethods.getFigure(ownerId, figureId) == null) {
                        //todo: should somehow pop context in case dead by health wheel
                        return Container();
                      }
                      return Row(children: [
                        if (hasShield)
                          Container(
                              height: _kHeaderHeight * scale,
                              margin: EdgeInsets.only(
                                  top: _kConditionMarginTop * scale,
                                  right: _kConditionMarginRight * scale),
                              child: ConditionIcon(
                                Condition.shield,
                                _kConditionIconSize * scale,
                                owner,
                                figure,
                                scale: scale,
                              )),
                        if (hasRetaliate)
                          Container(
                              height: _kHeaderHeight * scale,
                              margin: EdgeInsets.only(
                                  top: _kConditionMarginTop * scale,
                                  right: _kConditionMarginRight * scale),
                              child: ConditionIcon(
                                Condition.retaliate,
                                _kConditionIconSize * scale,
                                owner,
                                figure,
                                scale: scale,
                              )),
                        Container(
                            height: _kHeaderHeight * scale,
                            margin: EdgeInsets.only(
                                top: _kConditionMarginTop * scale),
                            child: MonsterBox(
                                figureId: figureId,
                                ownerId: ownerId,
                                displayStartAnimation: "",
                                blockInput: true,
                                scale: scale * _kMonsterBoxScale))
                      ]);
                    }),
              if (isIceWraith)
                TextButton(
                    clipBehavior: Clip.hardEdge,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.only(
                          right: _kSummonPaddingRight * scale),
                    ),
                    onPressed: () {
                      gameState.action(IceWraithChangeFormCommand(
                          isElite, ownerId, figureId,
                          gameState: gameState));
                      onIceWraithSwitch();
                    },
                    child: Text("                     Switch Form",
                        style: getButtonTextStyle(scale)))
            ]));
  }
}
