import 'package:flutter/material.dart';

import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  SettingsMenuState createState() => SettingsMenuState();
}

class SettingsMenuState extends State<SettingsMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();

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
                    CheckboxListTile( title: const Text("Fullscreen"), value: settings.fullScreen.value, onChanged: (bool? value) {
                      setState(() {
                        settings.setFullscreen(value!);
                      });
                    }),
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
