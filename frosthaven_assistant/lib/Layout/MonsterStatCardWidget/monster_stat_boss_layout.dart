import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/line_builder/line_builder.dart';
import '../view_models/monster_stat_card_view_model.dart';
import 'condition_list_builder.dart';

// Shared layout constants
const double _kShadowTextOffset = 0.4;
const double _kShadowTextBlur = 1.0;
const double _kCardWidth = 167.0;
const double _kCardHeight = 93.5;
const double _kStatsFontSize = 12.8;
const double _kStatsLineHeight = 1.2;
const double _kLevelFontSize = 14.4;
const double _kStatIconHeight = 16.0;
// Boss layout positions
const double _kBossLevelLeft = 7.0;
const double _kBossLevelTopFh = 0.5;
const double _kBossLevelTopGh = 2.0;
const double _kBossStatsTopFh = 29.4;
const double _kBossStatsTopGh = 30.4;
const double _kBossStatsWidth = 24.0;
const double _kBossAttribMarginRight = 1.0;
const double _kBossContentLeft = 40.0;
const double _kBossContentTop = 16.0;
const double _kBossContentWidth = 128.0;
const double _kBossSpecialWidth = 112.0;
const double _kBossSpecialFontSize = 11.2;
const double _kDividerScaleFactor = 0.15;
const double _kDividerHeight = 1.0;
const double _kDividerWidth = 125.0;
const double _kBossStatIconLeft = 23.5;
const double _kBossStatIconTop = 44.4;
const double _kBossRangeLeft = 24.0;
const double _kBossRangeTop = 74.4;
const double _kBossConditionRight = 10.0;
const double _kBossConditionTop = 1.0;

String _statDisplay(Object? stat, bool noCalc) {
  if (!noCalc) {
    final v = StatCalculator.calculateFormula(stat ?? 0);
    if (v != null) return v.toString();
  }
  return stat?.toString() ?? "";
}

class MonsterStatBossLayout extends StatelessWidget {
  const MonsterStatBossLayout({
    super.key,
    required this.data,
    required this.scale,
    required this.frosthavenStyle,
    required this.viewModel,
    this.settings,
  });

  final Monster data;
  final double scale;
  final bool frosthavenStyle;
  final MonsterStatCardViewModel viewModel;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final settings_ = settings ?? getIt<Settings>();
    final shadow = Shadow(
      offset: Offset(_kShadowTextOffset * scale, _kShadowTextOffset * scale),
      color: Colors.black87,
      blurRadius: _kShadowTextBlur * scale,
    );
    final shadowLeft = Shadow(
      offset: Offset(_kShadowTextOffset * scale, _kShadowTextOffset * scale),
      color: Colors.black54,
      blurRadius: _kShadowTextBlur * scale,
    );
    final leftStyle = getCardNumberStyle(
        _kStatsFontSize * scale, shadowLeft, frosthavenStyle,
        color: Colors.black, height: _kStatsLineHeight);
    final noCalculationSetting = settings_.noCalculation.value;
    MonsterStatsModel? normal = data.type.levels[data.level.value].boss;

    final health = viewModel
        .resolveBossHealth(_statDisplay(normal?.health, noCalculationSetting));
    final move = _statDisplay(normal?.move, noCalculationSetting);
    final attack = _statDisplay(normal?.attack, noCalculationSetting);

    String bossAttackAttributes = "";
    List<String> bossOtherAttributes = [];

    for (String item in normal?.attributes ?? []) {
      if (frosthavenStyle &&
          !bossAttackAttributes.contains("target") &&
          (item.startsWith('%wound%') ||
              item.startsWith('%poison%') ||
              item.startsWith("%brittle%"))) {
        bossAttackAttributes += item;
      } else if (frosthavenStyle && item.startsWith("%target%")) {
        bossAttackAttributes += "^$item";
      } else {
        bossOtherAttributes.add(item);
      }
    }

    Widget attackAttributes = LineBuilder.createLines([bossAttackAttributes],
        true, false, false, data, CrossAxisAlignment.start, scale, false);

    final specialStyle = getCardNumberStyle(
        _kBossSpecialFontSize * scale, shadow, frosthavenStyle,
        color: Colors.yellow, height: 1);

