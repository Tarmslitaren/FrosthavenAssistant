import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/network.dart';

import '../../Resource/state/game_state.dart';
import '../../Resource/settings.dart';
import '../service_locator.dart';
import 'dart:convert' show utf8;

class Client {
  String _leftOverMessage = "";
  bool serveResponsive = true;

  final GameState _gameState = getIt<GameState>();
  final Communication _communication = getIt<Communication>();

  Future<void> connect(String address) async {
// connect to the socket server
    serveResponsive = true;
    try {
      int port = int.parse(getIt<Settings>().lastKnownPort);
      print("port nr: ${port.toString()}");
      await Socket.connect(InternetAddress(address), port)
          .then((Socket socket) {
        runZoned(() {
          _communication.add(socket);
          getIt<Settings>().client.value = ClientState.connected;
          String info =
              'Client Connected to: ${socket.remoteAddress.address}:${socket.remotePort}';
          print(info);
          _gameState.commands.clear();
          getIt<Network>().networkMessage.value = info;
          getIt<Settings>().connectClientOnStartup = true;
          getIt<Settings>().saveToDisk();
          send("init version:${getIt<Network>().server.serverVersion}");
          _sendPing();
          _listen();
        });
      });
    } catch (error) {
      print("client error: $error");
      getIt<Network>().networkMessage.value = "client error: $error";
      getIt<Settings>().client.value = ClientState.disconnected;
      getIt<Settings>().connectClientOnStartup = false;
      getIt<Settings>().saveToDisk();
    }
  }

  void _sendPing() {
    if (_communication.connected() && getIt<Settings>().client.value == ClientState.connected) {
      Future.delayed(const Duration(seconds: 12), () {
        if (serveResponsive == true) {
          _communication.sendToAll("ping");
          _sendPing();
          serveResponsive = false; //set back to true when get response
        } else {
          disconnect("Server unresponsive. Client disconnected.");
        }
      });
    }
  }

  void _listen() {
    // listen for responses from the server
    try {
      _communication.listen(onListenData, onListenError, onListenDone);
    } catch (error) {
      print(error);
      //_socket?.destroy();
      getIt<Network>().networkMessage.value =
          'Client listen error: ${error.toString()}';
      //_cleanup();
    }
  }

  void onListenDone() {
    print('Lost connection to server.');
    if (serveResponsive != false) {
      getIt<Network>().networkMessage.value = "Lost connection to server";
    }
    _communication.disconnect();
    _cleanup();
  }

  onListenError(error) {
    print('Client error: ${error.toString()}');
    getIt<Network>().networkMessage.value = "client error: ${error.toString()}";
    //_socket?.destroy();
    //_cleanup();
  }

  void onListenData(Uint8List data) {
    String message = utf8.decode(data); // String.fromCharCodes(data);
    message = _leftOverMessage + message;
    _leftOverMessage = "";

    List<String> messages = message.split("S3nD:");
    //handle
    for (var message in messages) {
      if (message.endsWith("[EOM]")) {
        message = message.substring(0, message.length - "[EOM]".length);
        if (message.startsWith("Mismatch:")) {
          message = message.substring("Mismatch:".length);
          getIt<Network>().networkMessage.value =
              "Your state was not up to date, try again.";
        }
        if (message.startsWith("Index:")) {
          List<String> messageParts1 = message.split("Description:");
          String indexString = messageParts1[0].substring("Index:".length);
          List<String> messageParts2 = messageParts1[1].split("GameState:");
          String description = messageParts2[0];
          String data = messageParts2[1];

          print(
              'Client Receive Data, index: $indexString, description:$description');

          int newIndex = int.parse(indexString);
          //overwrite states if needed
          _gameState.commandIndex.value = newIndex;

          //don't worry about this, just run undo/redo without descriptions?
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
        } else if (message.startsWith("ping")) {
          send("pong");
        } else if (message.startsWith("pong")) {
          serveResponsive = true;
        }
      } else {
        _leftOverMessage = message;
      }
    }
  }

  void send(String data) {
    _communication.sendToAll(data);
  }

  void disconnect(String? message) {
    message ??= "client disconnected";
    if (_communication.connected()) {
      print(message);
      getIt<Network>().networkMessage.value = message;
      _communication.disconnect();
      getIt<Settings>().connectClientOnStartup = false;
      getIt<Settings>().saveToDisk();
      _cleanup();
    }
  }

  void _cleanup() {
    getIt<Settings>().client.value = ClientState.disconnected;
    _gameState.commandIndex.value = -1;
    _gameState.commands.clear();
    _gameState.commandDescriptions.clear();
    _gameState.gameSaveStates
        .removeRange(0, _gameState.gameSaveStates.length - 1);
    _leftOverMessage = "";

    if (getIt<Network>().appInBackground == true) {
      getIt<Network>().clientDisconnectedWhileInBackground = true;
    }
    serveResponsive = true;
  }
}
