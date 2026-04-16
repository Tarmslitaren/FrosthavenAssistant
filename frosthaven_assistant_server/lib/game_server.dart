
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
    result.index = int.tryParse(indexString) ?? -1;
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

    // Per-connection leftover buffer — avoids the shared-field bug where
    // messages from different clients could corrupt each other's partial frames.
    String leftOver = "";

    const String prefix = 'S3nD:';
    const String suffix = '[EOM]';

    // listen for events from the client
    try {
      client.listen(
        // handle data from the client
        (Uint8List data) {
          String chunk;
          try {
            chunk = utf8.decode(data);
          } on FormatException catch (e) {
            log('Invalid UTF-8 from client: $e');
            removeClientConnection(client);
            return;
          }
          leftOver += chunk;
          // Use indexOf-based framing: safe if the payload contains "S3nD:".
          while (true) {
            final int start = leftOver.indexOf(prefix);
            if (start == -1) break;
            final int contentStart = start + prefix.length;
            final int end = leftOver.indexOf(suffix, contentStart);
            if (end == -1) break;
            final String content = leftOver.substring(contentStart, end);
            leftOver = leftOver.substring(end + suffix.length);
            processMessages(content, client);
          }
        },
        // handle errors
        onError: (error) {
          log(error.toString());
          setNetworkMessage(error.toString());
          // Tolerate aborted connections if we're in a consistent state (i.e.,
          // not mid-message). This is particularly relevant for iOS clients,
          // where the app usually doesn't get a chance to close the socket
          // gracefully when the device is locked.
          if (error is SocketException && error.osError?.errorCode == 103) {
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

  /// Dispatches a single fully-decoded, unframed message content to the
  /// appropriate handler.  Framing (S3nD:/[EOM] extraction) is done by
  /// [handleConnection] before calling this method.
  void processMessages(String message, Socket client){
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
  }

  void handleIndexMessage(String message, Socket client){
    StateUpdateMessage parsedMessage = parseStateUpdateMessage(message);
    updateStateFromMessage(parsedMessage, client);
  }

  void handleInitMessage(String message, Socket client){
    List<String> initMessageParts = message.split("version:");
    if (initMessageParts.length < 2) {
      sendToOnly("Error: malformed init message (missing version field).", client);
      return;
    }
    final int? version = int.tryParse(initMessageParts[1]);
    if (version == null) {
      sendToOnly("Error: malformed init message (non-integer version).", client);
      return;
    }
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
