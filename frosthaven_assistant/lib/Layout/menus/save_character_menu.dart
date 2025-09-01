import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_modal_menu.dart';

import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SaveCharacterMenu extends StatefulWidget {
  const SaveCharacterMenu({super.key});

  @override
  SaveCharacterMenuState createState() => SaveCharacterMenuState();
}

class SaveCharacterMenuState extends State<SaveCharacterMenu> {
  // This list holds the data for the list view
  final List<String> _saves = [];
  final Settings _settings = getIt<Settings>();
  final ScrollController _scrollController = ScrollController();
  final List<Character> _characters = GameMethods.getCurrentCharacters();

  @override
  initState() {
    //fill list with all saved states
    for (String save in _settings.characterSaves.value.keys) {
      _saves.add(save);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //edge insets if width not too small
    return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
            margin: const EdgeInsets.all(2),
            child: Stack(children: [
              Column(
                children: [
                  Container(
                      height: 40,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Text('Load, Save or Delete Characters.',
                          style: getTitleTextStyle(1))),
                  const Text(
                    "Add new Save:",
                    style: TextStyle(fontSize: 24),
                  ),
                  Wrap(
                    children: [
                      for (var item in _characters)
                        IconButton(
                            onPressed: () {
                              //get nr
                              String number = "";
                              int nr = 1;
                              for (final saveName in _saves) {
                                if (saveName.startsWith(
                                    item.characterState.display.value)) {
                                  nr++;
                                }
                              }
                              if (nr > 1) {
                                number = nr.toString();
                              }

                              final saveName =
                                  "${item.characterState.display.value}$number";
                              final saveId = '$saveName\n${item.id}';

                              openDialog(
                                  context,
                                  SaveCharacterModalMenu(
                                    saveName: saveName,
                                    saveOnly: true,
                                    saveId: saveId,
                                    character: item,
                                  ));
                            },
                            icon: Image.asset(
                                "assets/images/class-icons/${item.id}.png")),
                    ],
                  ),
                  const Text(
                    "Load Character:",
                    style: TextStyle(fontSize: 24),
                  ),
                  Expanded(
                    child: Scrollbar(
                        controller: _scrollController,
                        child: ValueListenableBuilder<Map<String, String>>(
                            valueListenable: _settings.characterSaves,
                            builder: (context, value, child) {
                              _saves.clear();
                              List<String> characterId = [];
                              for (String save
                                  in _settings.characterSaves.value.keys) {
                                final split = save.split('\n');
                                characterId.add(split.last);
                                _saves.add(split.first);
                              }

                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: _saves.length,
                                itemBuilder: (context, index) => ListTile(
                                  leading: SizedBox(
                                      height: 36,
                                      width: 36,
                                      child: Image.asset(
                                          "assets/images/class-icons/${characterId[index]}.png")),
                                  //should show icon
                                  title: Text(_saves[index],
                                      style: const TextStyle(fontSize: 18)),
                                  onTap: () {
                                    openDialog(
                                        context,
                                        SaveCharacterModalMenu(
                                          saveName: _saves[index],
                                          saveId:
                                              '${_saves[index]}\n${characterId[index]}',
                                          saveOnly: false,
                                          character: null,
                                        ));
                                  },
                                ),
                              );
                            })),
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
