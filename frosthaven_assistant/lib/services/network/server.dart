import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import '../service_locator.dart';

import 'communication.dart';
import 'connection.dart';
import 'network.dart';
import 'dart:convert' show utf8;

class Server {
  final int serverVersion = 184;

  final GameState _gameState = getIt<GameState>();
  final _communication = getIt<Communication>();
  final _connection = getIt<Connection>();

  // bind the socket server to an address and port
  ServerSocket? _serverSocket;

  String leftOverMessage = "";

  void sendPing() {
    if (_serverSocket != null && getIt<Settings>().server.value != false) {
      Future.delayed(const Duration(seconds: 20), () {
        send("ping");
        sendPing();
      });
    }
  }

  Future<void> startServer() async {
    //_clients.clear();
    String connectTo = InternetAddress.anyIPv4.address; //"0.0.0.0";
    if (getIt<Network>().networkInfo.wifiIPv4.value.isNotEmpty &&
        !getIt<Network>().networkInfo.wifiIPv4.value.contains("Fail")) {
      connectTo = getIt<Network>().networkInfo.wifiIPv4.value;
    } else {
      getIt<Network>().networkInfo.wifiIPv4.value =
          connectTo; //if not on wifi show local ip
    }
    try {
      await ServerSocket.bind(InternetAddress.anyIPv4.address,
              int.parse(getIt<Settings>().lastKnownPort))
          .then((ServerSocket serverSocket) {
        runZoned(() {
          _serverSocket = serverSocket;

          getIt<Settings>().server.value = true;
          String info =
              'Server Online: IP: $connectTo, Port: ${_serverSocket!.port.toString()}';
          log(info);
          getIt<Network>().networkMessage.value = info;
          _gameState.commandIndex.value = -1;
          _gameState.commands.clear();
          _gameState.commandDescriptions.clear();
          _gameState.gameSaveStates
              .removeRange(0, _gameState.gameSaveStates.length - 1);

          //if has clients when connecting (re connect) run reset/welcome message
          String commandDescription = "";
          send(
              "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}");

          _serverSocket!.listen((Socket client) {
            handleConnection(client);
          }, onError: (e) {
            log('Server error: $e');
            getIt<Network>().networkMessage.value =
                'Server error: ${e.toString()}';
          });
          sendPing();
        });
      });
    } catch (error) {
      log('Server error: $error');
      getIt<Network>().networkMessage.value =
          'Server error: ${error.toString()}';
    }
  }

  void stopServer(String? error) {
    if (_serverSocket != null) {
      log('Server Offline');
      if (error != null) {
        getIt<Network>().networkMessage.value = error;
      } else {
        getIt<Network>().networkMessage.value = 'Server Offline';
      }
      _serverSocket!.close().catchError((error) =>
        log(error.toString())
      );

      _connection.removeAll();
    }
    getIt<Settings>().server.value = false;
    leftOverMessage = "";

    _gameState.gameSaveStates
        .removeRange(0, _gameState.gameSaveStates.length - 1);
    _gameState.commands.clear();
    _gameState.commandIndex.value = -1;
    _gameState.commandDescriptions.clear();
  }

