import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';


//TODO: maybe kill this?
Widget createBottomBar(BuildContext context) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      image: const DecorationImage(
          image: AssetImage('assets/images/psd/frosthaven-bar.png'),
          //fit: BoxFit.fitHeight,
          repeat: ImageRepeat.repeat
      ),
    ),
    child: Row(
      children: [
        const DrawButton(),
        Column(
          children: const [

            Text(
                "#10 The Gauntlet"
            ),
            Text("level: 1 trap: 2 hazard: 1 xp: +4 coin: x2"),
          ],
        ),

      ],
    )

  );
}