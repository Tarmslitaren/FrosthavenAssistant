import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/game_methods.dart';
import '../Resource/line_builder/line_builder.dart';
import '../Resource/stat_calculator.dart';
import '../Resource/ui_utils.dart';
import 'menus/stat_card_zoom.dart';
import 'view_models/monster_stat_card_view_model.dart';

class MonsterStatCardWidget extends StatelessWidget {
  // Card dimensions
  static const double _kCardWidth = 167.0;
  static const double _kCardHeight = 93.5;
  static const double _kBorderRadius = 8.0;
  static const double _kShadowBlur = 4.0;
  static const double _kShadowOffsetX = 2.0;
  static const double _kShadowOffsetY = 4.0;
  static const double _kShadowTextOffset = 0.4;
  static const double _kShadowTextBlur = 1.0;
  static const double _kMargin = 1.6;
  // Normal layout positions
  static const double _kTitleTop = 3.5;
  static const double _kTitleLeft = 2.0;
  static const double _kTitleFontSize = 11.0;
  static const double _kLevelLeft = 3.2;
  static const double _kLevelTop = 3.2;
  static const double _kLevelFontSize = 14.4;
  static const double _kStatsFontSize = 12.8;
  static const double _kStatsLineHeight = 1.2;
  static const double _kNormalStatsLeft = 64.0;
  static const double _kNormalStatsTop = 20.8;
  static const double _kNormalAttribTop = 19.2;
  static const double _kNormalAttribWidth = 58.4;
  static const double _kEliteStatsRight = 61.6;
  static const double _kEliteAttribWidth = 57.6;
  static const double _kStatIconHeight = 16.0;
  static const double _kStatIconLeft = 74.8;
  static const double _kStatIconTopMove = 35.6;
  static const double _kStatIconTopRange = 66.0;
  static const double _kConditionLeft = 45.0;
  static const double _kConditionBottom = 10.0;
  // Boss layout positions
  static const double _kBossLevelLeft = 7.0;
  static const double _kBossLevelTopFh = 0.5;
  static const double _kBossLevelTopGh = 2.0;
  static const double _kBossStatsTopFh = 29.4;
  static const double _kBossStatsTopGh = 30.4;
  static const double _kBossStatsWidth = 24.0;
  static const double _kBossAttribMarginRight = 1.0;
  static const double _kBossContentLeft = 40.0;
  static const double _kBossContentTop = 16.0;
  static const double _kBossContentWidth = 128.0;
  static const double _kBossSpecialWidth = 112.0;
  static const double _kBossSpecialFontSize = 11.2;
  static const double _kDividerScaleFactor = 0.15;
  static const double _kDividerHeight = 1.0;
  static const double _kDividerWidth = 125.0;
  static const double _kBossStatIconLeft = 23.5;
  static const double _kBossStatIconTop = 44.4;
  static const double _kBossRangeLeft = 24.0;
  static const double _kBossRangeTop = 74.4;
  static const double _kBossConditionRight = 10.0;
  static const double _kBossConditionTop = 1.0;
  // Widget-level layout
  static const double _kWidgetWidth = 166.0;
  static const double _kButtonBottom = 4.0;
  static const double _kButtonSide = 4.0;
  static const double _kButtonIconSize = 20.0;
  static const double _kButtonPadding = 8.0;
  // Condition list icons
  static const double _kConditionIconHeight = 11.0;
  static const double _kImmuneIconHeight = 4.0;
  static const double _kConditionIconWidth = 14.0;
  static const double _kImmuneIconLeft = 9.0;
  static const double _kImmuneIconTop = 3.5;

