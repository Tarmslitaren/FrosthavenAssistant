import 'package:flutter/material.dart';

import 'element_button.dart';

AppBar createTopBar() {
  return AppBar(
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    //TODO: set the text to be state specific: add characters, set scenario or add monsters, choose cards(initiative), take turns. Or don't. add instructions to drawer menu and instead highlight what t do next.
    title: const Text(
      "Frosthaven Helper", style: TextStyle(
      fontFamily: 'Pirata',
      color: Colors.white,
      fontSize: 25,
    ),
    ),
    toolbarHeight: 40, // Set this height
    flexibleSpace: const Image(
      image: AssetImage('assets/images/psd/frosthaven-bar.png'),
      //fit: BoxFit.fitHeight,
      repeat: ImageRepeat.repeat
    ),
    actions: [
      ElementButton(
          key: UniqueKey(),
          color: Colors.red,
          icon: 'assets/images/psd/element-fire.png'
        // Use the properties stored in the State class.
      ),
      ElementButton(
          key: UniqueKey(),
          color: Colors.blue,
          icon: 'assets/images/psd/element-ice.png'
        // Use the properties stored in the State class.
      ),
      ElementButton(
          key: UniqueKey(),
          color: Colors.grey,
          icon: 'assets/images/psd/element-air.png'
        // Use the properties stored in the State class.
      ),
      ElementButton(
          key: UniqueKey(),
          color: Colors.green,
          icon: 'assets/images/psd/element-earth.png'
        // Use the properties stored in the State class.
      ),
      ElementButton(
          key: UniqueKey(),
          color: Colors.yellow,
          icon: 'assets/images/psd/element-light.png'
        // Use the properties stored in the State class.
      ),
      ElementButton(
          key: UniqueKey(),
          color: Colors.black,
          icon: 'assets/images/psd/element-dark.png'
        // Use the properties stored in the State class.
      ),
    ],
  );
}
