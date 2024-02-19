import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/line_builder/frosthaven_converter.dart';
import 'package:frosthaven_assistant/Resource/line_builder/stat_applier.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../state/game_state.dart';

class LineBuilder {
  static const bool debugColors = false;
  static const Map<String, String> _tokens = {
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
    "enfeeble": "ENFEEBLE",
    "bless": "BLESS",
    "damage": "damage",
    "and": "and"
  };

  static bool isElement(String item) {
    if (item == "air" ||
        item == "earth" ||
        item == "earthfire" ||
        item == "fire" ||
        item == "ice" ||
        item == "dark" ||
        item == "light" ||
        item == "any") {
      return true;
    }
    return false;
  }

  static double _getIconHeight(
      String iconToken, double height, bool isFrosthavenStyle) {
    if (isElement(iconToken)) {
      //FH style: elements have same size as regular icons
      return isFrosthavenStyle ? height : height * 1.2;
    }
    if (iconToken.contains("aoe")) {
      return height * 2.0;
    }
    //if(shouldOverflow(isFrosthavenStyle, iconToken, true)) {
    //  return height * 1.2;
    //}
    return height;
  }

  static EdgeInsetsGeometry _getMarginForToken(String iconToken, double height,
      bool mainLine, CrossAxisAlignment alignment, bool isFrostHavenStyle) {
    double margin = 0.2;

    if (alignment != CrossAxisAlignment.center) {
      margin = 0.1;
    }
    if (isFrostHavenStyle) {
      margin = 0;
    }
    if (iconToken.contains("aoe")) {
      return EdgeInsets.only(left: margin * height, right: margin * height);
    }
    if (mainLine &&
        (iconToken == "attack" ||
            iconToken == "heal" ||
            iconToken == "loot" ||
            iconToken == "shield" ||
            iconToken == "move")) {
      return EdgeInsets.only(left: margin * height, right: margin * height);
    }
    if (iconToken == "pierce" ||
        iconToken == "target" ||
        iconToken == "curse" ||
        iconToken == "enfeeble" ||
        iconToken == "bless" ||
        iconToken == "enfeeble" ||
        iconToken == "push" ||
        iconToken == "pull" ||
        iconToken.contains("poison") ||
        iconToken.contains("wound") ||
        iconToken == "infect" ||
        iconToken == "chill" ||
        iconToken == "disarm" ||
        iconToken == "immobilize" ||
        iconToken == "stun" ||
        iconToken == "strengthen" ||
        iconToken == "impair" ||
        iconToken == "bane" ||
        iconToken == "brittle" ||
        iconToken == "invisible" ||
        iconToken == "muddle") {
      if (mainLine) {
        //smaller margins for secondary modifiers
        return const EdgeInsets.all(0);
      } else if (isFrostHavenStyle == true && iconToken != "target") {
        //need more margin around the over sized condition gfx
        return EdgeInsets.only(left: 0.25 * height, right: 0.25 * height);
      }
    }
    if (isFrostHavenStyle) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.only(left: 0.1 * height, right: 0.1 * height);
  }

  //get rid of this if it doesn't really help
  static double getTopPaddingForStyle(TextStyle style) {
    double height = style.fontSize!;
    bool markazi = style.fontFamily == "Markazi";

    if (!markazi && style.height == 0.85) {
      return height * 0.25;
    }
    if (markazi && style.height == 0.84) {
      return height * 0.1;
    }
    return 0;
  }

