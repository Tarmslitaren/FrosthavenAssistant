import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/campaign.dart';
import '../Resource/commands.dart';

Drawer createMainMenu(BuildContext context) {
  String? _currentSelectedValue;
  GameState _gameState = getIt<GameState>();

  return Drawer(
// Add a ListView to the drawer. This ensures the user can scroll
// through the options in the drawer if there isn't enough vertical
// space to fit everything.
    child: ValueListenableBuilder<CampaignModel?>(
      valueListenable: _gameState.modelData,
      builder: (context, value, child) {
        return ListView(
// Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Main Menu'),
              ),
              ListTile(
                title: const Text('Undo'),
                onTap: () {
// Update the state of the app
// ...
// Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Redo'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              _gameState.modelData.value == null
                  ? Container()
                  : FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: const InputDecoration(
                            counterText: '',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            // border: UnderlineInputBorder(
                            //   borderSide:
                            //      BorderSide(color: Colors.pink),
                            // ),
                          ),
                          isEmpty: _currentSelectedValue == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text("Set Scenario"),
                              value: _currentSelectedValue,
                              isDense: true,
                              onChanged: (String? newValue) {
                                //setState(() {
                                _currentSelectedValue = newValue;
                                state.didChange(newValue);
                                //TODO: run setscenario command
                                _gameState.action(SetScenarioCommand(_currentSelectedValue!));
                                //});
                              },
                              items: _gameState.modelData.value?.scenarios.keys
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
              ListTile(
                title: const Text('Set Scenario'),
                onTap: () {
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Add Section'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Add Characters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Remove Characters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Add Monsters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Remove Monsters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Documentation'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    ),
  );
}
