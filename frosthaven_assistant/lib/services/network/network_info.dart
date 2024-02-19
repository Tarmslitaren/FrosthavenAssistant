import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../service_locator.dart';
import 'network.dart';

class NetworkInformation {
  NetworkInformation() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (_connectionStatus != result) {
        if (_connectionStatus != null) {
          //null just to not show message on start.
          getIt<Network>().networkMessage.value = "Network connection: ${result.name}";
        }
      }
      _connectionStatus = result;
      initNetworkInfo();
    });
  }

  final NetworkInfo networkInfo = NetworkInfo();

  ConnectivityResult? _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final Set<String> wifiIPv4List = {};
  final wifiIPv4 = ValueNotifier<String>("");
  final outgoingIPv4 = ValueNotifier<String>("");

  Future<void> initNonWifiIPs() async {
    for (var interface in await NetworkInterface.list()) {
      //searching for eth should fix the ethernet ip address issue on
      // ethernet connections on windows and linux
      if (interface.name.toLowerCase().contains("eth") &&
          !interface.name.toLowerCase().contains("switch") &&
          !interface.name.toLowerCase().contains("veth")) {
        for (var address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4) {
            wifiIPv4List.add(address.address);
            if (wifiIPv4.value != "") {
              wifiIPv4.value = address.address; //default to ipv4 ethernet address if no wifi
            }
            break;
          }
        }
        if (wifiIPv4.value != "") {
          //break;
        }
      }
    }
    if (wifiIPv4.value == "") {
      wifiIPv4.value = "Failed to get Wifi IPv4";
    }
  }

  Future<void> initNetworkInfo() async {
    try {
      outgoingIPv4.value = await Ipify.ipv4();
    } catch (error) {
      outgoingIPv4.value = "";
    }

    try {
      String? ipv4 = await networkInfo.getWifiIP();
      if (ipv4 != null) {
        wifiIPv4.value = ipv4;
        wifiIPv4List.add(ipv4);
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
    }
    initNonWifiIPs();

    developer.log('Wifi IPv4: ${wifiIPv4.value}\n'
        'Outgoing IPv4: ${outgoingIPv4.value}\n');
  }
}
