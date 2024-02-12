import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../services/service_locator.dart';
import 'state/game_state.dart';

void openDialogOld(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
}

TextStyle getTitleTextStyle(double scale) {
  return TextStyle(
      fontSize: 18 * scale,
      color: getIt<Settings>().darkMode.value ? Colors.white : Colors.black);
}

TextStyle getSmallTextStyle(double scale) {
  return TextStyle(
    fontSize: 14 * scale,
    color: getIt<Settings>().darkMode.value ? Colors.white : Colors.black,
  );
}

TextStyle getButtonTextStyle(double scale) {
  return TextStyle(
    fontSize: 14 * scale,
    color: Colors.blue
  );
}

bool isLargeTablet(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  if (screenWidth < screenHeight && screenHeight > 1200) {
    return true;
  }
  if (screenWidth > screenHeight && screenWidth > 1200) {
    return true;
  }
  return false;
}

bool isPhoneScreen(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  if (screenWidth > screenHeight && screenHeight < 600) {
    return true;
  }
  if (screenWidth < screenHeight && screenWidth < 600) {
    return true;
  }
  return false;
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
          insetPadding: const EdgeInsets.all(18),
          child: ValueListenableBuilder<int>(
              valueListenable: getIt<GameState>().updateForUndo,
              builder: (context, value, child) {
                rebuildAllChildren(
                    context); //only way to remake the value listenable builders with broken references
                return widget;
              })),
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
          //shadowColor: Colors.red,
          color: Colors.transparent,
          child: ConstrainedBox(constraints: constraints, child: child)),
    ),
  );
}

bool hasGHVersion(String name) {
  if (name.contains("aoe")) {
    return false;
  }
  if (name == ("dodge")) {
    return false;
  }
  if (name == "bane") {
    return false;
  }
  if (name == "bless") {
    return false;
  }
  if (name == "curse") {
    return false;
  }
  if (name == "enfeeble") {
    return false;
  }
  if (name == "brittle") {
    return false;
  }
  if (name == "chill") {
    return false;
  }
  if (name == "infect") {
    return false;
  }
  if (name == "impair") {
    return false;
  }
  if (name == "muddle") {
    return false;
  }
  if (name == "regenerate") {
    return false;
  }
  if (name == "ward") {
    return false;
  }
  if (name == "rupture") {
    return false;
  }
  if (name == "bane") {
    return false;
  }
  if (name == "air") {
    return false;
  }
  if (name.contains("earth")) {
    return false;
  }
  if (name == "ice") {
    return false;
  }
  if (name == "dark") {
    return false;
  }
  if (name == "light") {
    return false;
  }
  if (name == "any") {
    return false;
  }
  if (name == "fire") {
    return false;
  }
  return true;
}

const TextStyle toastTextStyle = TextStyle(fontFamily: "markazi", fontSize: 28);
createToastContent(BuildContext context, String text) {
  return GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
    child: Text(text, style: toastTextStyle),
  );
}

showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.teal,
    content: createToastContent(context, text),
  ));
}

showToastSticky(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        duration: const Duration(days: 1),
        backgroundColor: Colors.teal,
        content: createToastContent(context, text),
      ))
      .closed
      .then((value) {
    if (getIt<GameState>().toastMessage.value == text) {
      GameMethods.setToastMessage("");
    }
  });
}

showErrorToastStickyWithRetry(
    BuildContext context, String text, Function() retry) {
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
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ))
      .closed
      .then((value) {
    if (getIt<GameState>().toastMessage.value == text) {
      GameMethods.setToastMessage("");
    }
  });
}
