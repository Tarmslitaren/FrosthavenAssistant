import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/network_info.dart';

import '../service_locator.dart';

import 'network.dart';

class Server {
  final int serverVersion = 152;

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
    if (getIt<Network>().networkInfo.wifiIPv4.value.isNotEmpty) {
      connectTo = getIt<Network>().networkInfo.wifiIPv4.value;
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
            "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}");

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

    _gameState.gameSaveStates.removeRange(0, _gameState.gameSaveStates.length-1);
    _gameState.commands.clear();
    _gameState.commandIndex.value = -1;
    _gameState.commandDescriptions.clear();
  }

  void handleConnection(Socket client) {
    String info = 'Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}';
    print(info);
    getIt<Network>().networkMessage.value = info;

    bool existed = false;
    for (var existingClient in _clients) {
      if (client.remoteAddress == existingClient.remoteAddress) {
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
                  String commandDescription = "";
                  if(_gameState.commandDescriptions.isNotEmpty) {
                    commandDescription = _gameState.commandDescriptions.last;
                  }
                  send("Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}");
                } else if (newIndex > _gameState.commandIndex.value) {
                  _gameState.commandIndex.value = int.parse(indexString);
                  if (newIndex >= 0) {
                    _gameState.commandDescriptions
                        .insert(_gameState.commandIndex.value, description);
                  }
                  _gameState.loadFromData(data);
                  _gameState.updateAllUI();
                  sendToOthers("Index:${_gameState.commandIndex.value}Description:${_gameState.commandDescriptions.last}GameState:${_gameState.gameSaveStates.last!.getState()}", client);
                  //getIt<GameState>().modifierDeck.
                  //client.write('your gameState changes received by server');
                } else {
                  getIt<Network>().networkMessage.value = "index mismatch: ignoring incoming message";
                  print(
                      'Got same or lower index. ignoring: received index: $newIndex current index ${_gameState.commandIndex.value}');

                  //overwrite client state with current server state.
                  sendToOnly(
                      "Index:${_gameState.commandIndex
                          .value}Description:${_gameState
                          .commandDescriptions[_gameState.commandIndex.value]}GameState:${_gameState
                          .gameSaveStates.last!.getState()}", client);
                  //ignore if same index from server
                }
              } else if (message.startsWith("init")) {
                print('Server Receive init');

                List<String> initMessageParts = message.split("version:");
                int version = int.parse(initMessageParts[1]);
                if(version != serverVersion) {
                  //version mismatch
                  getIt<Network>().networkMessage.value = "Client version mismatch. Please update.";
                  sendToOnly(
                      "Error: Server Version is $serverVersion. client version is $version. Please update your client.", client);

                } else {
                  String commandDescription = "";
                  if (_gameState.commandIndex.value > 0) {
                    commandDescription = _gameState
                        .commandDescriptions[_gameState.commandIndex.value];
                  }
                  print(
                      'Server sends init response: "S3nD:Index:${_gameState
                          .commandIndex.value}Description:$commandDescription');
                  sendToOnly(
                      "Index:${_gameState.commandIndex
                          .value}Description:${commandDescription}GameState:${_gameState
                          .gameSaveStates.last!.getState()}", client);
                }
              } else if (message.startsWith("undo")) {
                print('Server Receive undo command');
                _gameState.undo();
              } else if (message.startsWith("redo")) {
                print('Server Receive redo command');
                _gameState.redo();
              } else if (message.startsWith("ping")) {
              }} else {
              leftOverMessage = message;
            }
          }
        },

        // handle errors
        onError: (error) {
          print(error);
          client.close();
          for (int i = 0; i < _clients.length; i++) {
            if (_clients[i].remoteAddress == client.remoteAddress) {
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
            if (_clients[i].remoteAddress == client.remoteAddress) {
              _clients.removeAt(i);
              break;
            }
          }
        },
      );
    } catch (error) {
      print(error);
      client.close();
      for (int i = 0; i < _clients.length; i++) {
        if (_clients[i].remoteAddress == client.remoteAddress) {
          _clients.removeAt(i);
          break;
        }
      }

      //TODO: try to reconnect?
    }
  }

  void send(String data) {
    for (Socket client in _clients) {
      client.write("S3nD:$data[EOM]");
    }
  }

  void sendToOnly(String data, Socket client) {
    client.write("S3nD:$data[EOM]");
  }

  void sendToOthers(String data, Socket client) {
    for (Socket item in _clients) {
      if (item.remoteAddress != client.remoteAddress) {
        item.write("S3nD:$data[EOM]");
      }
    }
  }
}
