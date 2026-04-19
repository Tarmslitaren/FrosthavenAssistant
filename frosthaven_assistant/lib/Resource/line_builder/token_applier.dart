import 'package:flutter/material.dart';

import '../ui_utils.dart';
import 'line_builder.dart';

class TokenApplier {
  static const int _kModRangeStart = -2;
  static const int _kModRangeEnd = 4;
  static const int _kModifierTokenLength = 2;
  static const double _kTokenSize = 20.0;
  static const double _kTokenBorderRadius = 30.0;
  static const double _kDefaultFontSize = 16.0;
  static const double _kUseElementTop = 10.0;
  static const double _kUseElementLeft = 8.5;
  static const double _kUseElementScale = 0.5;

  static Widget applyTokensForPerks(final String text) {
    String line = text;
    for (int i = _kModRangeStart; i <= _kModRangeEnd; i++) {
      String sign = i < 0 ? "" : "+";
      String glyph = sign + i.toString();
      line = line.replaceAll(glyph, "%$glyph%");
    }
    line = line.replaceAll("2x", "%2x%");
    line = line.replaceAll("+X", "%+X%");

    //removing empty spaces  eg - 1 -> -1
    for (int i = 1; i <= _kModRangeEnd; i++) {
      line = line.replaceAll("- $i", "-$i");
      line = line.replaceAll("+ $i", "+$i");
    }

    List<InlineSpan> textPartListRowContent = [];
    int partStartIndex = 0;
    bool isIconPart = false;
    bool useElement = false;
    final imageSuffix = "_fh";
    const fontStyle = TextStyle(
        fontFamily: 'Majalla', color: Colors.black, fontSize: 24, height: 0.84);
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '%') {
        if (isIconPart) {
          String iconToken = line.substring(partStartIndex, i);
          if (iconToken.length == _kModifierTokenLength) {
            textPartListRowContent.add(WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                    width: _kTokenSize,
                    height: _kTokenSize,
                    decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                          color: Colors.black,
                        )),
                        borderRadius: BorderRadius.all(Radius.circular(_kTokenBorderRadius))),
                    child: Text(
                      iconToken,
                      textAlign: TextAlign.center,
                    ))));
          } else {
            //handle use element
            if (iconToken == "use") {
              useElement = true;
            } else {
              //create token part
              String iconGfx = iconToken;
              double height = 20;

              bool hasOldVersion = hasGHVersion(iconGfx);

              if (LineBuilder.tokens[iconToken] != null) {
                RegExp regEx = RegExp(
                    r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
                if (regEx.hasMatch(LineBuilder.tokens[iconToken]!)) { // ignore: avoid-non-null-assertion
                  iconGfx += "_black";
                }
              }

              String imagePath = "assets/images/abilities/$iconGfx.png";
              if (hasOldVersion) {
                imagePath = "assets/images/abilities/$iconGfx$imageSuffix.png";
              }

              Widget child = Image(
                height: height,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.medium,
                semanticLabel: iconGfx,
                image: AssetImage(imagePath),
              );

              if (!useElement) {
                child = Container(
                    height: height, clipBehavior: Clip.none, child: child);

                textPartListRowContent.add(WidgetSpan(
                    alignment: PlaceholderAlignment.middle, child: child));
              } else {
                final double fontSize = fontStyle.fontSize ?? _kDefaultFontSize;

                Image lastImage = (child is Image)
                    ? child
                    : (child as OverflowBox).child as Image;
                textPartListRowContent.add(WidgetSpan(
                    child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    lastImage,
                    Positioned(
                        //width: fontSize * 0.6,
                        top: _kUseElementTop,
                        left: _kUseElementLeft,
                        //why left?!

                        child: Image(
                          height: fontSize * _kUseElementScale,
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.medium,
                          semanticLabel: iconGfx,
                          image: AssetImage(
                              "assets/images/abilities/use_plain_fh.png"),
                        ))
                  ],
                )));
                // textPartListRowContent
                //     .add(TextSpan(text: " :", style: fontStyle));

                useElement = false;
              }
            }
          }
          isIconPart = false;
        } else {
          //create part up to now if length more than 0
          if (i > 0 && partStartIndex < i) {
            String textPart = line.substring(partStartIndex, i);
            textPartListRowContent
                .add(TextSpan(style: fontStyle, text: textPart));
          }
          isIconPart = true;
        }
        partStartIndex = i + 1;
      }
    }
    if (partStartIndex < line.length) {
      String textPart = line.substring(partStartIndex);
      textPartListRowContent.add(TextSpan(style: fontStyle, text: textPart));
    }
    return Text.rich(TextSpan(children: textPartListRowContent));
  }
}
