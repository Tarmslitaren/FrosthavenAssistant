import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Resource/commands/add_condition_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/ice_wraith_change_form_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_condition_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/character.dart';
import 'package:frosthaven_assistant/Resource/state/monster.dart';
import 'package:frosthaven_assistant/services/network/target.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import '../service_locator.dart';

class WebServer {
  static const String SHAMBLING_SKELETON = "Shambling Skeleton";
  final GameState _gameState = getIt<GameState>();
  final port = 8080;

  HttpServer? _server;

  Future<void> startServer() async {
    final _router = shelf_router.Router()
      ..get('/state', _getStateHandler)
      ..get('/startRound', _startRoundHandler)
      ..get('/endRound', _endRoundHandler)
      ..get('/addMonster', _addMonsterHandler)
      ..get('/switchMonster', _switchMonsterTypeHandler)
      ..post('/setScenario', _setScenarioHandler)
      ..post('/applyCondition', _applyConditionHandler)
      ..post('/changeHealth', _applyHealthChangeHandler)
      ..post('/setElement', _applySetElementHandler);

    _server = await shelf_io.serve(
      // See https://pub.dev/documentation/shelf/latest/shelf/logRequests.html
      // logRequests()
          // See https://pub.dev/documentation/shelf/latest/shelf/MiddlewareExtensions/addHandler.html
          // .addHandler(_router),
      _router,
      InternetAddress.anyIPv4, // Allows external connections
      port,
    );
  }

  void stopServer(String? error) {
    if (_server != null) {
      _server!.close().catchError((error) => print(error));
    }
  }

  // Router instance to handler requests.

  Response _getStateHandler(Request request) {
    Map<String, int> elements = {};
    var elementState = _gameState.elementState.value;
    for( var key in elementState.keys) {
      int value= 0;
      switch(elementState[key]!) {
        case ElementState.inert : value = 0; break;
        case ElementState.half : value = 1; break;
        case ElementState.full : value = 2; break;
      }
      elements[key.name] = value;
    }
    var state = '{'
        '"level": ${_gameState.level.value}, '
        '"roundState": ${_gameState.roundState.value.index}, '
        '"round": ${_gameState.round.value}, '
        '"currentList": ${_gameState.currentList.toString()}, '
        '"elements":  ${json.encode(elements)}'
        '}';
    var hash = state.hashCode;
    return Response.ok(state, headers: {"hash": "$hash"});
  }

  Future<Response> _setScenarioHandler(Request request) async {
    var data = Uri.decodeFull(await request.readAsString());
    if (data != null) {
      Map<String, dynamic> info = jsonDecode(data);
      var scenario = info["scenario"];
      print(scenario);
      _gameState.action(SetScenarioCommand(scenario, false));
      return Response.ok("");
    }
    return Response.notFound("");
  }

  Future<Response> _applySetElementHandler(Request request) async {
    var data = Uri.decodeFull(await request.readAsString());
    Map<String, dynamic> info = jsonDecode(data);
    var  element = Elements.fromString(info["element"]);
    var state = info["state"];
    print("element : $element, state: $state");
    if (element != null && state != null) {
      switch(state) {
        case 0 : _gameState.action(UseElementCommand(element)); break;
        case 1 : _gameState.action(ImbueElementCommand(element, true)); break;
        case 2 : _gameState.action(ImbueElementCommand(element, false));
      }
    }
    return _getStateHandler(request);
  }

  Target? findTarget(String target, int nr) {
    // A bit of hackery for the shambling skeletons ...
    if(target.startsWith(SHAMBLING_SKELETON)) {
      nr = int.parse(target.substring(SHAMBLING_SKELETON.length+1));
      target = SHAMBLING_SKELETON;
    }
    print("findTarget target:$target, nr:$nr");
    for (var item in _gameState.currentList) {
      if (item is Monster) {
        // startsWith lets us handle (FH) and scenario specific monsters without
        // special naming on the tabletop side
        if (item.id.startsWith(target)) {
          for (var instance in item.monsterInstances.value) {
            if (instance.standeeNr == nr) {
              return Target(instance, item.id, instance.getId());
            }
          }
        }
      }
      if (item is Character) {
        if (item.characterClass.name == target) {
          return Target(item.characterState, item.id, item.id);
        } else {
          // Look for the summons
          for (var summon in item.characterState.summonList.value) {
            print("summon : $summon");
            if (summon.name == target && summon.standeeNr == nr) {
              return Target(summon, item.id, summon.getId());
            }
          }
        }
      }
    }
    return null;
  }

