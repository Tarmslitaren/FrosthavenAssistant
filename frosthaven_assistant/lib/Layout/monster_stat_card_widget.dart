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
              child: MonsterStatCardView(
                  data: data,
                  scale: scale,
                  viewModel: vm,
                  settings: settings_)),
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
                            padding: EdgeInsets.only(
                                right: _kButtonPadding, top: _kButtonPadding),
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
                            padding: EdgeInsets.only(
                                left: _kButtonPadding, top: _kButtonPadding),
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
}

class _MonsterStatNormalLayout extends StatelessWidget {
  const _MonsterStatNormalLayout({
    required this.data,
    required this.scale,
    required this.shadow,
    required this.leftStyle,
    required this.rightStyle,
    required this.frosthavenStyle,
    this.settings,
  });

  final Monster data;
  final double scale;
  final Shadow shadow;
  final TextStyle leftStyle;
  final TextStyle rightStyle;
  final bool frosthavenStyle;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final settings_ = settings ?? getIt<Settings>();
    MonsterStatsModel? normal = data.type.levels[data.level.value].normal;
    MonsterStatsModel? elite = data.type.levels[data.level.value].elite;

    bool noCalculationSetting = settings_.noCalculation.value;

    String? health = normal?.health.toString();
    if (!noCalculationSetting) {
      int? healthValue = StatCalculator.calculateFormula(normal?.health ?? 0);
      if (healthValue != null) {
        health = healthValue.toString();
      }
    }

    String? move = normal?.move.toString();
    if (!noCalculationSetting) {
      int? moveValue = StatCalculator.calculateFormula(normal?.move ?? 0);
      if (moveValue != null) {
        move = moveValue.toString();
      }
    }

    String? attack = normal?.attack.toString();
    if (!noCalculationSetting) {
      int? attackValue = StatCalculator.calculateFormula(normal?.attack ?? 0);
      if (attackValue != null) {
        attack = attackValue.toString();
      }
    }

    return RepaintBoundary(
        child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
              Radius.circular(MonsterStatCardWidget._kBorderRadius * scale)),
          child: Image(
            height: MonsterStatCardWidget._kCardHeight * scale,
            width: MonsterStatCardWidget._kCardWidth * scale,
            fit: BoxFit.fitHeight,
            image:
                const AssetImage("assets/images/psd/monsterStats-normal.png"),
          ),
        ),
        Positioned(
            width: MonsterStatCardWidget._kCardWidth * scale,
            left: MonsterStatCardWidget._kTitleLeft * scale,
            top: MonsterStatCardWidget._kTitleTop * scale,
            child: Text(
              textAlign: TextAlign.center,
              data.type.display,
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'GermaniaOne' : 'Pirata',
                  color: Colors.white,
                  fontSize: MonsterStatCardWidget._kTitleFontSize * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
            left: MonsterStatCardWidget._kLevelLeft * scale,
            top: MonsterStatCardWidget._kLevelTop * scale,
            child: Text(
              data.level.value.toString(),
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                  color: Colors.white,
                  fontSize: MonsterStatCardWidget._kLevelFontSize * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
          left: MonsterStatCardWidget._kNormalStatsLeft * scale,
          top: MonsterStatCardWidget._kNormalStatsTop * scale,
          child: Column(
            children: <Widget>[
              Text(health ?? "", style: leftStyle),
              Text(move ?? "", style: leftStyle),
              Text(attack ?? "", style: leftStyle),
              Text(normal?.range != 0 ? normal?.range.toString() ?? "" : "-",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
            left: 0.0,
            top: MonsterStatCardWidget._kNormalAttribTop * scale,
            width: MonsterStatCardWidget._kNormalAttribWidth * scale,
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
          right: MonsterStatCardWidget._kEliteStatsRight * scale,
          top: MonsterStatCardWidget._kNormalStatsTop * scale,
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
          width: MonsterStatCardWidget._kEliteAttribWidth * scale,
          right: 0.0,
          top: MonsterStatCardWidget._kNormalAttribTop * scale,
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
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kStatIconLeft * scale,
              top: MonsterStatCardWidget._kStatIconTopMove * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/flying-stat_fh.png"
                    : "assets/images/psd/flying-stat.png"),
              )),
        if (!data.type.flying && frosthavenStyle)
          Positioned(
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kStatIconLeft * scale,
              top: MonsterStatCardWidget._kStatIconTopMove * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/move-stat_fh.png"),
              )),
        if (frosthavenStyle)
          Positioned(
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kStatIconLeft * scale,
              top: MonsterStatCardWidget._kStatIconTopRange * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/range-stat_fh.png"),
              )),
        if (data.type.capture)
          Positioned(
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kStatIconLeft * scale,
              top: MonsterStatCardWidget._kStatIconTopRange * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/capture.png"),
              )),
        Positioned(
            //TODO: move position to FH place in corner
            left: MonsterStatCardWidget._kConditionLeft * scale,
            bottom: MonsterStatCardWidget._kConditionBottom * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: MonsterStatCardWidget._createConditionList(
                  data, scale, normal!),
            )),
        Positioned(
            right: MonsterStatCardWidget._kConditionLeft * scale,
            bottom: MonsterStatCardWidget._kConditionBottom * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: MonsterStatCardWidget._createConditionList(
                  data, scale, elite!),
            ))
      ],
    ));
  }
}

