import 'package:flutter/material.dart';

void openDialog(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
  /*Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (BuildContext context) {
      return widget;
    },
  ));*/
}

void openDialogAtPosition(
    BuildContext context, Widget widget, double x, double y) {
  double xOffset =
      (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dx;
  double yOffset =
      (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
  openDialog(
      context,
      Stack(children: [
        Positioned(
            left: x + xOffset, // left coordinate
            top: y + yOffset, // top coordinate
            child: Dialog(
                /*shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(
                    color: Colors.green,
                  ),
                ),*/
                insetPadding: const EdgeInsets.all(0),
                insetAnimationCurve: Curves.easeInOut, //does nothing?
                //insetAnimationDuration: Duration(milliseconds: 1500),
                child: widget)),
      ]));
}