    return RepaintBoundary(
        child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
              Radius.circular(kGameCardBorderRadius * scale)),
          child: Image(
            height: _kCardHeight * scale,
            width: _kCardWidth * scale,
            fit: BoxFit.fitWidth,
            image:
                const AssetImage("assets/images/psd/monsterStats-boss.png"),
          ),
        ),
        Positioned(
            left: _kBossLevelLeft * scale,
            top: frosthavenStyle
                ? _kBossLevelTopFh * scale
                : _kBossLevelTopGh * scale,
            child: Text(
              data.level.value.toString(),
              style: getCardNumberStyle(
                  _kLevelFontSize * scale, shadow, frosthavenStyle,
                  height: 1),
            )),
        Positioned(
          left: 0,
          top: frosthavenStyle
              ? _kBossStatsTopFh * scale
              : _kBossStatsTopGh * scale,
          width: _kBossStatsWidth * scale,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(health, style: leftStyle),
              Text(move, style: leftStyle),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: EdgeInsets.only(
                        right: bossAttackAttributes.contains("target")
                            ? _kBossAttribMarginRight * scale
                            : 0),
                    child: attackAttributes),
                Text(attack, style: leftStyle)
              ]),
              Text(normal?.range != 0 ? normal?.range.toString() ?? " " : "",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
            left: _kBossContentLeft * scale,
            top: _kBossContentTop * scale,
            width: _kBossContentWidth * scale,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bossOtherAttributes.isNotEmpty
                      ? Row(children: [
                          Text("    ", style: specialStyle),
                          SizedBox(
                              width: _kBossSpecialWidth * scale,
                              child: RepaintBoundary(
                                  child: LineBuilder.createLines(
                                      bossOtherAttributes,
                                      false,
                                      false,
                                      false,
                                      data,
                                      CrossAxisAlignment.start,
                                      scale,
                                      settings_.shimmer.value))),
                        ])
                      : Container(),
                  if (bossOtherAttributes.isNotEmpty)
                    Image.asset(
                      scale: 1 / (scale * _kDividerScaleFactor),
                      height: _kDividerHeight * scale,
                      fit: BoxFit.fill,
                      width: _kDividerWidth * scale,
                      filterQuality: FilterQuality.medium,
                      "assets/images/abilities/divider_boss_fh.png",
                    ),
                  normal?.special1.isNotEmpty ?? false
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("1:", style: specialStyle),
                              SizedBox(
                                  width: _kBossSpecialWidth * scale,
                                  child: RepaintBoundary(
                                      child: LineBuilder.createLines(
                                          data.type.levels[data.level.value]
                                                  .boss?.special1 ??
                                              [],
                                          false,
                                          !noCalculationSetting,
                                          false,
                                          data,
                                          CrossAxisAlignment.start,
                                          scale,
                                          false))),
                            ])
                      : Container(),
                  normal?.special2.isNotEmpty ?? false
                      ? Image.asset(
                          scale: 1 / (scale * _kDividerScaleFactor),
                          height: _kDividerHeight * scale,
                          fit: BoxFit.fill,
                          width: _kDividerWidth * scale,
                          filterQuality: FilterQuality.medium,
                          "assets/images/abilities/divider_boss_fh.png",
                        )
                      : Container(),
                  normal?.special2.isNotEmpty ?? false
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("2:", style: specialStyle),
                              SizedBox(
                                  width: _kBossSpecialWidth * scale,
                                  child: RepaintBoundary(
                                      child: LineBuilder.createLines(
                                          data.type.levels[data.level.value]
                                                  .boss?.special2 ??
                                              [],
                                          false,
                                          !noCalculationSetting,
                                          false,
                                          data,
                                          CrossAxisAlignment.start,
                                          scale,
                                          false))),
                            ])
                      : Container()
                ])),
        if (data.type.flying)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kBossStatIconLeft * scale,
              top: _kBossStatIconTop * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/flying-stat_fh.png"
                    : "assets/images/psd/flying-stat.png"),
              )),
        if (!data.type.flying && !frosthavenStyle)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kBossStatIconLeft * scale,
              top: _kBossStatIconTop * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/move-stat.png"),
              )),
        if (normal?.range != 0)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kBossRangeLeft * scale,
              top: _kBossRangeTop * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/range-stat_fh.png"
                    : "assets/images/psd/range-stat.png"),
              )),
        Positioned(
            right: _kBossConditionRight * scale,
            top: _kBossConditionTop * scale,
            child: Row(
              children: createConditionList(data, scale, normal!),
            )),
      ],
    ));
  }
}
