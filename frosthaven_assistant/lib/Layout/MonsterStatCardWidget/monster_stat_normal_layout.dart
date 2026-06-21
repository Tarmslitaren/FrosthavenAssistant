import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:frosthaven_assistant/services/translation_service.dart';

import '../../Resource/line_builder/line_builder.dart';
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
// Normal layout positions
const double _kTitleTop = 3.5;
const double _kTitleLeft = 2.0;
const double _kTitleFontSize = 11.0;
const double _kLevelLeft = 3.2;
const double _kLevelTop = 3.2;
const double _kNormalStatsLeft = 64.0;
const double _kNormalStatsTop = 20.8;
const double _kNormalAttribTop = 19.2;
const double _kNormalAttribWidth = 58.4;
const double _kEliteStatsRight = 61.6;
const double _kEliteAttribWidth = 57.6;
const double _kStatIconLeft = 74.8;
const double _kStatIconTopMove = 35.6;
const double _kStatIconTopRange = 66.0;
const double _kConditionLeft = 45.0;
const double _kConditionBottom = 10.0;

String _statDisplay(Object? stat, bool noCalc) {
  if (!noCalc) {
    final v = StatCalculator.calculateFormula(stat ?? 0);
    if (v != null) return v.toString();
  }
  return stat?.toString() ?? "";
}

class MonsterStatNormalLayout extends StatelessWidget {
  const MonsterStatNormalLayout({
    super.key,
    required this.data,
    required this.scale,
    required this.frosthavenStyle,
    this.settings,
  });

  final Monster data;
  final double scale;
  final bool frosthavenStyle;
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
    final rightStyle = getCardNumberStyle(
        _kStatsFontSize * scale, shadow, frosthavenStyle,
        height: _kStatsLineHeight);
    MonsterStatsModel? normal = data.type.levels[data.level.value].normal;
    MonsterStatsModel? elite = data.type.levels[data.level.value].elite;

    final noCalculationSetting = settings_.noCalculation.value;
    final health = _statDisplay(normal?.health, noCalculationSetting);
    final move = _statDisplay(normal?.move, noCalculationSetting);
    final attack = _statDisplay(normal?.attack, noCalculationSetting);

    return RepaintBoundary(
        child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
              Radius.circular(kGameCardBorderRadius * scale)),
          child: Image(
            height: _kCardHeight * scale,
            width: _kCardWidth * scale,
            fit: BoxFit.fitHeight,
            image:
                const AssetImage("assets/images/psd/monsterStats-normal.png"),
          ),
        ),
        Positioned(
            width: _kCardWidth * scale,
            left: _kTitleLeft * scale,
            top: _kTitleTop * scale,
            child: Text(
              textAlign: TextAlign.center,
              getIt<TranslationService>().t(data.type.display),
              style: getCardTitleStyle(
                  _kTitleFontSize * scale, shadow, frosthavenStyle,
                  height: 1),
            )),
        Positioned(
            left: _kLevelLeft * scale,
            top: _kLevelTop * scale,
            child: Text(
              data.level.value.toString(),
              style: getCardNumberStyle(
                  _kLevelFontSize * scale, shadow, frosthavenStyle,
                  height: 1),
            )),
        Positioned(
          left: _kNormalStatsLeft * scale,
          top: _kNormalStatsTop * scale,
          child: Column(
            children: <Widget>[
              Text(health, style: leftStyle),
              Text(move, style: leftStyle),
              Text(attack, style: leftStyle),
              Text(normal?.range != 0 ? normal?.range.toString() ?? "" : "-",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
            left: 0.0,
            top: _kNormalAttribTop * scale,
            width: _kNormalAttribWidth * scale,
            child: RepaintBoundary(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  LineBuilder.createLines(
                      normal?.attributes ?? [],
                      true,
                      false,
                      false,
                      data,
                      CrossAxisAlignment.end,
                      scale,
                      settings_.shimmer.value),
                ]))),
        Positioned(
          right: _kEliteStatsRight * scale,
          top: _kNormalStatsTop * scale,
          child: Column(
            children: <Widget>[
              Text(
                  StatCalculator.calculateFormula(elite?.health ?? 0)
                      .toString(),
                  style: rightStyle),
              Text(StatCalculator.calculateFormula(elite?.move ?? 0).toString(),
                  style: rightStyle),
              Text(
                  StatCalculator.calculateFormula(elite?.attack ?? 0)
                      .toString(),
                  style: rightStyle),
              Text(elite?.range != 0 ? elite?.range.toString() ?? "" : "-",
                  style: rightStyle),
            ],
          ),
        ),
        Positioned(
          width: _kEliteAttribWidth * scale,
          right: 0.0,
          top: _kNormalAttribTop * scale,
          child: RepaintBoundary(
              child: LineBuilder.createLines(
                  elite?.attributes ?? [],
                  false,
                  false,
                  false,
                  data,
                  CrossAxisAlignment.start,
                  scale,
                  settings_.shimmer.value)),
        ),
        if (data.type.flying)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kStatIconLeft * scale,
              top: _kStatIconTopMove * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/flying-stat_fh.png"
                    : "assets/images/psd/flying-stat.png"),
              )),
        if (!data.type.flying && frosthavenStyle)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kStatIconLeft * scale,
              top: _kStatIconTopMove * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/move-stat_fh.png"),
              )),
        if (frosthavenStyle)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kStatIconLeft * scale,
              top: _kStatIconTopRange * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/range-stat_fh.png"),
              )),
        if (data.type.capture)
          Positioned(
              height: _kStatIconHeight * scale,
              left: _kStatIconLeft * scale,
              top: _kStatIconTopRange * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/capture.png"),
              )),
        Positioned(
            left: _kConditionLeft * scale,
            bottom: _kConditionBottom * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: createConditionList(data, scale, normal!),
            )),
        Positioned(
            right: _kConditionLeft * scale,
            bottom: _kConditionBottom * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: createConditionList(data, scale, elite!),
            ))
      ],
    ));
  }
}
