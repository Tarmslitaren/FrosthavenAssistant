import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../services/service_locator.dart';
import 'state/game_state.dart';

void openDialogOld(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
}

TextStyle getTitleTextStyle(double scale,
    {bool forceBlack = false, Settings? settings}) {
  //note force black since non modal menus are all white even in dark mode.
  return TextStyle(
      fontSize: kFontSizeTitle * scale,
      color: forceBlack || !(settings ?? getIt<Settings>()).darkMode.value
          ? Colors.black
          : Colors.white);
}

TextStyle getSmallTextStyle(double scale,
    {bool forceBlack = false, Settings? settings}) {
  //note force black since non modal menus are all white even in dark mode.
  return TextStyle(
      fontSize: kFontSizeSmall * scale,
      color: forceBlack || !(settings ?? getIt<Settings>()).darkMode.value
          ? Colors.black
          : Colors.white);
}

TextStyle getButtonTextStyle(double scale) {
  return TextStyle(fontSize: kFontSizeSmall * scale, color: Colors.blue);
}

bool isLargeTablet(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  if (screenWidth < screenHeight && screenHeight > kLargeTabletMinDimension) {
    return true;
  }
  if (screenWidth > screenHeight && screenWidth > kLargeTabletMinDimension) {
    return true;
  }
  return false;
}

bool isPhoneScreen(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  if (screenWidth > screenHeight && screenHeight < kPhoneScreenMaxDimension) {
    return true;
  }
  if (screenWidth < screenHeight && screenWidth < kPhoneScreenMaxDimension) {
    return true;
  }
  return false;
}

double getModalMenuScale(BuildContext context) {
  double scale = 1;
  if (!isPhoneScreen(context)) {
    scale = kModalScaleTablet;
    if (isLargeTablet(context)) {
      scale = kModalScaleLargeTablet;
    }
  }
  return scale;
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

void openDialog(BuildContext context, Widget widget) {
  openDialogWithDismissOption(context, widget, true);
}

void openDialogWithDismissOption(
    BuildContext context, Widget widget, bool dismissible) {
  //could potentially modify edge insets based on screen width.
  Widget innerWidget = Stack(children: [
    Positioned(
      child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(kDialogInsetPadding),
          child: widget),
    )
  ]);
  showDialog(
      barrierDismissible: dismissible,
      context: context,
      builder: (BuildContext context) => innerWidget);
}

//used to get transparent background when dragging in re-orderable widgets
Widget defaultBuildDraggableFeedback(
    BuildContext context, BoxConstraints constraints, Widget child) {
  return Transform(
    transform: Matrix4.rotationZ(0),
    alignment: FractionalOffset.topLeft,
    child: Material(
      elevation: 6.0,
      color: Colors.transparent,
      borderRadius: BorderRadius.zero,
      child: Card(
          color: Colors.transparent,
          child: ConstrainedBox(constraints: constraints, child: child)),
    ),
  );
}

final Set<String> _ghVersionSet = {
  "attack",
  "damage",
  "disarm",
  "flying",
  "heal",
  "immobilize",
  "invisible",
  "jump",
  "loot",
  "move",
  "pierce",
  "poison",
  "push",
  "pull",
  "stun",
  "target",
  "range",
  "retaliate",
  "shield",
  "strengthen",
  "teleport",
  "use",
  "wound"
};

bool hasGHVersion(String name) {
  return _ghVersionSet.contains(name);
}

const TextStyle toastTextStyle =
    TextStyle(fontFamily: "markazi", fontSize: kFontSizeToast);
GestureDetector createToastContent(BuildContext context, String text) {
  return GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
    child: Text(text, style: toastTextStyle),
  );
}

void showToast(BuildContext context, String text) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.teal,
      content: createToastContent(context, text),
    ));
  }
}

void showToastSticky(BuildContext context, String text,
    {GameState? gameState}) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          duration: const Duration(days: 1),
          backgroundColor: Colors.teal,
          content: createToastContent(context, text),
        ))
        .closed
        .then((value) {
      if ((gameState ?? getIt<GameState>()).toastMessage.value == text) {
        GameUtilMethods.setToastMessage("");
      }
    });
  }
}

void showErrorToastStickyWithRetry(
    BuildContext context, String text, Function() retry,
    {GameState? gameState}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        duration: const Duration(days: 1),
        backgroundColor: Colors.redAccent,
        content: Row(
          children: [
            Expanded(child: createToastContent(context, text)),
            TextButton(
                onPressed: () {
                  retry();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: const Text("RETRY",
                    style: TextStyle(
                        fontFamily: "markazi",
                        fontSize: kFontSizeToast,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ))
      .closed
      .then((value) {
    if ((gameState ?? getIt<GameState>()).toastMessage.value == text) {
      GameUtilMethods.setToastMessage("");
    }
  });
}
