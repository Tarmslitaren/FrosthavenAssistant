import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:format/format.dart';

import '../service_locator.dart';
import 'connection.dart';

/// Typed envelope for state-sync messages sent between server and clients.
///
/// The inner content (between `S3nD:` and `[EOM]`) is a JSON object:
/// `{"i": index, "d": "description", "e": {event_object}, "s": "gamestate"}`
///
/// The previous text-delimited format (`Index:NDescription:...GameState:...`)
/// is still accepted on receive for backwards compatibility with older peers.
class StateEnvelope {
  final int index;
  final String description;

  /// The event serialised as a JSON string (e.g. `'{"type":"none"}'`).
  final String eventJson;
  final String state;

  const StateEnvelope({
    required this.index,
    required this.description,
    required this.eventJson,
    required this.state,
  });

  /// Encodes this envelope as a JSON string ready to be wrapped in `S3nD:/[EOM]`.
  String encode() => jsonEncode({
        'i': index,
        'd': description,
        'e': jsonDecode(eventJson),
        's': state,
      });

  /// Attempts to decode [content] as a [StateEnvelope].
  /// Returns `null` if [content] is not in the new JSON format.
  static StateEnvelope? tryDecode(String content) {
    if (!content.startsWith('{')) return null;
    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      return StateEnvelope(
        index: map['i'] as int,
        description: map['d'] as String,
        eventJson: jsonEncode(map['e'] as Object),
        state: map['s'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

class Communication {
  static const beginning = "S3nD:";
  static const end = "[EOM]";
  final messageTemplate = "$beginning{}$end";
  final Connection _connection;

  Communication({Connection? connection})
      : _connection = connection ?? getIt<Connection>();

  // TODO: Need to test this somehow, or refactor altogether.
  // If testing, then better to verify assigned functions are being called on specific actions, rather than verify mock socket assignments.
  void listen(
      Function(Uint8List) onData, Function? onError, Function()? onDone) {
    final sockets = _connection.getAll();
    for (var socket in sockets) {
      socket.listen(onData, onError: onError, onDone: onDone);
    }
  }

  void sendToAllExcept(Socket client, String data) {
    final sockets = _connection.getAll();
    // Compare both address AND port: multiple clients from the same host
    // (e.g. all on loopback in tests, or same-device multi-window) share the
    // same remoteAddress but have distinct remotePort values.
    final recipients = sockets.where((x) =>
        x.remoteAddress != client.remoteAddress ||
        x.remotePort != client.remotePort);
    for (var socket in recipients) {
      sendTo(socket, data);
    }
  }

  void sendTo(Socket? socket, String data) {
    assert(socket != null, 'sendTo called with a null socket — message dropped');
    if (socket == null) {
      debugPrint('Communication.sendTo: null socket, message dropped: "$data"');
      return;
    }
    socket.write(_composeMessageFrom(data));
  }

  void sendToAll(String data) {
    final message = _composeMessageFrom(data);
    final sockets = _connection.getAll();
    for (var socket in sockets) {
      socket.write(message);
    }
  }

  String dataFrom(String message) {
    final valid = isValid(message);
    var data = valid
        ? message.substring(beginning.length, message.length - end.length)
        : "";
    return data;
  }

  bool isValid(String message) {
    return message.startsWith(beginning) && message.endsWith(end);
  }

  String _composeMessageFrom(String data) {
    return messageTemplate.format(data);
  }
}
