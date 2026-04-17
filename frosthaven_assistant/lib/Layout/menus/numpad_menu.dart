import 'package:flutter/material.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/ui_utils.dart';

class NumpadMenu extends StatefulWidget {
  const NumpadMenu(
      {super.key,
      required this.controller,
      required this.maxLength,
      this.onChange});

  final TextEditingController controller;
  final int maxLength;
  final Function(String)? onChange;

  @override
  NumpadMenuState createState() => NumpadMenuState();
}

class NumpadMenuState extends State<NumpadMenu> {
  static const double _kButtonSize = 40.0;
  static const double _kMenuWidth = 10.0;
  static const double _kMenuHeight = 180.0;
  static const double _kTopSpacing = 20.0;
  static const int _kNumpadRowCount = 3;
  static const int _kNumpadColCount = 3;

  String text = "";

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildNrButton(int nr, double scale) {
    return SizedBox(
      width: _kButtonSize * scale,
      height: _kButtonSize * scale,
      child: TextButton(
        child: Text(
          nr.toString(),
          style: getTitleTextStyle(scale),
        ),
        onPressed: () {
          text += nr.toString();
          widget.controller.text = text;
          widget.onChange?.call(text);

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
    double scale = getModalMenuScale(context);
    return ModalBackground(
        width: _kMenuWidth,
        height: _kMenuHeight * scale,
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: _kTopSpacing * scale,
              ),
              ...List.generate(
                _kNumpadRowCount,
                (rowIdx) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _kNumpadColCount,
                    (colIdx) => buildNrButton(rowIdx * _kNumpadColCount + colIdx + 1, scale),
                  ),
                ),
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
