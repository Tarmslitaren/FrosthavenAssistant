import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/line_builder/frosthaven_converter.dart';
import 'package:frosthaven_assistant/Resource/line_builder/line_styles.dart';
import 'package:frosthaven_assistant/Resource/line_builder/stat_applier.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../game_methods.dart';
import '../state/game_state.dart';

class LineBuilder {
  static const bool debugColors = false;

  // Image/icon scale factors
  static const double _kImageScaleBase = 0.8;
  static const double _kImageScaleAsset = 0.55;
  static const double _kElementScaleFactor = 0.6;
  static const double _kDividerImageScale = 0.15;
  static const double _kDividerImageHeight = 6.0;
  static const double _kDividerThinImageHeight = 2.0;
  static const double _kDividerImageWidth = 55.0;
  static const double _kAoeScaleRatio = 2.0;
  static const double _kSubLineHeightMod = 1.35 * 1.15;

  // "Use" token layout
  static const double _kUseFHWidthRatio = 0.8;
  static const double _kUseFHWidthAdd = 5.0;
  static const double _kUseGHRatio = 1.2;
  static const double _kUseLeft = 2.8;
  static const double _kUseFHHeightRatio = 0.5;

  // Height mod for main-line icons (no scaling)
  static const double _kHeightModMainLine = 1.0;
  static const double _kMidFontSizeGH = 8.8;

  // Margins and spacing
  static const double _kRightMarginNormal = 3.0;
  static const double _kRightMarginElementUse = 1.0;
  static const double _kMarginCenterRatio = 0.2;
  static const double _kMarginStatRatio = 0.1;
  static const double _kConditionMarginRatio = 0.25;

  static const Map<String, String> tokens = {
    "attack": "Attack",
    "move": "Move",
    "teleport": "Teleport",
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
    "empower": "EMPOWER",
    "bless": "BLESS",
    "safeguard": "SAFEGUARD",
    "flip": "ROLLING",
    "damage": "damage",
    "and": "and"
  };

  static bool isElement(String item) {
    if (item.contains("air") ||
        item.contains("earth") ||
        item.contains("fire") ||
        item.contains("ice") ||
        item.contains("dark") ||
        item.contains("light") ||
        item == "any") {
      return true;
    }
    return false;
  }

