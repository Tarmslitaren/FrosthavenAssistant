import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/unlock_special_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SpecialUnlocksMenu extends StatelessWidget {
  SpecialUnlocksMenu({super.key});

  final ScrollController _scrollController = ScrollController();
  final Settings _settings = getIt<Settings>();

  @override
  Widget build(BuildContext context) {
    List<List<String>> _unlocks = [
      ["Demons", "assets/images/demons.png"],
      ["Merchant-Guild", "assets/images/merchant-guild.png"],
      ["Military", "assets/images/military.png"],
      ["Bladeswarm", "assets/images/class-icons/Bladeswarm.png"]
    ];

    if (_settings.showCustomContent.value) {
      _unlocks.add(["Vanquisher", "assets/images/class-icons/Vanquisher.png"]);
    }

    bool getEnabled(String id) {
      return getIt<GameState>().unlockedClasses.contains(id);
    }

    return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
            margin: const EdgeInsets.all(2),
            child: Stack(children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text('Special Unlocks',
                        style: getTitleTextStyle(1, forceBlack: true)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Scrollbar(
                        controller: _scrollController,
                        child: ValueListenableBuilder<int>(
                            valueListenable: getIt<GameState>().commandIndex,
                            builder: (context, value, child) {
                              return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _unlocks.length,
                                  itemBuilder: (context, index) =>
                                      CheckboxListTile(
                                        secondary: Image.asset(
                                          _unlocks[index].last,
                                          height: kButtonSize,
                                          width: kButtonSize,
                                          cacheHeight:
                                              kCharacterIconCacheHeight,
                                          fit: BoxFit.contain,
                                          //color:
                                          filterQuality: FilterQuality.medium,
                                        ),
                                        title: Text(
                                            getEnabled(_unlocks[index].first)
                                                ? _unlocks[index].first
                                                : "???",
                                            style: TextStyle(
                                                fontSize: kFontSizeTitle,
                                                color: Colors.black)),
                                        onChanged: (bool? value) {
                                          getIt<GameState>().action(
                                              UnlockSpecialCommand(
                                                  _unlocks[index].first, gameState: getIt<GameState>()));
                                        },
                                        value:
                                            getEnabled(_unlocks[index].first),
                                      ));
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
