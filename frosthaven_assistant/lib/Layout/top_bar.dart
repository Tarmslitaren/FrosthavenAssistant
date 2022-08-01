import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../Resource/enums.dart';
import '../Resource/game_state.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

AppBar createTopBar() {
  return AppBar(
    iconTheme: const IconThemeData(color: Colors.white),
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    //TODO: scale: minimum 40 height but scale up
    title: const Text(
      "Frosthaven\nAssistant",
      style: TextStyle(
        fontFamily: 'Pirata',
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    toolbarHeight: 40,
    // Set this height
    flexibleSpace: ValueListenableBuilder<bool>(
        valueListenable: getIt<Settings>().darkMode,
        builder: (context, value, child) {
          return Image(
              height: 40,
              image: AssetImage(getIt<Settings>().darkMode.value
                  ? 'assets/images/psd/gloomhaven-bar.png'
                  : 'assets/images/psd/frosthaven-bar.png'),
              //fit: BoxFit.fitHeight,
              repeat: ImageRepeat.repeat);
        }),
    actions: [
      ElementButton(
          key: UniqueKey(),
          color: const Color.fromARGB(255, 226, 66, 30),
          element: Elements.fire,
          icon: 'assets/images/psd/element-fire.png'),
      ElementButton(
          key: UniqueKey(),
          color: const Color.fromARGB(255, 85, 200, 239),
          element: Elements.ice,
          icon: 'assets/images/psd/element-ice.png'),
      ElementButton(
          key: UniqueKey(),
          color: const Color.fromARGB(255, 152, 176, 181),
          element: Elements.air,
          icon: 'assets/images/psd/element-air.png'),
      ElementButton(
          key: UniqueKey(),
          color: const Color.fromARGB(255, 124, 168, 42),
          element: Elements.earth,
          icon: 'assets/images/psd/element-earth.png'),
      ElementButton(
          key: UniqueKey(),
          color: const Color.fromARGB(255, 236, 166, 15),
          element: Elements.light,
          icon: 'assets/images/psd/element-light.png'),
      ElementButton(
          key: UniqueKey(),
          color: const Color.fromARGB(255, 31, 50, 131),
          element: Elements.dark,
          icon: 'assets/images/psd/element-dark.png'),
    ],
  );
}
