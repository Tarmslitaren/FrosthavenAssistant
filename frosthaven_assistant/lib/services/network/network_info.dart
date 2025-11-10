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
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty && _connectionStatus != result.first) {
        if (_connectionStatus != null) {
          //null just to not show message on start.
          String connection = result.first.name;
          if (result.contains(ConnectivityResult.wifi)) {
            //default to show wifi if available
            connection = ConnectivityResult.wifi.name;
          }
          getIt<Network>().networkMessage.value =
              "Network connection: $connection";
        }
        _connectionStatus = result.first;
      }

      initNetworkInfo();
    });
  }

  final NetworkInfo networkInfo = NetworkInfo();

  ConnectivityResult? _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final Set<String> wifiIPv6List = {};
  final wifiIPv6 = ValueNotifier<String>("");
  final outgoingIPv6 = ValueNotifier<String>("");

  Future<void> initNonWifiIPs() async {
    for (var interface in await NetworkInterface.list()) {
      //searching for eth should fix the ethernet ip address issue on
      // ethernet connections on windows and linux
      if (interface.name.toLowerCase().contains("eth") &&
          !interface.name.toLowerCase().contains("switch") &&
          !interface.name.toLowerCase().contains("veth")) {
        for (var address in interface.addresses) {
          if (address.type == InternetAddressType.IPv6) {
            wifiIPv6List.add(address.address);
            if (wifiIPv6.value != "") {
              wifiIPv6.value =
                  address.address; //default to ipv4 ethernet address if no wifi
            }
            break;
          }
        }
        if (wifiIPv6.value != "") {
          //break;
        }
      }
    }
    if (wifiIPv6.value == "") {
      wifiIPv6.value = "Failed to get Wifi IPv6";
    }
  }

  Future<void> initNetworkInfo() async {
    try {
      outgoingIPv6.value = await Ipify.ipv64();
    } catch (error) {
      outgoingIPv6.value = "";
    }

    try {
      String? ipv6 = await networkInfo.getWifiIP();
      if (ipv6 != null) {
        wifiIPv6.value = ipv6;
        wifiIPv6List.add(ipv6);
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
    }
    initNonWifiIPs();

    developer.log('Wifi IPv6: ${wifiIPv6.value}\n'
        'Outgoing IPv6: ${outgoingIPv6.value}\n');
  }
}
