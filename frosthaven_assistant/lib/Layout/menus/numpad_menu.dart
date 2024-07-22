import 'package:flutter/material.dart';

import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class NumpadMenu extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final Function(String)? onChange;

  const NumpadMenu({super.key, required this.controller, required this.maxLength, this.onChange});

  @override
  NumpadMenuState createState() => NumpadMenuState();
}

class NumpadMenuState extends State<NumpadMenu> {
  String text = "";

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildNrButton(int nr, double scale) {
    return SizedBox(
      width: 40 * scale,
      height: 40 * scale,
      child: TextButton(
        child: Text(
          nr.toString(),
          style: getTitleTextStyle(scale),
        ),
        onPressed: () {
          text += nr.toString();
          widget.controller.text = text;

          if (widget.onChange != null) {
            widget.onChange!(text);
          }

          if (text.length >= widget.maxLength) {
            Navigator.pop(context);
          }
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;
    if (!isPhoneScreen(context)) {
      scale = 1.5;
      if (isLargeTablet(context)) {
        scale = 2;
      }
    }
    return Container(
        width: 10,
        height: 180 * scale,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value
                ? 'assets/images/bg/dark_bg.png'
                : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20 * scale,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(1, scale),
                      buildNrButton(2, scale),
                      buildNrButton(3, scale),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(4, scale),
                      buildNrButton(5, scale),
                      buildNrButton(6, scale),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(7, scale),
                      buildNrButton(8, scale),
                      buildNrButton(9, scale),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildNrButton(0, scale),
                    ],
                  ),
                ],
              ),
            ]));
  }
}
