import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../services/service_locator.dart';
import 'game_state.dart';

void openDialogOld(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
}

TextStyle getTitleTextStyle() {
  return TextStyle(
      fontSize: 18,
      color: getIt<Settings>().darkMode.value ? Colors.white : Colors.black);
}

TextStyle getSmallTextStyle() {
  return TextStyle(
    fontSize: 14,
    color: getIt<Settings>().darkMode.value ? Colors.white : Colors.black,
  );
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

void openDialog(BuildContext context, Widget widget) {
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
                    context); //only way to remake the valuelistenable builders with broken references
                return widget;
              })),
    )
  ]);
  showDialog(context: context, builder: (BuildContext context) => innerWidget);
}

//note: not working properly and not used
void openDialogAtPosition(
    BuildContext context, Widget widget, double x, double y) {
  double xOffset =
      (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dx;
  double yOffset =
      (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
  openDialogOld(
      context,
      Stack(children: [
        Positioned(
            left: x + xOffset, // left coordinate
            top: y + yOffset, // top coordinate
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Dialog(
                    backgroundColor: Colors.transparent,
                    /*shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(
                    color: Colors.green,
                  ),
                ),*/
                    insetPadding: const EdgeInsets.all(0),
                    insetAnimationCurve: Curves.easeInOut, //does nothing?
                    //insetAnimationDuration: Duration(milliseconds: 1500),
                    child: widget))),
      ]));
}

//used to get transpaarant background when dragging in reorderable widgets
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
  if (name == "bane") {
    return false;
  }
  if (name == "bless") {
    return false;
  }
  if (name == "curse") {
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

showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //duration: const Duration(days: 1),
    content: GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Text(
        text,
        style: const TextStyle(
            fontFamily: "markazi",
            fontSize: 28
        ),),
    ),
    backgroundColor: Colors.teal,
  ));
}

showToastSticky(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(days: 1),
    content: GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Text(
        text,
        style: const TextStyle(
            fontFamily: "markazi",
            fontSize: 28
        ),),
    ),
    backgroundColor: Colors.teal,
  ));

}