import 'package:flutter/material.dart';

import '../../Resource/enums.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../../services/translation_service.dart';
import '../view_models/monster_widget_view_model.dart';

const double _kImageMarginV = 4.0;
const double _kElevation = 8.0;
const double _kImageTopMargin = 2.0;
const double _kNameWidthRatio = 0.95;
const double _kNameMarginBottom = 2.0;
const double _kFontSize = 14.4;

class MonsterImagePart extends StatelessWidget {
  const MonsterImagePart({
    super.key,
    required this.data,
    required this.scale,
    required this.height,
    required this.vm,
  });

  final Monster data;
  final double scale;
  final double height;
  final MonsterWidgetViewModel vm;

  @override
  Widget build(BuildContext context) {
    final shadow = textShadow(scale);
    return RepaintBoundary(
        child: Stack(alignment: Alignment.bottomCenter, children: [
      Container(
          margin: EdgeInsets.only(
              bottom: _kImageMarginV * scale, top: _kImageMarginV * scale),
          child: PhysicalShape(
            color: vm.turnState == TurnsState.current
                ? Colors.tealAccent
                : Colors.transparent,
            shadowColor: Colors.black,
            elevation: _kElevation,
            clipper: const ShapeBorderClipper(shape: CircleBorder()),
            child: Container(
              margin: EdgeInsets.only(bottom: 0, top: _kImageTopMargin * scale),
              child: Image(
                fit: BoxFit.contain,
                height: height,
                width: height,
                image: AssetImage(
                    "assets/images/monsters/${data.type.gfx}.png"),
              ),
            ),
          )),
      Container(
          width: height * _kNameWidthRatio,
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
              bottom: vm.frosthavenStyle ? _kNameMarginBottom * scale : 0),
          child: Text(
            textAlign: TextAlign.center,
            getIt<TranslationService>().t(data.type.display),
            style: getCardTitleStyle(_kFontSize * scale, shadow, vm.frosthavenStyle),
          ))
    ]));
  }
}