class MonsterStatBossLayout extends StatelessWidget {
  const MonsterStatBossLayout({
    super.key,
    required this.data,
    required this.scale,
    required this.shadow,
    required this.leftStyle,
    required this.frosthavenStyle,
    required this.viewModel,
    this.settings,
  });

  final Monster data;
  final double scale;
  final Shadow shadow;
  final TextStyle leftStyle;
  final bool frosthavenStyle;
  final MonsterStatCardViewModel viewModel;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final settings_ = settings ?? getIt<Settings>();
    bool noCalculationSetting = settings_.noCalculation.value;
    MonsterStatsModel? normal = data.type.levels[data.level.value].boss;

    String? health = normal?.health.toString();
    if (!noCalculationSetting) {
      int? healthValue = StatCalculator.calculateFormula(normal?.health ?? 0);
      if (healthValue != null) {
        health = healthValue.toString();
      }
    }
    health = viewModel.resolveBossHealth(health ?? "0");

    String? attack = normal?.attack.toString();
    String? move = normal?.move.toString();
    if (!noCalculationSetting) {
      int? moveValue = StatCalculator.calculateFormula(normal?.move ?? 0);
      if (moveValue != null) {
        move = moveValue.toString();
      }
      int? attackValue = StatCalculator.calculateFormula(normal?.attack ?? 0);
      if (attackValue != null) {
        attack = attackValue.toString();
      }
    }

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