  const MonsterStatCardWidget({
    super.key,
    required this.data,
    this.gameState,
    this.settings,
  });

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  static Widget buildNormalLayout(Monster data, double scale, Shadow shadow,
      TextStyle leftStyle, TextStyle rightStyle, bool frosthavenStyle,
      {Settings? settings}) {
    settings = settings ?? getIt<Settings>();
    MonsterStatsModel normal = data.type.levels[data.level.value].normal!;
    MonsterStatsModel? elite = data.type.levels[data.level.value].elite;

    bool noCalculationSetting = settings.noCalculation.value;

    //normal stats calculated:
    String health = normal.health.toString();
    if (!noCalculationSetting) {
      int? healthValue = StatCalculator.calculateFormula(normal.health);
      if (healthValue != null) {
        health = healthValue.toString();
      }
    }

    String move = normal.move.toString();
    if (!noCalculationSetting) {
      int? moveValue = StatCalculator.calculateFormula(normal.move);
      if (moveValue != null) {
        move = moveValue.toString();
      }
    }

    String attack = normal.attack.toString();
    if (!noCalculationSetting) {
      int? attackValue = StatCalculator.calculateFormula(normal.attack);
      if (attackValue != null) {
        attack = attackValue.toString();
      }
    }

    return RepaintBoundary(
        child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(_kBorderRadius * scale)),
          child: Image(
            height: _kCardHeight * scale,
            width: _kCardWidth * scale,
            fit: BoxFit.fitHeight,
            image: AssetImage("assets/images/psd/monsterStats-normal.png"),
          ),
        ),
        Positioned(
            width: _kCardWidth * scale,
            left: _kTitleLeft * scale,
            top: _kTitleTop * scale,
            child: Text(
              textAlign: TextAlign.center,
              data.type.display,
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'GermaniaOne' : 'Pirata',
                  color: Colors.white,
                  fontSize: _kTitleFontSize * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
            left: _kLevelLeft * scale,
            top: _kLevelTop * scale,
            child: Text(
              data.level.value.toString(),
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                  color: Colors.white,
                  fontSize: _kLevelFontSize * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
          left: _kNormalStatsLeft * scale,
          top: _kNormalStatsTop * scale,
          child: Column(
            children: <Widget>[
              Text(health, style: leftStyle),
              Text(move, style: leftStyle),
              Text(attack, style: leftStyle),
              Text(normal.range != 0 ? normal.range.toString() : "-",
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
                  normal.attributes,
                  true,
                  false,
                  false,
                  data,
                  CrossAxisAlignment.end,
                  scale,
                  settings.shimmer.value),
            ]))),
        Positioned(
          right: _kEliteStatsRight * scale,
          top: _kNormalStatsTop * scale,
          child: Column(
            children: <Widget>[
              Text(StatCalculator.calculateFormula(elite!.health).toString(),
                  style: rightStyle),
              Text(StatCalculator.calculateFormula(elite.move).toString(),
                  style: rightStyle),
              Text(StatCalculator.calculateFormula(elite.attack).toString(),
                  style: rightStyle),
              Text(elite.range != 0 ? elite.range.toString() : "-",
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
                  elite.attributes,
                  false,
                  false,
                  false,
                  data,
                  CrossAxisAlignment.start,
                  scale,
                  settings.shimmer.value)),
        ),
        data.type.flying
            ? Positioned(
                height: _kStatIconHeight * scale,
                left: _kStatIconLeft * scale,
                top: _kStatIconTopMove * scale,
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(frosthavenStyle
                      ? "assets/images/psd/flying-stat_fh.png"
                      : "assets/images/psd/flying-stat.png"),
                ))
            : frosthavenStyle
                ? Positioned(
                    height: _kStatIconHeight * scale,
                    left: _kStatIconLeft * scale,
                    top: _kStatIconTopMove * scale,
                    child: const Image(
                      fit: BoxFit.fitHeight,
                      image: AssetImage("assets/images/psd/move-stat_fh.png"),
                    ))
                : Container(),
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
            //TODO: move position to FH place in corner
            left: _kConditionLeft * scale,
            bottom: _kConditionBottom * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: _createConditionList(data, scale, normal),
            )),
        Positioned(
            right: _kConditionLeft * scale,
            bottom: _kConditionBottom * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: _createConditionList(data, scale, elite),
            ))
      ],
    ));
  }

  static Widget buildBossLayout(Monster data, double scale, Shadow shadow,
      TextStyle leftStyle, bool frosthavenStyle,
      {required MonsterStatCardViewModel viewModel, Settings? settings}) {
    settings = settings ?? getIt<Settings>();
    bool noCalculationSetting = settings.noCalculation.value;
    MonsterStatsModel normal = data.type.levels[data.level.value].boss!;
    //normal stats calculated:
    String health = normal.health.toString();
    if (!noCalculationSetting) {
      int? healthValue = StatCalculator.calculateFormula(normal.health);
      if (healthValue != null) {
        health = healthValue.toString();
      }
    }
    health = viewModel.resolveBossHealth(health);

    String attack = normal.attack.toString();
    String move = normal.move.toString();
    if (!noCalculationSetting) {
      int? moveValue = StatCalculator.calculateFormula(normal.move);
      if (moveValue != null) {
        move = moveValue.toString();
      }
      int? attackValue = StatCalculator.calculateFormula(normal.attack);
      if (attackValue != null) {
        attack = attackValue.toString();
      }
    }

    String bossAttackAttributes = "";
    List<String> bossOtherAttributes = [];

    for (String item in normal.attributes) {
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

    final specialStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: _kBossSpecialFontSize * scale,
        height: 1,
        shadows: [shadow]);

    return RepaintBoundary(
        child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(_kBorderRadius * scale)),
          child: Image(
            height: _kCardHeight * scale,
            width: _kCardWidth * scale,
            fit: BoxFit.fitWidth,
            image: const AssetImage("assets/images/psd/monsterStats-boss.png"),
          ),
        ),
        Positioned(
            left: _kBossLevelLeft * scale,
            top: frosthavenStyle ? _kBossLevelTopFh * scale : _kBossLevelTopGh * scale,
            child: Text(
              data.level.value.toString(),
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                  color: Colors.white,
                  fontSize: _kLevelFontSize * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
          left: 0,
          top: frosthavenStyle ? _kBossStatsTopFh * scale : _kBossStatsTopGh * scale,
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
              Text(normal.range != 0 ? normal.range.toString() : "",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
            left: _kBossContentLeft * scale,
            top: _kBossContentTop * scale,
            width: _kBossContentWidth * scale, //useful or not?
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                  settings.shimmer.value))),
                    ])
                  : Container(),
              if (bossOtherAttributes.isNotEmpty)
                Image.asset(
                  scale: 1 / (scale * _kDividerScaleFactor),
                  height: _kDividerHeight * scale,
                  fit: BoxFit.fill,
                  width: _kDividerWidth * scale,
                  //actually 40, but some layout might depend on wider size so not changing now
                  filterQuality: FilterQuality.medium,
                  "assets/images/abilities/divider_boss_fh.png",
                ),
              normal.special1.isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            "1:",
                            style: specialStyle,
                          ),
                          SizedBox(
                              width: _kBossSpecialWidth * scale,
                              child: RepaintBoundary(
                                  child: LineBuilder.createLines(
                                      data.type.levels[data.level.value].boss!
                                          .special1,
                                      false,
                                      !noCalculationSetting,
                                      false,
                                      data,
                                      CrossAxisAlignment.start,
                                      scale,
                                      false))),
                        ])
                  : Container(),
              normal.special2.isNotEmpty
                  ? Image.asset(
                      scale: 1 / (scale * _kDividerScaleFactor),
                      height: _kDividerHeight * scale,
                      fit: BoxFit.fill,
                      width: _kDividerWidth * scale,
                      //actually 40, but some layout might depend on wider size so not changing now
                      filterQuality: FilterQuality.medium,
                      "assets/images/abilities/divider_boss_fh.png",
                    )
                  : Container(),
              normal.special2.isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text("2:", style: specialStyle),
                          SizedBox(
                              width: _kBossSpecialWidth * scale,
                              child: RepaintBoundary(
                                  child: LineBuilder.createLines(
                                      data.type.levels[data.level.value].boss!
                                          .special2,
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
        data.type.flying
            ? Positioned(
                height: _kStatIconHeight * scale,
                left: _kBossStatIconLeft * scale,
                top: _kBossStatIconTop * scale,
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(frosthavenStyle
                      ? "assets/images/psd/flying-stat_fh.png"
                      : "assets/images/psd/flying-stat.png"),
                ),
              )
            : !frosthavenStyle
                ? Positioned(
                    height: _kStatIconHeight * scale,
                    left: _kBossStatIconLeft * scale,
                    top: _kBossStatIconTop * scale,
                    child: const Image(
                      fit: BoxFit.fitHeight,
                      image: AssetImage("assets/images/psd/move-stat.png"),
                    ),
                  )
                : Container(),
        if (normal.range != 0)
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
              children: _createConditionList(data, scale, normal),
            )),
      ],
    ));
  }

  static Widget buildCard(Monster data, double scale,
      {required MonsterStatCardViewModel viewModel, Settings? settings}) {
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(data.type);

    var shadow = Shadow(
      offset: Offset(_kShadowTextOffset * scale, _kShadowTextOffset * scale),
      color: Colors.black87,
      blurRadius: _kShadowTextBlur * scale,
    );

    var shadowLeft = Shadow(
      offset: Offset(_kShadowTextOffset * scale, _kShadowTextOffset * scale),
      color: Colors.black54,
      blurRadius: _kShadowTextBlur * scale,
    );

    final leftStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.black,
        fontSize: _kStatsFontSize * scale,
        height: _kStatsLineHeight,
        shadows: [shadowLeft]);

    final rightStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.white,
        fontSize: _kStatsFontSize * scale,
        height: _kStatsLineHeight,
        shadows: [shadow]);

    return ValueListenableBuilder<int>(
        valueListenable: data.level,
        builder: (context, value, child) {
          bool isBoss = data.type.levels[data.level.value].boss != null;

          return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: _kShadowBlur * scale,
                    offset: Offset(_kShadowOffsetX * scale, _kShadowOffsetY * scale), // Shadow position
                  ),
                ],
              ),
              margin: EdgeInsets.all(_kMargin * scale),
              child: isBoss
                  ? buildBossLayout(
                      data, scale, shadow, leftStyle, frosthavenStyle,
                      viewModel: viewModel, settings: settings)
                  : buildNormalLayout(data, scale, shadow, leftStyle,
                      rightStyle, frosthavenStyle,
                      settings: settings));
        });
  }

  final Monster data;

  @override
  Widget build(BuildContext context) {
    final vm = MonsterStatCardViewModel(data,
        gameState: gameState, settings: settings);
    final settings_ = settings ?? getIt<Settings>();
    double scale = getScaleByReference(context);

    return SizedBox(
        width: _kWidgetWidth * scale,
        child: Stack(children: [
          GestureDetector(
              onDoubleTap: () {
                openDialog(context, StatCardZoom(monster: data));
              },
              child:
                  buildCard(data, scale, viewModel: vm, settings: settings_)),
          if (!vm.isBoss)
            Positioned(
                bottom: _kButtonBottom * scale,
                left: _kButtonSide * scale,
                child: SizedBox(
                    width: _kButtonIconSize * scale + _kButtonPadding,
                    height: _kButtonIconSize * scale + _kButtonPadding,
                    child: ValueListenableBuilder<int>(
                        valueListenable: vm.commandIndex,
                        builder: (context, value, child) {
                          return IconButton(
                            padding: EdgeInsets.only(right: _kButtonPadding, top: _kButtonPadding),
                            icon: Image.asset(
                                height: _kButtonIconSize * scale,
                                fit: BoxFit.fitHeight,
                                color: vm.allStandeesOut
                                    ? Colors.white24
                                    : Colors.grey,
                                colorBlendMode: BlendMode.modulate,
                                'assets/images/psd/add.png'),
                            onPressed: () => vm.handleAddNormal(context),
                          );
                        }))),
          Positioned(
              bottom: _kButtonBottom * scale,
              right: _kButtonSide * scale,
              child: SizedBox(
                  width: _kButtonIconSize * scale + _kButtonPadding,
                  height: _kButtonIconSize * scale + _kButtonPadding,
                  child: ValueListenableBuilder<int>(
                      valueListenable: vm.commandIndex,
                      builder: (context, value, child) {
                        return IconButton(
                            padding: EdgeInsets.only(left: _kButtonPadding, top: _kButtonPadding),
                            icon: Image.asset(
                                color: vm.allStandeesOut
                                    ? Colors.white24
                                    : Colors.grey,
                                height: _kButtonIconSize * scale,
                                fit: BoxFit.fitHeight,
                                colorBlendMode: BlendMode.modulate,
                                'assets/images/psd/add.png'),
                            onPressed: () => vm.handleAddElite(context));
                      }))),
        ]));
  }

  static List<Widget> _createConditionList(
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
      Image image = Image(
        height: _kConditionIconHeight * scale,
        filterQuality: FilterQuality.medium, //needed because of the edges
        image: AssetImage(imagePath),
      );
      Image immuneIcon = Image(
        height: _kImmuneIconHeight * scale,
        filterQuality: FilterQuality.medium, //needed because of the edges
        image: const AssetImage("assets/images/psd/immune.png"),
      );
      Stack stack = Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 0, top: 0, child: image),
          Positioned(left: _kImmuneIconLeft * scale, top: _kImmuneIconTop * scale, child: immuneIcon),
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
}
