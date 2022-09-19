import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/network_info.dart';

import '../service_locator.dart';
import 'network.dart';
//import 'dart:developer' as developer;

class Server {
  final serverVersion = 1;

  final GameState _gameState = getIt<GameState>();

  final List<Socket> _clients = [];

  // bind the socket server to an address and port
  ServerSocket? _serverSocket;

  String leftOverMessage = "";

  Future<void> startServer() async {
    //_clients.clear();
    //cannot bind to outgoing
    //server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);
    String connectTo = "0.0.0.0";
    /*if(NetworkInformation.outgoingIPv4 != null) {
      connectTo = NetworkInformation.outgoingIPv4!;
    }*/ //it is wrong to try to bind to an outgoing ip, since it is not owned by the network?
    if (getIt<Network>().networkInfo.wifiIPv4 != null && getIt<Network>().networkInfo.wifiIPv4!.isNotEmpty) {
      connectTo = getIt<Network>().networkInfo.wifiIPv4!;
    }
    await ServerSocket.bind(connectTo,
            int.parse(getIt<Settings>().lastKnownPort))
        .then((ServerSocket serverSocket) {
      runZoned(() {
        _serverSocket = serverSocket;
        getIt<Settings>().server.value = true;
        String info = 'Server Online: IP: ${_serverSocket!.address.address}, Port: ${_serverSocket!.port.toString()}';
        print(info);
        getIt<Network>().networkMessage.value = info;
        _gameState.commandIndex.value = -1;
        _gameState.commands.clear();
        _gameState.commandDescriptions.clear();
        _gameState.gameSaveStates
            .removeRange(0, _gameState.gameSaveStates.length - 1);

        //if has clients when connecting (re connect) run reset/welcome message
        String commandDescription = "";
        if (_gameState.commandIndex.value > 0) {
          commandDescription = _gameState.commandDescriptions[_gameState.commandIndex.value];
        }
        send(
            "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last.getState()}");

        _serverSocket!.listen((client) {
          handleConnection(client);
        }, onError: (e) {
          print('Server error: $e');
          getIt<Network>().networkMessage.value = 'Server error: $e';
        });
      });
    });
  }

  void stopServer() {
    if (_serverSocket != null) {

      print('Server Offline');
      getIt<Network>().networkMessage.value = 'Server Offline';
      _serverSocket!.close();

      for (var item in _clients) {
        item.close();
      }
      _clients.clear();
      //_serverSocket!.close();
      //print('Server Offline');
    }
    getIt<Settings>().server.value = false;
    leftOverMessage = "";
  }

  void handleConnection(Socket client) {
    String info = 'Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}';
    print(info);
    getIt<Network>().networkMessage.value = info;

    bool existed = false;
    for (var existingClient in _clients) {
      if (client.address == existingClient.address) {
        existed = true;
      }
    }
    if (!existed) {
      _clients.add(client);
    }
    // listen for events from the client
    try {
      client.listen(
        // handle data from the client
        (Uint8List data) async {
          //await Future.delayed(Duration(seconds: 1));
          String message = String.fromCharCodes(data);
          message = leftOverMessage + message;
          leftOverMessage = "";

          List<String> messages = message.split("S3nD:");
          //handle
          for (var message in messages) {
            if (message.endsWith("[EOM]")) {
              message = message.substring(0, message.length - "[EOM]".length);
              if (message.startsWith("Index:")) {
                print('Server Receive data');
                List<String> messageParts1 = message.split("Description:");
                String indexString =
                    messageParts1[0].substring("Index:".length);
                List<String> messageParts2 =
                    messageParts1[1].split("GameState:");
                String description = messageParts2[0];
                String data = messageParts2[1];

                print(
                    'Server Receive Data, index: $indexString, description:$description');

                int newIndex = int.parse(indexString);
                if(newIndex > _gameState.commandDescriptions.length) {
                  //invalid: index too high. send correction to clients
                  send("Index:${_gameState.commandIndex.value}Description:${_gameState.commandDescriptions.last}GameState:${_gameState.gameSaveStates.last.getState()}");
                } else if (newIndex > _gameState.commandIndex.value) {
                  _gameState.commandIndex.value = int.parse(indexString);
                  if (newIndex >= 0) {
                    _gameState.commandDescriptions
                        .insert(_gameState.commandIndex.value, description);
                  }
                  _gameState.loadFromData(data);
                  _gameState.updateAllUI();
                  //getIt<GameState>().modifierDeck.
                  //client.write('your gameState changes received by server');
                } else {
                  getIt<Network>().networkMessage.value = "index mismatch: ignoring incoming message";
                  print(
                      'Got same or lower index. ignoring: received index: $newIndex current index ${_gameState.commandIndex.value}');
                  //ignore if same index from server
                }
              } else if (message.startsWith("init")) {
                print('Server Receive init');

                List<String> initMessageParts = message.split("version:");
                int version = int.parse(initMessageParts[1]);
                if(version != serverVersion) {
                  //version mismatch
                  client.write(
                      "S3nD:Error: Server Version is $serverVersion. client version is $version. Please update your client.[EOM]");

                } else {
                  String commandDescription = "";
                  if (_gameState.commandIndex.value > 0) {
                    commandDescription = _gameState
                        .commandDescriptions[_gameState.commandIndex.value];
                  }
                  print(
                      'Server sends init response: "S3nD:Index:${_gameState
                          .commandIndex.value}Description:$commandDescription');
                  client.write(
                      "S3nD:Index:${_gameState.commandIndex
                          .value}Description:${commandDescription}GameState:${_gameState
                          .gameSaveStates.last.getState()}[EOM]");
                }
              }
            } else {
              leftOverMessage = message;
            }
          }
        },

        // handle errors
        onError: (error) {
          print(error);
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
          print('Client left');
          getIt<Network>().networkMessage.value = 'Client left.';
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
    for (Socket client in _clients) {
      client.write("S3nD:$data[EOM]");
    }
  }
}
