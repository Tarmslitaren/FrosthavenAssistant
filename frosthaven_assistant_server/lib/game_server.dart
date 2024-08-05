
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

class StateUpdateMessage {
  String indexString = "";
  String description = "";
  String data = "";
  int index = 0;
}

abstract class GameServer {

  final int serverVersion = 191;

  ServerSocket? _serverSocket;
  ServerSocket? get serverSocket {
    return _serverSocket;
  }
  set serverSocket(ServerSocket? value){
    _serverSocket = value;
  }

  bool _serverEnabled = false;
  bool get serverEnabled {
    return _serverEnabled;
  }
  set serverEnabled(bool value){
    _serverEnabled = value;
  }

  String _leftOverMessage = "";
  String get leftOverMessage{
    return _leftOverMessage;
  }
  set leftOverMessage(String value){
    _leftOverMessage = value;
  }

  void resetState();
  void undoState();
  void redoState();
  void updateStateFromMessage(StateUpdateMessage message, Socket client);

  void setNetworkMessage(String data);
  void send(String data);
  String currentStateMessage(String commandDescription);
  Future<String> getConnectToIP();

  void sendPing();
  void addClientConnection(Socket client);
  void removeClientConnection(Socket client);
  void removeAllClientConnections();
  void sendToOnly(String data, Socket client);
  void sendToOthers(String data, Socket client);
  void sendInitResponse(Socket client);


  StateUpdateMessage parseStateUpdateMessage(String message) {
    List<String> messageParts1 = message.split("Description:");
    String indexString =
        messageParts1[0].substring("Index:".length);
    List<String> messageParts2 =
        messageParts1[1].split("GameState:");
    String description = messageParts2[0];
    String data = messageParts2[1];
    StateUpdateMessage result =  StateUpdateMessage();
    result.indexString = indexString;
    result.index = int.parse(indexString);
    result.description = description;
    result.data = data;
    return result;
  }

  Future<void> startServerInternal(String ip, int port) async {
    try {
      serverSocket = await ServerSocket.bind(ip, port);
      serverEnabled = true;
      final ServerSocket server = serverSocket!;
      String connectTo = await getConnectToIP();
      String info =
          'Server Online: IP: $connectTo, Port: ${server.port.toString()}';
      log(info);
      setNetworkMessage(info);
      resetState();
      send(currentStateMessage(""));
      var subscriptions = server.listen((Socket client) {
        handleConnection(client);
      }, onError: (e) {
        log('Server error: $e');
        setNetworkMessage('Server error: ${e.toString()}');
      });
      sendPing();
      await subscriptions.asFuture();
    } catch (error) {
      log('Server error: $error');
      setNetworkMessage('Server error: ${error.toString()}');
    }
  }

  void stopServer(String? error) {
    if (serverSocket != null) {
      log('Server Offline');
      if (error != null) {
        setNetworkMessage(error);
      } else {
        setNetworkMessage('Server Offline');
      }

      serverSocket!.close().catchError((error) {
        log(error.toString());
        return error;
      });

      removeAllClientConnections();
    }
    serverEnabled = false;
    leftOverMessage = "";

    resetState();
  }

  void logHandleConnection(Socket client){
    String info = 'Connection from ${safeGetClientAddress(client)}';
    log(info);
    setNetworkMessage(info);
  }

  void handleConnection(Socket client) {
    client.setOption(SocketOption.tcpNoDelay, true);
    client.encoding = utf8;

    logHandleConnection(client);

    addClientConnection(client);

    // listen for events from the client
    try {
      client.listen(
        // handle data from the client
        (Uint8List data) async {
          String message = utf8.decode(data);
          message = leftOverMessage + message;
          leftOverMessage = "";
          processMessages(message, client);
        },
        // handle errors
        onError: (error) {
          log(error.toString());
          setNetworkMessage(error.toString());
          if (error is SocketException &&
              (error.osError?.errorCode == 103 ||
                  error.osError?.errorCode == 32)) {
            stopServer(error.toString());
          }
        },
        // handle the client closing the connection
        onDone: () {
          if (serverEnabled) {
            removeClientConnection(client);
            log('Client left');
            setNetworkMessage('Client left.');
          }
        },
      );
    } catch (error) {
      log(error.toString());
      setNetworkMessage(error.toString());
    }
  }

  void processMessages(String socketMessages, Socket client){
    List<String> messages = socketMessages.split("S3nD:");
          //handle
          for (var message in messages) {
            if (message.endsWith("[EOM]")) {
              message = message.substring(0, message.length - "[EOM]".length);
              if (message.startsWith("Index:")) {
                handleIndexMessage(message, client);
              } else if (message.startsWith("init")) {
                handleInitMessage(message, client);
              } else if (message.startsWith("undo")) {
                handleUndoMessage();
              } else if (message.startsWith("redo")) {
                handleRedoMessage();
              } else if (message.startsWith("pong")) {
                handlePongMessage(client);
              } else if (message.startsWith("ping")) {
                handlePingMessage(client);
              }
            } else {
              leftOverMessage = message;
            }
          }
  }

  void handleIndexMessage(String message, Socket client){
    StateUpdateMessage parsedMessage = parseStateUpdateMessage(message);
    updateStateFromMessage(parsedMessage, client);
  }

  void handleInitMessage(String message, Socket client){
    List<String> initMessageParts = message.split("version:");
    int version = int.parse(initMessageParts[1]);
    if (version != serverVersion) {
      //version mismatch
      setNetworkMessage("Client version mismatch. Please update. Client $version Server $serverVersion");
      sendToOnly(
          "Error: Server Version is $serverVersion. client version is $version. Please update your client.",
          client);
    } else {
      sendInitResponse(client);
    }
  }

  void handleUndoMessage(){
    log('Server Receive undo command');
    undoState();
  }
  void handleRedoMessage(){
    log('Server Receive redo command');
    redoState();
  }
  void handlePongMessage(Socket client){
    log('pong from ${safeGetClientAddress(client)}');
  }
  void handlePingMessage(Socket client) {
    log('ping from ${safeGetClientAddress(client)}');
    sendToOnly("pong", client);
  }

  String safeGetClientAddress(Socket client){
    try {
      return "${client.remoteAddress}:${client.remotePort}";
    } catch (exception) {
      log("Encountered error accessing client");
      log(exception.toString());
      // There might be a chance that is is for a different 
      // reason, but this is the most common reason I've 
      // seen so far
      return "Closed socket"; 
    }
  }
}
