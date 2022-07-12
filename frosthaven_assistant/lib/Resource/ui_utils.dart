import 'package:flutter/material.dart';

import '../services/service_locator.dart';
import 'commands/change_stat_command.dart';
import 'game_state.dart';

void openDialogOld(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
  /*Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (BuildContext context) {
      return widget;
    },
  ));*/
}

void openDialog(BuildContext context, Widget widget) {
  Widget innerWidget = Stack(children: [
    Positioned(
      child: Dialog(backgroundColor: Colors.transparent, child: widget),
    )
  ]);
  showDialog(context: context, builder: (BuildContext context) => innerWidget);
}

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
            child:GestureDetector(
                onTap: (){
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

Widget buildCounterButtons(
    ValueNotifier<int> notifier,
    int maxValue,
    String image,
    BuildContext context,
    Figure figure,
    bool showTotalValue,
    Color color) {
  GameState gameState = getIt<GameState>();

  final totalChangeValue = ValueNotifier<int>(0);
  return Row(children: [
    Container(
        width: 40,
        height: 40,
        child: IconButton(
            icon: Image.asset('assets/images/psd/sub.png'),
//iconSize: 30,
            onPressed: () {
              if (notifier.value > 0) {
                totalChangeValue.value--;
                gameState.action(ChangeStatCommand(-1, notifier, figure));
                if (notifier == figure.health && figure.health.value <= 0) {
                  {
                    Navigator.pop(context);
                  }
                }
              }
            })),
    Stack(children: [
      Container(
        width: 40,
        height: 40,
        child: Image(
          color: color,
          colorBlendMode: BlendMode.modulate,
          image: AssetImage(image),
        ),
      ),
      ValueListenableBuilder<int>(
          valueListenable: notifier,
          builder: (context, value, child) {
            String text = "";
            if(totalChangeValue.value > 0) {
              text = "+${totalChangeValue.value.toString()}";
            }
            else if(totalChangeValue.value != 0) {
              text = totalChangeValue.value.toString();
            }
            if(showTotalValue) {
              text = notifier.value.toString();
            }
            return Positioned(
              bottom: 0,
              right: 0,
              child: Text(text, style: TextStyle(color: color,
                  shadows: [
                  Shadow(offset: Offset(1, 1), color: Colors.black)]
            ),)
            );
          })
    ]),
    Container(
        width: 40,
        height: 40,
        child: IconButton(
          icon: Image.asset('assets/images/psd/add.png'),
//iconSize: 30,
          onPressed: () {
            if (notifier.value < maxValue) {
              totalChangeValue.value++;
              gameState.action(ChangeStatCommand(1, notifier, figure));
              if (notifier.value <= 0 && notifier == figure.health) {
                Navigator.pop(context);
              }
            }
//increment
          },
        )),
  ]);
}
