import 'dart:developer';

import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy1922/models/lazy_location_error.dart';

Future<Position> getLocation() async {
  // check if service is enabled
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw LazyLocationError.serviceNotEnabled;
  }

  // check if perission is granted
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    throw LazyLocationError.permissionDenied;
  } else if (permission == LocationPermission.deniedForever) {
    throw LazyLocationError.permissionDeniedForever;
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<void> sendMessage(String message) async {
  try {
    await sendSMS(message: message, recipients: ['1922']);
  } catch (error) {
    log(error.toString(), name: 'SMS');
  }
}

DateTime date(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}
