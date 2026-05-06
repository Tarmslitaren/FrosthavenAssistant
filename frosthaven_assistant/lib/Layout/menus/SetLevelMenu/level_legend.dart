import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

const double _kLegendImageHeight = 20.0;
const double _kLegendLevelImageHeight = 15.0;
const double _kLegendSpacer = 8.0;
const double _kBoxShadowAlpha = 0.3;
const double _kBoxShadowSpread = 1.0;
const double _kBoxShadowBlur = 3.0;

class LevelLegend extends StatelessWidget {
  const LevelLegend({
    super.key,
    required this.name,
    required this.gfx,
    required this.value,
    required this.scale,
  });

  final String name;
  final String gfx;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final shadow = textShadow(scale);
    final textStyleLevelWidget = TextStyle(
        color: Colors.white,
        overflow: TextOverflow.fade,
        fontSize: kFontSizeTitle * scale,
        shadows: [shadow]);
    double height = _kLegendImageHeight * scale;
    if (gfx.contains("level")) {
      height = _kLegendLevelImageHeight * scale;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: _kLegendSpacer * scale),
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _kBoxShadowAlpha),
                  spreadRadius: _kBoxShadowSpread,
                  blurRadius: _kBoxShadowBlur,
                ),
              ],
            ),
            child: Image(height: height, image: AssetImage(gfx))),
        Text(value, style: textStyleLevelWidget),
        Text(" ($name)", style: textStyleLevelWidget),
      ],
    );
  }
}
