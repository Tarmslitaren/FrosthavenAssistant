import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

const double _kConditionIconHeight = 11.0;
const double _kImmuneIconHeight = 4.0;
const double _kConditionIconWidth = 14.0;
const double _kImmuneIconLeft = 9.0;
const double _kImmuneIconTop = 3.5;

List<Widget> createConditionList(
    Monster data, double scale, MonsterStatsModel stats) {
  List<Widget> list = [];
  String suffix = "";
  if (GameMethods.isFrosthavenStyle(data.type)) {
    suffix = "_fh";
  }
  for (var item in stats.immunities) {
    item = item.substring(1, item.length - 1);
    String imagePath = "assets/images/abilities/$item.png";
    if (suffix.isNotEmpty && hasGHVersion(item)) {
      imagePath = "assets/images/abilities/$item$suffix.png";
    }
    final image = Image(
      height: _kConditionIconHeight * scale,
      filterQuality: FilterQuality.medium,
      image: AssetImage(imagePath),
    );
    final immuneIcon = Image(
      height: _kImmuneIconHeight * scale,
      filterQuality: FilterQuality.medium,
      image: const AssetImage("assets/images/psd/immune.png"),
    );
    final stack = Stack(
      alignment: Alignment.center,
      children: [
        Positioned(left: 0, top: 0, child: image),
        Positioned(
            left: _kImmuneIconLeft * scale,
            top: _kImmuneIconTop * scale,
            child: immuneIcon),
      ],
    );
    list.add(SizedBox(
      width: _kConditionIconWidth * scale,
      height: _kConditionIconHeight * scale,
      child: stack,
    ));
  }
  return list;
}
