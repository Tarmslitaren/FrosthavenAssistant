import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class SaveCharacterModalMenu extends StatefulWidget {
  const SaveCharacterModalMenu(
      {super.key,
      required this.saveName,
      required this.saveOnly,
      required this.saveId,
      required this.character});

  final String saveId;
  final bool saveOnly;
  final String saveName;
  final Character? character;

  @override
  SaveCharacterModalMenuState createState() => SaveCharacterModalMenuState();
}

class SaveCharacterModalMenuState extends State<SaveCharacterModalMenu> {
  static const double _kBorderWidth = 2.0;
  static const double _kMenuWidth = 240.0;
  static const double _kMenuHeight = 160.0;
  static const double _kTopSpacing = 2.0;
  static const double _kButtonSpacing = 10.0;
  static const double _kNameSpacing = 20.0;
  static const double _kNameFieldWidth = 200.0;

  final TextEditingController nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String _newSaveName = "";

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    _newSaveName = widget.saveName;
    nameController.text = _newSaveName;

    focusNode.addListener(_focusNodeListener);
  }

  void _focusNodeListener() {
    if (!focusNode.hasFocus) {
      if (nameController.text.isNotEmpty) {
        _newSaveName = nameController.text;
      }
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_focusNodeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scale = getModalMenuScale(context);

    Settings settings = getIt<Settings>();

    final ButtonStyle buttonStyle = OutlinedButton.styleFrom(
      side: BorderSide(width: _kBorderWidth * scale, color: Colors.blue),
    );

    final character = widget.character;

    return ModalBackground(
        width: _kMenuWidth * scale,
        height: _kMenuHeight * scale,
        alignment: Alignment.center,
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _kTopSpacing * scale,
              ),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.saveOnly)
                      OutlinedButton(
                        style: buttonStyle,
                        onPressed: () {
                          settings.loadCharacterSave(widget.saveId);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text("Load", style: getButtonTextStyle(scale)),
                      ),
                    SizedBox(
                      width: _kButtonSpacing * scale,
                    ),
                    if (character != null)
                      OutlinedButton(
                        style: buttonStyle,
                        onPressed: () {
                          settings.deleteCharacterSave(widget.saveId);
                          settings.saveCharacterState(_newSaveName, character);
                          Navigator.pop(context);
                        },
                        child: Text("Save", style: getButtonTextStyle(scale)),
                      ),
                    SizedBox(
                      width: _kButtonSpacing * scale,
                    ),
                    if (!widget.saveOnly)
                      OutlinedButton(
                        style: buttonStyle,
                        onPressed: () {
                          settings.deleteCharacterSave(widget.saveId);
                          Navigator.pop(context);
                        },
                        child: Text("Delete", style: getButtonTextStyle(scale)),
                      )
                  ]),
              SizedBox(
                height: _kNameSpacing * scale,
              ),
              Text("Set save name:", style: getTitleTextStyle(scale)),
              SizedBox(
                  width: _kNameFieldWidth,
                  child: TextField(
                    controller: nameController,
                    focusNode: focusNode,
                    style: getTitleTextStyle(scale),
                    onSubmitted: (String string) {
                      //set the name
                      if (nameController.text.isNotEmpty) {
                        _newSaveName = nameController.text;
                      }
                    },
                  ))
            ],
          ),
        ]));
  }
}