    final specialStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: MonsterStatCardWidget._kBossSpecialFontSize * scale,
        height: 1,
        shadows: [shadow]);

    return RepaintBoundary(
        child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
              Radius.circular(MonsterStatCardWidget._kBorderRadius * scale)),
          child: Image(
            height: MonsterStatCardWidget._kCardHeight * scale,
            width: MonsterStatCardWidget._kCardWidth * scale,
            fit: BoxFit.fitWidth,
            image: const AssetImage("assets/images/psd/monsterStats-boss.png"),
          ),
        ),
        Positioned(
            left: MonsterStatCardWidget._kBossLevelLeft * scale,
            top: frosthavenStyle
                ? MonsterStatCardWidget._kBossLevelTopFh * scale
                : MonsterStatCardWidget._kBossLevelTopGh * scale,
            child: Text(
              data.level.value.toString(),
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                  color: Colors.white,
                  fontSize: MonsterStatCardWidget._kLevelFontSize * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
          left: 0,
          top: frosthavenStyle
              ? MonsterStatCardWidget._kBossStatsTopFh * scale
              : MonsterStatCardWidget._kBossStatsTopGh * scale,
          width: MonsterStatCardWidget._kBossStatsWidth * scale,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(health, style: leftStyle),
              Text(move ?? "0", style: leftStyle),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: EdgeInsets.only(
                        right: bossAttackAttributes.contains("target")
                            ? MonsterStatCardWidget._kBossAttribMarginRight *
                                scale
                            : 0),
                    child: attackAttributes),
                Text(attack ?? "0", style: leftStyle)
              ]),
              Text(normal?.range != 0 ? normal?.range.toString() ?? " " : "",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
            left: MonsterStatCardWidget._kBossContentLeft * scale,
            top: MonsterStatCardWidget._kBossContentTop * scale,
            width: MonsterStatCardWidget._kBossContentWidth * scale,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              bossOtherAttributes.isNotEmpty
                  ? Row(children: [
                      Text("    ", style: specialStyle),
                      SizedBox(
                          width:
                              MonsterStatCardWidget._kBossSpecialWidth * scale,
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
                  scale:
                      1 / (scale * MonsterStatCardWidget._kDividerScaleFactor),
                  height: MonsterStatCardWidget._kDividerHeight * scale,
                  fit: BoxFit.fill,
                  width: MonsterStatCardWidget._kDividerWidth * scale,
                  filterQuality: FilterQuality.medium,
                  "assets/images/abilities/divider_boss_fh.png",
                ),
              normal?.special1.isNotEmpty ?? false
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            "1:",
                            style: specialStyle,
                          ),
                          SizedBox(
                              width: MonsterStatCardWidget._kBossSpecialWidth *
                                  scale,
                              child: RepaintBoundary(
                                  child: LineBuilder.createLines(
                                      data.type.levels[data.level.value].boss
                                              ?.special1 ??
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
                      scale: 1 /
                          (scale * MonsterStatCardWidget._kDividerScaleFactor),
                      height: MonsterStatCardWidget._kDividerHeight * scale,
                      fit: BoxFit.fill,
                      width: MonsterStatCardWidget._kDividerWidth * scale,
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
                              width: MonsterStatCardWidget._kBossSpecialWidth *
                                  scale,
                              child: RepaintBoundary(
                                  child: LineBuilder.createLines(
                                      data.type.levels[data.level.value].boss
                                              ?.special2 ??
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
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kBossStatIconLeft * scale,
              top: MonsterStatCardWidget._kBossStatIconTop * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/flying-stat_fh.png"
                    : "assets/images/psd/flying-stat.png"),
              )),
        if (!data.type.flying && !frosthavenStyle)
          Positioned(
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kBossStatIconLeft * scale,
              top: MonsterStatCardWidget._kBossStatIconTop * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/move-stat.png"),
              )),
        if (normal?.range != 0)
          Positioned(
              height: MonsterStatCardWidget._kStatIconHeight * scale,
              left: MonsterStatCardWidget._kBossRangeLeft * scale,
              top: MonsterStatCardWidget._kBossRangeTop * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/range-stat_fh.png"
                    : "assets/images/psd/range-stat.png"),
              )),
        Positioned(
            right: MonsterStatCardWidget._kBossConditionRight * scale,
            top: MonsterStatCardWidget._kBossConditionTop * scale,
            child: Row(
              children: MonsterStatCardWidget._createConditionList(
                  data, scale, normal!),
            )),
      ],
    ));
  }
}

class MonsterStatCardView extends StatelessWidget {
  const MonsterStatCardView({
    super.key,
    required this.data,
    required this.scale,
    required this.viewModel,
    this.settings,
  });

  final Monster data;
  final double scale;
  final MonsterStatCardViewModel viewModel;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(data.type);

    var shadow = Shadow(
      offset: Offset(MonsterStatCardWidget._kShadowTextOffset * scale,
          MonsterStatCardWidget._kShadowTextOffset * scale),
      color: Colors.black87,
      blurRadius: MonsterStatCardWidget._kShadowTextBlur * scale,
    );

    var shadowLeft = Shadow(
      offset: Offset(MonsterStatCardWidget._kShadowTextOffset * scale,
          MonsterStatCardWidget._kShadowTextOffset * scale),
      color: Colors.black54,
      blurRadius: MonsterStatCardWidget._kShadowTextBlur * scale,
    );

    final leftStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.black,
        fontSize: MonsterStatCardWidget._kStatsFontSize * scale,
        height: MonsterStatCardWidget._kStatsLineHeight,
        shadows: [shadowLeft]);

    final rightStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.white,
        fontSize: MonsterStatCardWidget._kStatsFontSize * scale,
        height: MonsterStatCardWidget._kStatsLineHeight,
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
                    blurRadius: MonsterStatCardWidget._kShadowBlur * scale,
                    offset: Offset(
                        MonsterStatCardWidget._kShadowOffsetX * scale,
                        MonsterStatCardWidget._kShadowOffsetY * scale),
                  ),
                ],
              ),
              margin: EdgeInsets.all(MonsterStatCardWidget._kMargin * scale),
              child: isBoss
                  ? MonsterStatBossLayout(
                      data: data,
                      scale: scale,
                      shadow: shadow,
                      leftStyle: leftStyle,
                      frosthavenStyle: frosthavenStyle,
                      viewModel: viewModel,
                      settings: settings)
                  : _MonsterStatNormalLayout(
                      data: data,
                      scale: scale,
                      shadow: shadow,
                      leftStyle: leftStyle,
                      rightStyle: rightStyle,
                      frosthavenStyle: frosthavenStyle,
                      settings: settings));
        });
  }
}
