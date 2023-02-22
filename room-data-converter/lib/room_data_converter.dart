import 'dart:convert';
import 'dart:io';

import 'package:room_data_converter/ReCase.dart';
import 'package:room_data_converter/model.dart';

Future<int> calculate() async {
  File file = File('./assets/data/1.json');
  Future<String> futureContent = file.readAsString();
  futureContent.then((c) async {
    Scenario scenario = Scenario();
    final data = await json.decode(c.toString());
    if (data.containsKey('rooms')) {
      final rooms = data['rooms'] as List;
      for (var room in rooms) {
        String roomName = room['ref'];
        var roomMap = <String, Map<String, Monster>>{};
        List<String> monsters = [];
        if (room.containsKey('monster')) {
          //1 find all different monsters
          for (var item in room['monster']) {
            if (!monsters.contains(item['name'])) {
              monsters.add(item['name']);
            }
          }
          //2 create arrays and fill them for each monster

          for (var item in monsters) {
            List<int> monsterAmountNormal = [0, 0, 0];
            List<int> monsterAmountElite = [0, 0, 0];
            for (var data in room['monster']) {
              if (data['name'] == item) {
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
    var file = await File('1.json').writeAsString(encoder.convert(scenario));
  });

  return 6 * 7;
}

//caveat: room order makes a difference?
//can convert gh,fc and jotl.  cs, toa, sox, solo and fh no data