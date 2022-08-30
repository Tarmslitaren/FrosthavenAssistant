import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
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
    double referenceMinBarWidth = 40 * 6.5;
    double maxBarScale = screenWidth / referenceMinBarWidth;

    return Card(
        child: SingleChildScrollView(
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
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 18),
                ),
                CheckboxListTile(
                    title: const Text("Dark mode"),
                    value: settings.darkMode.value,
                    onChanged: (bool? value) {
                      setState(() {
                        settings.darkMode.value = value!;
                        settings.saveToDisk();
                      });
                    }),
                CheckboxListTile(
                    title: const Text("Soft numpad for input"),
                    value: settings.softNumpadInput.value,
                    onChanged: (bool? value) {
                      setState(() {
                        settings.softNumpadInput.value = value!;
                        settings.saveToDisk();
                      });
                    }),
                CheckboxListTile(
                    title: const Text("Drag for initiative"),
                    value: settings.noInit.value,
                    onChanged: (bool? value) {
                      setState(() {
                        settings.noInit.value = value!;
                        settings.saveToDisk();
                      });
                    }),
                CheckboxListTile(
                    title: const Text("Don't track Standees"),
                    value: settings.noStandees.value,
                    onChanged: (bool? value) {
                      setState(() {
                        settings.noStandees.value = value!;
                        settings.handleNoStandeesSettingChange();
                        settings.saveToDisk();
                      });
                    }),
                CheckboxListTile(
                    title: const Text("Random Standees"),
                    value: settings.randomStandees.value,
                    onChanged: (bool? value) {
                      setState(() {
                        settings.randomStandees.value = value!;
                        settings.saveToDisk();
                      });
                    }),
                CheckboxListTile(
                    title: const Text("No Calculations"),
                    value: settings.noCalculation.value,
                    onChanged: (bool? value) {
                      setState(() {
                        settings.noCalculation.value = value!;
                        settings.saveToDisk();
                        getIt<GameState>().updateList.value++;
                      });
                    }),
                if (!Platform.isIOS)
                  CheckboxListTile(
                      title: const Text("Fullscreen"),
                      value: settings.fullScreen.value,
                      onChanged: (bool? value) {
                        setState(() {
                          settings.setFullscreen(value!);
                        });
                      }),
                Container(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  padding: const EdgeInsets.only(left: 16, top: 10),
                  alignment: Alignment.bottomLeft,
                  child: const Text("Main List Scaling:"),
                ),
                Slider(
                  min: 0.2,
                  max: 3.0,
                  //divisions: 1,
                  value: settings.userScalingMainList.value,
                  onChanged: (value) {
                    setState(() {
                      settings.userScalingMainList.value = value;
                      setMaxWidth();
                      settings.saveToDisk();
                    });
                  },
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  padding: const EdgeInsets.only(left: 16, top: 10),
                  alignment: Alignment.bottomLeft,
                  child: const Text("App Bar Scaling:"),
                ),
                Slider(
                  min: min(0.8, maxBarScale),
                  max: min(maxBarScale, 3.0),
                  //divisions: 1,
                  value: settings.userScalingBars.value,
                  onChanged: (value) {
                    setState(() {
                      settings.userScalingBars.value = value;
                      settings.saveToDisk();
                    });
                  },
                ),
                const Text(
                  "Style:",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Radio(value: Style.frosthaven, groupValue: settings.style.value, onChanged: (index) {
                          setState(() {
                            settings.style.value = Style.frosthaven;
                            settings.saveToDisk();
                            getIt<GameState>().updateList.value++;
                          });
                        }),
                        const Text('Frosthaven')
                      ],
                    ),
                    Row(
                      children: [
                        Radio(value: Style.gloomhaven, groupValue: settings.style.value, onChanged: (index) {
                          setState(() {
                            settings.style.value = Style.gloomhaven;
                            settings.saveToDisk();
                            getIt<GameState>().updateList.value++;
                          });
                        }),
                        const Text('Gloomhaven')
                      ],
                    ),
                    Row(
                      children: [
                        Radio(value: Style.original, groupValue: settings.style.value, onChanged: (index) {
                          setState(() {
                            settings.style.value = Style.original;
                            settings.saveToDisk();
                            getIt<GameState>().updateList.value++;
                          });
                        }),
                        const Text('Original')
                      ],
                    ),
                  ],
                ),
                ListTile(
                    title: const Text("Clear unlocked characters"),
                    onTap: () {
                      setState(() {
                        getIt<GameState>().unlockedClasses = {};
                      });
                    }
                    ),
              ],
            ),
          ),
          const SizedBox(
            height: 34,
          ),
        ],
      ),
      Positioned(
          width: 100,
          height: 40,
          right: 0,
          bottom: 0,
          child: TextButton(
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              }))
    ])));
  }
}
