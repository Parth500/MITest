import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> checkInternet() async {
  bool isCheckInternet = false;

  String connectionStatus;

  try {
    connectionStatus = (await Connectivity().checkConnectivity()).toString();
  } on PlatformException catch (e) {
    // print(e.toString());
    connectionStatus = "Internet connectivity failed";
  }
  if (connectionStatus == "ConnectivityResult.mobile" ||
      connectionStatus == "ConnectivityResult.wifi") {
    isCheckInternet = await internetService();
  } else {
    return isCheckInternet;
  }

  return isCheckInternet;
}

internetService() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    // print('not connected');
    return false;
  }
}

snackBar(BuildContext context, String message, bool isError) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
    ),
    backgroundColor: (isError) ? Colors.red : Colors.green,
  ));
}
