import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;

import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../service_locator.dart';

Client client = Client();

class Client {
  Socket? _socket;
  String _leftOverMessage = "";

  final GameState _gameState = getIt<GameState>();

  Future<void> connect(String address) async {
// connect to the socket server
    try {
      await Socket.connect(address, int.parse(getIt<Settings>().lastKnownPort)).then((Socket socket) {
        runZoned(() {
          _socket = socket;
          getIt<Settings>().client.value = true;
          print(
              'Client Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
          client.send("init");
          listen();
        });
      });
    } catch (error) {
      print("client error: $error");
      getIt<Settings>().client.value = false;
    }
  }

  void listen() {
    // listen for responses from the server
    try {
      _socket!.listen(
        // handle data from the server
            (Uint8List data) {
          String message = String.fromCharCodes(data);
          print('Server: $message');
          message = _leftOverMessage+message;
          _leftOverMessage = "";

          List<String> messages = message.split("S3nD:");
          //handle
          for (var message in messages) {
            if(message.endsWith("[EOM]")) {
              message = message.substring(0, message.length-"[EOM]".length);
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
                if (newIndex > 0) {
                  _gameState.commandDescriptions.insert(newIndex, description);
                }
                if (newIndex + 1 < _gameState.commandDescriptions.length) {
                  _gameState.commandDescriptions.removeRange(
                      newIndex + 1, _gameState.commandDescriptions.length);
                }
                _gameState.loadFromData(data);
                _gameState.updateAllUI();
                //getIt<GameState>().modifierDeck.
              }
            } else {
              _leftOverMessage = message;
            }
          }
        },

        // handle errors
        onError: (error) {
          print('Client error: $error');
          _socket!.destroy();
          _cleanup();
        },

        // handle server ending connection
        onDone: () {
          print('Server left.');
          _socket!.destroy();
          _cleanup();
        },
      );
    } catch (error) {
      print(error);
      _cleanup();
    }
  }

  void send(String data) {
    if (_socket != null) {
      //print('Client sends: $data');
      _socket!.write("S3nD:$data[EOM]");
      //await Future.delayed(Duration(seconds: 2));
    } else {

    }
  }

  void disconnect() {
    if (_socket != null) {
      print('Client disconnected');
      _socket!.close();
      _cleanup();
    }
  }

  void _cleanup() {
    getIt<Settings>().client.value = false;
    _gameState.commandIndex.value = -1;
    _gameState.commands.clear();
    _gameState.commandDescriptions.clear();
    _gameState.gameSaveStates.removeRange(0, _gameState.gameSaveStates.length-1);
    _leftOverMessage = "";
  }
}
