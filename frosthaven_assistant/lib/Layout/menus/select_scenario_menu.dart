import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Resource/commands/set_scenario_command.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class SelectScenarioMenu extends StatefulWidget {
  const SelectScenarioMenu({Key? key}) : super(key: key);

  @override
  _SelectScenarioMenuState createState() => _SelectScenarioMenuState();
}

class _SelectScenarioMenuState extends State<SelectScenarioMenu> {
  // This list holds the data for the list view
  List<String> _foundScenarios = [];
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    setCampaign(_gameState.currentCampaign.value);
    super.initState();
  }

  int? findNrFromScenarioName(String scenario){
    String nr = scenario.substring(1);
    for(int i = 0; i < nr.length; i++){
      if (nr[i] == ' ') {
        nr = nr.substring(0, i);
        int? number = int.tryParse(nr);
        return number;
      }
    }

    return null;
  }

  void setCampaign(String campaign) {
    //TODO:clear search
    _gameState.currentCampaign.value = campaign;
    _foundScenarios = _gameState
        .modelData.value[_gameState.currentCampaign.value]!.scenarios.keys
        .toList();
    _foundScenarios.sort((a, b) {

      int? aNr = findNrFromScenarioName(a);
      int? bNr = findNrFromScenarioName(b);
      if(aNr != null && bNr != null){
        return aNr.compareTo(bNr);
      }
      return a.compareTo(b);
    });
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all
      results = _gameState
          .modelData.value[_gameState.currentCampaign.value]!.scenarios.keys
          .toList();
    } else {
      results = _gameState
          .modelData.value[_gameState.currentCampaign.value]!.scenarios.keys
          .toList()
          .where((user) =>
              user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundScenarios = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        //color: Colors.transparent,
        // shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(2),
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Column(children: [
                Text("Set Scenario"),
                ExpansionTile(
                    title: Text("Current Scenario: ${_gameState.currentCampaign.value}"),
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          setCampaign("JotL");
                        });
                      },
                      child: Text("Jaws of the Lion"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          setCampaign("Gloomhaven");
                        });
                      },
                      child: Text("Gloomhaven"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          setCampaign("Forgotten Circles");
                        });
                      },
                      child: Text("Forgotten Circles"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          setCampaign("Crimson Scales");
                        });
                      },
                      child: Text("Crimson Scales"),
                    ),
                  ],
                ),
              ]),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child:RawKeyboardListener( //needed to trigger onEditingComplete on enter
                    focusNode: FocusNode(),
                    onKey: (event) {
                      if (kDebugMode) {
                        print(event.data.logicalKey.keyId);
                      }
                       if (event.runtimeType == RawKeyDownEvent &&
                          (event.logicalKey.keyId == 13)) {
                         if(_foundScenarios.isNotEmpty){
                           //_gameState.action(
                           //    SetScenarioCommand(_foundScenarios[0], false));
                           //Navigator.pop(context);
                         }
                         //Navigator.pop(context, this._textController.text);
                       }

                    },
                    child:  TextField(
                  onChanged: (value) => _runFilter(value),
                  //TODO: test this on device
                  onEditingComplete: () {
                    if(_foundScenarios.isNotEmpty){
                      _gameState.action(
                          SetScenarioCommand(_foundScenarios[0], false));
                      Navigator.pop(context);
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Set Scenario',
                      suffixIcon: Icon(Icons.search)),
                )),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _foundScenarios.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundScenarios.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(_foundScenarios[index],
                              style: TextStyle(fontSize: 18)),
                          onTap: () {
                            _gameState.action(
                                SetScenarioCommand(_foundScenarios[index], false));
                            Navigator.pop(context);
                          },
                        ),
                      )
                    : const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
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