  void handleConnection(Socket client) {
    client.setOption(SocketOption.tcpNoDelay, true);
    client.encoding = utf8;

    String info = 'Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}';
    log(info);
    getIt<Network>().networkMessage.value = info;

    _connection.add(client);

    // listen for events from the client
    try {
      client.listen(
        // handle data from the client
        (Uint8List data) async {
          String message = utf8.decode(data);
          message = leftOverMessage + message;
          leftOverMessage = "";

          List<String> messages = message.split("S3nD:");
          //handle
          for (var message in messages) {
            if (message.endsWith("[EOM]")) {
              message = message.substring(0, message.length - "[EOM]".length);
              if (message.startsWith("Index:")) {
                log('Server Receive data');
                List<String> messageParts1 = message.split("Description:");
                String indexString =
                    messageParts1[0].substring("Index:".length);
                List<String> messageParts2 =
                    messageParts1[1].split("GameState:");
                String description = messageParts2[0];
                String data = messageParts2[1];

                log(
                    'Server Receive Data, index: $indexString, description:$description');

                int newIndex = int.parse(indexString);
                if (newIndex > _gameState.commandDescriptions.length) {
                  //invalid: index too high. send correction to clients
                  String commandDescription = "";
                  if (_gameState.commandDescriptions.isNotEmpty) {
                    commandDescription = _gameState.commandDescriptions.last;
                  }
                  send(
                      "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}");
                } else if (newIndex > _gameState.commandIndex.value) {
                  _gameState.commandIndex.value = int.parse(indexString);
                  if (newIndex >= 0) {
                    _gameState.commandDescriptions
                        .insert(_gameState.commandIndex.value, description);
                  }
                  _gameState.loadFromData(data);
                  _gameState.updateAllUI();
                  sendToOthers(
                      "Index:${_gameState.commandIndex.value}Description:${_gameState.commandDescriptions.last}GameState:${_gameState.gameSaveStates.last!.getState()}",
                      client);
                  //getIt<GameState>().modifierDeck.
                  //client.write('your gameState changes received by server');
                } else {
                  //getIt<Network>().networkMessage.value = "index mismatch: ignoring incoming message";
                  log(
                      'Got same or lower index. ignoring: received index: $newIndex current index ${_gameState.commandIndex.value}');

                  //overwrite client state with current server state.
                  sendToOnly(
                      "Mismatch:Index:${_gameState.commandIndex.value}Description:${_gameState.commandDescriptions[_gameState.commandIndex.value]}GameState:${_gameState.gameSaveStates.last!.getState()}",
                      client);
                  //ignore if same index from server
                }
              } else if (message.startsWith("init")) {
                log('Server Receive init');

                List<String> initMessageParts = message.split("version:");
                int version = int.parse(initMessageParts[1]);
                if (version != serverVersion) {
                  //version mismatch
                  getIt<Network>().networkMessage.value =
                      "Client version mismatch. Please update.";
                  sendToOnly(
                      "Error: Server Version is $serverVersion. client version is $version. Please update your client.",
                      client);
                } else {
                  String commandDescription = "";
                  if (_gameState.commandIndex.value > 0 &&
                      _gameState.commandDescriptions.length >
                          _gameState.commandIndex.value) {
                    commandDescription = _gameState
                        .commandDescriptions[_gameState.commandIndex.value];
                  } else {
                    //should not happen
                    if (kDebugMode) {
                      print("?");
                    }
                  }
                  log(
                      'Server sends init response: "S3nD:Index:${_gameState.commandIndex.value}Description:$commandDescription');
                  sendToOnly(
                      "Index:${_gameState.commandIndex.value}Description:${commandDescription}GameState:${_gameState.gameSaveStates.last!.getState()}",
                      client);
                }
              } else if (message.startsWith("undo")) {
                log('Server Receive undo command');
                _gameState.undo();
              } else if (message.startsWith("redo")) {
                log('Server Receive redo command');
                _gameState.redo();
              } else if (message.startsWith("pong")) {
                log('pong from ${client.remoteAddress}');
              } else if (message.startsWith("ping")) {
                log('ping from ${client.remoteAddress}');
                sendToOnly("pong", client);
              }
            } else {
              leftOverMessage = message;
            }
          }
        },

        // handle errors
        onError: (error) {
          log(error);
          getIt<Network>().networkMessage.value = error.toString();
          /*stopServer(error.toString());
          for (int i = 0; i < _clients.length; i++) {
            try {
              if (_clients[i].remoteAddress == client.remoteAddress) {
                _clients.removeAt(i);
                break;
              }
            } catch (e) {
              _clients.removeAt(i);
              break;
            }
          }*/
          if (error is SocketException &&
              (error.osError?.errorCode == 103 ||
                  error.osError?.errorCode == 32)) {
            stopServer(error.toString());
          }
        },

        // handle the client closing the connection
        onDone: () {
          if (getIt<Settings>().server.value == false) {
            //no op
          } else {
            _connection.remove(client);
            log('Client left');
            getIt<Network>().networkMessage.value = 'Client left.';
          }
        },
      );
    } catch (error) {
      log(error.toString());
      getIt<Network>().networkMessage.value = error.toString();
      //client.close();
      /*for (int i = 0; i < _clients.length; i++) {
        try {
          if (_clients[i].remoteAddress == client.remoteAddress) {
            _clients.removeAt(i);
            break;
          }
        } catch (e) {
          _clients.removeAt(i);
          break;
        }
      }*/
    }
  }

  void send(String data) {
    _communication.sendToAll(data);
  }

  void sendToOnly(String data, Socket client) {
    _communication.sendTo(client, data);
  }

  void sendToOthers(String data, Socket client) {
    _communication.sendToAllExcept(client, data);
  }
}
