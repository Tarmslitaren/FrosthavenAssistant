import 'package:flutter/material.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class NumpadMenu extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final Function(String)? onChange;
  const NumpadMenu({Key? key, required this.controller, required this.maxLength, this.onChange}) : super(key: key);

  @override
  NumpadMenuState createState() => NumpadMenuState();
}

class NumpadMenuState extends State<NumpadMenu> {
  final GameState _gameState = getIt<GameState>();
  String text = "";

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildNrButton(int nr) {
    return  SizedBox(
            width: 32,
            height: 32,
            child: TextButton(
              child: Text(
                nr.toString(),
                style: getTitleTextStyle(),
              ),
              onPressed: () {
                text += nr.toString();
                widget.controller.text = text;

                if(widget.onChange != null) {
                  widget.onChange!(text);
                }

                if (text.length >= widget.maxLength){
                  Navigator.pop(context);
                }
                FocusManager
                    .instance.primaryFocus
                    ?.unfocus();
              },
            ),
          );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 10,
        height: 160,
        decoration: BoxDecoration(
          //color: Colors.black,
          //borderRadius: BorderRadius.all(Radius.circular(8)),

          /*border: Border.fromBorderSide(BorderSide(
            color: Colors.blueGrey,
            width: 10
          )),*/
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value?
            'assets/images/bg/dark_bg.png'
                :'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          //alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(1),
                      buildNrButton(2),
                      buildNrButton(3),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(4),
                      buildNrButton(5),
                      buildNrButton(6),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(7),
                      buildNrButton(8),
                      buildNrButton(9),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(0),
                    ],
                  ),
                ],
              ),
            ]));
  }
}
