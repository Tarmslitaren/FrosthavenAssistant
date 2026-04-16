
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

class StateUpdateMessage {
  String indexString = "";
  String description = "";
  String eventJson = '{"type":"none"}';
  String data = "";
  int index = 0;
}

abstract class GameServer {

  final int serverVersion = 1302;

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


  /// Encodes a state message as a JSON envelope.
  ///
  /// [eventJson] must be a valid JSON string (e.g. `'{"type":"none"}'`).
  static String encodeStateEnvelope({
    required int index,
    required String description,
    required String eventJson,
    required String state,
  }) {
    return jsonEncode({
      'i': index,
      'd': description,
      'e': jsonDecode(eventJson),
      's': state,
    });
  }

  /// Tries to decode [content] as a JSON envelope.
  /// Returns `null` if it is not in the new format.
  static StateUpdateMessage? tryDecodeStateEnvelope(String content) {
    if (!content.startsWith('{')) return null;
    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      final result = StateUpdateMessage();
      result.index = map['i'] as int;
      result.indexString = result.index.toString();
      result.description = map['d'] as String;
      result.eventJson = jsonEncode(map['e'] as Object);
      result.data = map['s'] as String;
      return result;
    } catch (_) {
      return null;
    }
  }

  StateUpdateMessage parseStateUpdateMessage(String message) {
    // Try new JSON envelope format first.
    final StateUpdateMessage? envelope = tryDecodeStateEnvelope(message);
    if (envelope != null) return envelope;

    // Legacy text format: "Index:NDescription:textEvent:{...}GameState:state"
    List<String> messageParts1 = message.split("Description:");
    String indexString = messageParts1[0].substring("Index:".length);
    final String afterDescription = messageParts1[1];

    String description;
    String eventJson;
    String data;

    if (afterDescription.contains("Event:")) {
      List<String> parts2 = afterDescription.split("Event:");
      description = parts2[0];
      List<String> parts3 = parts2[1].split("GameState:");
      eventJson = parts3[0];
      data = parts3[1];
    } else {
      // Backwards-compatible: older client without Event field.
      List<String> parts2 = afterDescription.split("GameState:");
      description = parts2[0];
      eventJson = '{"type":"none"}';
      data = parts2[1];
    }

    StateUpdateMessage result = StateUpdateMessage();
    result.indexString = indexString;
    result.index = int.parse(indexString);
    result.description = description;
    result.eventJson = eventJson;
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
          // Tolerate aborted connections if we're in a consistent state (i.e.,
          // not mid-message). This is particularly relevant for iOS clients,
          // where the app usually doesn't get a chance to close the socket
          // gracefully when the device is locked.
          if (error is SocketException &&
              (error.osError?.errorCode == 103 ||
                  !leftOverMessage.isEmpty)) {
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
              if (message.startsWith("Index:") || message.startsWith("{")) {
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
