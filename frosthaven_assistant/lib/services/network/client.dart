import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:frosthaven_assistant/services/network/network.dart';

import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../service_locator.dart';

class Client {
  Socket? _socket;
  String _leftOverMessage = "";

  final GameState _gameState = getIt<GameState>();

  Future<void> connect(String address) async {
// connect to the socket server
    try {
      int port = int.parse(getIt<Settings>().lastKnownPort);
      print("port nr: ${port.toString()}");
      await Socket.connect(address, port).then((Socket socket) {
        runZoned(() {
          _socket = socket;
          _socket?.setOption(SocketOption.tcpNoDelay, true);
          getIt<Settings>().client.value = ClientState.connected;
          String info = 'Client Connected to: ${socket.remoteAddress.address}:${socket.remotePort}';
          print(info);
          getIt<Network>().networkMessage.value = info;
          send("init version:${getIt<Network>().server.serverVersion}");
          _listen();
        });
      });
    } catch (error) {
      print("client error: $error");
      getIt<Network>().networkMessage.value = "client error: $error";
      getIt<Settings>().client.value = ClientState.disconnected;
    }
  }

  void _listen() {
    // listen for responses from the server
    try {
      _socket!.listen(
        // handle data from the server
            (Uint8List data) {
          String message = String.fromCharCodes(data);
          message = _leftOverMessage+message;
          _leftOverMessage = "";

          List<String> messages = message.split("S3nD:");
          //handle
          for (var message in messages) {
            if(message.endsWith("[EOM]")) {
              message = message.substring(0, message.length-"[EOM]".length);
              if(message.startsWith("Mismatch:")) {
                message = message.substring("Mismatch:".length);
                getIt<Network>().networkMessage.value = "Your state was not up to date, try again.";
              }
              if (message.startsWith("Index:")) {
                List<String> messageParts1 = message.split("Description:");
                String indexString = messageParts1[0].substring(
                    "Index:".length);
                List<String> messageParts2 = messageParts1[1].split(
                    "GameState:");
                String description = messageParts2[0];
                String data = messageParts2[1];

                print(
                    'Client Receive Data, index: $indexString, description:$description');

                int newIndex = int.parse(indexString);
                //overwrite states if needed
                _gameState.commandIndex.value = newIndex;

                //don't worry about this, just disallow undo/redo from clients
                /*if (newIndex + 1 < _gameState.commandDescriptions.length) {
                  _gameState.commandDescriptions.removeRange(
                      newIndex + 1, _gameState.commandDescriptions.length);
                }
                if(newIndex >= _gameState.commandDescriptions.length) {
                  for(int i = 0; i < newIndex-_gameState.commandDescriptions.length; i++) {
                    _gameState.commandDescriptions.add(""); //add dummy descriptions since we don't have the data?
                  }
                  _gameState.commandDescriptions.add(description);
                }
                if (newIndex >= 0) {
                  _gameState.commandDescriptions.add(description);
                }*/
                _gameState.loadFromData(data);
                _gameState.updateAllUI();
              } else if (message.startsWith("Error")) {
                throw (message);
              } else if (message.startsWith("undo")) {
              } else if (message.startsWith("redo")) {
              } else if (message.startsWith("ping")) {
                send("pong");
              }
            } else {
              _leftOverMessage = message;
            }
          }
        },

        // handle errors
        onError: (error) {
          print('Client error: $error');
          getIt<Network>().networkMessage.value = "client error: $error";
          _socket?.destroy();
          _cleanup();
        },

        // handle server ending connection
        onDone: () {
          print('Lost connection to server.');
          getIt<Network>().networkMessage.value = "Lost connection to server";
          _socket?.destroy();
          _cleanup();
        },
      );
    } catch (error) {
      print(error);
      _socket?.destroy();
      getIt<Network>().networkMessage.value = error.toString();
      _cleanup();
    }
  }

  void send(String data) {
    if (_socket != null) {
      //print('Client sends: $data');
      _socket!.write("S3nD:$data[EOM]");
    } else {

    }
  }

  void disconnect() {
    if (_socket != null) {
      print('Client disconnected');
      getIt<Network>().networkMessage.value = "client disconnected";
      _socket!.destroy();
      _cleanup();
    }
  }

  void _cleanup() {
    getIt<Settings>().client.value = ClientState.disconnected;
    _gameState.commandIndex.value = -1;
    _gameState.commands.clear();
    _gameState.commandDescriptions.clear();
    _gameState.gameSaveStates.removeRange(0, _gameState.gameSaveStates.length-1);
    _leftOverMessage = "";
  }
}
