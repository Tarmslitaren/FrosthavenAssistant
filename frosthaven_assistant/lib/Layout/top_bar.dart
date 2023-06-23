import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../Resource/enums.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

PreferredSize createTopBar() {
  Settings settings = getIt<Settings>();
  return PreferredSize(
      preferredSize: Size(double.infinity, 40 * settings.userScalingBars.value),
      child: ValueListenableBuilder<double>(
          valueListenable: getIt<Settings>().userScalingBars,
          builder: (context, value, child) {
            var shadow = Shadow(
              offset: Offset(1 * settings.userScalingBars.value,
                  1 * settings.userScalingBars.value),
              color: Colors.black87,
              blurRadius: 1 * settings.userScalingBars.value,
            );
            return AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                //could modify constraints to make the button take less space when small, but could potentially cause issues
                padding: EdgeInsets.all(
                    min(8.0 * settings.userScalingBars.value, 8.0)),
                icon: Icon(Icons.menu,
                    shadows: [shadow],
                    size: 24 * settings.userScalingBars.value),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              title: Container(
                padding:
                    EdgeInsets.only(left: 2.0 * settings.userScalingBars.value),
                child: Text(
                  "X-haven\nAssistant",
                  style: TextStyle(
                    //fontFamily: 'Pirata',
                    color: Colors.white,
                    fontSize: 16 * settings.userScalingBars.value,
                    shadows: [shadow],
                  ),
                ),
              ),
              toolbarHeight: 40 * settings.userScalingBars.value,
              flexibleSpace: ValueListenableBuilder<bool>(
                  valueListenable: getIt<Settings>().darkMode,
                  builder: (context, value, child) {
                    return Container(
                        height: 42 * settings.userScalingBars.value,
                        color: getIt<Settings>().darkMode.value
                            ? Colors.black
                            : Colors.white,
                        child: Image(
                            height: 40 * settings.userScalingBars.value,
                            image: AssetImage(getIt<Settings>().darkMode.value
                                ? 'assets/images/psd/gloomhaven-bar.png'
                                : 'assets/images/psd/frosthaven-bar.png'),
                            fit: BoxFit.cover,
                            repeat: ImageRepeat.repeatX));
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
          }));
}
