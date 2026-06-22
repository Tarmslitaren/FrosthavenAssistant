import 'dart:async';

import 'package:flutter/material.dart';

import '../../../Resource/app_constants.dart';
import '../../../Resource/settings.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/network/client.dart';
import '../../../services/network/network.dart';

class SettingsNetworkSection extends StatefulWidget {
  static const double _kInputWidth = 200.0;
  static const double _kInputHeight = 40.0;
  static const double _kDropdownHeight = 20.0;
  static const int _kPortMaxLength = 6;

  const SettingsNetworkSection({
    super.key,
    required this.settings,
    required this.network,
    required this.client,
  });

  final Settings settings;
  final Network network;
  final Client client;

  @override
  SettingsNetworkSectionState createState() => SettingsNetworkSectionState();
}

class SettingsNetworkSectionState extends State<SettingsNetworkSection> {
  final TextEditingController _serverTextController = TextEditingController();
  final TextEditingController _portTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.network.networkInfo.initNetworkInfo();
    _serverTextController.text = widget.settings.lastKnownConnection;
    _portTextController.text = widget.settings.lastKnownPort;
  }

  List<DropdownMenuItem<String>> _getIPList() {
    return widget.network.networkInfo.wifiIPv6List
        .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.networkConnectLocal),
        ValueListenableBuilder<ClientState>(
            valueListenable: widget.settings.client,
            builder: (context, value, child) {
              final l10n = AppLocalizations.of(context)!;
              bool connected = false;
              final clientState = widget.settings.client.value;
              String connectionText = l10n.connectAsClientLabel;
              if (clientState == ClientState.connected) {
                connected = true;
                connectionText = l10n.connectedAsClient;
              }
              if (clientState == ClientState.connecting) {
                connectionText = l10n.connecting;
              }
              return CheckboxListTile(
                  enabled: !widget.settings.server.value &&
                      widget.settings.client.value != ClientState.connecting,
                  title: Text(connectionText),
                  value: connected,
                  onChanged: (bool? value) {
                    if (widget.settings.client.value != ClientState.connected) {
                      setState(() {
                        widget.settings.client.value = ClientState.connecting;
                        widget.settings.lastKnownPort =
                            _portTextController.text;
                        widget.settings.lastKnownConnection =
                            _serverTextController.text;
                      });
                      unawaited(widget.client
                          .connect(_serverTextController.text)
                        ..whenComplete(widget.settings.saveToDisk));
                    } else {
                      setState(() {
                        widget.client.disconnect(null);
                      });
                    }
                  });
            }),
        Container(
          margin:
              const EdgeInsets.only(top: SettingsNetworkSection._kInputHeight),
          width: SettingsNetworkSection._kInputWidth,
          child: TextField(
            controller: _serverTextController,
            decoration: InputDecoration(
              counterText: "",
              helperText: AppLocalizations.of(context)!.networkServerIpHint,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: kMenuTopPadding),
          width: SettingsNetworkSection._kInputWidth,
          height: SettingsNetworkSection._kInputHeight,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _portTextController,
            decoration: InputDecoration(
              counterText: "",
              helperText: AppLocalizations.of(context)!.networkPortHint,
            ),
            maxLength: SettingsNetworkSection._kPortMaxLength,
          ),
        ),
        ValueListenableBuilder<bool>(
            valueListenable: widget.settings.server,
            builder: (context, value, child) {
              final l10n = AppLocalizations.of(context)!;
              return CheckboxListTile(
                  title: Text(widget.settings.server.value
                      ? l10n.stopServerButton
                      : l10n.startHostServerButton),
                  value: widget.settings.server.value,
                  onChanged: (bool? value) {
                    if (!widget.settings.server.value) {
                      widget.settings.lastKnownPort = _portTextController.text;
                      widget.settings.lastKnownHostIP =
                          "(${widget.network.networkInfo.wifiIPv6.value})";
                      widget.settings.saveToDisk();
                      widget.network.server.startServer();
                    } else {
                      widget.network.server.stopServer(null);
                    }
                  });
            }),
        ValueListenableBuilder<String>(
            valueListenable: widget.network.networkInfo.wifiIPv6,
            builder: (context, value, child) {
              return SizedBox(
                width: SettingsNetworkSection._kInputWidth,
                height: SettingsNetworkSection._kDropdownHeight,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        value: widget.network.networkInfo.wifiIPv6.value,
                        items: _getIPList(),
                        onChanged: (value) => widget
                            .network.networkInfo.wifiIPv6.value = value ?? "")),
              );
            }),
        ValueListenableBuilder<String>(
            valueListenable: widget.network.networkInfo.outgoingIPv6,
            builder: (context, value, child) {
              return SizedBox(
                  width: SettingsNetworkSection._kInputWidth,
                  height: SettingsNetworkSection._kDropdownHeight,
                  child: Text(widget.network.networkInfo.outgoingIPv6.value));
            }),
        Container(
          margin: const EdgeInsets.only(top: kMenuTopPadding),
          width: SettingsNetworkSection._kInputWidth,
          height: SettingsNetworkSection._kInputHeight,
          child: TextField(
            controller: _portTextController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              counterText: "",
              helperText: AppLocalizations.of(context)!.networkPortHint,
            ),
            maxLength: SettingsNetworkSection._kPortMaxLength,
          ),
        ),
      ],
    );
  }
}