  Future<Response> _applyConditionHandler(Request request) async {
    var data = Uri.decodeFull(await request.readAsString());
      Map<String, dynamic> info = jsonDecode(data);
      String name = info["target"];
      var nr = info["nr"];
      var condition = Condition.fromString(info["condition"]);
      if (condition != null) {
        var target = findTarget(name, nr);
        if(target != null) {
          var conditions = target.state.conditions.value;
          if (!conditions.contains(condition)) {
            _gameState.action(AddConditionCommand(
                condition, target.id, target.ownerId));
          } else {
            _gameState.action(RemoveConditionCommand(
                condition, target.id, target.ownerId));
          }
        }
      }
    return _getStateHandler(request);
  }

  Future<Response> _applyHealthChangeHandler(Request request) async {
    print("changeHealth");
    var data = Uri.decodeFull(await request.readAsString());
    Map<String, dynamic> info = jsonDecode(data);
    String name = info["target"];
    var nr = info["nr"];
    var change = info["change"];
    var target = findTarget(name, nr);
    if(target != null) {
      _gameState.action(ChangeHealthCommand(change, target.id, target.ownerId));
    }
    return _getStateHandler(request);
  }

  Response _startRoundHandler(Request request) {
    var data = Uri.decodeFull(request.url.query);
    if (data != null) {
      Map<String, dynamic> initiatives = jsonDecode(data);
      initiatives.forEach((key, value) {
        print("$key -> $value");
        _gameState.action(SetInitCommand(key, value));
      });
      if (GameMethods.canDraw()) {
        _gameState.action(DrawCommand());
      }
      //_gameState.updateAllUI();
    }
    return Response.ok('{}');
  }

  Response _endRoundHandler(Request request) {
    _gameState.action(NextRoundCommand());
    return Response.ok('{}');
  }

  Response _addMonsterHandler(Request request) {
    var data = Uri.decodeFull(request.url.query);
    if (data != null) {
      Map<String, dynamic> info = jsonDecode(data);
      var monsterName = info["monster"];
      var isBoss = info["isBoss"];
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          // startsWith lets us handle (FH) and scenario specific monsters without
          // special naming on the tabletop side
          if (item.id.startsWith(monsterName)) {
            int nrOfStandees = item.type.count;
            List<int> available = [];
            for (int i = 0; i < nrOfStandees; i++) {
              bool isAvailable = true;
              for (var item in item.monsterInstances.value) {
                if (item.standeeNr == i + 1) {
                  isAvailable = false;
                  break;
                }
              }
              if (isAvailable) {
                available.add(i + 1);
              }
            }
            int standeeNr = available[Random().nextInt(available.length)];
            _gameState.action(AddStandeeCommand(standeeNr, null, item.id,
                isBoss ? MonsterType.boss : MonsterType.normal, false));
            return Response.ok("$standeeNr");
          }
        }
      }
    }
    return Response.notFound("");
  }

  Response _switchMonsterTypeHandler(Request request) {
    var data = Uri.decodeFull(request.url.query);
    if (data != null) {
      Map<String, dynamic> info = jsonDecode(data);
      var monsterName = info["monster"];
      var number = int.parse(info["nr"]);
      print("Swapping monster $monsterName number $number");
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          print(item);
          if (item.id.startsWith(monsterName)) {
            for (var monster in item.monsterInstances.value) {
              if (monster.standeeNr == number) {
                // Can't really swap as it messes up the stats, so special case
                // if hp == max, to remove a standee, and add a new one
                if (monster.health.value == monster.maxHealth.value) {
                  var newType = monster.type == MonsterType.normal
                      ? MonsterType.elite
                      : MonsterType.normal;
                  _gameState.action(
                      ChangeHealthCommand(-999, monster.getId(), item.id));
                  _gameState.action(
                      AddStandeeCommand(number, null, item.id, newType, false));
                  return Response.ok("");
                } else if (monsterName == "Ice Wraith") {
                  _gameState.action(IceWraithChangeFormCommand(
                      monster.type == MonsterType.elite,
                      item.id,
                      monster.getId()));
                }
              }
            }
          }
        }
      }
    }
    return Response.notFound("");
  }
}
