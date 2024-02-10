import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/network/client.dart';

import '../../Resource/ui_utils.dart';
import '../service_locator.dart';
import 'network.dart';

class NetworkUI extends StatefulWidget {
  const NetworkUI({super.key});

  @override
  NetworkUIState createState() => NetworkUIState();
}

class NetworkUIState extends State<NetworkUI> {
  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //dummy ui to get context to make toasts.
    return ValueListenableBuilder<String>(
        valueListenable: getIt<Network>().networkMessage,
        builder: (context, value, child) {
          Future.delayed(const Duration(milliseconds: 200), () {
            String message = getIt<Network>().networkMessage.value;
            if (message != "") {
              if (message.toLowerCase().contains("error") ||
                  message.toLowerCase().contains("disconnected") ||
                  message.toLowerCase().contains("lost")) {
                showErrorToastStickyWithRetry(
                    context, getIt<Network>().networkMessage.value, () {
                  Settings settings = getIt<Settings>();
                  if (settings.client.value != ClientState.connected &&
                      settings.lastKnownConnection != "") {
                    settings.client.value = ClientState.connecting;
                    getIt<Client>()
                        .connect(settings.lastKnownConnection)
                        .then((value) => null);
                    settings.saveToDisk();
                  }
                });
              } else {
                showToast(context, getIt<Network>().networkMessage.value);
              }
              getIt<Network>().networkMessage.value = "";
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