  static double getTopPaddingForStyle(TextStyle style) {
    double height = style.fontSize ?? 0.0;
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

  static Widget createLines(
      List<String> strings,
      final bool left,
      final bool applyStats,
      final bool applyAll,
      final Monster? monster,
      final CrossAxisAlignment alignment,
      final double scale,
      final bool animate) {
    bool isBossStatCard = monster?.type.levels.first.boss != null &&
        alignment == CrossAxisAlignment.start;

    String imageSuffix = "";
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(monster?.type);
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

    final styles = LineStyles(
      scale: scale,
      left: left,
      frosthavenStyle: frosthavenStyle,
      alignment: alignment,
      debugColors: debugColors,
    );

    List<Widget> lines = [];
    List<String> localStrings = [];
    localStrings.addAll(strings);
    localStrings = FrosthavenConverter.expandEmbeddedNewlines(localStrings);
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

    final textColor =
        alignment == CrossAxisAlignment.end ? Colors.black : Colors.white;
    final colorizeColors = [
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
      var styleToUse = styles.normal;
      List<Widget> textPartListRowContent = [];

      //handle FH layout with gray background for sub-lines
      if (line.contains("[subLineEnd]")) {
        FrosthavenConverter.buildFHStyleBackgrounds(
            lines,
            lastLineTextPartListRowContent,
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
        for (final item in widgetsInInnerRow) {
          texts += FrosthavenConverter.getAllTextInWidget(item);
        }
        if (texts.contains(" :")) {
          elementUse = true;
          conditional = true;
        }
        if (texts.lastIndexOf(" :") != texts.indexOf(" :")) {
          columnHack = true;
        }

        double rightMargin = _kRightMarginNormal * scale;
        if (texts == " :") {
          //has only element to element:
          rightMargin = _kRightMarginElementUse * scale;
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
        for (final item in widgetsInRow) {
          texts += FrosthavenConverter.getAllTextInWidget(item);
        }
        if (texts.contains(" :")) {
          elementUse = true;
          conditional = true;
        }
        if (texts.lastIndexOf(" :") != texts.indexOf(" :")) {
          columnHack = true;
        }

        double rightMargin = _kRightMarginNormal * scale;
        if (texts == " :") {
          //has only element to element:
          rightMargin = _kRightMarginElementUse * scale;
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
        double scaleConstant = _kImageScaleBase *
            _kImageScaleAsset; //this is because of the actual size of the assets
        if (isElement(line.substring(1))) {
          //because we added new graphics for these that are bigger
          scaleConstant *= _kElementScaleFactor;
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
        styleToUse = styles.small;
        line = line.substring(1, line.length);
        if (line.startsWith("....") || line.startsWith("*....")) {
          styleToUse = styles.divider;
          if (line.startsWith('*')) {
            line = line.substring(1, line.length);
            styleToUse = styles.dividerThin;
          }

          if (frosthavenStyle || alignment == CrossAxisAlignment.start) {
            Widget image = Image.asset(
              alignment: alignment == CrossAxisAlignment.start
                  ? Alignment.centerLeft
                  : Alignment.center,
              scale: 1 / (scale * _kDividerImageScale),
              //for some reason flutter likes scale to be inverted
              height: styleToUse == styles.dividerThin
                  ? _kDividerThinImageHeight * scale
                  : _kDividerImageHeight * scale,
              width: _kDividerImageWidth *
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
        styleToUse = styles.mid;
        line = line.substring(1, line.length);
        if (line.startsWith('^')) {
          //double ^^ : no means no, you bastard!
          styleToUse = styles.midSquished;
          line = line.substring(1, line.length);
        }
      }
      if (line.startsWith('>')) {
        //disable apply stats (for granted lines) //Too bad it doesn't work here
        line = line.substring(1, line.length);
      } else if (applyStats && monster != null) {
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
            bool hasOldStyle = hasGHVersion(iconGfx);
            if (monster != null && iconToken == "move" && monster.type.flying) {
              iconGfx = "flying";
            }
            if (left) {
              RegExp regEx = RegExp(
                  r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
              final tokenVal = tokens[iconToken];
              if (tokenVal != null && regEx.hasMatch(tokenVal)) {
                iconGfx += "_black";
              }
            }
            if (iconToken == "use") {
              Widget part = textPartListRowContent.removeLast();
              Container container = part as Container;
              final child = container.child;
              Image lastImage = (child is Image)
                  ? child
                  : (child as OverflowBox).child as Image;
              textPartListRowContent.add(Container(
                  color: debugColors ? Colors.amber : null,
                  //margin: margin,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      lastImage,
                      Positioned(
                          width: frosthavenStyle
                              ? (styleToUse.fontSize ?? 0.0) *
                                      _kUseFHWidthRatio +
                                  scale * _kUseFHWidthAdd
                              : (styleToUse.fontSize ?? 0.0) * _kUseGHRatio,
                          bottom: 0,
                          left: frosthavenStyle ? _kUseLeft * scale : 0.0,
                          //why left?!

                          child: Image(
                            height: frosthavenStyle
                                ? (styleToUse.fontSize ?? 0.0) *
                                    _kUseFHHeightRatio
                                : (styleToUse.fontSize ?? 0.0) * _kUseGHRatio,
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
                      top: getTopPaddingForStyle(styles.normal) *
                          _kUseFHHeightRatio),
                  child: Text(frosthavenStyle ? " :" : " : ",
                      style: styles.normal)));
            } else {
              double height = _getIconHeight(
                  iconToken, styleToUse.fontSize ?? 0.0, frosthavenStyle);
              if (addText) {
                String? iconTokenText = tokens[iconToken];
                if (frosthavenStyle) {
                  iconTokenText = null;
                } else if (iconTokenText != null) {
                  //TODO: add animation on other texts too? and need to animate icons as well then for FH style
                  bool shouldAnimate = animate &&
                      monster != null &&
                      (line.toLowerCase().contains('disadvantage') ||
                          line.contains('retaliate') ||
                          line.contains('shield')) &&
                      monster.isActive;
                  if (monster != null &&
                      monster.turnState.value == TurnsState.current) {
                    if (line.toLowerCase().contains("advantage")) {
                      shouldAnimate = true;
                    }
                  }

                  textPartListRowContent.add(Container(
                      color: debugColors ? Colors.red : null,
                      padding: EdgeInsets.only(
                          top: getTopPaddingForStyle(styleToUse)),
                      child: shouldAnimate
                          ? RepaintBoundary(
                              child: AnimatedTextKit(
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
                            ))
                          : Text(iconTokenText, style: styleToUse)));
                }
              }
              bool mainLine =
                  styleToUse == styles.normal || styleToUse == styles.elite;
              EdgeInsetsGeometry margin = _getMarginForToken(
                  iconToken, height, mainLine, alignment, frosthavenStyle);

              String imagePath = "assets/images/abilities/$iconGfx.png";
              if (imageSuffix.isNotEmpty && hasOldStyle) {
                imagePath = "assets/images/abilities/$iconGfx$imageSuffix.png";
              }
              bool overflow =
                  FrosthavenConverter.shouldOverflow(frosthavenStyle, iconGfx);
              double heightMod = mainLine
                  ? _kHeightModMainLine
                  : _kSubLineHeightMod; //to make sub line conditions have larger size and overflow on FH style
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
          if (styleToUse == styles.normal) {
            styleToUse = styles.elite;
          } else if (styleToUse == styles.small) {
            styleToUse = styles.eliteSmall;
          } else if (styleToUse == styles.mid) {
            styleToUse = styles.eliteMid;
          }
        }
        if (line[i] == "Å") {
          styleToUse = TextStyle(
              backgroundColor: debugColors ? Colors.amber : null,
              fontFamily: 'Majalla',
              color: Colors.transparent,
              fontSize: _kMidFontSizeGH * scale,
              height: _kHeightModMainLine);
        }
      }

      //TODO: add animation on other texts too? and need to animate icons as well then for FH style
      bool shouldAnimate = animate &&
          monster != null &&
          (line.toLowerCase().contains('disadvantage') ||
              line.contains('retaliate') ||
              line.contains('shield')) &&
          monster.isActive;
      if (monster != null && monster.turnState.value == TurnsState.current) {
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
                ? RepaintBoundary(
                    child: AnimatedTextKit(
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
                  ))
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

  static double _getIconHeight(
      String iconToken, double height, bool isFrosthavenStyle) {
    if (isElement(iconToken)) {
      //FH style: elements have same size as regular icons
      return isFrosthavenStyle ? height : height * _kUseGHRatio;
    }
    if (iconToken.contains("aoe")) {
      return height * _kAoeScaleRatio;
    }
    return height;
  }

  static EdgeInsetsGeometry _getMarginForToken(String iconToken, double height,
      bool mainLine, CrossAxisAlignment alignment, bool isFrostHavenStyle) {
    double margin = _kMarginCenterRatio;

    if (alignment != CrossAxisAlignment.center) {
      margin = _kMarginStatRatio;
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
        iconToken == "safeguard" ||
        iconToken == "muddle") {
      //todo; optimize with else and no strcmp
      if (mainLine) {
        //smaller margins for secondary modifiers
        return const EdgeInsets.all(0);
      } else if (isFrostHavenStyle && iconToken != "target") {
        //need more margin around the over sized condition gfx
        return EdgeInsets.only(
            left: _kConditionMarginRatio * height,
            right: _kConditionMarginRatio * height);
      }
    }
    if (isFrostHavenStyle) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.only(
        left: _kMarginStatRatio * height, right: _kMarginStatRatio * height);
  }
}
