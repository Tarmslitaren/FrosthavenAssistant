import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/network_info.dart';

import '../../Resource/ui_utils.dart';
import '../service_locator.dart';
import 'dart:developer' as developer;

Server server = Server();

class Server {

  final GameState _gameState = getIt<GameState>();

  final List<Socket> _clients = [];

  // bind the socket server to an address and port
  ServerSocket? _serverSocket;

  String leftOverMessage = "";

  Future<void> startServer() async {
    _clients.clear();
    //cannot bind to outgoing
    //server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);
    await ServerSocket.bind(NetworkInformation.wifiIPv4, int.parse(getIt<Settings>().lastKnownPort)).then((
        ServerSocket serverSocket) {
      runZoned(() {

        _serverSocket = serverSocket;
        getIt<Settings>().server.value = true;
        developer.log('Server Online');
        _gameState.commandIndex.value = -1;
        _gameState.commands.clear();
        _gameState.commandDescriptions.clear();
        _gameState.gameSaveStates.removeRange(0, _gameState.gameSaveStates.length-1);
        _serverSocket!.listen((client) {
          handleConnection(client);
        }, onError: (e) {
          developer.log('Server error: $e');

        });
      });
    });
  }

  void stopServer() {
    if(_serverSocket != null) {
      _serverSocket!.close();
      developer.log('Server Offline');
    }
    getIt<Settings>().server.value = false;
    leftOverMessage ="";
  }

  void handleConnection(Socket client) {
      developer.log('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');


      _clients.add(client);
    // listen for events from the client
      try {
        client.listen(

          // handle data from the client
              (Uint8List data) async {
            //await Future.delayed(Duration(seconds: 1));
            String message = String.fromCharCodes(data);
            message = leftOverMessage+message;
            leftOverMessage = "";

            List<String> messages = message.split("S3nD:");
            //handle
            for (var message in messages) {
              if(message.endsWith("[EOM]")) {
                message = message.substring(0, message.length - "[EOM]".length);
                if (message.startsWith("Index:")) {
                  developer.log('Server Receive data');
                  List<String> messageParts1 = message.split("Description:");
                  String indexString = messageParts1[0].substring(
                      "Index:".length);
                  List<String> messageParts2 = messageParts1[1].split(
                      "GameState:");
                  String description = messageParts2[0];
                  String data = messageParts2[1];

                  print(
                      'Server Receive Data, index: $indexString, description:$description');

                  int newIndex = int.parse(indexString);
                  if (newIndex > _gameState.commandIndex.value) {
                    _gameState.commandIndex.value = int.parse(indexString);
                    if (newIndex >= 0) {
                      _gameState.commandDescriptions.insert(
                          _gameState.commandIndex.value, description);
                    }
                    _gameState.loadFromData(data);
                    _gameState.updateAllUI();
                    //getIt<GameState>().modifierDeck.
                    //client.write('your gameState changes received by server');
                  } else {
                    print(
                        'Got same or lower index. ignoring: received index: $newIndex current index ${_gameState
                            .commandIndex.value}');
                    //ignore if same index from server
                  }
                } else if (message.startsWith("init")) {
                  //TODO: check version code is same
                  print('Server Receive init');
                  String commandDescription = "";
                  if (_gameState.commandIndex.value > 0) {
                    commandDescription =
                    _gameState.commandDescriptions[_gameState.commandIndex
                        .value];
                  }
                  print('Server sends init response: "S3nD:Index:${_gameState
                      .commandIndex
                      .value}Description:$commandDescription');
                  client.write("S3nD:Index:${_gameState.commandIndex
                      .value}Description:${commandDescription}GameState:${_gameState
                      .gameSaveStates.last.getState()}[EOM]");
                }
              } else {
                leftOverMessage = message;
              }
            }
          },

          // handle errors
          onError: (error) {
            developer.log(error);
            client.close();
            for (int i = 0; i < _clients.length; i++) {
              if (_clients[i].address == client.address) {
                _clients.removeAt(i);
                break;
              }
            }
          },

          // handle the client closing the connection
          onDone: () {
            developer.log('Client left');
            client.close();
            for (int i = 0; i < _clients.length; i++) {
              if (_clients[i].address == client.address) {
                _clients.removeAt(i);
                break;
              }
            }
            //todo: toast
            //showToast(context, 'Client left');
          },
        );
      } catch (error) {
        print(error);
        client.close();
        for (int i = 0; i < _clients.length; i++) {
          if (_clients[i].address == client.address) {
            _clients.removeAt(i);
            break;
          }
        }
    }
  }

  void send(String data) {
    //if (_serverSocket!.isBroadcast) {
      //developer.log('Client sends: $data');
      for(Socket client in _clients) {
        client.write("S3nD:$data[EOM]");
      }
      //await Future.delayed(Duration(seconds: 2));
    //}
  }
}