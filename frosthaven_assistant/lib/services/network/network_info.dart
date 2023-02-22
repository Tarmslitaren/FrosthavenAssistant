import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;

import 'dart:async';

import '../service_locator.dart';
import 'network.dart';


class NetworkInformation {

  NetworkInformation() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result){
          if (_connectionStatus != result) {
            if(_connectionStatus != null) { //null just to not show message on start.
              getIt<Network>().networkMessage.value =
              "Network connection: ${result.name}";
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

  final wifiIPv4 = ValueNotifier<String>("");
  final outgoingIPv4 = ValueNotifier<String>("");
  //final wifiName = ValueNotifier<String>("");
  //final wifiBSSID = ValueNotifier<String>("");
      //wifiIPv6,
      //wifiGatewayIP,
      //wifiBroadcast,
      //wifiSubmask;

  Future<void> initNetworkInfo() async {
    try {
      outgoingIPv4.value = await Ipify.ipv4();
    } catch (error) {
      outgoingIPv4.value = "";
    }

    /*try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          String? wifi = await networkInfo.getWifiName();
          if(wifi != null) {
            wifiName.value = wifi;
          }
        } else {
          String? name = await networkInfo.getWifiName();
          if(name != null) {
            wifiName.value = name;
          }
        }
      } else {
        String? name = await networkInfo.getWifiName();
        if(name != null) {
          wifiName.value = name;
        }
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName.value = 'Failed to get Wifi Name';
    }*/

    /*try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          String? bssid = await networkInfo.getWifiBSSID();
          if(bssid != null) {
            wifiBSSID.value = bssid;
          }
        } else {
          String? bssid = await networkInfo.getWifiBSSID();
          if(bssid != null) {
            wifiBSSID.value = bssid;
          }
        }
      } else {
        String? bssid = await networkInfo.getWifiBSSID();
        if(bssid != null) {
          wifiBSSID.value = bssid;
        }
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID.value = 'Failed to get Wifi BSSID';
    }*/

    try {
      String? ipv4 = await networkInfo.getWifiIP();
      if(ipv4 != null) {
        wifiIPv4.value = ipv4;
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4.value = 'Failed to get Wifi IPv4';
      for (var interface in await NetworkInterface.list()) {
        //searching for eth should fix the ethernet ip address issue on ethernet connections on windows and linux
        if (interface.name.toLowerCase().contains("eth")) {
          for (var address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4) {
              wifiIPv4.value = address.address; //default to ipv4 ethernet address if no wifi
              break;
            }
          }
        }
      }

    }

    /*try {
      wifiIPv6 = await networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }*/

    /*try {
      wifiSubmask = await networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }*/

    /*try {
      wifiBroadcast = await networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }*/

    /*try {
      wifiGatewayIP = await networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }*/

    /*try {
      wifiSubmask = await networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask', error: e);
      wifiSubmask = 'Failed to get Wifi submask';
    }*/

    developer.log(
	//'Wifi Name: ${wifiName.value}\n'
          //'Wifi BSSID: ${wifiBSSID.value}\n'
          'Wifi IPv4: ${wifiIPv4.value}\n'
          'Outgoing IPv4: ${outgoingIPv4.value}\n'
          //'Wifi Broadcast: $wifiBroadcast\n'
          //'Wifi Gateway: $wifiGatewayIP\n'
          //'Wifi Submask: $wifiSubmask\n'
    );

  }
}