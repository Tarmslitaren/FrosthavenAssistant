import 'package:flutter/material.dart';

import '../ui_utils.dart';
import 'line_builder.dart';

class TokenApplier {
  static Widget applyTokensForPerks(final String text) {
    String line = text;
    for (int i = -2; i <= 4; i++) {
      String sign = i < 0 ? "-" : "+";
      String glyph = sign + i.toString();
      line = line.replaceAll(glyph, "%$glyph%");
    }

    List<InlineSpan> textPartListRowContent = [];
    int partStartIndex = 0;
    bool isIconPart = false;
    final imageSuffix = "_fh";
    const fontStyle = TextStyle(
        fontFamily: 'Majalla', color: Colors.black, fontSize: 24, height: 0.84);
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '%') {
        if (isIconPart) {
          String iconToken = line.substring(partStartIndex, i);
          if (iconToken.length == 2) {
            textPartListRowContent.add(WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                          color: Colors.black,
                        )),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text(
                      iconToken,
                      textAlign: TextAlign.center,
                    ))));
          } else {
            //create token part
            String iconGfx = iconToken;
            double height = 20;

            RegExp regEx = RegExp(
                r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
            if (regEx.hasMatch(LineBuilder.tokens[iconToken]!)) {
              iconGfx += "_black";
            }

            String imagePath = "assets/images/abilities/$iconGfx.png";
            if (imageSuffix.isNotEmpty && hasGHVersion(iconGfx)) {
              imagePath = "assets/images/abilities/$iconGfx$imageSuffix.png";
            }
            Widget child = Image(
              height: height,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.medium,
              semanticLabel: iconGfx,
              image: AssetImage(imagePath),
            );
            child = Container(
                height: height, clipBehavior: Clip.none, child: child);

            textPartListRowContent.add(WidgetSpan(
                alignment: PlaceholderAlignment.middle, child: child));
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
