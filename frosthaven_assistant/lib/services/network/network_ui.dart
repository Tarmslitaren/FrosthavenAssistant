import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/client.dart';

import '../../Resource/ui_utils.dart';
import '../service_locator.dart';
import 'network.dart';

class NetworkUI extends StatefulWidget {
  const NetworkUI({super.key, this.network, this.settings, this.client});

  // injected for testing
  final Network? network;
  final Settings? settings;
  final Client? client;

  @override
  NetworkUIState createState() => NetworkUIState();
}

class NetworkUIState extends State<NetworkUI> {
  late final Network _network;
  late final Settings _settings;
  late final Client _client;

  @override
  initState() {
    _network = widget.network ?? getIt<Network>();
    _settings = widget.settings ?? getIt<Settings>();
    _client = widget.client ?? getIt<Client>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //dummy ui to get context to make toasts.
    return ValueListenableBuilder<String>(
        valueListenable: _network.networkMessage,
        builder: (context, value, child) {
          Future.delayed(const Duration(milliseconds: 200), () {
            String message = _network.networkMessage.value;
            if (message != "") {
              if (context.mounted &&
                  (message.toLowerCase().contains("error") ||
                      message.toLowerCase().contains("disconnected") ||
                      message.toLowerCase().contains("lost"))) {
                showErrorToastStickyWithRetry(
                    context, _network.networkMessage.value, () {
                  if (_settings.client.value != ClientState.connected &&
                      _settings.lastKnownConnection != "") {
                    _settings.client.value = ClientState.connecting;
                    _client
                        .connect(_settings.lastKnownConnection)
                        .then((value) => null);
                    _settings.saveToDisk();
                  }
                });
              } else {
                if (context.mounted) {
                  showToast(context, _network.networkMessage.value);
                }
              }
              _network.networkMessage.value = "";
            }
          });

          return const SizedBox(
            //todo: remove hack?
            width: 0.00001,
            height: 0.00001,
          );
        });
  }
}
