import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class SaveModalMenu extends StatefulWidget {
  const SaveModalMenu({super.key, required this.saveName, required this.saveOnly});

  final bool saveOnly;
  final String saveName;

  @override
  SaveModalMenuState createState() => SaveModalMenuState();
}

class SaveModalMenuState extends State<SaveModalMenu> {
  final TextEditingController nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  late String _newSaveName;

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
  initState() {
    // at the beginning, all items are shown
    super.initState();
    _newSaveName = widget.saveName;
    nameController.text = _newSaveName;

    focusNode.addListener(_focusNodeListener);
  }

  @override
  Widget build(BuildContext context) {
    //todo: extract to ui utils
    double scale = 1;
    if (!isPhoneScreen(context)) {
      scale = 1.5;
      if (isLargeTablet(context)) {
        scale = 2;
      }
    }

    Settings settings = getIt<Settings>();

    return Container(
        width: 240 * scale,
        height: 160 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value
                ? 'assets/images/bg/dark_bg.png'
                : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 2 * scale,
              ),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  //todo: scale button sizes
                  children: [
                    if (!widget.saveOnly)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 2 * scale, color: Colors.blue),
                        ),
                        onPressed: () {
                          settings.loadSave(widget.saveName);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text("Load", style: getButtonTextStyle(scale)),
                      ),
                    SizedBox(
                      width: 10 * scale,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 2 * scale, color: Colors.blue),
                      ),
                      onPressed: () {
                        settings.deleteSave(widget.saveName);
                        settings.saveState(_newSaveName);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("Save", style: getButtonTextStyle(scale)),
                    ),
                    SizedBox(
                      width: 10 * scale,
                    ),
                    if (!widget.saveOnly)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 2 * scale, color: Colors.blue),
                        ),
                        onPressed: () {
                          settings.deleteSave(widget.saveName);
                          Navigator.pop(context);
                        },
                        child: Text("Delete", style: getButtonTextStyle(scale)),
                      )
                  ]),
              SizedBox(
                height: 20 * scale,
              ),
              Text("Set save name:", style: getTitleTextStyle(scale)),
              SizedBox(
                  width: 200,
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
