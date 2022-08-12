import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../Resource/scaling.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  SettingsMenuState createState() => SettingsMenuState();
}

class SettingsMenuState extends State<SettingsMenu> {

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();

    double screenWidth = MediaQuery.of(context).size.width;
    double referenceMinBarWidth = 40*6;
    double maxBarScale = screenWidth/referenceMinBarWidth;

    return Card(
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),

                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Settings", style: TextStyle(fontSize: 18),),
                    CheckboxListTile( title: const Text("Dark mode"), value: settings.darkMode.value, onChanged: (bool? value) {
                      setState(() {
                        settings.darkMode.value = value!;
                        settings.saveToDisk();
                      });
                    }),
                    CheckboxListTile( title: const Text("Soft numpad for input"), value: settings.softNumpadInput.value, onChanged: (bool? value) {
                      setState(() {
                        settings.softNumpadInput.value = value!;
                        settings.saveToDisk();
                      });
                    }),
                    if (Platform.isIOS ) CheckboxListTile( title: const Text("Fullscreen"), value: settings.fullScreen.value, onChanged: (bool? value) {
                      setState(() {
                        settings.setFullscreen(value!);
                      });
                    }),
                    Container(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      padding: const EdgeInsets.only(left: 16, top: 10),
                      alignment: Alignment.bottomLeft,
                      child: const Text("Main List Scaling:"),),
                    Slider(
                      min: 0.2,
                      max: 3.0,
                      //divisions: 1,
                      value: settings.userScalingMainList.value,
                      onChanged: (value) {
                        setState(() {
                          settings.userScalingMainList.value = value;
                          setMaxWidth();
                        });
                      },
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      padding: EdgeInsets.only(left: 16, top: 10),
                      alignment: Alignment.bottomLeft,
                      child: const Text("App Bar Scaling:"),),
                    Slider(
                      min: min(0.5, maxBarScale),
                      max: min(maxBarScale, 3.0),
                      //divisions: 1,
                      value: settings.userScalingBars.value,
                      onChanged: (value) {
                        setState(() {
                          settings.userScalingBars.value = value;
                        });
                      },
                    )
                    //Todo: maybe comprehensive ui scaling. or not. (test on tv and small screen devices)
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
          Positioned(
              width: 100,
              right: 2,
              bottom: 2,
              child: TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }))
        ]));
  }
}