  static Widget createLinesColumn(
      CrossAxisAlignment alignment, List<Widget> lines) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.max,
        children: lines);
  }

  static Widget createLines(List<String> strings,
      final bool left,
      final bool applyStats,
      final bool applyAll,
      final Monster monster,
      final CrossAxisAlignment alignment,
      final double scale,
      final bool animate) {

    //todo: for performance - check how often is this being run
    bool isBossStatCard = monster.type.levels[0].boss != null &&
        alignment == CrossAxisAlignment.start;

    String imageSuffix = "";
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(monster.type);
    if (frosthavenStyle) {
      imageSuffix = "_fh";
    }
    MainAxisAlignment rowMainAxisAlignment = MainAxisAlignment.center;
    if (alignment == CrossAxisAlignment.start) {
      rowMainAxisAlignment = MainAxisAlignment.start;
    }
    if (alignment == CrossAxisAlignment.end) {
      rowMainAxisAlignment = MainAxisAlignment.end;
    }

    var shadow = Shadow(
      offset: Offset(0.4 * scale, 0.4 * scale),
      color: left ? Colors.black54 : Colors.black87,
      blurRadius: 1.0 * scale,
    );
    var dividerStyle = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: 6.4 * scale,
        letterSpacing: 1.6 * scale,
        height: 0.7,
        shadows: [shadow]);

    var dividerStyleExtraThin = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: 4.8 * scale,
        letterSpacing: 1.6 * scale,
        height: 0.1,
        shadows: [shadow]);

    var smallStyle = TextStyle(
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center ? 8.0 : 7.4) * scale,
        //sizes are larger on stat cards
        height: 0.8,
        backgroundColor: debugColors ? Colors.amber : null,
        //0.85,
        shadows: [shadow]);
    var midStyle = TextStyle(
        backgroundColor: debugColors ? Colors.greenAccent : null,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: ((alignment == CrossAxisAlignment.center
            ? frosthavenStyle
            ? 9.52 //7.52 is closer to physical size, but too hard to see on smaller screens
            : 8.8
            : frosthavenStyle
            ? 8.8
            : 9.9) *
            scale), //.floorToDouble()+0.5, //not sur eif flooring the mid scale is really the best option. or only happens to work on my android
        //sizes are larger on stat cards
        height: (alignment == CrossAxisAlignment.center
                ? frosthavenStyle
                    ? 1.0 //he one problem here: one line no icons -> squished
                    : 0.85
                : 0.85 //0.8
            ),
        // 0.9,
        shadows: [shadow]);
    var normalStyle = TextStyle(
        //maybe slightly bigger between chars space?
        //leadingDistribution: TextLeadingDistribution.even,
        //textBaseline: TextBaseline.alphabetic,
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: left ? Colors.black : Colors.white,
        backgroundColor: debugColors ? Colors.lightGreen : null,
        fontSize: (alignment == CrossAxisAlignment.center
                ? frosthavenStyle
                    ? 13.1
                    : 12.56
                : 11.2) *
            scale,
        height: (alignment == CrossAxisAlignment.center)
            ? frosthavenStyle
                ? 0.84
                : 0.85 //need a little more than 1 to align the icons? why?
            : frosthavenStyle
                ? 0.84
                : 0.85, // needs to be at least one for the icon alignment...
        //height is really low for gh style due to text not being center aligned in font - so to force to center the height is reduced. this is a shitty solution to a shitty problem.
        // 0.84,

        shadows: [shadow]);

    var eliteStyle = TextStyle(
        backgroundColor: debugColors ? Colors.lightGreen : null,
        //leadingDistribution: TextLeadingDistribution.even,
        //textBaseline: TextBaseline.alphabetic,
        //maybe slightly bigger between chars space?
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: frosthavenStyle ? 13.1 * scale : 12.56 * scale,
        height: frosthavenStyle ? 0.84 : 0.85,
        shadows: [shadow]);

    var eliteSmallStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 8.0 * scale,
        height: 1.0,
        shadows: [shadow]);
    var eliteMidStyle = TextStyle(
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: frosthavenStyle ? 9.52 * scale : 8.8 * scale,
        height: frosthavenStyle ? 1.0 : 0.85,
        shadows: [shadow]);

    var midStyleSquished = TextStyle(
        backgroundColor: debugColors ? Colors.greenAccent : null,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center
                ? frosthavenStyle
                    ? 9.52
                    : 8.8
                : frosthavenStyle
                    ? 8.8
                    : 9.9) *
            scale,
        //sizes are larger on stat cards
        height: (alignment == CrossAxisAlignment.center ? 0.8 : 0.8),
        // 0.9,
        shadows: [shadow]);

    List<Widget> lines = [];
    List<String> localStrings = [];
    localStrings.addAll(strings);
    //List<InlineSpan> lastLineTextPartList = [];
    List<Widget> lastLineTextPartListRowContent = [];

    if (frosthavenStyle) {
      localStrings =
          FrosthavenConverter.convertLinesToFH(localStrings, applyStats);
    } else {
      localStrings.removeWhere((element) => element == "[newLine]");
      localStrings.removeWhere((element) => element == "[subLineEnd]");
    }

    //specialized layouts
    bool isInColumn = false;
    bool isInRow = false;
    bool isColumnInRow = false;
    List<Widget> widgetsInColumn = [];
    List<Widget> widgetsInRow = [];
    List<Widget> widgetsInInnerRow = [];
    Widget column;

    bool hasInnerRow = false;

    TextAlign textAlign = TextAlign.center;
    if (alignment == CrossAxisAlignment.start) {
      textAlign = TextAlign.start;
    }
    if (alignment == CrossAxisAlignment.end) {
      textAlign = TextAlign.end;
    }

    var textColor = alignment == CrossAxisAlignment.end ? Colors.black : Colors.white;
    var colorizeColors = [
      textColor,
      textColor,
      Colors.blueGrey,
      textColor,
      Colors.blueGrey,
      textColor,
      Colors.blueGrey,
      textColor,
    ];
    const int animationSpeed = 3500;

    for (int i = 0; i < localStrings.length; i++) {
      String line = localStrings[i];
      String sizeToken = "";
      bool isRightPartOfLastLine = false;
      var styleToUse = normalStyle;
      //List<InlineSpan> textPartList = [];
      List<Widget> textPartListRowContent = [];

      if (line == "[subLineStart]") {
        //continue;
      }
      //handle FH layout with gray background for sub-lines
      if (line.contains("[subLineEnd]")) {
        FrosthavenConverter.buildFHStyleBackgrounds(
            lines,
            lastLineTextPartListRowContent,
            textAlign,
            rowMainAxisAlignment,
            scale,
            isInRow,
            isInColumn,
            isColumnInRow,
            hasInnerRow,
            widgetsInColumn,
            widgetsInRow,
            widgetsInInnerRow,
            isBossStatCard);
        continue;
      }

      //Note: this solution can only have one column in a row and no deeper nesting
      if (line == "[c]") {
        isInColumn = true;
        if (isInRow) {
          isColumnInRow = true;
        }
        continue;
      }
      if (line == "[/c]") {
        //end column  //handle the results
        isInColumn = false;
        column = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.max,
          children: widgetsInColumn.toList(),
        );
        widgetsInColumn = [];
        if (isColumnInRow) {
          widgetsInRow.add(column);
        } else {
          lines.add(column);
          if (i == localStrings.length - 1) {
            //this never happens -unless last line is a [/c]
            return createLinesColumn(alignment, lines);
          }
        }
        continue;
      }
      if (line == "[r]") {
        isInRow = true;
        //start row
        continue;
      }
      if (line == "[s]") {
        //inner row. sort of
        hasInnerRow = true;
        continue;
      }
      if (line == "[/s]") {
        hasInnerRow = false;
        /////start the dotted hack
        bool elementUse = false;
        bool conditional = false;
        bool columnHack = false;
        //this is used since there is a bug where if there is a [r] %element%%use% [c] ... [/c][/r] then the use is drawn twice. the bug is likely higher up
        String texts = "";
        for (var item in widgetsInInnerRow) {
          texts += FrosthavenConverter.getAllTextInWidget(item);
        }
        if (texts.contains(" :")) {
          elementUse = true;
          conditional = true;
        }
        if (texts.lastIndexOf(" :") != texts.indexOf(" :")) {
          columnHack = true;
        }

        double rightMargin = 3.0 * scale;
        if (texts == " :") {
          //has only element to element:
          rightMargin = 1.0 * scale;
        }

        Row row = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: rowMainAxisAlignment,
          children: columnHack
              ? widgetsInInnerRow.sublist(1)
              : widgetsInInnerRow.toList(),
        );
        widgetsInInnerRow = [];

        if (frosthavenStyle && conditional) {
          //might need ot check if in column or row here
          FrosthavenConverter.applyConditionalGraphics(widgetsInColumn, scale,
              elementUse, rightMargin, isBossStatCard, row);
        } else {
          widgetsInColumn.add(row);
        }
        continue;
      }
      if (line == "[/r]") {
        //end row
        //end column  //handle the results
        isInRow = false;

        /////start the dotted hack
        bool elementUse = false;
        bool conditional = false;
        bool columnHack = false;
        //this is used since there is a bug where if there is a [r] %element%%use% [c] ... [/c][/r] then the use is drawn twice. the bug is likely higher up
        String texts = "";
        for (var item in widgetsInRow) {
          texts += FrosthavenConverter.getAllTextInWidget(item);
        }
        if (texts.contains(" :")) {
          elementUse = true;
          conditional = true;
        }
        if (texts.lastIndexOf(" :") != texts.indexOf(" :")) {
          columnHack = true;
        }

        double rightMargin = 3.0 * scale;
        if (texts == " :") {
          //has only element to element:
          rightMargin = 1.0 * scale;
        }

        Row row = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: rowMainAxisAlignment,
          children:
              columnHack ? widgetsInRow.sublist(1) : widgetsInRow.toList(),
        );
        widgetsInRow = [];

        if (frosthavenStyle && conditional) {
          FrosthavenConverter.applyConditionalGraphics(
              lines, scale, elementUse, rightMargin, isBossStatCard, row);
        } else {
          lines.add(row);
        }
        if (i == localStrings.length - 1) {
          //error just a string compare
          return createLinesColumn(alignment, lines);
        }
        continue;
      }

      if (line.startsWith('¤')) {
        double scaleConstant =
            0.8 * 0.55; //this is because of the actual size of the assets
        if (isElement(line.substring(1))) {
          //because we added new graphics for these that are bigger
          scaleConstant *= 0.6;
        }
        Widget image = Image.asset(
          scale: 1.0 / (scale * scaleConstant),
          //for some reason flutter likes scale to be inverted
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          semanticLabel: line.substring(1),
          "assets/images/abilities/${line.substring(1)}.png",
        );
        //create pure picture, not a WidgetSpan (scale 5.5)
        if (hasInnerRow) {
          widgetsInInnerRow.add(image);
        } else if (isInColumn && (!isInRow || isColumnInRow)) {
          widgetsInColumn.add(image);
        } else if (isInRow && (!isInColumn)) {
          widgetsInRow.add(image);
        } else {
          lines.add(image);
        }
        if (i == localStrings.length - 1) {
          return createLinesColumn(alignment, lines);
        }
        continue;
      }

      if (line.startsWith('!')) {
        //add as
        isRightPartOfLastLine = true;
        line = line.substring(1, line.length);
      }
      if (line.startsWith('*')) {
        sizeToken = '*';
        styleToUse = smallStyle;
        line = line.substring(1, line.length);
        if (line.startsWith("....") || line.startsWith("*....")) {
          styleToUse = dividerStyle;
          if (line.startsWith('*')) {
            line = line.substring(1, line.length);
            styleToUse = dividerStyleExtraThin;
          }

          if (frosthavenStyle || alignment == CrossAxisAlignment.start) {
            Widget image = Image.asset(
              alignment: alignment == CrossAxisAlignment.start
                  ? Alignment.centerLeft
                  : Alignment.center,
              scale: 1 / (scale * 0.15),
              //for some reason flutter likes scale to be inverted
              //fit: BoxFit.fitHeight,
              height:
                  styleToUse == dividerStyleExtraThin ? 2 * scale : 6.0 * scale,
              width: 55.0 *
                  scale, //actually 40, but some layout might depend on wider size so not changing now
              filterQuality: FilterQuality.medium,
              semanticLabel: "divider",
              alignment == CrossAxisAlignment.start
                  ? "assets/images/abilities/divider_boss_fh.png"
                  : "assets/images/abilities/divider_fh.png",
            );
            //create pure picture, not a WidgetSpan (scale 5.5)
            if (hasInnerRow) {
              widgetsInInnerRow.add(image);
            } else if (isInColumn && (!isInRow || isColumnInRow)) {
              widgetsInColumn.add(image);
            } else if (isInRow && (!isInColumn)) {
              widgetsInRow.add(image);
            } else {
              lines.add(image);
            }
            if (i == localStrings.length - 1) {
              return createLinesColumn(alignment, lines);
            }
            continue;
          }
        }
      }
      if (line.startsWith('^')) {
        sizeToken = '^';
        styleToUse = midStyle;
        line = line.substring(1, line.length);
        if (line.startsWith('^')) {
          //double ^^ : no means no, you bastard!
          styleToUse = midStyleSquished;
          line = line.substring(1, line.length);
        }
      }
      if (line.startsWith('>')) {
        //disable apply stats (for granted lines) //Too bad it doesn't work here
        line = line.substring(1, line.length);
      } else if (applyStats) {
        List<String> statLines =
            StatApplier.applyMonsterStats(line, sizeToken, monster, applyAll);
        line = statLines.removeAt(0);
        if (statLines.isNotEmpty) {
          localStrings.insertAll(i + 1, statLines);
        }
      }

      int partStartIndex = 0;
      bool isIconPart = false;
      bool addText = true;
      for (int i = 0; i < line.length; i++) {
        if (line[i] == "|") {
          //don't add text for conditions added with calculations
          addText = false;
        }
        if (line[i] == '%') {

          if (isIconPart) {
            //create token part
            String iconToken = line.substring(partStartIndex, i);
            String iconGfx = iconToken;
            if (left) {
              RegExp regEx = RegExp(
                  r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
              if (regEx.hasMatch(_tokens[iconToken]!) == true) {
                iconGfx += "_black";
              }
            }
            if (iconToken == "use") {
              //put use gfx on top of previous and add ':'
              // WidgetSpan part = textPartList.removeLast() as WidgetSpan;
              Widget part = textPartListRowContent.removeLast();
              Container container = part as Container;
              Image lastImage;
              if (container.child is Image) {
                lastImage = container.child as Image;
              } else {
                lastImage = (container.child as OverflowBox).child as Image;
              }
              //Image lastImage = ((part.child as Container).child as OverflowBox).child as Image;
              textPartListRowContent.add(Container(
                  color: debugColors ? Colors.amber : null,
                  //margin: margin,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      lastImage,
                      Positioned(
                          width: frosthavenStyle
                              ? styleToUse.fontSize! * 0.8 + scale * 5.0
                              : styleToUse.fontSize! * 1.2,
                          bottom: 0,
                          left: frosthavenStyle ? 2.8 * scale : 0.0,
                          //why left?!

                          child: Image(
                            height: frosthavenStyle
                                ? styleToUse.fontSize! * 1.0 * 0.5
                                : styleToUse.fontSize! * 1.2,
                            //width: frosthavenStyle? styleToUse.fontSize! * 1.2 * 0.5: styleToUse.fontSize! * 1.2,
                            //alignment: Alignment.topCenter,
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.medium,
                            semanticLabel: iconGfx,
                            image: AssetImage(
                                "assets/images/abilities/${iconGfx + imageSuffix}.png"),
                          ))
                    ],
                  )));
              textPartListRowContent.add(Container(
                  color: debugColors ? Colors.red : null,
                  padding: EdgeInsets.only(
                      top: getTopPaddingForStyle(normalStyle) * 0.5),
                  child: Text(
                    frosthavenStyle ? " :" : " : ",
                    style:
                        normalStyle, /*TextStyle(
                      //maybe slightly bigger between chars space?
                      fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                      color: left ? Colors.black : Colors.white,
                      backgroundColor: debugColors? Colors.amber : null,
                      fontSize:
                      ((alignment == CrossAxisAlignment.center ? 12 : 12) * scale),
                      height: (alignment == CrossAxisAlignment.center)
                          ? frosthavenStyle
                              ? 1.0
                              : 1.1
                          : 1.0,

                      shadows: [
                        shadow
                      ]))*/
                  )));
            } else {
              double height = _getIconHeight(
                  iconToken, styleToUse.fontSize!, frosthavenStyle);
              if (frosthavenStyle &&
                  styleToUse == midStyle &&
                  !FrosthavenConverter.shouldOverflow(true, iconToken, false)) {
              }
              if (addText) {
                String? iconTokenText = _tokens[iconToken];
                if (frosthavenStyle) {
                  iconTokenText = null;
                } else if (iconTokenText != null) {
                  //TODO: add animation on other texts too? and need to animate icons as well then for FH style
                  bool shouldAnimate = animate &&
                      (line.toLowerCase().contains('disadvantage') ||
                          line.contains('retaliate') ||
                          line.contains('shield')) &&
                      (monster.isActive ||
                          monster.monsterInstances.isNotEmpty);
                  if (monster.turnState == TurnsState.current) {
                    if (line.toLowerCase().contains("advantage")) {
                      shouldAnimate = true;
                    }
                  }

                  textPartListRowContent.add(Container(
                      color: debugColors ? Colors.red : null,
                      padding: EdgeInsets.only(
                          top: getTopPaddingForStyle(styleToUse)),
                      child: shouldAnimate
                          ? AnimatedTextKit(
                              repeatForever: true,
                              //pause: const Duration(milliseconds: textAnimationDelay),
                              animatedTexts: [
                                ColorizeAnimatedText(
                                  iconTokenText,
                                  speed: Duration(
                                      milliseconds: (animationSpeed /
                                              iconTokenText.length)
                                          .ceil()),
                                  textStyle: styleToUse,
                                  colors: colorizeColors,
                                ),
                              ],
                              // isRepeatingAnimation: true,
                            )
                          : Text(iconTokenText, style: styleToUse)));
                }
              }
              bool mainLine =
                  styleToUse == normalStyle || styleToUse == eliteStyle;
              EdgeInsetsGeometry margin = _getMarginForToken(
                  iconToken, height, mainLine, alignment, frosthavenStyle);
              if (iconToken == "move" && monster.type.flying) {
                iconGfx = "flying";
              }
              String imagePath = "assets/images/abilities/$iconGfx.png";
              if (imageSuffix.isNotEmpty && hasGHVersion(iconGfx)) {
                imagePath = "assets/images/abilities/$iconGfx$imageSuffix.png";
              }
              bool overflow = FrosthavenConverter.shouldOverflow(
                  frosthavenStyle, iconGfx, mainLine);
              double heightMod = mainLine
                  ? 1.0
                  : 1.35 *
                      1.15; //to make sub line conditions have larger size and overflow on FH style
              Widget child = Image(
                //could do funk stuff with the color value for cool effects maybe?
                height: overflow ? height * heightMod : height,
                // isAntiAlias: true,
                //this causes lines to have variable height if height set to less than 1
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.medium,
                semanticLabel: iconGfx,
                image: AssetImage(imagePath),
              );
              child = Container(
                  color: debugColors ? Colors.blue : null,
                  height: height,
                  width: overflow ? height : null,
                  margin: margin,
                  clipBehavior: Clip.none,
                  child: overflow
                      ? OverflowBox(
                          minWidth: 0.0,
                          minHeight: 0.0,
                          maxHeight: double.infinity,
                          maxWidth: double.infinity,
                          child: child,
                        )
                      : child);

              textPartListRowContent.add(child);
            }
            isIconPart = false;
            addText = true;
          } else {
            //create part up to now if length more than 0
            if (i > 0 && partStartIndex < i) {
              String textPart = line.substring(partStartIndex, i);
              if (i > 0 && line[i - 1] == "|") {
                //voi ei. remove the | from output. would be nice to find better place to do this
                textPart = line.substring(partStartIndex, i - 1);
              }

              textPartListRowContent.add(Container(
                  color: debugColors ? Colors.red : null,
                  padding:
                      EdgeInsets.only(top: getTopPaddingForStyle(styleToUse)),
                  child: Text(textPart, style: styleToUse)));
            }
            isIconPart = true;
          }
          partStartIndex = i + 1;
        }
        if (line[i] == "£") {
          //finish current part
          partStartIndex = i + 1;
          if (styleToUse == normalStyle) {
            styleToUse = eliteStyle;
          } else if (styleToUse == smallStyle) {
            styleToUse = eliteSmallStyle;
          } else if (styleToUse == midStyle) {
            styleToUse = eliteMidStyle;
          }
        }
        if (line[i] == "Å") {
          styleToUse = TextStyle(
              backgroundColor: debugColors ? Colors.amber : null,
              fontFamily: 'Majalla',
              color: Colors.transparent,
              fontSize: 8.8 * scale,
              height: 1);
        }
      }

      //TODO: add animation on other texts too? and need to animate icons as well then for FH style
      bool shouldAnimate = animate &&
          (line.toLowerCase().contains('disadvantage') ||
              line.contains('retaliate') ||
              line.contains('shield')) &&
          (monster.isActive || monster.monsterInstances.isNotEmpty);
      if (monster.turnState == TurnsState.current) {
        if (line.toLowerCase().contains("advantage")) {
          shouldAnimate = true;
        }
      }

      if (partStartIndex < line.length) {
        String textPart = line.substring(partStartIndex, line.length);
        textPartListRowContent.add(Container(
            color: debugColors ? Colors.red : null,
            padding: EdgeInsets.only(top: getTopPaddingForStyle(styleToUse)),
            child: shouldAnimate
                ? AnimatedTextKit(
                    repeatForever: true,
                    //pause: const Duration(milliseconds: textAnimationDelay),
                    animatedTexts: [
                      ColorizeAnimatedText(
                        speed: Duration(
                            milliseconds:
                                (animationSpeed / textPart.length).ceil()),
                        textPart,
                        textStyle: styleToUse,
                        colors: colorizeColors,
                      ),
                    ],
                    // isRepeatingAnimation: true,
                  )
                : Text(textPart, style: styleToUse)));
      }

      Row row = Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: rowMainAxisAlignment,
          children: textPartListRowContent);

      if (isRightPartOfLastLine) {
        if (hasInnerRow) {
          if (widgetsInInnerRow.isNotEmpty) {
            widgetsInInnerRow.removeLast();
          }
        } else if (isInColumn && (!isInRow || isColumnInRow)) {
          if (widgetsInColumn.isNotEmpty) {
            widgetsInColumn.removeLast();
          }
        } else if (isInRow && (!isInColumn)) {
          if (widgetsInRow.isNotEmpty) {
            widgetsInRow.removeLast();
          }
        } else {
          lines.removeLast();
        }
        textPartListRowContent.insertAll(0, lastLineTextPartListRowContent);

        row = Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: rowMainAxisAlignment,
            children: textPartListRowContent);
      }

      if (hasInnerRow) {
        widgetsInInnerRow.add(row);
      } else if (isInColumn && (!isInRow || isColumnInRow)) {
        widgetsInColumn.add(row);
      } else if (isInRow && (!isInColumn)) {
        widgetsInRow.add(row);
      } else {
        lines.add(row);
      }
      lastLineTextPartListRowContent = textPartListRowContent;
    }
    return createLinesColumn(alignment, lines);
  }
}
