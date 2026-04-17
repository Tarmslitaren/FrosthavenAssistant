import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class SaveModalMenu extends StatefulWidget {
  const SaveModalMenu(
      {super.key, required this.saveName, required this.saveOnly});

  final bool saveOnly;
  final String saveName;

  @override
  SaveModalMenuState createState() => SaveModalMenuState();
}

class SaveModalMenuState extends State<SaveModalMenu> {
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
                          settings.loadSave(widget.saveName);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text("Load", style: getButtonTextStyle(scale)),
                      ),
                    SizedBox(
                      width: _kButtonSpacing * scale,
                    ),
                    OutlinedButton(
                      style: buttonStyle,
                      onPressed: () {
                        settings.deleteSave(widget.saveName);
                        settings.saveState(_newSaveName);
                        Navigator.pop(context);
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
                          settings.deleteSave(widget.saveName);
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
                    onChanged: (String string) {
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
