import 'package:flutter/material.dart';

class MainListWidget extends StatefulWidget {
  const MainListWidget({Key? key }) : super(key: key);

  @override
  MainListWidgetState createState() => MainListWidgetState();

}


class MainListWidgetState extends State<MainListWidget> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onVerticalDragStart: (details) {
          //start moving the widget in the list
        },
        onVerticalDragUpdate:(details) {
          //update widget position?
        },
        onVerticalDragEnd: (details) {
          //place back in list
        },

    );
  }
}
