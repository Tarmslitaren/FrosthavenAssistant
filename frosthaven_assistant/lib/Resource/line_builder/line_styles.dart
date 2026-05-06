import 'package:flutter/material.dart';

const double _kLineHeightFH = 0.84;
const double _kLineHeightGH = 0.85;
const double _kLineHeightSmall = 0.8;
const double _kLineHeightMidFH = 1.0;
const double _kLineHeightDivider = 0.7;
const double _kLineHeightDividerThin = 0.1;

const double _kDividerFontSize = 6.4;
const double _kDividerThinFontSize = 4.8;
const double _kDividerLetterSpacing = 1.6;
const double _kSmallFontSizeCenter = 8.0;
const double _kSmallFontSizeStat = 7.4;
const double _kMidFontSizeFH = 9.52;
const double _kMidFontSizeGH = 8.8;
const double _kMidFontSizeGHStat = 9.9;
const double _kNormalFontSizeFH = 13.1;
const double _kNormalFontSizeGH = 12.56;
const double _kNormalFontSizeStat = 11.2;

const double _kShadowOffset = 0.4;
const double _kShadowBlur = 1.0;

class LineStyles {
  final TextStyle divider;
  final TextStyle dividerThin;
  final TextStyle small;
  final TextStyle mid;
  final TextStyle midSquished;
  final TextStyle normal;
  final TextStyle elite;
  final TextStyle eliteSmall;
  final TextStyle eliteMid;

  factory LineStyles({
    required double scale,
    required bool left,
    required bool frosthavenStyle,
    required CrossAxisAlignment alignment,
    required bool debugColors,
  }) {
    final shadow = Shadow(
      offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
      color: left ? Colors.black54 : Colors.black87,
      blurRadius: _kShadowBlur * scale,
    );

    final divider = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: _kDividerFontSize * scale,
        letterSpacing: _kDividerLetterSpacing * scale,
        height: _kLineHeightDivider,
        shadows: [shadow]);

    final dividerThin = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: _kDividerThinFontSize * scale,
        letterSpacing: _kDividerLetterSpacing * scale,
        height: _kLineHeightDividerThin,
        shadows: [shadow]);

    final small = TextStyle(
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center
                ? _kSmallFontSizeCenter
                : _kSmallFontSizeStat) *
            scale,
        height: _kLineHeightSmall,
        backgroundColor: debugColors ? Colors.amber : null,
        shadows: [shadow]);

    bool isCenterAlignment = alignment == CrossAxisAlignment.center;
    double centerMidFontSize = frosthavenStyle ? _kMidFontSizeFH : _kMidFontSizeGH;
    double nonCenterMidFontSize = frosthavenStyle ? _kMidFontSizeGH : _kMidFontSizeGHStat;
    double midFontSize = isCenterAlignment ? centerMidFontSize : nonCenterMidFontSize;
    double centerMidLineHeight = frosthavenStyle ? _kLineHeightMidFH : _kLineHeightGH;
    double midLineHeight = isCenterAlignment ? centerMidLineHeight : _kLineHeightGH;
    double centerNormalFontSize = frosthavenStyle ? _kNormalFontSizeFH : _kNormalFontSizeGH;
    double normalFontSize = isCenterAlignment ? centerNormalFontSize : _kNormalFontSizeStat;

    final mid = TextStyle(
        backgroundColor: debugColors ? Colors.greenAccent : null,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: midFontSize * scale,
        height: midLineHeight,
        shadows: [shadow]);

    final midSquished = TextStyle(
        backgroundColor: debugColors ? Colors.greenAccent : null,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: midFontSize * scale,
        height: _kLineHeightSmall,
        shadows: [shadow]);

    final normal = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: left ? Colors.black : Colors.white,
        backgroundColor: debugColors ? Colors.lightGreen : null,
        fontSize: normalFontSize * scale,
        height: frosthavenStyle ? _kLineHeightFH : _kLineHeightGH,
        shadows: [shadow]);

    final elite = TextStyle(
        backgroundColor: debugColors ? Colors.lightGreen : null,
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: frosthavenStyle
            ? _kNormalFontSizeFH * scale
            : _kNormalFontSizeGH * scale,
        height: frosthavenStyle ? _kLineHeightFH : _kLineHeightGH,
        shadows: [shadow]);

    final eliteSmall = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: _kSmallFontSizeCenter * scale,
        height: _kLineHeightMidFH,
        shadows: [shadow]);

    final eliteMid = TextStyle(
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: frosthavenStyle ? _kMidFontSizeFH * scale : _kMidFontSizeGH * scale,
        height: frosthavenStyle ? _kLineHeightMidFH : _kLineHeightGH,
        shadows: [shadow]);

    return LineStyles._(
      divider: divider,
      dividerThin: dividerThin,
      small: small,
      mid: mid,
      midSquished: midSquished,
      normal: normal,
      elite: elite,
      eliteSmall: eliteSmall,
      eliteMid: eliteMid,
    );
  }

  const LineStyles._({
    required this.divider,
    required this.dividerThin,
    required this.small,
    required this.mid,
    required this.midSquished,
    required this.normal,
    required this.elite,
    required this.eliteSmall,
    required this.eliteMid,
  });

}
