import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
double tempScale = 0.8;

double getIconHeight(String iconToken, double height) {
  if(iconToken == "air" ||
      iconToken == "earth"||
      iconToken == "fire"||
      iconToken == "ice"||
      iconToken == "dark"||
      iconToken == "light"
  ){
    return height * 1.2;
  }
  if(iconToken.contains("aoe")){
    return height*2;
  }
  return height;
}

EdgeInsetsGeometry? getMarginForToken(String iconToken, double height, bool mainLine, CrossAxisAlignment alignment) {
  double margin = 0.5;
  if(alignment != CrossAxisAlignment.center) {
    margin = 0.1;
  }
  if (iconToken.contains("aoe")) {
    return EdgeInsets.only(left: margin * height, right: margin * height);
  }
  if(mainLine && (iconToken == "attack" ||
      iconToken == "heal" ||
      iconToken == "loot" ||
      iconToken == "shield" ||
      iconToken == "move")){
    return EdgeInsets.only(left: margin * height, right: margin * height);
  }
  if(iconToken == "air" ||
      iconToken == "earth"||
      iconToken == "fire"||
      iconToken == "ice"||
      iconToken == "dark"||
      iconToken == "light"
  ){
    return EdgeInsets.only(top: 0.19 * height); //since icons lager, need lager margin top
  }
  return null;
}

Widget createLines(List<String> strings, bool left, bool flying, CrossAxisAlignment alignment, double scale) {
  const Map<String, String> _tokens = {
    "attack": "Attack",
    "move": "Move",
    "range": "Range",
    "heal": "Heal",
    "target": "Target",
    "shield": "Shield",
    "loot": "Loot",
    "retaliate": "Retaliate",
    "jump": "Jump",
    "stun": "STUN",
    "wound": "WOUND",
    "disarm": "DISARM",
    "immobilize": "IMMOBILIZE",
    "poison": "POISON",
    "invisible": "INVISIBLE",
    "strengthen": "STRENGTHEN",
    "muddle": "MUDDLE",
    "regenerate": "REGENERATE",
    "ward": "WARD",
    "impair": "IMPAIR",
    "bane": "BANE",
    "brittle": "BRITTLE",
    "chill": "CHILL",
    "infect": "INFECT",
    "rupture": "RUPTURE",
    "push": "PUSH",
    "pull": "PULL",
    "pierce": "PIERCE",
    "curse": "CURSE",
    "bless": "BLESS",
    "and": "and"
  };

  var shadow = Shadow(
      offset: Offset(1 * scale * tempScale, 1 * scale* tempScale),
      color: left ? Colors.white : Colors.black);

  var dividerStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 8 * tempScale * scale,
      letterSpacing: 2 * tempScale * scale,
      height: 0.7,
      shadows: [shadow]);

  var smallStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 9 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  var midStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 12 * tempScale * scale,
      height: 0.9,
      shadows: [shadow]);
  var normalStyle = TextStyle( //maybe slightly bigger between chars space?
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 14 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  List<Widget> lines = [];
  for (String line in strings) {
    bool isRightPartOfLastLine = false;
    var styleToUse = normalStyle;
    List<InlineSpan> textPartList = [];
    if (line.startsWith('!')) {
      //add as
      isRightPartOfLastLine = true;
      line = line.substring(1, line.length);
    }
    if (line.startsWith('*')) {
      styleToUse = smallStyle;
      line = line.substring(1, line.length);
      if (line.startsWith("....")) {
        styleToUse = dividerStyle;
      }
    }
    if (line.startsWith('^')) {
      styleToUse = midStyle;
      line = line.substring(1, line.length);
    }

    int partStartIndex = 0;
    bool isIconPart = false;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '%') {
        //TODO: handle monster attributes and calculations:
        //TODO: show / and elite values in yellow only if elites available and vice versa for normals
        //TODO: if + check if move/attack/range and change calculations
        //TODO: if attributes has line of %muddle% etc. add muddle icon etc to attack line
        //TODO: do for all conditions + jump, pierce, add target  etc.
        

        if (isIconPart) {
          //create token part
          String iconToken = line.substring(partStartIndex, i);
          String iconGfx = iconToken;
          if(left) {
            RegExp regEx = RegExp(r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
            if(regEx.hasMatch(_tokens[iconToken]!) == true){
              iconGfx += "-medium-black";
            }
          }
          if (iconToken == "use") { //put use gfx on top of previous and add ':'
            WidgetSpan part = textPartList.removeLast() as WidgetSpan;
            Image lastImage = (part.child as Container).child as Image;
            textPartList.add(WidgetSpan(
                alignment: PlaceholderAlignment.top,
                style: TextStyle(fontSize: styleToUse.fontSize!*0.8),
                child: Stack(
                  children: [
                    lastImage,
                    Image(
                      height: styleToUse.fontSize! * 1.2,
                      //alignment: Alignment.topCenter,
                      image: AssetImage("assets/images/abilities/$iconGfx.png"),)
                  ],
                )));
            textPartList.add(TextSpan(text: ": ", style: styleToUse));
            //TODO: examine if removing the Container margins is the right thing to do for this case
          } else {
            double height = getIconHeight(iconToken, styleToUse.fontSize!);
            String? iconTokenText = _tokens[iconToken];
            textPartList.add(TextSpan(text: iconTokenText, style: styleToUse));
            bool mainLine = styleToUse == normalStyle;
            EdgeInsetsGeometry? margin = getMarginForToken(iconToken, height, mainLine, alignment);
            if(iconToken == "move" && flying){
              iconGfx = "flying";
            }
            Widget child = Image(
              height: height,
              //alignment: Alignment.topCenter,
              image: AssetImage("assets/images/abilities/$iconGfx.png"),
            );
            if (margin != null){
              child = Container(
                margin: margin,
                child: child,
              );
            }
            textPartList.add(WidgetSpan(
                alignment: PlaceholderAlignment.top,
                style: TextStyle(fontSize: styleToUse.fontSize!*0.8),//styleToUse, //don't ask (probably because height is 0.8
                child: child
            ));

          }
          isIconPart = false;
        } else {
          //create part up to now if length more than 0
          if (i > 0 && partStartIndex < i) {
            String textPart = line.substring(partStartIndex, i - 1);
            textPartList.add(TextSpan(text: textPart, style: styleToUse));
          }
          isIconPart = true;
        }
        partStartIndex = i + 1;
      }
    }

    if (partStartIndex < line.length) {
      String textPart = line.substring(partStartIndex, line.length);
      textPartList.add(TextSpan(text: textPart, style: styleToUse));
    }
    TextAlign textAlign = TextAlign.center;
    if(alignment == CrossAxisAlignment.start) {
      textAlign = TextAlign.start;
    }
    if(alignment == CrossAxisAlignment.end) {
      textAlign = TextAlign.end;
    }
    var text = Text.rich(
      textAlign: textAlign,
      TextSpan(
        children: textPartList,
      ),
    );
    if (isRightPartOfLastLine) {
      Widget line = lines.last;
      lines.removeLast();
      lines.add(Row(
        children: [line, text],
      ));
    } else {
      lines.add(text);
    }
  }
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.max,
      children: lines);
}
