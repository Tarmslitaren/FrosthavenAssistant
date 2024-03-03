import 'dart:convert';
import 'dart:io';

import 'package:room_data_converter/ReCase.dart';
import 'package:room_data_converter/model.dart';

Future<int> calculate() async {
  bool ttsData = false;
  //await File('Gloomhaven.json').writeAsString("");
  String res = "{\n";
  for (int scenarioNumber = 1; scenarioNumber <= 24; scenarioNumber++) {
    File file = File('./assets/data/$scenarioNumber.json');
    Future<String> futureContent = file.readAsString();
    futureContent.then((c) async {
      String scenarioName = scenarioNumber.toString();
      final data = await json.decode(c.toString());
     // if (data.containsKey('id')) {
      //  scenarioName = data['id'];
      //}
      //print(scenarioName);
      Scenario scenario = Scenario(scenarioName);
      if (data.containsKey('rooms')) {
        final rooms = data['rooms'] as List;
        for (var room in rooms) {
          String roomName = "unknown";
          if(data.containsKey("name") && data.containsKey("index")) {
            roomName = data['index'] + " " + data['name'];
          }
          if (room.containsKey('ref')) {
            roomName = room['ref'];
          }
          if (room.containsKey('mapTiles')) {
            var mapTiles = room['mapTiles'];
            var tile = mapTiles[0];
            if(tile != null) {
              roomName = tile['tile'];
            }
          }
          roomName = roomName.titleCase;
          var roomMap = <String, Map<String, Monster>>{};
          List<String> monsters = [];
          String monsterKey = 'monster';
          if (ttsData) {
            monsterKey = 'monsters';
          }
          if (room.containsKey(monsterKey)) {
            //1 find all different monsters
            for (var item in room[monsterKey]) {
              if (!monsters.contains(item['name'])) {
                monsters.add(item['name']);
              }
            }

            //2 create arrays and fill them for each monster
            for (var item in monsters) {
              List<int> monsterAmountNormal = [0, 0, 0];
              List<int> monsterAmountElite = [0, 0, 0];
              for (var data in room[monsterKey]) {
                if (data['name'] == item) {
                  if(!ttsData) {
                    if (data.containsKey('type')) {
                      //means it is always there, other wise it would say player2-4
                      if (data['type'] == "elite") {
                        monsterAmountElite[0]++;
                        monsterAmountElite[1]++;
                        monsterAmountElite[2]++;
                      } else {
                        monsterAmountNormal[0]++;
                        monsterAmountNormal[1]++;
                        monsterAmountNormal[2]++;
                      }
                    }
                    if (data.containsKey('player2')) {
                      if (data['player2'] == "elite") {
                        monsterAmountElite[0]++;
                      } else {
                        monsterAmountNormal[0]++;
                      }
                    }
                    if (data.containsKey('player3')) {
                      if (data['player3'] == "elite") {
                        monsterAmountElite[1]++;
                      } else {
                        monsterAmountNormal[1]++;
                      }
                    }
                    if (data.containsKey('player4')) {
                      if (data['player4'] == "elite") {
                        monsterAmountElite[2]++;
                      } else {
                        monsterAmountNormal[2]++;
                      }
                    }
                  } else {
                    var tiles = data['tiles'];
                    for (var item in tiles) {
                      if(item.containsKey("numCharacters")) {
                        var tile = item['numCharacters'];
                        if(tile.containsKey("2")) {
                          int val = tile["2"];
                          if(val == 1) {
                            monsterAmountNormal[0]++;
                          } else if (val == 2) {
                            monsterAmountElite[0]++;
                          }
                        }
                        if(tile.containsKey("3")) {
                          int val = tile["3"];
                          if(val == 1) {
                            monsterAmountNormal[1]++;
                          } else {
                            monsterAmountElite[1]++;
                          }
                        }
                        if(tile.containsKey("4")) {
                          int val = tile["4"];
                          if(val == 1) {
                            monsterAmountNormal[2]++;
                          } else {
                            monsterAmountElite[2]++;
                          }
                        }
                      }
                    }
                  }
                }
              }
              Monster monsterValue =
                  Monster(monsterAmountNormal, monsterAmountElite);
              if (roomMap[roomName] == null) {
                roomMap[roomName] = {};
              }

              //3 rename monsters to fit with other format
              String monsterName = item;
              monsterName.replaceAll("-", " ");
              monsterName = monsterName.titleCase;
              roomMap[roomName]![monsterName] = monsterValue;
            }

            scenario.sections.add(roomMap);
          }
        }
      }
      //print(scenario);
      //write file
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String scenarioJson = encoder.convert(scenario);
      scenarioJson = scenarioJson.substring(2, scenarioJson.length - 2);
      res += "$scenarioJson,\n";
    }).then((value) async {
      await File('random.json').writeAsString(res, mode: FileMode.append);
    });
  }

  return 6 * 7;
}

//caveat: room order makes a difference?
//can convert gh,fc and jotl.  cs, toa, sox, solo and fh no data
