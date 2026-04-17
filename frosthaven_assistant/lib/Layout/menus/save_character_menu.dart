import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_modal_menu.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SaveCharacterMenu extends StatefulWidget {
  const SaveCharacterMenu({
    super.key,
    this.settings,
  });

  final Settings? settings;

  @override
  SaveCharacterMenuState createState() => SaveCharacterMenuState();
}

class SaveCharacterMenuState extends State<SaveCharacterMenu> {
  static const double _kMaxWidth = 400.0;
  static const double _kCardMargin = 2.0;
  static const double _kHeaderHeight = 40.0;
  static const double _kHeaderPadding = 10.0;
  static const double _kIconSize = 36.0;

  // This list holds the data for the list view
  final List<String> _saves = [];
  late final Settings _settings;
  final ScrollController _scrollController = ScrollController();
  final List<Character> _characters = GameMethods.getCurrentCharacters();

  @override
  initState() {
    _settings = widget.settings ?? getIt<Settings>();
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
        constraints: const BoxConstraints(maxWidth: _kMaxWidth),
        child: Card(
            margin: const EdgeInsets.all(_kCardMargin),
            child: Stack(children: [
              Column(
                children: [
                  Container(
                      height: _kHeaderHeight,
                      margin: const EdgeInsets.only(left: _kHeaderPadding, right: _kHeaderPadding),
                      child: Text('Load, Save or Delete Characters.',
                          style: getTitleTextStyle(1, forceBlack: true))),
                  const Text(
                    "Add new Save:",
                    style: kHeadingStyle,
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
                    style: kHeadingStyle,
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
                                      height: _kIconSize,
                                      width: _kIconSize,
                                      child: Image.asset(
                                          "assets/images/class-icons/${characterId[index]}.png")),
                                  //should show icon
                                  title:
                                      Text(_saves[index], style: kTitleStyle),
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
                    height: kMenuCloseButtonSpacing,
                  ),
                ],
              ),
              Positioned(
                  width: kCloseButtonWidth,
                  height: kButtonSize,
                  right: 0,
                  bottom: 0,
                  child: TextButton(
                      child: const Text(
                        'Close',
                        style: kButtonLabelStyle,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }))
            ])));
  }
}
